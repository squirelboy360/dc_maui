import 'package:flutter/foundation.dart';

/// Event bus for component system-wide notifications
class ComponentEventBus {
  static final ComponentEventBus _instance = ComponentEventBus._internal();
  static ComponentEventBus get instance => _instance;

  ComponentEventBus._internal();

  // General rebuild notification
  Function? onRebuild;

  // Map of specific event listeners
  final Map<String, List<Function>> _eventListeners = {};

  /// Notify all listeners of a rebuild event
  void notifyRebuild() {
    if (kDebugMode) {
      print('ComponentEventBus: Notifying rebuild');
    }
    onRebuild?.call();
  }

  /// Subscribe to a named event
  void subscribe(String eventName, Function callback) {
    if (!_eventListeners.containsKey(eventName)) {
      _eventListeners[eventName] = [];
    }
    _eventListeners[eventName]!.add(callback);
  }

  /// Unsubscribe from a named event
  void unsubscribe(String eventName, Function callback) {
    if (_eventListeners.containsKey(eventName)) {
      _eventListeners[eventName]!.remove(callback);
    }
  }

  /// Publish a named event with optional data
  void publish(String eventName, [dynamic data]) {
    if (kDebugMode) {
      print('ComponentEventBus: Publishing event $eventName with data: $data');
    }

    if (_eventListeners.containsKey(eventName)) {
      for (var listener in _eventListeners[eventName]!) {
        if (data != null) {
          if (listener is Function(dynamic)) {
            listener(data);
          } else {
            listener();
          }
        } else {
          listener();
        }
      }
    }
  }
}
