import 'package:flutter/foundation.dart';

// Improved state management system with better isolation and change tracking
class GlobalStateManager {
  static final GlobalStateManager _instance = GlobalStateManager._internal();
  static GlobalStateManager get instance => _instance;

  // Private constructor
  GlobalStateManager._internal();

  // State storage by component ID and state key
  final Map<String, Map<String, dynamic>> _stateStore = {};

  // Track callbacks for state changes
  final Map<String, List<Function>> _stateListeners = {};

  // Track component event handlers
  final Map<String, Map<String, Function>> _eventHandlers = {};

  // Track last event timestamp to prevent rapid re-triggers
  final Map<String, int> _lastEventTime = {};

  // Track derived state dependencies
  final Map<String, Set<String>> _stateDependencies = {};

  // Store memoized values with their dependencies
  final Map<String, _MemoizedValue> _memoCache = {};

  // Track pending updates for batching
  final Map<String, Map<String, dynamic>> _pendingUpdates = {};
  bool _batchingUpdates = false;

  // Track last state values for dependency checking in memoization
  final Map<String, Map<String, dynamic>> _lastStateValues = {};

  // Store an individual state value with change notification
  void setState(String componentId, String key, dynamic value) {
    if (!_stateStore.containsKey(componentId)) {
      _stateStore[componentId] = {};
    }

    final currentValue = _stateStore[componentId]![key];
    if (!_deepEquals(currentValue, value)) {
      // Track previous value for memo dependency checking
      if (!_lastStateValues.containsKey(componentId)) {
        _lastStateValues[componentId] = {};
      }
      _lastStateValues[componentId]![key] = currentValue;

      // Only update if the value has changed
      _stateStore[componentId]![key] = value;

      if (_batchingUpdates) {
        // Queue up the update for later notification
        if (!_pendingUpdates.containsKey(componentId)) {
          _pendingUpdates[componentId] = {};
        }
        _pendingUpdates[componentId]![key] = value;
        return;
      }

      // Notify listeners
      _notifyStateChange(componentId, key, value);

      // Invalidate any memoized values that depend on this state
      _invalidateAffectedMemos(componentId, key);

      if (kDebugMode) {
        print(
            'GlobalStateManager: State updated for $componentId.$key: $value');
      }
    }
  }

  // Invalidate memoized values that depend on the changed state
  void _invalidateAffectedMemos(String componentId, String key) {
    final dependencyKey = "$componentId:$key";

    // Find all memos that depend on this state key
    final affectedMemos = <String>[];
    for (final memoId in _memoCache.keys) {
      final memo = _memoCache[memoId]!;
      if (memo.dependencies.contains(dependencyKey)) {
        affectedMemos.add(memoId);
      }
    }

    // Invalidate all affected memos
    for (final memoId in affectedMemos) {
      _memoCache[memoId]!.isValid = false;
    }
  }

  // Create a memoized value that only recalculates when dependencies change
  T memoize<T>(String componentId, String memoKey, T Function() computeFn,
      List<String> dependencies) {
    final memoId = "$componentId:$memoKey";

    // Format dependencies to add component ID
    final formattedDeps = dependencies.map((dep) {
      if (dep.contains(':')) return dep; // Already formatted
      return "$componentId:$dep"; // Add component ID
    }).toSet();

    // Check if this memo exists and is valid
    if (_memoCache.containsKey(memoId) && _memoCache[memoId]!.isValid) {
      return _memoCache[memoId]!.value as T;
    }

    // Compute new value
    final value = computeFn();

    // Store in cache
    _memoCache[memoId] = _MemoizedValue(
      value: value,
      dependencies: formattedDeps,
      isValid: true,
    );

    return value;
  }

  // Clear memoization cache for a component
  void clearMemos(String componentId) {
    final toRemove = <String>[];
    _memoCache.forEach((key, value) {
      if (key.startsWith("$componentId:")) {
        toRemove.add(key);
      }
    });

    for (final key in toRemove) {
      _memoCache.remove(key);
    }
  }

  // Notify listeners about a state change
  void _notifyStateChange(String componentId, String key, dynamic value) {
    // Direct listeners on this specific state key
    final listenerKey = "$componentId:$key";
    if (_stateListeners.containsKey(listenerKey)) {
      for (final listener in _stateListeners[listenerKey]!) {
        listener(value);
      }
    }

    // Notify any derived state that depends on this key
    final dependentKey = "$componentId:$key";
    if (_stateDependencies.containsKey(dependentKey)) {
      for (final derivedKey in _stateDependencies[dependentKey]!) {
        final parts = derivedKey.split(':');
        if (parts.length == 2) {
          final derivedComponentId = parts[0];
          final derivedStateKey = parts[1];

          // Recalculate derived state - this would need implementation
          // of a derivation function registry
        }
      }
    }
  }

  // Start batching state updates
  void beginBatch() {
    _batchingUpdates = true;
    _pendingUpdates.clear();
  }

  // End batching and notify all listeners of changed state
  void commitBatch() {
    _batchingUpdates = false;

    // Notify listeners for all pending updates
    for (final componentId in _pendingUpdates.keys) {
      for (final key in _pendingUpdates[componentId]!.keys) {
        final value = _pendingUpdates[componentId]![key];
        _notifyStateChange(componentId, key, value);
      }
    }

    _pendingUpdates.clear();
  }

