import 'package:flutter/services.dart';

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
  Future<String?> createView(String viewType,
      {Map<String, dynamic>? properties}) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': viewType,
        ...?properties,
      });
      return viewId;
    } catch (e) {
      print('Error creating view: $e');
      return null;
    }
  }

  Future<bool> attachView(String parentId, String childId) async {
    try {
      final result = await _channel.invokeMethod<bool>('attachView', {
        'parentId': parentId,
        'childId': childId,
      });
      return result ?? false;
    } catch (e) {
      print('Error attaching view: $e');
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
      print('Error deleting view: $e');
      return false;
    }
  }

  Future<bool> updateView(
      String viewId, Map<String, dynamic> properties) async {
    try {
      final result = await _channel.invokeMethod<bool>('updateView', {
        'viewId': viewId,
        'properties': properties,
      });
      return result ?? false;
    } catch (e) {
      print('Error updating view: $e');
      return false;
    }
  }

  // Event Handling
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
      print('Error registering event: $e');
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
      print('Error unregistering event: $e');
      return false;
    }
  }

  // Styling Methods
  Future<bool> setViewBackgroundColor(String viewId, String color) async {
    try {
      final result =
          await _channel.invokeMethod<bool>('changeViewBackgroundColor', {
        'viewId': viewId,
        'color': color,
      });
      return result ?? false;
    } catch (e) {
      print('Error setting background color: $e');
      return false;
    }
  }

  Future<bool> setViewVisibility(String viewId, bool isVisible) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewVisibility', {
        'viewId': viewId,
        'isVisible': isVisible,
      });
      return result ?? false;
    } catch (e) {
      print('Error setting visibility: $e');
      return false;
    }
  }

  // Hierarchy Methods
  Future<Map<String, dynamic>?> getViewById(String viewId) async {
    try {
      final result = await _channel.invokeMethod('getViewById', {
        'viewId': viewId,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting view: $e');
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
      print('Error getting children: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRootView() async {
    try {
      final result = await _channel.invokeMethod('getRootView');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting root view: $e');
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