import 'package:dc_test/framework/bridge/base.dart';
import 'package:dc_test/framework/core/types/events.dart';
import 'package:dc_test/framework/style/view_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../layout/layout_config.dart';
import '../core/types/layout/yoga_types.dart'; // Add this import
import '../core/types/view/view_types.dart';


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

// Update Color extension to use correct integer conversion
extension ColorExtension on Color {
  String toHexString() {
    final r = red.round().toRadixString(16).padLeft(2, '0');
    final g = green.round().toRadixString(16).padLeft(2, '0');
    final b = blue.round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}



// Layout system enums and types
enum LayoutType { flex, absolute, relative }

enum LayoutAlign { auto, start, center, end, stretch, baseline }

// Yoga-compatible layout configuration
class Core {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');
  final _logger = Logger('NativeUIBridge');

  // Add these constants
  static const double matchParent = -1.0;
  static const double wrapContent = -2.0;

  // Singleton pattern
  static final Core _instance = Core._();
  factory Core() => _instance;
  Core._() {
    _setupEventHandler();
  }

  // Callback registry
  final Map<String, Map<String, Function>> _eventCallbacks = {};

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
  /// - viewType: String (e.g. 'Button', 'TextView', 'LinearLayout')
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
  Future<String?> createView(
      ViewType viewType, Map<String, dynamic> args) async {
    try {
      // Sending exactly what native expects
      final Map<String, dynamic> nativeArgs = {
        'viewType': viewType.value,
        if (args['properties'] != null) 'properties': args['properties'],
        if (args['layout'] != null) 'layout': args['layout'],
      };

      final viewId =
          await _channel.invokeMethod<String>('createView', nativeArgs);
      return viewId;
    } catch (e, stack) {
      _logger.severe('Error creating view: $e\n$stack');
      return null;
    }
  }

  Future<bool> attachView(String parentId, String childId) async {
    try {
      // Check if already attached to prevent duplicates
      final children = await getChildren(parentId) ?? [];
      if (children.contains(childId)) {
        _logger.warning('View $childId already attached to $parentId');
        return false;
      }

      final result = await _channel.invokeMethod<bool>('attachView', {
        'parentId': parentId,
        'childId': childId,
      });

      if (result ?? false) {
        Base.trackViewForDebug(childId, parentId);
      }

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
  Future<bool> updateView(String viewId, Map<String, dynamic> styles) async {
    try {
      print('Updating view $viewId with styles: $styles'); // Debug log

      final result = await _channel.invokeMethod<bool>('updateView', {
        'viewId': viewId,
        'properties': styles,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error updating view: $e');
      return false;
    }
  }

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


  // Single unified layout method
  Future<bool> setLayout(String viewId, LayoutConfig config) async {
    try {
      // Get parent dimensions before applying new layout
      final parent = await getParentView(viewId);
      final parentHeight = parent?['height'] as double?;
      final parentWidth = parent?['width'] as double?;

      // Store original parent dimensions if using percentages
      if (config.height?.unit == YGUnit.percent ||
          config.width?.unit == YGUnit.percent) {
        await _channel.invokeMethod('preserveParentDimensions', {
          'viewId': viewId,
          'parentHeight': parentHeight,
          'parentWidth': parentWidth,
        });
      }

      final result = await _channel.invokeMethod('applyLayout', {
        'viewId': viewId,
        'config': config.toJson(),
        'preserveParent':
            true, // Tell native side to preserve parent dimensions
      });

      return result ?? false;
    } catch (e) {
      _logger.severe('Error applying layout: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getParentView(String viewId) async {
    try {
      final result =
          await _channel.invokeMethod('getParentView', {'viewId': viewId});
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      _logger.severe('Error getting parent view: $e');
      return null;
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
    Map<TouchEventType, Function(TouchEvent)>? events,
  }) async {
    // Fix: Convert properties to proper args map format
    final args = {
      'viewType': ViewType.touchableOpacity.value,
      if (properties != null) 'properties': properties,
    };

    final viewId = await createView(ViewType.touchableOpacity, args);
    if (viewId != null && events != null) {
      for (final entry in events.entries) {
        _registerTouchEvent(viewId, entry.key, entry.value);
      }
    }
    return viewId;
  }

  // Update createButton method
  Future<String?> createButton({
    required String text,
    required Map<String, dynamic> style,
    LayoutConfig? layout,
    Map<ButtonEventType, Future<void> Function()>? events,
  }) async {
    try {
      // Convert events to a format that can be serialized
      final Map<String, dynamic>? serializedEvents = events?.map(
        (key, value) => MapEntry(key.name, {'type': key.name}),
      );

      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': ViewType.button.value,
        'properties': style,
        if (layout != null) 'layout': layout.toJson(),
        if (serializedEvents != null) 'events': serializedEvents,
      });

      if (viewId != null && events != null) {
        // Store callbacks for later use
        _eventHandlers[viewId] = {};

        for (final entry in events.entries) {
          // Register the event type with native
          await _channel.invokeMethod('registerEvent', {
            'viewId': viewId,
            'eventType': entry.key.name,
          });

          // Store the callback
          _eventHandlers[viewId]![entry.key.name] = entry.value;
        }

        // Set up method channel handler if not already done
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'onButtonEvent') {
            final args = call.arguments as Map<String, dynamic>;
            final eventViewId = args['viewId'] as String;
            final eventType = args['type'] as String;

            if (_eventHandlers.containsKey(eventViewId) &&
                _eventHandlers[eventViewId]!.containsKey(eventType)) {
              await _eventHandlers[eventViewId]![eventType]!();
              return true;
            }
          }
          return null;
        });
      }

      return viewId;
    } catch (e, stack) {
      _logger.severe('Error creating button: $e');
      _logger.severe('Stack trace: $stack');
      return null;
    }
  }

  // Internal event registration methods
  void _registerTouchEvent(
      String viewId, TouchEventType type, Function(TouchEvent) callback) {
    // Store in a separate map for touch events
    _touchEventCallbacks[viewId] ??= {};
    _touchEventCallbacks[viewId]![type] = callback;
  }

  // Add new maps for typed events
  final Map<String, Map<TouchEventType, Function(TouchEvent)>>
      _touchEventCallbacks = {};

  // Update event handlers storage to use string keys (enum names)
  final Map<String, Map<String, Future<void> Function()>> _eventHandlers = {};

  // Add new convenience method for root handling
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

  Future<bool> clearAllViews() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearAllViews');
      return result ?? false;
    } catch (e) {
      _logger.severe('Error clearing views: $e');
      return false;
    }
  }

  // Add helper method to force parent dimension update
  Future<bool> updateParentDimensions(String viewId) async {
    try {
      final result = await _channel.invokeMethod('updateParentDimensions', {
        'viewId': viewId,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error updating parent dimensions: $e');
      return false;
    }
  }

  


}

// Helper classes for type-safe view creation
class NativeView {
  final String viewId;
  final Core _bridge;

  NativeView(this.viewId) : _bridge = Core();

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
