import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../low_apis/ui_apis.dart';

final _logger = Logger('GlobalState');

class GlobalState extends ChangeNotifier {
  static const _channel = MethodChannel('com.dcmaui.framework');
  static final GlobalState instance = GlobalState._internal();

  final Map<String, dynamic> _state = {};
  final NativeUIBridge _bridge = NativeUIBridge();
  final _subscribers = <String, Set<Function(dynamic)>>{};
  final _keyListeners = <String, Set<VoidCallback>>{};

  GlobalState._internal();
  factory GlobalState() => instance;

  T? get<T>(String key) => _state[key] as T?;

  Future<void> set<T>(String key, T value,
      {List<String>? affectedViews}) async {
    _state[key] = value;
    if (affectedViews != null) {
      await _bridge.invokeMethod('updateState',
          {'key': key, 'value': value, 'affectedViews': affectedViews});
    }
    _notifyKeyListeners(key);
    notifyListeners();
  }

  Future<void> setState(String key, dynamic value) async {
    _state[key] = value;
    try {
      await _channel.invokeMethod('onStateChange', {
        'key': key,
        'value': value,
      });
      _notifySubscribers(key);
      _notifyKeyListeners(key);
      notifyListeners();
    } catch (e) {
      _logger.severe('Failed to update native state: $e');
    }
  }

  dynamic getState(String key) => _state[key];

  Future<bool> bind(
      String viewId, String key, Function(dynamic) callback) async {
    _subscribers[key] ??= {};
    _subscribers[key]!.add(callback);

    if (_state.containsKey(key)) {
      callback(_state[key]);
    }

    try {
      return await _channel.invokeMethod('bindState', {
            'viewId': viewId,
            'key': key,
          }) ??
          false;
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

  void _notifyKeyListeners(String key) {
    if (_keyListeners.containsKey(key)) {
      for (final listener in _keyListeners[key]!) {
        listener();
      }
    }
  }

  // Implement state-specific listener methods that don't override ChangeNotifier
  void addStateListener(String key, VoidCallback listener) {
    _keyListeners[key] ??= {};
    _keyListeners[key]!.add(listener);
  }

  void removeStateListener(String key, VoidCallback listener) {
    _keyListeners[key]?.remove(listener);
    if (_keyListeners[key]?.isEmpty ?? false) {
      _keyListeners.remove(key);
    }
  }
}