  // Deep equality check for better object comparison
  bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;

    // Handle collections
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    } else if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }

    // Regular value comparison
    return a == b;
  }

  // Get an individual state value
  T? getState<T>(String componentId, String key, [T? defaultValue]) {
    if (!_stateStore.containsKey(componentId)) {
      return defaultValue;
    }
    return _stateStore[componentId]![key] as T? ?? defaultValue;
  }

  // Initialize a component's state
  void initializeState(String componentId, Map<String, dynamic> initialState) {
    if (!_stateStore.containsKey(componentId)) {
      _stateStore[componentId] = Map<String, dynamic>.from(initialState);
    } else {
      // Merge with existing state
      _stateStore[componentId]!.addAll(initialState);
    }
  }

  // Listen for changes to a specific state key
  void addStateListener(
      String componentId, String key, Function(dynamic) listener) {
    final listenerKey = "$componentId:$key";
    if (!_stateListeners.containsKey(listenerKey)) {
      _stateListeners[listenerKey] = [];
    }
    _stateListeners[listenerKey]!.add(listener);
  }

  // Remove a state listener
  void removeStateListener(
      String componentId, String key, Function(dynamic) listener) {
    final listenerKey = "$componentId:$key";
    if (_stateListeners.containsKey(listenerKey)) {
      _stateListeners[listenerKey]!.remove(listener);
    }
  }

  // Register an event handler with debouncing to prevent double-firing
  void registerEventHandler(
      String componentId, String eventName, Function handler) {
    if (!_eventHandlers.containsKey(componentId)) {
      _eventHandlers[componentId] = {};
    }

    _eventHandlers[componentId]![eventName] = (args) {
      // Simple debouncing - prevent the same event from firing twice in 300ms
      final now = DateTime.now().millisecondsSinceEpoch;
      final handlerId = "$componentId:$eventName";
      final lastTime = _lastEventTime[handlerId] ?? 0;

      if (now - lastTime > 300) {
        // 300ms debounce
        _lastEventTime[handlerId] = now;
        handler(args);
      } else if (kDebugMode) {
        print(
            'GlobalStateManager: Debounced event $eventName for $componentId');
      }
    };
  }

  // Get an event handler
  Function? getEventHandler(String componentId, String eventName) {
    return _eventHandlers[componentId]?[eventName];
  }

  // Clean up a component's state
  void cleanupState(String componentId) {
    _stateStore.remove(componentId);

    // Clean up listeners
    final keysToRemove = _stateListeners.keys
        .where((key) => key.startsWith("$componentId:"))
        .toList();
    for (final key in keysToRemove) {
      _stateListeners.remove(key);
    }

    // Clean up event handlers
    _eventHandlers.remove(componentId);

    // Clean up event timestamps
    final timeKeysToRemove = _lastEventTime.keys
        .where((key) => key.startsWith("$componentId:"))
        .toList();
    for (final key in timeKeysToRemove) {
      _lastEventTime.remove(key);
    }

    // Clean up derived state dependencies
    final depKeysToRemove = _stateDependencies.keys
        .where((key) => key.startsWith("$componentId:"))
        .toList();
    for (final key in depKeysToRemove) {
      _stateDependencies.remove(key);
    }

    // Clean up memoization cache
    clearMemos(componentId);

    // Clean up last state values
    _lastStateValues.remove(componentId);
  }

  // Register a derived state that depends on other state
  void registerDerivedState(
      String componentId, String derivedKey, List<String> dependencies) {
    for (final dep in dependencies) {
      final depParts = dep.split('.');
      if (depParts.length != 2) continue;

      final depComponentId = depParts[0];
      final depStateKey = depParts[1];

      final fullDepKey = "$depComponentId:$depStateKey";
      if (!_stateDependencies.containsKey(fullDepKey)) {
        _stateDependencies[fullDepKey] = {};
      }

      _stateDependencies[fullDepKey]!.add("$componentId:$derivedKey");
    }
  }

  // Create a selector function that efficiently computes derived state
  T Function() createSelector<T>(String componentId, String derivedKey,
      T Function() selectorFn, List<String> dependencies) {
    // Register dependencies for this derived state
    registerDerivedState(componentId, derivedKey, dependencies);

    // Cache for memoization
    T? lastResult;
    bool initialized = false;

    return () {
      if (!initialized) {
        lastResult = selectorFn();
        initialized = true;
        return lastResult as T;
      }

      // Check if any dependencies have changed
      bool dependenciesChanged = false;
      
      // Implement dependency tracking
      for (final dep in dependencies) {
        final depParts = dep.split('.');
        if (depParts.length != 2) continue;
        
        final depComponentId = depParts[0];
        final depStateKey = depParts[1];
        
        // Check if this dependency has changed since last check
        if (_lastStateValues.containsKey(depComponentId) && 
            _lastStateValues[depComponentId]!.containsKey(depStateKey)) {
          dependenciesChanged = true;
          break;
        }
      }

      if (dependenciesChanged) {
        lastResult = selectorFn();
      }

      return lastResult as T;
    };
  }
}

// Helper class for storing memoized values with dependency tracking
class _MemoizedValue {
  final dynamic value;
  final Set<String> dependencies;
  bool isValid;

  _MemoizedValue({
    required this.value,
    required this.dependencies,
    this.isValid = true,
  });
}
