import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/component_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

// NativeVDOM combines ComponentVDOM functionality with native event handling
class NativeVDOM extends ComponentVDOM {
  // Event handlers map: viewId -> eventName -> callback
  final Map<String, Map<String, Function>> _eventHandlers = {};

  // Additional map to track event handler keys to identify replacements
  // key: [button/control identifier] -> viewId
  final Map<String, String> _controlKeyToViewId = {};

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

      // Check if we have a direct handler for this view
      if (_eventHandlers.containsKey(viewId) &&
          _eventHandlers[viewId]!.containsKey(eventName)) {
        debugPrint(
            'NativeVDOM: Found direct handler for $eventName, executing...');
        _eventHandlers[viewId]![eventName]!(eventData);
        return;
      }

      // This is where your issue occurs - we need to fix how we track and resolve event handlers
      // Let's try to find a handler based on control type + title/id for buttons

      // CRITICAL FIX: Try to match the handler based on title or ID
      // This is essential for when views are re-created during state updates
      if (!_eventHandlers.containsKey(viewId)) {
        bool handlerFound = false;

        // Extract control info from the native event
        final buttonTitle = eventData['title'];
        final controlType = event['controlType'] ?? '';
        final controlId = eventData['id'];

        // Create keys for lookup based on control details
        final possibleKeys = <String>[];
        if (buttonTitle != null) possibleKeys.add('button_$buttonTitle');
        if (controlId != null) possibleKeys.add('control_$controlId');
        if (controlType.isNotEmpty) possibleKeys.add('${controlType}_$viewId');

        for (final key in possibleKeys) {
          final srcViewId = _controlKeyToViewId[key];
          if (srcViewId != null && _eventHandlers.containsKey(srcViewId)) {
            debugPrint(
                'NativeVDOM: Found handler by control key: $key, mapping from $srcViewId to $viewId');

            // Copy the handler from source view to current view
            _eventHandlers[viewId] = Map.from(_eventHandlers[srcViewId]!);

            // Also update the view ID mapping
            _controlKeyToViewId[key] = viewId;

            // Execute the handler
            if (_eventHandlers[viewId]!.containsKey(eventName)) {
              _eventHandlers[viewId]![eventName]!(eventData);
              handlerFound = true;
              break;
            }
          }
        }

        if (handlerFound) return;
      }

      // LEGACY FALLBACK: Try numeric view ID approach (can be removed after new approach is confirmed)
      bool handlerFound = false;
      if (viewId.startsWith('view_')) {
        final numericPart = int.tryParse(viewId.substring(5));
        if (numericPart != null) {
          // Try to find a corresponding handler in any other view
          for (final srcViewId in _eventHandlers.keys) {
            if (srcViewId.startsWith('view_') &&
                _eventHandlers[srcViewId]!.containsKey(eventName)) {
              debugPrint(
                  'NativeVDOM: Borrowing handler from $srcViewId for $viewId');

              // Copy all handlers
              _eventHandlers[viewId] = Map.from(_eventHandlers[srcViewId]!);

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
            'NativeVDOM: No handler found for $eventName on view $viewId');
      }
    } catch (e, stack) {
      debugPrint('NativeVDOM: ERROR handling native event - $e');
      debugPrint('NativeVDOM: Stack trace: $stack');
    }
  }

  // Register an event handler
  void registerEventHandler(String viewId, String eventName, Function callback,
      {Map<String, dynamic>? props}) {
    // Initialize the map for this view if needed
    _eventHandlers.putIfAbsent(viewId, () => {});
    _eventHandlers[viewId]![eventName] = callback;

    // Extract key information from props to help with tracking
    if (props != null) {
      final title = props['title'];
      final id = props['id'] ?? props['style']?['id'];

      // Store mappings that will help us find the handler when views are recreated
      if (title != null) {
        _controlKeyToViewId['button_$title'] = viewId;
      }

      if (id != null) {
        _controlKeyToViewId['control_$id'] = viewId;
      }

      // Store by type
      final type = props['_type'] ?? props['_viewType'] ?? '';
      if (type.isNotEmpty) {
        _controlKeyToViewId['${type}_$viewId'] = viewId;
      }
    }

    debugPrint('NativeVDOM: Registered handler for $eventName on view $viewId');
  }

  @override
  void createView(VNode node, String viewId) {
    try {
      // Extract event handlers before sending to native
      final eventHandlers = _extractEventHandlers(node.props);

      // Create a copy of props without event handlers
      final cleanProps = _removeEventHandlersFromProps(node.props);

      // Add type information for tracking
      cleanProps['_viewType'] = node.type;

      debugPrint('NativeVDOM: Creating view $viewId of type ${node.type}');

      if (eventHandlers.isNotEmpty) {
        debugPrint(
            'NativeVDOM: Found ${eventHandlers.length} event handlers: ${eventHandlers.keys.toList()}');

        // Register event handlers on our side
        for (final entry in eventHandlers.entries) {
          registerEventHandler(viewId, entry.key, entry.value,
              props: cleanProps);
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

      // Add type information for tracking
      cleanProps['_viewType'] = newNode.type;

      // Add any event listener prop keys to cleanProps to signal to native side
      final listenerNames = eventHandlers.keys
          .map((name) => 'on${name[0].toUpperCase()}${name.substring(1)}')
          .toList();
      if (listenerNames.isNotEmpty) {
        cleanProps['_eventListeners'] = listenerNames;
      }

      // Re-register event handlers
      if (eventHandlers.isNotEmpty) {
        for (final entry in eventHandlers.entries) {
          registerEventHandler(viewId, entry.key, entry.value,
              props: cleanProps);
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
