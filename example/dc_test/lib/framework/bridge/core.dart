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

  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

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
      default:
        throw MissingPluginException();
    }
  }

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
  }

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
  
  // State registration methods
  
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
  
  static void setState<T>(String stateKey, T newValue) {
    // Update state on native side
    _channel.invokeMethod('setState', {
      'stateKey': stateKey,
      'value': newValue,
    });
  }

  static Future<bool> _updateViewState(String viewId, Map<String, dynamic> state) async {
    try {
      return await _channel.invokeMethod('updateViewState', {
        'viewId': viewId,
        'state': state,
      }) ?? false;
    } catch (e) {
      debugPrint('Error updating view state: $e');
      return false;
    }
  }
}

// State value wrapper for hooks-like API
class StateValue<T> {
  final T initialValue;
  String? _stateKey;
  
  StateValue(this.initialValue) {
    _stateKey = 'state_${identityHashCode(this)}';
  }
  
  T register(String viewId) {
    return Core.registerState(viewId, _stateKey!, initialValue);
  }
  
  void setValue(T newValue) {
    if (_stateKey != null) {
      Core.setState(_stateKey!, newValue);
    }
  }
}
