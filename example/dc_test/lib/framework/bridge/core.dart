import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef EventCallback = void Function(String type, dynamic data);

class Core {
  static const MethodChannel _channel =
      MethodChannel('com.dcmaui.framework'); // Match iOS channel name
  static final Map<String, EventCallback> _eventCallbacks = {};

  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    print("Received method call: ${call.method}");
    print("Arguments: ${call.arguments}");
    
    switch (call.method) {
      case 'onComponentEvent':
        final Map<String, dynamic> args = call.arguments;
        final String viewId = args['viewId'];
        final callback = _eventCallbacks[viewId];
        if (callback != null) {
            print("Handling event for view: $viewId");
            callback(
                args['type'] as String,
                args['data'],
            );
        } else {
            print("No callback found for view: $viewId");
        }
        return null;
      default:
        throw MissingPluginException();
    }
  }

  static Future<String?> createView({
    required String viewType,
    required Map<String, dynamic> properties,
    EventCallback? onEvent,
  }) async {
    try {
      final String? viewId = await _channel.invokeMethod('createView', {
        'viewType': viewType,
        'properties': properties,
      });

      if (viewId != null && onEvent != null) {
        _eventCallbacks[viewId] = onEvent;
      }

      return viewId;
    } catch (e) {
      debugPrint('Error creating view: $e');
      return null;
    }
  }

  static Future<bool> attachView(String parentId, String childId) async {
    try {
      return await _channel.invokeMethod('attachView', {
            'parentId': parentId,
            'childId': childId,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error attaching view: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getRootView() async {
    try {
      final result = await _channel.invokeMethod('getRootView');
      if (result == null) return null;

      // Explicitly cast the result
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      debugPrint('Error getting root view: $e');
      return null;
    }
  }

  static Future<bool> deleteView(String viewId) async {
    try {
      _eventCallbacks.remove(viewId);
      return await _channel.invokeMethod('deleteView', {
            'viewId': viewId,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error deleting view: $e');
      return false;
    }
  }
}


// test