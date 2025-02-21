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
    Map<String, dynamic>? style,
    Map<String, dynamic>? events,
    EventCallback? onEvent,
  }) async {
    try {
      final args = {
        'viewType': viewType,
        if (style != null) 'style': style,
        if (events != null) 'events': events,
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
    Map<String, dynamic>? style,
    Map<String, dynamic>? layout,
    Map<String, dynamic>? state,
  }) async {
    try {
      final args = {
        'viewId': viewId,
        if (style != null) 'style': style,
        if (layout != null) 'layout': layout,
        if (state != null) 'state': state,
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
