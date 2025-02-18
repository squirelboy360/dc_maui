import 'package:dc_test/framework/core/types/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../layout/layout_config.dart';
import '../core/types/layout/yoga_types.dart'; // Add this import
import '../core/types/view/view_types.dart';

// Add this enum at the top of the file after imports
enum ScrollDirection { vertical, horizontal }

// Add these enums
enum FlexDirection { row, column }

enum FlexAlignment {
  start,
  center,
  end,
  spaceBetween,
  spaceAround,
  spaceEvenly
}

// Add these enums after existing enums
enum StackType {
  vertical, // VStack
  horizontal, // HStack
  depth // ZStack
}

// Update Color extension to use new API
extension ColorExtension on Color {
  String toHexString() {
    return '#'
        '${r.round().toRadixString(16).padLeft(2, '0')}'
        '${g.round().toRadixString(16).padLeft(2, '0')}'
        '${b.round().toRadixString(16).padLeft(2, '0')}';
  }
}

enum ListViewStyle { list, grid }

// Add this enum after existing enums
enum ScrollAxis { vertical, horizontal, free }

// Layout system enums and types
enum LayoutType { flex, absolute, relative }

enum LayoutAlign { auto, start, center, end, stretch, baseline }

// Add comprehensive event handling types
enum TouchableEvent { onTouchDown, onTouchMove, onTouchUp, onTouchCancel }

enum GestureEvent {
  onTap,
  onDoubleTap,
  onLongPress,
  onPanStart,
  onPanUpdate,
  onPanEnd,
  onScaleStart,
  onScaleUpdate,
  onScaleEnd,
  onRotateStart,
  onRotateUpdate,
  onRotateEnd
}

class TouchEventData {
  final String viewId;
  final TouchableEvent type;
  final Offset position;
  final double pressure;
  final double timestamp;

  TouchEventData({
    required this.viewId,
    required this.type,
    required this.position,
    this.pressure = 1.0,
    required this.timestamp,
  });

  factory TouchEventData.fromJson(Map<String, dynamic> json) {
    return TouchEventData(
      viewId: json['viewId'] as String,
      type: TouchableEvent.values[json['type'] as int],
      position: Offset(
        json['x'] as double,
        json['y'] as double,
      ),
      pressure: json['pressure'] as double? ?? 1.0,
      timestamp: json['timestamp'] as double,
    );
  }
}

// Yoga-compatible layout configuration
class NativeUIBridge {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');
  final _logger = Logger('NativeUIBridge');

  // Add these constants
  static const double matchParent = -1.0;
  static const double wrapContent = -2.0;

  // Singleton pattern
  static final NativeUIBridge _instance = NativeUIBridge._();
  factory NativeUIBridge() => _instance;
  NativeUIBridge._() {
    _setupEventHandler();
    _setupLayoutHandlers();
  }

  // Add missing event handlers map
  final Map<String, Map<String, Future<void> Function()>> _eventHandlers = {};

  // Event handler setup
  void _setupEventHandler() {
    _channel.setMethodCallHandler((call) async {
      try {
        switch (call.method) {
          case 'onNativeEvent':
          case 'onButtonEvent':
            final args = Map<String, dynamic>.from(call.arguments as Map);
            final String viewId = args['viewId'] as String;
            final String eventType = args['eventType'] as String;

            if (_eventHandlers.containsKey(viewId) &&
                _eventHandlers[viewId]!.containsKey(eventType)) {
              await _eventHandlers[viewId]![eventType]!();
              return true;
            }
            return false;

          default:
            return null;
        }
      } catch (e, stack) {
        _logger.severe('Error handling method call: $e');
        _logger.severe('Stack trace: $stack');
        return null;
      }
    });
  }

  // Add new method for button event registration
  Future<bool> registerButtonEvent(
    String buttonId,
    String eventType,
    Future<void> Function() callback,
  ) async {
    try {
      // First store the callback
      _eventHandlers[buttonId] ??= {};
      _eventHandlers[buttonId]![eventType] = callback;

      // Then register with native side
      final result = await _channel.invokeMethod('registerEvent', {
        'viewId': buttonId,
        'eventType': eventType,
        'handler':
            true, // Just send a flag, actual handler is stored in _eventHandlers
      });

      return result ?? false;
    } catch (e) {
      _logger.severe('Error registering button event: $e');
      return false;
    }
  }

// View Management Methods
  /// Creates a new native view
  /// Native expects:
  /// - viewType: String (e.g. `Button`, `TextView`, `LinearLayout`)
  /// - properties: {
  ///     text?: String,
  ///     textSize?: double,
  ///     backgroundColor?: String (hex color),
  ///     width?: int,
  ///     height?: int,
  ///     padding?: int,
  ///     margin?: int,
  ///     isEnabled?: bool
  ///   }
  /// Returns: String viewId or null if failed
  ///
  Future<String?> createView(
    ViewType viewType, {
    Map<String, dynamic>? properties,
    LayoutConfig? layout,
    Map<TouchEventType, Function(TouchEventData)>? events,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': viewType.value,
        if (properties != null) 'properties': properties,
        if (layout != null) 'layout': layout.toJson(),
      });

