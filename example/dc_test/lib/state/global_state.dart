import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('GlobalState');

// Temporary inclusion of GlobalState in Label file
class GlobalState {
  static const _channel = MethodChannel('com.dcmaui.framework');
  static final GlobalState instance = GlobalState._internal();
  
  final _state = <String, dynamic>{};
  final _subscribers = <String, Set<Function(dynamic)>>{};

  GlobalState._internal();
  factory GlobalState() => instance;

  Future<void> setState(String key, dynamic value) async {
    _state[key] = value;
    try {
      await _channel.invokeMethod('onStateChange', {
        'key': key,
        'value': value,
      });
      _notifySubscribers(key);
    } catch (e) {
      _logger.severe('Failed to update native state: $e');
    }
  }

  dynamic getState(String key) => _state[key];

  Future<bool> bind(String viewId, String key, Function(dynamic) callback) async {
    _subscribers[key] ??= {};
    _subscribers[key]!.add(callback);

    if (_state.containsKey(key)) {
      callback(_state[key]);
    }

    try {
      return await _channel.invokeMethod('bindState', {
        'viewId': viewId,
        'key': key,
      }) ?? false;
    } catch (e) {
      _logger.severe('Failed to bind native state: $e');
      return false;
    }
  }

  void unbind(String key, Function(dynamic) callback) {
    _subscribers[key]?.remove(callback);
    if (_subscribers[key]?.isEmpty ?? false) {
      _subscribers.remove(key);
    }
  }

  void _notifySubscribers(String key) {
    if (_subscribers.containsKey(key)) {
      final value = _state[key];
      for (final callback in _subscribers[key]!) {
        callback(value);
      }
    }
  }
}
