import 'dart:async';
import 'package:flutter/foundation.dart';

/// Global state manager for components and hooks
class GlobalStateManager {
  // Singleton instance
  static final GlobalStateManager _instance = GlobalStateManager._internal();
  static GlobalStateManager get instance => _instance;

  // Private constructor
  GlobalStateManager._internal();

  // Global state store organized by component ID
  final Map<String, Map<String, dynamic>> _globalState = {};

  // Event handlers by viewId and eventName
  final Map<String, Map<String, Function>> _eventHandlers = {};

  // State change listeners
  final Map<String, Map<String, List<Function>>> _stateListeners = {};

  // Memo cache for hooks
  final Map<String, Map<String, _MemoData>> _memoCache = {};

  // Initialize state for a component
  void initializeState(String componentId, Map<String, dynamic> initialState) {
    _globalState[componentId] = initialState;
  }

  // Get state value
  T? getState<T>(String componentId, String key, T defaultValue) {
    if (!_globalState.containsKey(componentId)) {
      return defaultValue;
    }

    if (!_globalState[componentId]!.containsKey(key)) {
      return defaultValue;
    }

    final value = _globalState[componentId]![key];
    if (value is T) {
      return value;
    }

    return defaultValue;
  }

  // Set state value
  void setState<T>(String componentId, String key, T value) {
    if (!_globalState.containsKey(componentId)) {
      _globalState[componentId] = {};
    }

    final oldValue = _globalState[componentId]![key];
    _globalState[componentId]![key] = value;

    // Notify listeners if value changed
    if (oldValue != value) {
      _notifyStateListeners(componentId, key, value);
    }
  }

  // Clean up state
  void cleanupState(String componentId) {
    _globalState.remove(componentId);
    _stateListeners.remove(componentId);
    _memoCache.remove(componentId);
  }

  // Get a memoized value
  T memoize<T>(String componentId, String key, T Function() factory,
      List<String> dependencies) {
    if (!_memoCache.containsKey(componentId)) {
      _memoCache[componentId] = {};
    }

    final cache = _memoCache[componentId]!;
    final memoData = cache[key];

    // If no memo data exists, or dependencies changed, recalculate
    if (memoData == null ||
        !_areDependenciesEqual(memoData.dependencies, dependencies)) {
      final T value = factory();
      cache[key] = _MemoData<T>(value, dependencies);
      return value;
    }

    return memoData.value as T;
  }

  // Register event handler
  void registerEventHandler(String viewId, String eventName, Function handler) {
    // Normalize event name to React Native convention
    final normalizedEventName = _normalizeEventName(eventName);

    debugPrint(
        'GlobalStateManager: Registering event handler for $normalizedEventName on view $viewId');

    if (!_eventHandlers.containsKey(viewId)) {
      _eventHandlers[viewId] = {};
    }

    _eventHandlers[viewId]![normalizedEventName] = handler;
  }

  // Normalize event name to be consistent with React Native conventions
  String _normalizeEventName(String eventName) {
    if (eventName.startsWith('on')) {
      return eventName;
    }

    return 'on${eventName.substring(0, 1).toUpperCase()}${eventName.substring(1)}';
  }

  // Get event handler
  Function? getEventHandler(String viewId, String eventName) {
    if (!_eventHandlers.containsKey(viewId)) {
      return null;
    }

    // Try exact match first
    if (_eventHandlers[viewId]!.containsKey(eventName)) {
      return _adaptHandlerWithParams(_eventHandlers[viewId]![eventName]!);
    }

    // Try normalized version if exact match fails
    final normalizedEventName = _normalizeEventName(eventName);
    if (_eventHandlers[viewId]!.containsKey(normalizedEventName)) {
      return _adaptHandlerWithParams(
          _eventHandlers[viewId]![normalizedEventName]!);
    }

    // Handle common event name variations
    if (eventName == 'onChange' &&
        _eventHandlers[viewId]!.containsKey('onValueChange')) {
      return _adaptHandlerWithParams(_eventHandlers[viewId]!['onValueChange']!);
    }

    if (eventName == 'onValueChange' &&
        _eventHandlers[viewId]!.containsKey('onChange')) {
      return _adaptHandlerWithParams(_eventHandlers[viewId]!['onChange']!);
    }

    return null;
  }

  // CRITICAL FIX: Adapt handler to accept any parameter values
  Function _adaptHandlerWithParams(Function handler) {
    return (dynamic param) {
      try {
        // Check the number of parameters the handler expects
        final runtimeType = handler.runtimeType.toString();

        // Handler takes no parameters
        if (runtimeType.contains('() =>')) {
          debugPrint('GlobalStateManager: Calling handler with no parameters');
          return handler();
        }

        // Handler takes one parameter
        if (runtimeType.contains('(dynamic) =>')) {
          debugPrint('GlobalStateManager: Calling handler with parameter');
          if (param is Map && param.containsKey('value')) {
            // Extract 'value' field for handlers expecting a simple value
            return handler(param['value']);
          } else {
            // Pass the map or value directly
            return handler(param);
          }
        }

        // Default case - try to call the handler with the parameter
        // This might still fail if the handler expects specific parameter types
        debugPrint('GlobalStateManager: Calling handler with raw parameter');
        return handler(param);
      } catch (e) {
        // If all attempts fail, just call the handler without parameters
        debugPrint(
            'GlobalStateManager: Error calling handler: $e, trying without parameters');
        try {
          return handler();
        } catch (e2) {
          debugPrint('GlobalStateManager: Failed to call handler: $e2');
        }
      }
    };
  }

  // Add state listener
  void addStateListener(String componentId, String key, Function listener) {
    if (!_stateListeners.containsKey(componentId)) {
      _stateListeners[componentId] = {};
    }

    if (!_stateListeners[componentId]!.containsKey(key)) {
      _stateListeners[componentId]![key] = [];
    }

    _stateListeners[componentId]![key]!.add(listener);
  }

  // Remove state listener
  void removeStateListener(String componentId, String key, Function listener) {
    if (!_stateListeners.containsKey(componentId) ||
        !_stateListeners[componentId]!.containsKey(key)) {
      return;
    }

    _stateListeners[componentId]![key]!.remove(listener);
  }

  // Notify state listeners
  void _notifyStateListeners(String componentId, String key, dynamic value) {
    if (!_stateListeners.containsKey(componentId) ||
        !_stateListeners[componentId]!.containsKey(key)) {
      return;
    }

    for (final listener in _stateListeners[componentId]![key]!) {
      try {
        listener(value);
      } catch (e) {
        debugPrint('GlobalStateManager: Error in state listener: $e');
      }
    }
  }

  // Compare dependencies for memo
  bool _areDependenciesEqual(List<dynamic>? a, List<dynamic>? b) {
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}

/// Class for storing memoized data with dependencies
class _MemoData<T> {
  final T value;
  final List<dynamic> dependencies;

  _MemoData(this.value, this.dependencies);
}
