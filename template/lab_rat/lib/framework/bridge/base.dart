import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'hot_restart.dart';
import 'core.dart';

final bridge = Core();

class Base {
  static late final HotReloadManager _manager;
  static bool _isInitialized = false;
  static final _logger = Logger('Base');

  static Future<void> startApp({required Function bindApp}) async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });

    final binding = WidgetsFlutterBinding.ensureInitialized();

    if (kDebugMode) {
      await _setupDebugMode(binding);
    }

    try {
      await bindApp();
      _logger.info('App started successfully');

      if (kDebugMode) {
        await _manager.debugPrintHierarchy();
      }
    } catch (e, stack) {
      _logger.severe('Failed to start app: $e');
      _logger.severe('Stack trace: $stack');
    }
  }

  static Future<void> _setupDebugMode(WidgetsBinding binding) async {
    if (_isInitialized) return;
    _isInitialized = true;

    _manager = HotReloadManager();
    await _manager.initialize();

    binding.addObserver(
      _DebugObserver(
        onHotRestart: () async {
          _logger.info('🔁 Hot restart detected');
          await _manager.handleHotRestart();
        },
      ),
    );

    if (await _manager.needsCleanup()) {
      _logger.info('Previous state detected, cleaning up');
      await _manager.handleHotRestart();
    }
  }

  // Public API to track views for debugging
  static void trackViewForDebug(String viewId, String? parentId) {
    if (kDebugMode) {
      _manager.trackView(viewId, parentId);
    }
  }

  // Clean up resources
  static Future<void> dispose() async {
    if (kDebugMode) {
      await _manager.dispose();
    }
  }
}

class _DebugObserver extends WidgetsBindingObserver {
  final Future<void> Function() onHotRestart;

  _DebugObserver({required this.onHotRestart});

  @override
  Future<void> didHaveMemoryPressure() async {
    await onHotRestart();
  }
}
