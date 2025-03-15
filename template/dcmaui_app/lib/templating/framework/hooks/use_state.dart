import 'package:dc_test/templating/framework/utility/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// Hook-like state management for function components
class UseState<T> {
  final String _componentId;
  final String _stateKey;
  final T _initialValue;
  late T _currentValue;

  /// Create a state hook
  ///
  /// Example usage:
  /// ```dart
  /// final counterState = UseState<int>('counter', 0);
  ///
  /// // Get the current value
  /// int count = counterState.value;
  ///
  /// // Update the value
  /// counterState.value = count + 1;
  /// ```
  UseState(String key, T initialValue, {String? componentId})
      : _stateKey = key,
        _initialValue = initialValue,
        _componentId = componentId ?? 'global_${key}_${identityHashCode(key)}' {
    // Initialize in the state manager
    _currentValue = GlobalStateManager.instance
            .getState<T>(_componentId, _stateKey, _initialValue) ??
        _initialValue;

    GlobalStateManager.instance
        .initializeState(_componentId, {_stateKey: _currentValue});
  }

  /// Get the current state value
  T get value =>
      GlobalStateManager.instance
          .getState<T>(_componentId, _stateKey, _currentValue) ??
      _currentValue;

  /// Set a new state value
  set value(T newValue) {
    if (_currentValue != newValue) {
      _currentValue = newValue;
      GlobalStateManager.instance.setState(_componentId, _stateKey, newValue);
      if (kDebugMode) {
        print('UseState: Updated $_stateKey to $newValue');
      }
    }
  }

  /// Reset state to initial value
  void reset() {
    value = _initialValue;
  }

  /// Clean up this state hook
  void dispose() {
    GlobalStateManager.instance.cleanupState(_componentId);
  }
}