      if (viewId != null && events != null) {
        for (final entry in events.entries) {
          await _registerTouchEvent(
            viewId,
            entry.key,
            entry.value,
          );
        }
      }

      return viewId;
    } catch (e) {
      _logger.severe('Error creating view: $e');
      return null;
    }
  }

  /// Attaches child view to parent view in native hierarchy
  /// Native expects:
  /// - parentId: String (must be existing view ID)
  /// - childId: String (must be existing view ID)
  /// Returns: bool success
  Future<bool> attachView(String parentId, String childId) async {
    try {
      final result = await _channel.invokeMethod<bool>('attachView', {
        'parentId': parentId,
        'childId': childId,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error attaching view: $e');
      return false;
    }
  }

  Future<bool> deleteView(String viewId) async {
    try {
      final result = await _channel.invokeMethod<bool>('deleteView', {
        'viewId': viewId,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error deleting view: $e');
      return false;
    }
  }

  /// Updates properties of existing native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - properties: {
  ///     text?: String,
  ///     textSize?: double,
  ///     backgroundColor?: String (hex),
  ///     width?: int,
  ///     height?: int,
  ///     isEnabled?: bool,
  ///     isVisible?: bool
  ///   }
  Future<bool> updateView(
      String viewId, Map<String, dynamic> properties) async {
    try {
      // Convert any Color objects to hex strings
      var processedProperties = Map<String, dynamic>.from(properties);
      if (properties['textColor'] is Color) {
        processedProperties['textColor'] =
            (properties['textColor'] as Color).toHexString();
      }

      final result = await _channel.invokeMethod<bool>('updateView', {
        'viewId': viewId,
        'properties': processedProperties,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error updating view: $e');
      return false;
    }
  }

  // Event Handling

  // Styling Methods

  /// Sets background color of native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - color: String (hex format: '#RRGGBB' or '#AARRGGBB')
  Future<bool> setViewBackgroundColor(String viewId, dynamic color) async {
    try {
      String colorString;
      if (color is Color) {
        colorString = color.toHexString();
      } else if (color is String) {
        colorString = color;
      } else {
        throw ArgumentError('Color must be either a Color object or a String');
      }

      final result = await _channel.invokeMethod<bool>(
        'changeViewBackgroundColor',
        {
          'viewId': viewId,
          'color': colorString,
        },
      );
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting background color: $e');
      return false;
    }
  }

  /// Sets visibility of native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - isVisible: bool (true = View.VISIBLE, false = View.GONE)
  Future<bool> setViewVisibility(String viewId, bool isVisible) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewVisibility', {
        'viewId': viewId,
        'isVisible': isVisible,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting visibility: $e');
      return false;
    }
  }

  // Hierarchy Methods

  /// Get native view properties by ID
  /// Returns: Map with properties:
  /// {
  ///   viewType: String,
  ///   properties: Map<String, dynamic>,
  ///   children: List<String>,
  ///   parent: String?
  /// }
  Future<Map<String, dynamic>?> getViewById(String viewId) async {
    try {
      final result = await _channel.invokeMethod('getViewById', {
        'viewId': viewId,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      _logger.severe('Error getting view: $e');
      return null;
    }
  }

  Future<List<String>?> getChildren(String parentId) async {
    try {
      final result = await _channel.invokeMethod('getChildren', {
        'parentId': parentId,
      });
      return List<String>.from(result);
    } catch (e) {
      _logger.severe('Error getting children: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRootView() async {
    try {
      final result = await _channel.invokeMethod('getRootView');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      _logger.severe('Error getting root view: $e');
      return null;
    }
  }

  Future<ListViewController?> createListView({
    ListViewStyle style = ListViewStyle.list,
    int columns = 1,
    double spacing = 8.0,
    EdgeInsets padding = EdgeInsets.zero,
    bool enableRefresh = false,
    bool enablePagination = false,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createListView', {
        'style': style.toString(),
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

      if (viewId != null) {
        return ListViewController(this, viewId);
      }
      return null;
    } catch (e) {
      _logger.severe('Error creating list view: $e');
      return null;
    }
  }

  Future<bool> setViewLayout(
    String viewId, {
    double? width,
    double? height,
    double? flex,
    FlexDirection? direction,
    FlexAlignment? alignment,
    double? spacing,
  }) async {
    try {
      final result = await _channel.invokeMethod('setViewLayout', {
        'viewId': viewId,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (flex != null) 'flex': flex,
        if (direction != null)
          'direction': direction.toString().split('.').last,
        if (alignment != null)
          'alignment': alignment.toString().split('.').last,
        if (spacing != null) 'spacing': spacing,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting view layout: $e');
      return false;
    }
  }

  Future<String?> createStackView(
    StackType type, {
    double spacing = 8.0,
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) async {
    try {
      _logger.info('Creating stack view of type: ${type.toString()}');
      final viewId = await _channel.invokeMethod<String>('createStackView', {
        'stackType': type.toString().split('.').last,
        'spacing': spacing,
        'alignment': alignment?.toString().split('.').last,
        'padding': {
          'top': padding.top,
          'left': padding.left,
          'bottom': padding.bottom,
          'right': padding.right,
        },
      });
      _logger.info('Stack view created with ID: $viewId');
      return viewId;
    } catch (e) {
      _logger.severe('Error creating stack view: $e');
      return null;
    }
  }

  // Helper methods for specific stack types
  Future<String?> createVStack({
    double spacing = 8.0,
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return createStackView(
      StackType.vertical,
      spacing: spacing,
      alignment: alignment,
      padding: padding,
    );
  }

  Future<String?> createHStack({
    double spacing = 8.0,
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return createStackView(
      StackType.horizontal,
      spacing: spacing,
      alignment: alignment,
      padding: padding,
    );
  }

  Future<String?> createZStack({
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return createStackView(
      StackType.depth,
      spacing: 0,
      alignment: alignment,
      padding: padding,
    );
  }

  Future<double> getScreenWidth() async {
    try {
      final width = await _channel.invokeMethod<double>('getScreenWidth');
      return width ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting screen width: $e');
      return 0.0;
    }
  }

  Future<double> getScreenHeight() async {
    try {
      final height = await _channel.invokeMethod<double>('getScreenHeight');
      return height ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting screen height: $e');
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> getDeviceMetrics() async {
    try {
      final metrics = await _channel.invokeMethod<Map>('getDeviceMetrics');
      return Map<String, dynamic>.from(metrics ?? {});
    } catch (e) {
      _logger.severe('Error getting device metrics: $e');
      return {};
    }
  }

  Future<bool> isDarkMode() async {
    try {
      final isDark = await _channel.invokeMethod<bool>('isDarkMode');
      return isDark ?? false;
    } catch (e) {
      _logger.severe('Error checking dark mode: $e');
      return false;
    }
  }

  Future<double> getStatusBarHeight() async {
    try {
      final height = await _channel.invokeMethod<double>('getStatusBarHeight');
      return height ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting status bar height: $e');
      return 0.0;
    }
  }

  Future<double> getSafeAreaInsets(String edge) async {
    try {
      final inset = await _channel.invokeMethod<double>('getSafeAreaInset', {
        'edge': edge, // top, bottom, left, right
      });
      return inset ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting safe area inset: $e');
      return 0.0;
    }
  }

  Future<bool> setViewToFillParent(String viewId) async {
    return setViewLayout(viewId, width: matchParent, height: matchParent);
  }

  Future<bool> setViewToFillWidth(String viewId) async {
    return setViewLayout(viewId, width: matchParent);
  }

  Future<bool> setViewToFillHeight(String viewId) async {
    return setViewLayout(viewId, height: matchParent);
  }

  // Add this helper method for direct method channel invocation
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      return result;
    } catch (e) {
      _logger.severe('Error invoking native method $method: $e');
      return null;
    }
  }

  Future<bool> setScrollContent(
      String scrollViewId, String contentViewId) async {
    try {
      final result = await _channel.invokeMethod('setScrollContent', {
        'scrollViewId': scrollViewId,
        'contentViewId': contentViewId,
      });
      return result as bool? ?? false;
    } catch (e) {
      _logger.severe('Error setting scroll content: $e');
      return false;
    }
  }

  // Single unified layout method
  Future<bool> setLayout(String viewId, LayoutConfig config) async {
    try {
      final result = await _channel.invokeMethod('applyLayout', {
        'viewId': viewId,
        ...config.toJson(),
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error applying layout: $e');
      return false;
    }
  }

  // Convenience methods
  Future<bool> centerInParent(String viewId) {
    return setLayout(
        viewId,
        LayoutConfig(
          alignSelf: YGAlign.center,
          justifyContent: YGJustify.center,
        ));
  }

  Future<bool> fillParent(String viewId) {
    return setLayout(
        viewId,
        LayoutConfig(
          width: YGValue.percent(100), // Use YGValue constructor
          height: YGValue.percent(100), // Use YGValue constructor
        ));
  }

  Future<bool> setAbsoluteLayout(
    String viewId, {
    double? x,
    double? y,
    double? width,
    double? height,
    EdgeInsets? margin,
  }) {
    return setLayout(
        viewId,
        LayoutConfig(
          position: YGPositionType.absolute,
          width: width != null
              ? YGValue.points(width)
              : null, // Convert numbers to YGValue
          height: height != null ? YGValue.points(height) : null,
          margin: margin,
        ));
  }

  Future<bool> setFlexLayout(
    String viewId, {
    YGFlexDirection? direction,
    YGJustify? justify,
    YGAlign? alignItems,
    double? flex,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return setLayout(
        viewId,
        LayoutConfig(
          flexDirection: direction,
          justifyContent: justify,
          alignItems: alignItems,
          flex: flex,
          margin: margin,
          padding: padding,
        ));
  }

  // Add new method for creating touchable components
  Future<String?> createTouchable({
    Map<String, dynamic>? properties,
    Map<TouchEventType, Function(TouchEventData)>? events,
  }) async {
    final viewId =
        await createView(ViewType.touchableOpacity, properties: properties);
    if (viewId != null && events != null) {
      for (final entry in events.entries) {
        await _registerTouchEvent(viewId, entry.key, entry.value);
      }
    }
    return viewId;
  }

  // Enhanced button creation
  Future<String?> createButton({
    required String text,
    required Map<String, dynamic> style,
    required LayoutConfig layout,
    Map<ButtonEventType, Future<void> Function()>? events,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': ViewType.button.value,
        'properties': {
          ...style,
          'text': text,
        },
        'layout': layout.toJson(),
      });

      if (viewId != null) {
        // Register events
        if (events != null) {
          for (final entry in events.entries) {
            await registerButtonEvent(
              viewId,
              entry.key.toString(),
              entry.value,
            );
          }
        }
        return viewId;
      }
      return null;
    } catch (e) {
      _logger.severe('Error creating button: $e');
      return null;
    }
  }

  // Fix TouchableOpacity event registration
  Future<String?> createTouchableOpacity({
    required Map<String, dynamic> style,
    required LayoutConfig layout,
    required Widget child,
    Map<TouchableEvent, void Function(TouchEventData)>? events,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': ViewType.touchableOpacity.value,
        'properties': style,
        'layout': layout.toJson(),
      });

      if (viewId != null && events != null) {
        for (final entry in events.entries) {
          _touchEventHandlers[viewId] ??= {};
          _touchEventHandlers[viewId]![entry.key.toString()] = entry.value;

          await _channel.invokeMethod('registerEvent', {
            'viewId': viewId,
            'eventType': entry.key.toString(),
            'hasHandler': true,
          });
        }
      }
      return viewId;
    } catch (e) {
      _logger.severe('Error creating touchable opacity: $e');
      return null;
    }
  }

  // Add gesture detector support
  Future<String?> createGestureDetector({
    required Map<String, dynamic> style,
    required LayoutConfig layout,
    required Widget child,
    Map<GestureEvent, dynamic Function(dynamic)>? events,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': ViewType.gestureDetector.value,
        'properties': style,
        'layout': layout.toJson(),
      });

      if (viewId != null && events != null) {
        for (final entry in events.entries) {
          await _registerGestureEvent(
            viewId,
            entry.key.toString(),
            entry.value,
          );
        }
      }
      return viewId;
    } catch (e) {
      _logger.severe('Error creating gesture detector: $e');
      return null;
    }
  }

  // Internal event registration methods
  Future<bool> _registerTouchEvent(
    String viewId,
    TouchEventType type,
    Function(TouchEventData) callback,
  ) async {
    try {
      _touchEventHandlers[viewId] ??= {};
      _touchEventHandlers[viewId]![type.name] = callback;

      final result = await _channel.invokeMethod('registerEvent', {
        'viewId': viewId,
        'eventType': type.name,
        'hasHandler': true,
      });

      return result ?? false;
    } catch (e) {
      _logger.severe('Error registering touch event: $e');
      return false;
    }
  }

  Future<bool> _registerGestureEvent(
    String viewId,
    String eventType,
    Function callback,
  ) async {
    try {
      _gestureEventHandlers[viewId] ??= {};
      _gestureEventHandlers[viewId]![eventType] = callback;

      return await _channel.invokeMethod('registerEvent', {
        'viewId': viewId,
        'eventType': eventType,
        'hasHandler': true,
      });
    } catch (e) {
      _logger.severe('Error registering gesture event: $e');
      return false;
    }
  }

  // Event handler storage
  final Map<String, Map<String, Function(TouchEventData)>> _touchEventHandlers =
      {};
  final Map<String, Map<String, Function>> _gestureEventHandlers = {};

  // Add orientation/window change handlers
  void _setupLayoutHandlers() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onOrientationChange':
          final args = Map<String, dynamic>.from(call.arguments);
          _handleOrientationChange(
            orientation: args['orientation'] as String,
            width: args['width'] as double,
            height: args['height'] as double,
          );
          return true;

        case 'onWindowChange':
          final args = Map<String, dynamic>.from(call.arguments);
          _handleWindowChange(
            width: args['width'] as double,
            height: args['height'] as double,
          );
          return true;

        default:
          return null;
      }
    });
  }

  void _handleOrientationChange({
    required String orientation,
    required double width,
    required double height,
  }) {
    // Notify listeners of orientation change
    for (final callback in _orientationListeners) {
      callback(orientation, width, height);
    }
  }

  void _handleWindowChange({
    required double width,
    required double height,
  }) {
    // Notify listeners of window size change
    for (final callback in _windowListeners) {
      callback(width, height);
    }
  }

  // Listener management
  final _orientationListeners = <Function(String, double, double)>[];
  final _windowListeners = <Function(double, double)>[];

  void addOrientationListener(Function(String, double, double) listener) {
    _orientationListeners.add(listener);
  }

  void removeOrientationListener(Function(String, double, double) listener) {
    _orientationListeners.remove(listener);
  }

  void addWindowListener(Function(double, double) listener) {
    _windowListeners.add(listener);
  }

  void removeWindowListener(Function(double, double) listener) {
    _windowListeners.remove(listener);
  }

  // Add missing attachToRoot method
  Future<bool> attachToRoot(String viewId) async {
    try {
      final rootInfo = await getRootView();
      if (rootInfo == null) {
        _logger.severe('Failed to get root view');
        return false;
      }

      final rootId = rootInfo['viewId'] as String;
      await attachView(rootId, viewId);

      // Handle root layout automatically
      await setLayout(
        rootId,
        LayoutConfig(
          width: YGValue.percent(100),
          height: YGValue.percent(100),
        ),
      );

      return true;
    } catch (e) {
      _logger.severe('Error attaching to root: $e');
      return false;
    }
  }
}

// Helper classes for type-safe view creation
class NativeView {
  final String viewId;
  final NativeUIBridge _bridge;

  NativeView(this.viewId) : _bridge = NativeUIBridge();

  Future<bool> setBackgroundColor(String color) {
    return _bridge.setViewBackgroundColor(viewId, color);
  }

  Future<bool> setVisibility(bool isVisible) {
    return _bridge.setViewVisibility(viewId, isVisible);
  }

  Future<bool> delete() {
    return _bridge.deleteView(viewId);
  }

  Future<bool> update(Map<String, dynamic> properties) {
    return _bridge.updateView(viewId, properties);
  }


  Future<bool> setSize({double? width, double? height}) {
    return _bridge.setViewLayout(viewId, width: width, height: height);
  }

  Future<bool> setFlex(double flex) {
    return _bridge.setViewLayout(viewId, flex: flex);
  }
}

class ListViewController {
  final NativeUIBridge _bridge;
  final String viewId;
  final List<String> itemIds = [];

  ListViewController(this._bridge, this.viewId);

  Future<bool> addItem(Future<String?> Function() itemBuilder) async {
    try {
      final itemId = await itemBuilder();
      if (itemId != null) {
        itemIds.add(itemId);
        await _bridge.attachView(viewId, itemId);
        return true;
      }
      return false;
    } catch (e) {
      _bridge._logger.severe('Error adding item to list: $e');
      return false;
    }
  }

  Future<bool> removeItem(int index) async {
    if (index >= 0 && index < itemIds.length) {
      final itemId = itemIds[index];
      if (await _bridge.deleteView(itemId)) {
        itemIds.removeAt(index);
        return true;
      }
    }
    return false;
  }
}
