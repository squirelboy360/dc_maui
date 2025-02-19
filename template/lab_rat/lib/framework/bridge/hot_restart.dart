import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'core.dart';

class HotReloadManager {
  final _logger = Logger('HotReloadManager');
  final Core _core = Core();
  Database? _db;

  // Track basic view hierarchy for debugging
  final Map<String, List<String>> _viewHierarchy = {};
  String? _rootViewId;

  Future<void> initialize() async {
    await _initDatabase();
    _logger.info('Hot restart manager initialized');
  }

  Future<void> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'debug_state.db');

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE view_state (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp INTEGER,
              root_id TEXT,
              hierarchy TEXT,
              cleaned INTEGER DEFAULT 0
            )
          ''');
        },
      );
    } catch (e) {
      _logger.severe('Database initialization failed: $e');
    }
  }

  Future<void> trackView(String viewId, String? parentId) async {
    try {
      if (parentId == null) {
        _rootViewId = viewId;
      } else {
        _viewHierarchy[parentId] ??= [];
        if (!_viewHierarchy[parentId]!.contains(viewId)) {
          // Prevent duplicates
          _viewHierarchy[parentId]!.add(viewId);
        }
      }
      await _saveState();

      // Debug log
      _logger.fine(
          'Tracked view: $viewId${parentId != null ? ' under parent: $parentId' : ' as root'}');
    } catch (e) {
      _logger.severe('Error tracking view: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final state = {
        'rootId': _rootViewId,
        'hierarchy': _viewHierarchy,
      };

      await _db?.insert('view_state', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'root_id': _rootViewId,
        'hierarchy': jsonEncode(state),
        'cleaned': 0,
      });
    } catch (e) {
      _logger.severe('Error saving state: $e');
    }
  }

  Future<bool> needsCleanup() async {
    try {
      final result = await _db?.query(
        'view_state',
        where: 'cleaned = 0',
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      return result != null && result.isNotEmpty;
    } catch (e) {
      _logger.severe('Error checking cleanup status: $e');
      return false;
    }
  }

  Future<void> handleHotRestart() async {
    _logger.info('🔁 Hot restart detected');

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (await needsCleanup()) {
        _logger.info('Cleaning up views from previous run');
        
        // Get root view first
        final rootView = await _core.getRootView();
        if (rootView != null) {
          final rootId = rootView['viewId'] as String;
          
          // Get all children recursively and delete them
          await _clearViewsExceptRoot(rootId);
          
          await _db?.update('view_state', {'cleaned': 1}, where: 'cleaned = 0');
        }
      }

      _viewHierarchy.clear();
      _rootViewId = null;
      
      // Wait for root view stability
      bool hasRoot = false;
      int attempts = 0;
      while (!hasRoot && attempts < 3) {
        try {
          final rootView = await _core.getRootView();
          if (rootView != null) {
            hasRoot = true;
            await debugPrintHierarchy();
          }
        } catch (e) {
          _logger.warning('Attempt $attempts: Waiting for root view...');
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }
    } catch (e) {
      _logger.severe('Error during hot restart: $e');
    }
  }

  Future<void> _clearViewsExceptRoot(String rootId) async {
    try {
      // Get immediate children of root
      final children = await _core.getChildren(rootId) ?? [];
      
      // Delete each child and its subtree
      for (final childId in children) {
        await _deleteViewAndChildren(childId);
      }
    } catch (e) {
      _logger.severe('Error clearing views: $e');
    }
  }

  Future<void> _deleteViewAndChildren(String viewId) async {
    try {
      // Get children first
      final children = await _core.getChildren(viewId) ?? [];
      
      // Recursively delete children
      for (final childId in children) {
        await _deleteViewAndChildren(childId);
      }
      
      // Delete the view itself
      await _core.deleteView(viewId);
      _logger.fine('Deleted view: $viewId');
    } catch (e) {
      _logger.severe('Error deleting view $viewId: $e');
    }
  }

  Future<void> debugPrintHierarchy() async {
    final rootView = await _core.getRootView();
    if (rootView == null) {
      _logger.info('No view hierarchy to print');
      return;
    }

    _logger.info('📱 Current View Hierarchy:');
    await _printViewTree(rootView['viewId'] as String, '', true);
  }

  Future<void> _printViewTree(String viewId, String prefix, bool isLast) async {
    try {
      final children = await _core.getChildren(viewId) ?? [];
      final uniqueChildren = children.toSet().toList(); // Remove duplicates

      String viewType = viewId.split('-').first; // Extract view type from ID
      _logger.info('$prefix${isLast ? '└── ' : '├── '}$viewId ($viewType)');

      for (var i = 0; i < uniqueChildren.length; i++) {
        await _printViewTree(
          uniqueChildren[i],
          '$prefix${isLast ? '    ' : '│   '}',
          i == uniqueChildren.length - 1,
        );
      }
    } catch (e) {
      _logger.severe('Error printing view tree: $e');
    }
  }

  Future<void> dispose() async {
    await _db?.close();
    _viewHierarchy.clear();
    _rootViewId = null;
  }
}
