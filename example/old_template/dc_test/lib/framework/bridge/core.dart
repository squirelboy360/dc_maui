import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef EventCallback = void Function(String type, dynamic data);
typedef StateChangeCallback<T> = void Function(T newValue);

class Core {
  static const MethodChannel _channel =
      MethodChannel('com.dcmaui.framework'); // Match iOS channel name
  static final Map<String, EventCallback> _eventCallbacks = {};
  static final Map<String, Map<String, dynamic>> _viewStates = {};
  static final Map<String, List<String>> _stateConsumers = {};

  // Store observers for state changes
  static final Map<String, List<Function()>> _stateObservers = {};

  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles method calls from native side
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    print("Received method call: ${call.method}");
    print("Arguments: ${call.arguments}");

    switch (call.method) {
      case 'onComponentEvent':
        final Map<String, dynamic> args = call.arguments;
        final String viewId = args['viewId'];
        final callback = _eventCallbacks[viewId];
        if (callback != null) {
          print("Handling event for view: $viewId");
          callback(
            args['type'] as String,
            args['data'],
          );
        } else {
          print("No callback found for view: $viewId");
        }
        return null;
      case 'onStateChange':
        final Map<String, dynamic> args = call.arguments;
        final String stateKey = args['stateKey'];
        final dynamic newValue = args['value'];
        _handleStateChange(stateKey, newValue);
        return null;
      case 'onLifecycleHook':
        // Handle component lifecycle events
        return null;
      case 'requestItem':
        // Handle item request from virtualized list
        final Map<String, dynamic> args = call.arguments;
        final String listViewId = args['listViewId'];
        final int index = args['index'];
        _handleItemRequest(listViewId, index);
        return null;
      default:
        throw MissingPluginException();
    }
  }

  /// Processes state changes and notifies consumers
  static void _handleStateChange(String stateKey, dynamic newValue) {
    // Notify all consumers of the state change
    final consumers = _stateConsumers[stateKey] ?? [];
    for (final viewId in consumers) {
      if (_viewStates.containsKey(viewId)) {
        // Update the state
        _viewStates[viewId]![stateKey] = newValue;

        // Notify the native side about the state change
        _updateViewState(viewId, {stateKey: newValue});
      }
    }

    // Notify observers
    final observers = _stateObservers[stateKey] ?? [];
    for (final callback in observers) {
      callback();
    }
  }

  /// Creates a new native view with specified properties
  static Future<String?> createView({
    required String viewType,
    required Map<String, dynamic> properties,
    EventCallback? onEvent,
    List<String>? children,
    Map<String, dynamic>? initialState,
  }) async {
    try {
      final Map<String, dynamic> props = {...properties};

      // Add children IDs to properties if provided
      if (children != null && children.isNotEmpty) {
        props['children'] = children;
      }

      // Add initial state if provided
      if (initialState != null && initialState.isNotEmpty) {
        props['initialState'] = initialState;
      }

      final String? viewId = await _channel.invokeMethod('createView', {
        'viewType': viewType,
        'properties': props,
      });

      if (viewId != null) {
        if (onEvent != null) {
          _eventCallbacks[viewId] = onEvent;
        }

        // Store initial state
        if (initialState != null) {
          _viewStates[viewId] = Map.from(initialState);
        }
      }

      return viewId;
    } catch (e) {
      debugPrint('Error creating view: $e');
      return null;
    }
  }

  /// Attaches a child view to a parent view
  static Future<bool> attachView(String parentId, String childId) async {
    try {
      return await _channel.invokeMethod('attachView', {
            'parentId': parentId,
            'childId': childId,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error attaching view: $e');
      return false;
    }
  }

  /// Returns information about the root view
  static Future<Map<String, dynamic>?> getRootView() async {
    try {
      final result = await _channel.invokeMethod('getRootView');
      if (result == null) return null;

      // Explicitly cast the result
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      debugPrint('Error getting root view: $e');
      return null;
    }
  }

  /// Completely removes a view from native side
  static Future<bool> deleteView(String viewId) async {
    try {
      _eventCallbacks.remove(viewId);
      _viewStates.remove(viewId);

      // Remove this view from state consumers
      _stateConsumers.forEach((stateKey, consumers) {
        consumers.remove(viewId);
      });

      return await _channel.invokeMethod('deleteView', {
            'viewId': viewId,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error deleting view: $e');
      return false;
    }
  }

  /// Registers a component as a consumer of a state value
  static T registerState<T>(String viewId, String stateKey, T initialValue) {
    // Create state entry if it doesn't exist
    _viewStates.putIfAbsent(viewId, () => {});

    // Register this view as a consumer of the state
    _stateConsumers.putIfAbsent(stateKey, () => []).add(viewId);

    // Initialize the state if not already set
    if (!_viewStates[viewId]!.containsKey(stateKey)) {
      _viewStates[viewId]![stateKey] = initialValue;
    }

    return _viewStates[viewId]![stateKey] as T;
  }

  /// Updates a state value and notifies all consumers
  static void setState<T>(String stateKey, T newValue) {
    // Update state on native side
    _channel.invokeMethod('setState', {
      'stateKey': stateKey,
      'value': newValue,
    });
  }

  /// Updates state values for a specific view
  static Future<bool> _updateViewState(
      String viewId, Map<String, dynamic> state) async {
    try {
      return await _channel.invokeMethod('updateViewState', {
            'viewId': viewId,
            'state': state,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error updating view state: $e');
      return false;
    }
  }

  /// Retrieves specific state values for a view
  static Future<Map<String, dynamic>?> getState(
      String viewId, List<String> keys) async {
    try {
      final result = await _channel.invokeMethod('getState', {
        'viewId': viewId,
        'keys': keys,
      });
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('Error getting state: $e');
      return null;
    }
  }

  /// Removes a child from parent without destroying it
  static Future<bool> detachView(String parentId, String childId) async {
    try {
      return await _channel.invokeMethod('detachView', {
            'parentId': parentId,
            'childId': childId,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error detaching view: $e');
      return false;
    }
  }

  /// Returns list of child view IDs for a parent
  static Future<List<String>> getChildrenIds(String viewId) async {
    try {
      final result = await _channel.invokeMethod('getChildrenIds', {
        'viewId': viewId,
      });
      if (result == null) return [];
      return List<String>.from(result);
    } catch (e) {
      debugPrint('Error getting children IDs: $e');
      return [];
    }
  }

  /// Registers for specific event types from a view
  static Future<bool> addEventListener(String viewId, String eventType,
      Function(Map<String, dynamic>) callback) async {
    try {
      _eventCallbacks["${viewId}_${eventType}"] = (type, data) {
        if (type == eventType) {
          callback(data);
        }
      };

      return await _channel.invokeMethod('addEventListener', {
            'viewId': viewId,
            'eventType': eventType,
          }) ??
          false;
    } catch (e) {
      debugPrint('Error adding event listener: $e');
      return false;
    }
  }

  /// Helper to find a state value in all views
  static dynamic _findStateValue(String stateKey) {
    for (var entry in _viewStates.entries) {
      if (entry.value.containsKey(stateKey)) {
        return entry.value[stateKey];
      }
    }
    return null;
  }

  static Future<dynamic> invokeMethod(String method,
      [dynamic arguments]) async {
    try {
      debugPrint('Invoking method: $method with args: $arguments');
      final result = await _channel.invokeMethod(method, arguments);
      debugPrint('Method result: $result');
      return result;
    } catch (e) {
      debugPrint('Error invoking method $method: $e');

      // Add special handling for ListView methods
      if (method == 'setItem' ||
          method == 'scrollToIndex' ||
          method == 'refreshData') {
        debugPrint('Using fallback behavior for ListView method: $method');

        // Return a default value to avoid null exceptions
        switch (method) {
          case 'setItem':
          case 'scrollToIndex':
          case 'refreshData':
            return true;
          default:
            return null;
        }
      }

      return null;
    }
  }

  // Handle on-demand item rendering requests from the native side
  static void _handleItemRequest(String listViewId, int index) {
    final callback = _eventCallbacks[listViewId];
    if (callback != null) {
      callback('requestItem', {'index': index});
    }
  }
}

/// Reactive state wrapper for declarative state management
class StateValue<T> {
  /// Initial value for this state
  final T initialValue;
  String? _stateKey;

  StateValue(this.initialValue) {
    _stateKey = 'state_${identityHashCode(this)}';
  }

  /// Register a component as consumer of this state
  T register(String viewId) {
    return Core.registerState(viewId, _stateKey!, initialValue);
  }

  /// Update this state value (propagates to all consumers)
  void setValue(T newValue) {
    if (_stateKey != null) {
      Core.setState(_stateKey!, newValue);
    }
  }

  /// Get the current value of this state
  T getValue() {
    // Attempt to retrieve the latest value from global state
    var globalState = Core._findStateValue(_stateKey!);
    return globalState ?? initialValue;
  }

  /// Register a callback for when this state changes
  void addObserver(Function() callback) {
    if (_stateKey != null) {
      Core._stateObservers[_stateKey!] = Core._stateObservers[_stateKey!] ?? [];
      Core._stateObservers[_stateKey!]!.add(callback);
    }
  }
}
