import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/hooks/base_hook.dart';
import 'package:dc_test/templating/framework/utility/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// Hook-like state management for function components
class UseState<T> extends BaseHook {
  final String _stateKey;
  final T _initialValue;
  late T _currentValue;
  String? _componentId;

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
  UseState(String key, T initialValue,
      {String? componentId, Component? component})
      : _stateKey = key,
        _initialValue = initialValue,
        super('state_$key') {
    if (component != null) {
      registerComponent(component);
      _componentId = component.componentId;
    } else {
      _componentId = componentId ?? 'global_${key}_${identityHashCode(key)}';
    }

    // Initialize in the state manager
    _currentValue = GlobalStateManager.instance
            .getState<T>(_componentId!, _stateKey, _initialValue) ??
        _initialValue;

    GlobalStateManager.instance
        .initializeState(_componentId!, {_stateKey: _currentValue});
  }

  /// Get the current state value
  T get value =>
      GlobalStateManager.instance
          .getState<T>(_componentId!, _stateKey, _currentValue) ??
      _currentValue;

  /// Set a new state value
  set value(T newValue) {
    if (_currentValue != newValue) {
      _currentValue = newValue;
      GlobalStateManager.instance.setState(_componentId!, _stateKey, newValue);

      // Trigger component update if registered
      triggerUpdate();

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
  @override
  void dispose() {
    GlobalStateManager.instance.cleanupState(_componentId!);
  }
}
