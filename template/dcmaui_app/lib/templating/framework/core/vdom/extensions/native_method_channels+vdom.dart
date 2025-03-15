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
      final String eventName = event['eventName'];
      final Map<String, dynamic> eventData =
          Map<String, dynamic>.from(event['data'] ?? {});

      debugPrint(
          'NativeVDOM: Received event $eventName for view $viewId with data: $eventData');

      // Find and trigger the event handler
      if (_eventHandlers.containsKey(viewId) &&
          _eventHandlers[viewId]!.containsKey(eventName)) {
        debugPrint('NativeVDOM: Found handler for $eventName, executing...');
        _eventHandlers[viewId]![eventName]!(eventData);
      } else {
        debugPrint(
            'NativeVDOM: No handler found for $eventName on view $viewId');
        debugPrint('NativeVDOM: Available handlers: ${_eventHandlers.keys}');
        if (_eventHandlers.containsKey(viewId)) {
          debugPrint(
              'NativeVDOM: Events for $viewId: ${_eventHandlers[viewId]!.keys.toList()}');
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

  // Helper to extract event handlers from props
  Map<String, Function> _extractEventHandlers(Map<String, dynamic> props) {
    final handlers = <String, Function>{};
    props.forEach((key, value) {
      if (key.startsWith('on') && key.length > 2 && value is Function) {
        final eventName = key[2].toLowerCase() +
            key.substring(3); // Convert "onClick" to "click"
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
