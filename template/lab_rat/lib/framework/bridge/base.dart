import 'package:dc_test/framework/bridge/hot_restart.dart';
import 'package:dc_test/framework/core/types/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, ScrollView, ListView;
import 'package:logging/logging.dart';
import '../core/types/view/view_types.dart';
import '../style/view_style.dart';
import '../layout/layout_config.dart';
import 'core.dart';

final bridge = UIBridge();

class UIBridge {
  final Core _core = Core();

  Future<String> createView(
    ViewType type, {
    TextStyle? textStyle,
    ViewStyle? style,
    LayoutConfig? layout,
    List<dynamic>? items, // Changed from List<ListViewItem> to List<dynamic>
    Function(int, dynamic)? attachedListViewChild, // Updated to include item data
    Map<NativeEventType, Function(NativeEventData)>? events,
  }) async {
    // Transform configs to match native expectations
    final Map<String, dynamic> args = {
      'viewType': type.value,
      'properties': {
        if (textStyle != null) 'textStyle': textStyle.toJson(),
        if (style != null) ...style.toJson(),
      },
      if (layout != null) 'layout': layout.toJson(),
      if (items != null && type == ViewType.listView)
        'items': items, // Just pass the raw items list
      if (attachedListViewChild != null && type == ViewType.listView)
        'useCustomRenderer': true, // Flag for native side
      if (events != null) 'events': events.map((k, _) => MapEntry(k.name, true)),
    };

    final viewId = await _core.createView(type, args);

    // Handle list view child creation if needed
    if (viewId != null &&
        type == ViewType.listView &&
        attachedListViewChild != null &&
        items != null) {
      for (var i = 0; i < items.length; i++) {
        final childView = await attachedListViewChild(i, items[i]); // Pass both index and item data
        await _core.attachView(viewId, childView);
      }
    }

    // Register events after view creation
    if (viewId != null && events != null) {
      for (final entry in events.entries) {
        await _core.registerEvent(viewId, entry.key, entry.value);
      }
    }

    if (viewId == null) {
      throw ViewCreationException(
          'Failed to create view of type: ${type.value}');
    }

    return viewId;
  }

  // View Styling - Strongly typed
  Future<void> setViewStyle(String viewId, ViewStyle style) async {
    final success = await _core.updateView(viewId, style.toJson());
    if (!success) {
      throw ViewUpdateException('Failed to update view style: $viewId');
    }
  }

  // Layout Configuration - Strongly typed
  Future<void> setViewLayout(String viewId, LayoutConfig layout) async {
    final success = await _core.setLayout(viewId, layout);
    if (!success) {
      throw ViewLayoutException('Failed to set view layout: $viewId');
    }
  }

  // View Hierarchy - Strongly typed operations
  Future<void> attachView(String parentId, String childId) async {
    final success = await _core.attachView(parentId, childId);
    if (!success) {
      throw ViewHierarchyException(
          'Failed to attach view $childId to $parentId');
    }
  }

  // Debug Tools - Type safe
  Future<void> debugLogHierarchy() async {
    final rootView = await _core.getRootView();
    if (rootView == null) {
      throw DebugException('No root view found');
    }
    // Todo
  }
}

// Custom exceptions for better error handling
class ViewCreationException implements Exception {
  final String message;
  ViewCreationException(this.message);
  @override
  String toString() => 'ViewCreationException: $message';
}

class ViewUpdateException implements Exception {
  final String message;
  ViewUpdateException(this.message);
  @override
  String toString() => 'ViewUpdateException: $message';
}

class ViewLayoutException implements Exception {
  final String message;
  ViewLayoutException(this.message);
  @override
  String toString() => 'ViewLayoutException: $message';
}

class EventRegistrationException implements Exception {
  final String message;
  EventRegistrationException(this.message);
  @override
  String toString() => 'EventRegistrationException: $message';
}

class ViewHierarchyException implements Exception {
  final String message;
  ViewHierarchyException(this.message);
  @override
  String toString() => 'ViewHierarchyException: $message';
}

class DebugException implements Exception {
  final String message;
  DebugException(this.message);
  @override
  String toString() => 'DebugException: $message';
}

// Debug functionality
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

  static void trackViewForDebug(String viewId, String? parentId) {
    if (kDebugMode) {
      _manager.trackView(viewId, parentId);
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
