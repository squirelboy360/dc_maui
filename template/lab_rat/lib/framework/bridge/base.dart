import 'package:dc_test/framework/bridge/hot_restart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, ScrollView, ListView;
import 'package:logging/logging.dart';
import '../core/types/events.dart';
import '../core/types/view/view_types.dart';
import '../style/view_style.dart';
import '../layout/layout_config.dart';
import 'core.dart';
import '../core/types/layout/yoga_types.dart';

final bridge = UIBridge();

class UIBridge {
  final Core _core = Core();

  Future<String> createView(
    ViewType type, {
    TextStyle? testStyle,
    ViewStyle? style,
    LayoutConfig? layout,
  }) async {
    // Transform configs to match native expectations
    final Map<String, dynamic> args = {
      'viewType': type.value,
      'properties': {
        if (testStyle != null) 'textStyle': testStyle.toJson(),
        if (style != null) ...style.toJson(),
      },
      if (layout != null) 'layout': layout.toJson(),
    };

    final viewId = await _core.createView(type, args);
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

  // Event Handling - Typed events
  Future<void> addButtonEvent(
    String viewId,
    ButtonEventType eventType,
    Future<void> Function() callback,
  ) async {
    final success =
        await _core.registerButtonEvent(viewId, eventType.name, callback);
    if (!success) {
      throw EventRegistrationException(
          'Failed to register button event: $eventType');
    }
  }

  Future<void> addTouchEvent(
    String viewId,
    TouchEventType eventType,
    void Function(TouchEvent) callback,
  ) async {
    // Todo
    // Implementation for touch events
  }

  // View Hierarchy - Strongly typed operations
  Future<void> attachView(String parentId, String childId) async {
    final success = await _core.attachView(parentId, childId);
    if (!success) {
      throw ViewHierarchyException(
          'Failed to attach view $childId to $parentId');
    }
  }

  Future<void> attachToRoot(String viewId) async {
    final success = await _core.attachToRoot(viewId);
    if (!success) {
      throw ViewHierarchyException('Failed to attach view to root: $viewId');
    }
  }

  // Updated ScrollView creation
  Future<String> createScrollView({
    ScrollAxis axis = ScrollAxis.vertical,
    EdgeInsets padding = EdgeInsets.zero,
    ViewStyle? style,
    LayoutConfig? layout,
  }) async {
    // First create the base view with style
    final viewId = await createView(
      ViewType.view,
      style: style ?? ViewStyle(),
      layout: layout,
    );

    // Then configure it as a scroll view
    final result = await _core.invokeMethod('configureAsScrollView', {
      'viewId': viewId,
      'axis': axis.toString().split('.').last,
      'padding': {
        'top': padding.top,
        'left': padding.left,
        'bottom': padding.bottom,
        'right': padding.right,
      },
    });

    if (result == null || result == false) {
      throw ViewCreationException('Failed to configure ScrollView');
    }

    return viewId;
  }

  Future<void> setScrollContent(
      String scrollViewId, String contentViewId) async {
    final success = await _core.setScrollContent(scrollViewId, contentViewId);
    if (!success) {
      throw ViewUpdateException(
          'Failed to set scroll content for view: $scrollViewId');
    }
  }

  // Updated ListView creation
  Future<ListViewController> createListView({
    ListViewStyle style = ListViewStyle.list,
    int columns = 1,
    double spacing = 8.0,
    EdgeInsets padding = EdgeInsets.zero,
    bool enableRefresh = false,
    bool enablePagination = false,
    ViewStyle? viewStyle,
    LayoutConfig? layout,
  }) async {
    // First create the base view with style
    final viewId = await createView(
      ViewType.view,
      style: viewStyle ?? ViewStyle(),
      layout: layout,
    );

    // Then configure it as a list view
    final result = await _core.invokeMethod('configureAsListView', {
      'viewId': viewId,
      'style': style.toString().split('.').last,
      'columns': columns,
      'spacing': spacing,
      'padding': {
        'top': padding.top,
        'left': padding.left,
        'bottom': padding.bottom,
        'right': padding.right,
      },
      'enableRefresh': enableRefresh,
      'enablePagination': enablePagination,
    });

    if (result == null || result == false) {
      throw ViewCreationException('Failed to configure ListView');
    }

    return ListViewController(_core, viewId);
  }

  // Add helper method for filling parent with scroll content
  Future<void> fillParentWithScroll(String scrollViewId) async {
    final layout = LayoutConfig(
      width: YGValue.percent(100),
      height: YGValue.percent(100),
      flexGrow: 1,
      flexShrink: 1,
    );

    await setViewLayout(scrollViewId, layout);
  }

  // Updated vertical scroll container helper
  Future<String> createVerticalScrollContainer({
    EdgeInsets padding = EdgeInsets.zero,
    ViewStyle? style,
    LayoutConfig? layout,
  }) async {
    final scrollViewId = await createScrollView(
      axis: ScrollAxis.vertical,
      padding: padding,
      style: style ??
          ViewStyle(
            backgroundColor: Colors.transparent,
          ),
      layout: layout ??
          LayoutConfig(
            width: YGValue.percent(100),
            height: YGValue.percent(100),
            flexGrow: 1,
          ),
    );

    final contentId = await createView(
      ViewType.view,
      style: ViewStyle(
        backgroundColor: Colors.transparent,
      ),
      layout: LayoutConfig(
        width: YGValue.percent(100),
        flexGrow: 1,
        flexShrink: 1,
        flexDirection: YGFlexDirection.column,
      ),
    );

    await setScrollContent(scrollViewId, contentId);
    return scrollViewId;
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
