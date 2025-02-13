import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('NativeUIBridge');

class NativeUIBridge {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');

  // Singleton pattern
  static final NativeUIBridge _instance = NativeUIBridge._internal();
  factory NativeUIBridge() => _instance;
  NativeUIBridge._internal() {
    _setupEventHandler();
  }

  // Callback registry
  final Map<String, Map<String, Function>> _eventCallbacks = {};

  // Event handler setup
  void _setupEventHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNativeEvent') {
        final Map<String, dynamic> args = call.arguments;
        final String viewId = args['viewId'];
        final String eventType = args['eventType'];

        if (_eventCallbacks.containsKey(viewId) &&
            _eventCallbacks[viewId]!.containsKey(eventType)) {
          _eventCallbacks[viewId]![eventType]!.call();
        }
      }
    });
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
  Future<String?> createView(String viewType,
      {Map<String, dynamic>? properties}) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': viewType,
        ...?properties,
      });
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
      final result = await _channel.invokeMethod<bool>('updateView', {
        'viewId': viewId,
        'properties': properties,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error updating view: $e');
      return false;
    }
  }

  // Event Handling

  /// Registers event listener on native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - eventType: String (supported events:
  ///   'click', 'longClick', 'focus', 'blur',
  ///   'textChanged', 'scrolled')
  /// Returns: bool success
  Future<bool> registerEvent(
      String viewId, String eventType, Function callback) async {
    try {
      final result = await _channel.invokeMethod<bool>('registerEvent', {
        'viewId': viewId,
        'eventType': eventType,
      });

      if (result ?? false) {
        _eventCallbacks[viewId] ??= {};
        _eventCallbacks[viewId]![eventType] = callback;
        return true;
      }
      return false;
    } catch (e) {
      _logger.severe('Error registering event: $e');
      return false;
    }
  }

  Future<bool> unregisterEvent(String viewId, String eventType) async {
    try {
      final result = await _channel.invokeMethod<bool>('unregisterEvent', {
        'viewId': viewId,
        'eventType': eventType,
      });

      if (result ?? false) {
        _eventCallbacks[viewId]?.remove(eventType);
        if (_eventCallbacks[viewId]?.isEmpty ?? false) {
          _eventCallbacks.remove(viewId);
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.severe('Error unregistering event: $e');
      return false;
    }
  }

  // Styling Methods

  /// Sets background color of native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - color: String (hex format: '#RRGGBB' or '#AARRGGBB')
  Future<bool> setViewBackgroundColor(String viewId, String color) async {
    try {
      final result =
          await _channel.invokeMethod<bool>('changeViewBackgroundColor', {
        'viewId': viewId,
        'color': color,
      });
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

  /// Sets view size
  /// Native expects:
  /// - viewId: String
  /// - width: double
  /// - height: double
  Future<bool> setViewSize(String viewId, {
    required double width,
    required double height,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewSize', {
        'viewId': viewId,
        'width': width,
        'height': height,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting view size: $e');
      return false;
    }
  }

  /// Sets view margins
  Future<bool> setViewMargin(String viewId, EdgeInsets margins) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewMargin', {
        'viewId': viewId,
        'margins': {
          'top': margins.top,
          'left': margins.left,
          'right': margins.right,
          'bottom': margins.bottom,
        },
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting view margins: $e');
      return false;
    }
  }

  /// Sets view padding
  Future<bool> setViewPadding(String viewId, EdgeInsets padding) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewPadding', {
        'viewId': viewId,
        'padding': {
          'top': padding.top,
          'left': padding.left,
          'right': padding.right,
          'bottom': padding.bottom,
        },
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting view padding: $e');
      return false;
    }
  }

  /// Sets view border
  Future<bool> setViewBorder(String viewId, {
    required double width,
    required String color,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewBorder', {
        'viewId': viewId,
        'width': width,
        'color': color,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting view border: $e');
      return false;
    }
  }

  /// Sets view corner radius
  Future<bool> setViewCornerRadius(String viewId, double radius) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewCornerRadius', {
        'viewId': viewId,
        'radius': radius,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting corner radius: $e');
      return false;
    }
  }

  // Hierarchy Methods

  /// Get native view properties by ID
  /// Returns: Map with properties:
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

  // Additional UI methods to expose native capabilities
  
  // Layout methods
  Future<bool> setFlex(String viewId, int flex) async {
    return await _channel.invokeMethod('setFlex', {
      'viewId': viewId,
      'flex': flex,
    }) ?? false;
  }

  Future<bool> setAlignment(String viewId, String alignment) async {
    return await _channel.invokeMethod('setAlignment', {
      'viewId': viewId,
      'alignment': alignment,
    }) ?? false;
  }

  // Stack specific methods
  Future<bool> setStackPosition(String viewId, {
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) async {
    return await _channel.invokeMethod('setStackPosition', {
      'viewId': viewId,
      'top': top,
      'left': left,
      'right': right,
      'bottom': bottom,
    }) ?? false;
  }

  Future<bool> setZIndex(String viewId, int zIndex) async {
    return await _channel.invokeMethod('setZIndex', {
      'viewId': viewId,
      'zIndex': zIndex,
    }) ?? false;
  }

  // Animation methods
  Future<bool> animate(String viewId, Map<String, dynamic> properties, {
    int duration = 300,
    String curve = 'easeInOut',
  }) async {
    return await _channel.invokeMethod('animate', {
      'viewId': viewId,
      'properties': properties,
      'duration': duration,
      'curve': curve,
    }) ?? false;
  }

  // Advanced style methods
  Future<bool> setGradient(String viewId, {
    required List<String> colors,
    List<double>? stops,
    String type = 'linear',
    double angle = 0,
  }) async {
    return await _channel.invokeMethod('setGradient', {
      'viewId': viewId,
      'colors': colors,
      'stops': stops,
      'type': type,
      'angle': angle,
    }) ?? false;
  }

  Future<bool> setBlur(String viewId, double radius) async {
    return await _channel.invokeMethod('setBlur', {
      'viewId': viewId,
      'radius': radius,
    }) ?? false;
  }

  Future<bool> setMask(String viewId, String maskType) async {
    return await _channel.invokeMethod('setMask', {
      'viewId': viewId,
      'maskType': maskType,
    }) ?? false;
  }

  // Gesture handling
  Future<bool> enableGesture(String viewId, String gestureType) async {
    return await _channel.invokeMethod('enableGesture', {
      'viewId': viewId,
      'gestureType': gestureType,
    }) ?? false;
  }

  Future<bool> disableGesture(String viewId, String gestureType) async {
    return await _channel.invokeMethod('disableGesture', {
      'viewId': viewId,
      'gestureType': gestureType,
    }) ?? false;
  }
}