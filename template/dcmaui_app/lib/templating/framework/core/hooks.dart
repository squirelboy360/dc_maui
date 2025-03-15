import 'package:flutter/foundation.dart';

/// Hook system similar to React Hooks
class HookContext {
  static int _currentComponent = -1;
  static final List<_ComponentHookState> _componentStates = [];

  static void beginHooks(int componentId) {
    _currentComponent = componentId;

    // Ensure we have a state object for this component
    while (_componentStates.length <= componentId) {
      _componentStates.add(_ComponentHookState());
    }

    // Reset hook index for this render pass
    _componentStates[componentId].currentHookIndex = 0;
  }

  static void endHooks() {
    _currentComponent = -1;
  }

  static T _getHookState<T>(T Function() initialState) {
    if (_currentComponent < 0) {
      throw Exception('Hooks can only be called inside function components');
    }

    final componentState = _componentStates[_currentComponent];
    final hookIndex = componentState.currentHookIndex++;

    // Initialize hook state if needed
    while (componentState.hookStates.length <= hookIndex) {
      componentState.hookStates.add(initialState());
    }

    return componentState.hookStates[hookIndex] as T;
  }

  static void _setHookState<T>(int hookIndex, T newState) {
    if (_currentComponent < 0) {
      throw Exception(
          'Cannot update hook state outside of a function component');
    }

    final componentState = _componentStates[_currentComponent];
    componentState.hookStates[hookIndex] = newState;

    // Trigger re-render
    componentState.updateCallback?.call();
  }

  static void registerUpdateCallback(int componentId, VoidCallback callback) {
    while (_componentStates.length <= componentId) {
      _componentStates.add(_ComponentHookState());
    }
    _componentStates[componentId].updateCallback = callback;
  }

  static void disposeComponent(int componentId) {
    if (componentId < _componentStates.length) {
      final componentState = _componentStates[componentId];

      // Run cleanup functions
      for (var effect in componentState.effectCleanupFunctions) {
        if (effect != null) {
          effect();
        }
      }

      // Reset state
      componentState.hookStates.clear();
      componentState.currentHookIndex = 0;
      componentState.effectCleanupFunctions.clear();
      componentState.updateCallback = null;
    }
  }
}

class _ComponentHookState {
  int currentHookIndex = 0;
  final List<dynamic> hookStates = [];
  final List<Function?> effectCleanupFunctions = [];
  VoidCallback? updateCallback;
}

/// STATE HOOKS

/// useState hook - returns [value, setter]
List<dynamic> useState<T>(T initialValue) {
  final hookIndex = HookContext
      ._componentStates[HookContext._currentComponent].currentHookIndex;

  final state = HookContext._getHookState<T>(() => initialValue);

  setState(T newValue) {
    HookContext._setHookState<T>(hookIndex, newValue);
  }

  return [state, setState];
}

/// useReducer hook - returns [state, dispatch]
List<dynamic> useReducer<S, A>(
    S Function(S state, A action) reducer, S initialState) {
  final hookIndex = HookContext
      ._componentStates[HookContext._currentComponent].currentHookIndex;

  final state = HookContext._getHookState<S>(() => initialState);

  dispatch(A action) {
    final newState = reducer(state, action);
    HookContext._setHookState<S>(hookIndex, newState);
  }

  return [state, dispatch];
}

/// EFFECT HOOKS

/// useEffect hook
void useEffect(Function() effect, [List<dynamic>? dependencies]) {
  final componentState =
      HookContext._componentStates[HookContext._currentComponent];
  final hookIndex = componentState.currentHookIndex++;

  // Get previous dependencies
  final prevDeps = hookIndex < componentState.hookStates.length
      ? componentState.hookStates[hookIndex] as List<dynamic>?
      : null;

  // Check if dependencies have changed
  bool shouldRun = prevDeps == null;
  if (!shouldRun && dependencies != null) {
    shouldRun = !_areListsEqual(prevDeps, dependencies);
  }

  // Store new dependencies
  if (hookIndex >= componentState.hookStates.length) {
    componentState.hookStates.add(dependencies);
  } else {
    componentState.hookStates[hookIndex] = dependencies;
  }

  // Ensure we have a slot for cleanup function
  while (componentState.effectCleanupFunctions.length <= hookIndex) {
    componentState.effectCleanupFunctions.add(null);
  }

  if (shouldRun) {
    // Run cleanup from last effect
    final cleanup = componentState.effectCleanupFunctions[hookIndex];
    if (cleanup != null) {
      cleanup();
    }

    // Run effect and store cleanup
    final cleanupFn = effect();
    componentState.effectCleanupFunctions[hookIndex] = cleanupFn;
  }
}

/// useMemo hook
T useMemo<T>(T Function() factory, List<dynamic> dependencies) {
  final hookIndex = HookContext
      ._componentStates[HookContext._currentComponent].currentHookIndex++;
  final componentState =
      HookContext._componentStates[HookContext._currentComponent];

  final stored = hookIndex < componentState.hookStates.length
      ? componentState.hookStates[hookIndex] as _MemoizedValue<T>
      : null;

  if (stored == null || !_areListsEqual(stored.dependencies, dependencies)) {
    final newValue = _MemoizedValue<T>(factory(), dependencies);
    if (hookIndex >= componentState.hookStates.length) {
      componentState.hookStates.add(newValue);
    } else {
      componentState.hookStates[hookIndex] = newValue;
    }
    return newValue.value;
  }

  return stored.value;
}

/// useCallback hook
Function useCallback(Function callback, List<dynamic> dependencies) {
  return useMemo(() => callback, dependencies);
}

/// Helper class for memoized values
class _MemoizedValue<T> {
  final T value;
  final List<dynamic> dependencies;

  _MemoizedValue(this.value, this.dependencies);
}

/// Helper function to compare dependency lists
bool _areListsEqual(List<dynamic> a, List<dynamic> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
