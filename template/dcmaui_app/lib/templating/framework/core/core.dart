import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Interface for communicating with the native UI layer
class MainViewCoordinatorInterface {
  // Correct channel names matching the actual Swift implementation
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');
  static const EventChannel _eventChannel =
      EventChannel('com.dcmaui.framework/events');

  static late Stream<Map<String, dynamic>> eventStream;
  static bool _initialized = false;

  // Initialize the coordinator
  static Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('DC MAUI: Setting up method channel handler');
    _channel.setMethodCallHandler(_handleMethodCall);

    debugPrint('DC MAUI: Setting up event channel listener');
    eventStream = _eventChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>((event) => Map<String, dynamic>.from(event));

    try {
      // Send initialize signal to native side
      debugPrint('DC MAUI: Calling initialize on native side');
      await _channel.invokeMethod('initialize');
      _initialized = true;
      debugPrint('DC MAUI: MainViewCoordinatorInterface initialized');
    } catch (e) {
      debugPrint('DC MAUI: ERROR initializing - $e');
      // Create root container view manually to bypass initialization
      await createRootContainer();
    }
  }

  // Create a root container view directly
  static Future<void> createRootContainer() async {
    try {
      debugPrint('DC MAUI: Creating root container view');
      await _channel.invokeMethod('createRootContainer');
    } catch (e) {
      debugPrint('DC MAUI: ERROR creating root container - $e');
    }
  }

  // Create a view on the native side
  static Future<bool> createView(
      String viewId, String viewType, Map<String, dynamic> props) async {
    try {
      // Clean the props to ensure they're serializable
      final cleanProps = _cleanPropsForSerialization(props);

      debugPrint('DC MAUI: Creating view $viewId of type $viewType');
      final result = await _channel.invokeMethod('createView', {
        'viewId': viewId,
        'viewType': viewType,
        'props': cleanProps,
      });
      debugPrint('Core: View created result: $result');
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR creating view: $e');
      debugPrint('Core: Props that failed: $props');
      return false;
    }
  }

  // Update a view's properties
  static Future<bool> updateView(
      String viewId, Map<String, dynamic> props) async {
    try {
      final cleanProps = _cleanPropsForSerialization(props);

      // Add enhanced debugging for state updates
      debugPrint('Core: Updating view $viewId with props: $cleanProps');

      final result = await _channel.invokeMethod('updateView', {
        'viewId': viewId,
        'props': cleanProps,
      });

      // Debug the result
      debugPrint('Core: View update result: $result');

      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR updating view: $e');
      return false;
    }
  }

  // Delete a view from the native side
  static Future<bool> deleteView(String viewId) async {
    try {
      final result =
          await _channel.invokeMethod('deleteView', {'viewId': viewId});
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR deleting view: $e');
      return false;
    }
  }

  // Set children relationship on native side
  static Future<bool> setChildren(
      String parentId, List<String> childIds) async {
    try {
      // Debug output to check parameter values
      debugPrint('Core: Setting children for $parentId: $childIds');

      final result = await _channel.invokeMethod('setChildren', {
        'parentId': parentId,
        'childIds': childIds, // Make sure this key matches what Swift expects
      });
      debugPrint('Core: SetChildren result: $result');
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR setting children: $e');
      // Add more detailed error information
      debugPrint(
          'Core: Parameters were: parentId=$parentId, childIds=$childIds');
      return false;
    }
  }

  // Register event listeners for a view
  static Future<bool> addEventListeners(
      String viewId, List<String> eventNames) async {
    try {
      final result = await _channel.invokeMethod('addEventListeners', {
        'viewId': viewId,
        'eventNames': eventNames,
      });
      debugPrint('Core: Added event listeners: $eventNames for view: $viewId');
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR adding event listeners: $e');
      return false;
    }
  }

  // Remove event listeners from a view
  static Future<bool> removeEventListeners(
      String viewId, List<String> eventNames) async {
    try {
      final result = await _channel.invokeMethod('removeEventListeners', {
        'viewId': viewId,
        'eventNames': eventNames,
      });
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR removing event listeners: $e');
      return false;
    }
  }

  // CRITICAL FIX: Removed simulate event method as it's not needed

  // Make logging more verbose for debugging
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint(
        'DC MAUI: Received method call: ${call.method} with args: ${call.arguments}');

    if (call.method == 'onNativeEvent') {
      final event = Map<String, dynamic>.from(call.arguments);

      // ENHANCEMENT: Request additional information about the control
      // This helps us track the control even when view IDs change
      if (event['viewId'] != null && !event.containsKey('controlType')) {
        try {
          final viewInfo = await _channel.invokeMethod('getViewInfo', {
            'viewId': event['viewId'],
          });

          if (viewInfo != null && viewInfo is Map) {
            // Add control type and other properties to event data
            if (viewInfo.containsKey('type')) {
              event['controlType'] = viewInfo['type'];
            }

            // Add control properties to event data if not already present
            if (event['data'] == null) {
              event['data'] = {};
            } else if (event['data'] is! Map) {
              event['data'] = {'value': event['data']};
            }

            // Add title, id, or other identifying information
            if (viewInfo.containsKey('title')) {
              event['data']['title'] = viewInfo['title'];
            }
            if (viewInfo.containsKey('id')) {
              event['data']['id'] = viewInfo['id'];
            }
          }
        } catch (e) {
          debugPrint('DC MAUI: Error getting view info: $e');
        }
      }

      debugPrint(
          'DC MAUI: Received native event: ${event['eventName']} for view ${event['viewId']} with data: ${event['data']}');
      return;
    } else if (call.method == 'logTree') {
      final treeData = call.arguments as String;
      debugPrint(
          '\n=== NATIVE VIEW TREE ===\n$treeData\n=====================');
      return;
    }

    return null;
  }

  // Add a method to request the native side to print its view tree
  static Future<void> logNativeViewTree() async {
    try {
      await _channel.invokeMethod('logViewTree');
    } catch (e) {
      debugPrint('DC MAUI: ERROR logging view tree - $e');
    }
  }

  // Helper method to clean props for serialization
  static Map<String, dynamic> _cleanPropsForSerialization(
      Map<String, dynamic> props) {
    final result = <String, dynamic>{};

    // Deep copy of props, removing functions which can't be serialized
    props.forEach((key, value) {
      if (value is Function) {
        // Skip functions - they'll be handled separately through event registration
      } else if (value is Map) {
        // Recursively process nested maps
        result[key] = _cleanMapForSerialization(value);
      } else if (value is List) {
        // Process lists
        result[key] = _cleanListForSerialization(value);
      } else {
        // Regular value
        result[key] = value;
      }
    });

    return result;
  }

  // Clean a map for serialization
  static Map<String, dynamic> _cleanMapForSerialization(Map value) {
    final result = <String, dynamic>{};
    value.forEach((key, val) {
      if (val is Function) {
        // Skip functions
      } else if (val is Map) {
        result[key] = _cleanMapForSerialization(val);
      } else if (val is List) {
        result[key] = _cleanListForSerialization(val);
      } else {
        result[key] = val;
      }
    });
    return result;
  }

  // Clean a list for serialization
  static List _cleanListForSerialization(List value) {
    final result = [];
    for (final item in value) {
      if (item is Function) {
        // Skip functions
      } else if (item is Map) {
        result.add(_cleanMapForSerialization(item));
      } else if (item is List) {
        result.add(_cleanListForSerialization(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }
}
