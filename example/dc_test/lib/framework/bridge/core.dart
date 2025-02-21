import 'package:flutter/services.dart';

typedef EventCallback = void Function(String type, Map<String, dynamic> data);

class Core {
  static const _channel = MethodChannel('com.dcmaui.framework');

  // Internal state management
  static final Map<String, EventCallback> _eventHandlers = {};

  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onComponentEvent') {
      final args = Map<String, dynamic>.from(call.arguments);
      final viewId = args['viewId'] as String;
      final type = args['type'] as String;
      final data = Map<String, dynamic>.from(args['data'] ?? {});

      _eventHandlers[viewId]?.call(type, data);
    }
  }

  static Future<String?> createView({
    required String viewType,
    Map<String, dynamic>? properties, // Contains style, layout, AND events
    EventCallback? onEvent,
  }) async {
    try {
      final args = {
        'viewType': viewType,
        if (properties != null) 'properties': {
          ...properties,
          if (onEvent != null) 'events': {
            'onEvent': true
          }
        },
      };

      final String? viewId = await _channel.invokeMethod('createView', args);

      if (viewId != null && onEvent != null) {
        _eventHandlers[viewId] = onEvent;
      }

      return viewId;
    } on PlatformException catch (e) {
      print('Error creating view: ${e.message}');
      return null;
    }
  }

  static Future<bool> updateView(
    String viewId, {
    Map<String, dynamic>? properties, // Changed: properties includes style and layout
  }) async {
    try {
      final args = {
        'viewId': viewId,
        if (properties != null) 'properties': properties,
      };

      await _channel.invokeMethod('updateView', args);
      return true;
    } on PlatformException catch (e) {
      print('Error updating view: ${e.message}');
      return false;
    }
  }

  static Future<bool> deleteView(String viewId) async {
    try {
      await _channel.invokeMethod('deleteView', {'viewId': viewId});
      _eventHandlers.remove(viewId);
      return true;
    } on PlatformException catch (e) {
      print('Error deleting view: ${e.message}');
      return false;
    }
  }
}
