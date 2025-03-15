import 'package:dc_test/templating/framework/hooks/use_state.dart';
import 'package:dc_test/templating/framework/hooks/use_effect.dart';
import 'package:dc_test/templating/framework/hooks/use_reducer.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:flutter/foundation.dart';

/// Integrates hooks with the Component class
class ComponentHooks {
  final Component _component;
  final List<UseState> _stateHooks = [];
  final List<UseEffect> _effectHooks = [];

  ComponentHooks(this._component);

  /// Create a state hook bound to this component
  UseState<T> useState<T>(String key, T initialValue) {
    // Create the hook first, then assign the callback to avoid reference error
    final stateHook =
        UseState<T>(key, initialValue, componentId: _component.componentId);

    // Set the update callback after creating it
    stateHook.setUpdateCallback(() {
      // Trigger component update using the component's setState
      if (_component.mounted) {
        // Update the actual component state too
        _component.setState({key: stateHook.value});
      }
    });

    // Track for cleanup
    _stateHooks.add(stateHook);

    return stateHook;
  }

  /// Create an effect hook
  UseEffect useEffect(String name) {
    final effect = UseEffect(name);
    _effectHooks.add(effect);
    return effect;
  }

  /// Create a reducer hook
  UseReducer<S, A> useReducer<S, A>(
      String key, S initialState, S Function(S, A) reducer) {
    final hook = UseReducer<S, A>(key, initialState, reducer,
        componentId: _component.componentId);
    return hook;
  }

  /// Initialize the component's state with values from hooks
  void syncStateToComponent() {
    final state = <String, dynamic>{};

    for (final hook in _stateHooks) {
      // Use the public key getter
      final fieldName = hook.key;
      final value = hook.value;
      state[fieldName] = value;
    }

    // Update the component's state
    if (state.isNotEmpty) {
      _component.initializeState(state);
    }
  }

  /// Clean up all hooks
  void dispose() {
    // Clean up state hooks
    for (final hook in _stateHooks) {
      hook.dispose();
    }
    _stateHooks.clear();

    // Clean up effect hooks
    for (final hook in _effectHooks) {
      hook.dispose();
    }
    _effectHooks.clear();
  }
}
