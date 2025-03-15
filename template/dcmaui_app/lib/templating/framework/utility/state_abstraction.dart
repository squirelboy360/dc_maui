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

  // Store an individual state value with change notification
  void setState(String componentId, String key, dynamic value) {
    if (!_stateStore.containsKey(componentId)) {
      _stateStore[componentId] = {};
    }

    final currentValue = _stateStore[componentId]![key];
    if (currentValue != value) {
      // Only update if the value has changed
      _stateStore[componentId]![key] = value;

      // Notify listeners
      final listenerKey = "$componentId:$key";
      if (_stateListeners.containsKey(listenerKey)) {
        for (final listener in _stateListeners[listenerKey]!) {
          listener(value);
        }
      }

      if (kDebugMode) {
        print(
            'GlobalStateManager: State updated for $componentId.$key: $value');
      }
    }
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
  }
}
