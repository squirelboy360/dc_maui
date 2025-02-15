import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

// Add this enum at the top of the file after imports
enum ScrollDirection { vertical, horizontal }

// Add this extension near the top of the file
extension ColorExtension on Color {
  String toHexString() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}

class NativeUIBridge {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');
  final _logger = Logger('NativeUIBridge');

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
        try {
          // Explicitly cast the arguments to Map<String, dynamic>
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final String viewId = args['viewId'] as String;
          final String eventType = args['eventType'] as String;

          if (_eventCallbacks.containsKey(viewId) &&
              _eventCallbacks[viewId]!.containsKey(eventType)) {
            await _eventCallbacks[viewId]![eventType]!.call();
            return true;
          }
          _logger.warning('No callback found for $eventType on view $viewId');
          return false;
        } catch (e, stack) {
          _logger.severe('Error handling native event: $e');
          _logger.severe('Stack trace: $stack');
          throw FlutterError('Failed to process native event: $e');
        }
      }
      return null;
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
      // Convert any Color objects to hex strings
      var processedProperties = Map<String, dynamic>.from(properties);
      if (properties['textColor'] is Color) {
        processedProperties['textColor'] = (properties['textColor'] as Color).toHexString();
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

      if (result == true) {
        // Initialize the map for this viewId if it doesn't exist
        _eventCallbacks[viewId] ??= {};
        // Store the callback - this was missing!
        _eventCallbacks[viewId]![eventType] = callback;
        _logger.info('Successfully registered $eventType for view $viewId');
        return true;
      }
      _logger.warning('Failed to register event on native side');
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
    ScrollDirection direction = ScrollDirection.vertical,
    double spacing = 8.0,
    EdgeInsets padding = EdgeInsets.zero,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createListView', {
        'direction':
            direction == ScrollDirection.horizontal ? 'horizontal' : 'vertical',
        'spacing': spacing,
        'padding': {
          'top': padding.top,
          'left': padding.left,
          'bottom': padding.bottom,
          'right': padding.right,
        },
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

  Future<bool> addEventListener(String eventType, Function callback) {
    return _bridge.registerEvent(viewId, eventType, callback);
  }

  Future<bool> removeEventListener(String eventType) {
    return _bridge.unregisterEvent(viewId, eventType);
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
