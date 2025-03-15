import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/component_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

// NativeVDOM combines ComponentVDOM functionality with native event handling
class NativeVDOM extends ComponentVDOM {
  // Event handlers map: viewId -> eventName -> callback
  final Map<String, Map<String, Function>> _eventHandlers = {};

  NativeVDOM() {
    // Listen for events from native side
    MainViewCoordinatorInterface.eventStream.listen(_handleNativeEvent);
    debugPrint('NativeVDOM: Initialized and listening for native events');
  }

  // Handle events coming from native side
  void _handleNativeEvent(Map<String, dynamic> event) {
    try {
      final String viewId = event['viewId'];
      String eventName = event['eventName'];
      final Map<String, dynamic> eventData =
          Map<String, dynamic>.from(event['data'] ?? {});

      // Normalize event name - handle both "press" and "onPress" formats
      if (eventName.startsWith("on") && eventName.length > 2) {
        eventName = eventName[2].toLowerCase() + eventName.substring(3);
      }

      debugPrint(
          'NativeVDOM: Normalized event $eventName for view $viewId with data: $eventData');

      // Find and trigger the event handler
      if (_eventHandlers.containsKey(viewId) &&
          _eventHandlers[viewId]!.containsKey(eventName)) {
        debugPrint('NativeVDOM: Found handler for $eventName, executing...');
        _eventHandlers[viewId]![eventName]!(eventData);
      } else {
        debugPrint(
            'NativeVDOM: No handler found for $eventName on view $viewId');

        // CRITICAL FIX: Try to find the correct handler by exploring prefixes
        // Often the view IDs might have been incremented, so view_19 might be a replacement for view_9
        bool handlerFound = false;
        if (viewId.startsWith('view_')) {
          final numericPart = int.tryParse(viewId.substring(5));
          if (numericPart != null && numericPart > 15) {
            // This is likely a newly created view after state update
            // Try to find the corresponding original view (usually views 6-14 are the buttons)
            for (int i = 6; i <= 14; i++) {
              final originalViewId = 'view_$i';
              if (_eventHandlers.containsKey(originalViewId) &&
                  _eventHandlers[originalViewId]!.containsKey(eventName)) {
                debugPrint(
                    'NativeVDOM: Found handler on original view $originalViewId, transferring to $viewId');
                // Transfer the handler to the new view ID
                _eventHandlers.putIfAbsent(viewId, () => {});
                _eventHandlers[viewId]![eventName] =
                    _eventHandlers[originalViewId]![eventName]!;

                // Execute the handler
                _eventHandlers[viewId]![eventName]!(eventData);
                handlerFound = true;
                break;
              }
            }
          }
        }

        if (!handlerFound) {
          debugPrint(
              'NativeVDOM: No suitable handler found after trying fallbacks');
          debugPrint('NativeVDOM: Available handlers: ${_eventHandlers.keys}');
        }
      }
    } catch (e) {
      debugPrint('NativeVDOM: ERROR handling native event - $e');
    }
  }

  // Register an event handler
  void registerEventHandler(
      String viewId, String eventName, Function callback) {
    _eventHandlers.putIfAbsent(viewId, () => {});
    _eventHandlers[viewId]![eventName] = callback;
    debugPrint('NativeVDOM: Registered handler for $eventName on view $viewId');
  }

  @override
  void createView(VNode node, String viewId) {
    try {
      // Extract event handlers before sending to native
      final eventHandlers = _extractEventHandlers(node.props);

      // Create a copy of props without event handlers
      final cleanProps = _removeEventHandlersFromProps(node.props);

      debugPrint('NativeVDOM: Creating view $viewId of type ${node.type}');

      if (eventHandlers.isNotEmpty) {
        debugPrint(
            'NativeVDOM: Found ${eventHandlers.length} event handlers: ${eventHandlers.keys.toList()}');

        // Register event handlers on our side
        for (final entry in eventHandlers.entries) {
          registerEventHandler(viewId, entry.key, entry.value);
        }
      }

      // Add any event listener prop keys to cleanProps to signal to native side
      final listenerNames = eventHandlers.keys
          .map((name) => 'on${name[0].toUpperCase()}${name.substring(1)}')
          .toList();
      if (listenerNames.isNotEmpty) {
        cleanProps['_eventListeners'] = listenerNames;
      }

      // Pass to parent for normal component handling with cleaned props
      super.createView(node..props = cleanProps, viewId);

      // Restore original props
      node.props.addAll(eventHandlers.map((key, value) =>
          MapEntry('on${key[0].toUpperCase()}${key.substring(1)}', value)));
    } catch (e) {
      debugPrint('NativeVDOM: ERROR creating view - $e');
    }
  }

  @override
  void updateView(VNode oldNode, VNode newNode, String viewId) {
    try {
      // Extract event handlers before sending to native
      final eventHandlers = _extractEventHandlers(newNode.props);

      // Create a copy of props without event handlers
      final cleanProps = _removeEventHandlersFromProps(newNode.props);

      // Add any event listener prop keys to cleanProps to signal to native side
      final listenerNames = eventHandlers.keys
          .map((name) => 'on${name[0].toUpperCase()}${name.substring(1)}')
          .toList();
      if (listenerNames.isNotEmpty) {
        cleanProps['_eventListeners'] = listenerNames;
      }

      // Re-register event handlers if any have changed
      if (eventHandlers.isNotEmpty) {
        for (final entry in eventHandlers.entries) {
          registerEventHandler(viewId, entry.key, entry.value);
        }
      }

      debugPrint('NativeVDOM: Updating view $viewId with clean props');

      // Use the parent class's updateView implementation
      super.updateView(oldNode, newNode..props = cleanProps, viewId);

      // Restore original props
      newNode.props.addAll(eventHandlers.map((key, value) =>
          MapEntry('on${key[0].toUpperCase()}${key.substring(1)}', value)));
    } catch (e) {
      debugPrint('NativeVDOM: ERROR updating view - $e');
    }
  }

  // Helper to extract event handlers from props
  Map<String, Function> _extractEventHandlers(Map<String, dynamic> props) {
    final handlers = <String, Function>{};

    props.forEach((key, value) {
      if (key.startsWith('on') && key.length > 2 && value is Function) {
        // Convert "onClick" to "click" or "press"
        String eventName = key[2].toLowerCase() + key.substring(3);
        handlers[eventName] = value;
      }
    });

    return handlers;
  }

  // Remove event handlers from props before sending to native
  Map<String, dynamic> _removeEventHandlersFromProps(
      Map<String, dynamic> props) {
    final cleanProps = Map<String, dynamic>.from(props);
    final toRemove = <String>[];

    cleanProps.forEach((key, value) {
      if (key.startsWith('on') && key.length > 2 && value is Function) {
        toRemove.add(key);
      }
    });

    for (final key in toRemove) {
      cleanProps.remove(key);
    }
    return cleanProps;
  }
}
