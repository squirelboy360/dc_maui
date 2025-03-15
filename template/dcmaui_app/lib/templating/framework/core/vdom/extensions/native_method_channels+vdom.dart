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

  // Override _diffNodeUpdate to properly register event handlers for all nodes
  @override
  void _diffNodeUpdate(VNode oldNode, VNode newNode, String viewId) {
    debugPrint('ComponentVDOM: Diffing node update for $viewId');

    // Continue with the standard diffing process
    final nodeKey = oldNode.key;
    if (!nodeToViewId.containsKey(nodeKey)) {
      nodeToViewId[nodeKey] = viewId;
    }

    if (oldNode.type != newNode.type) {
      // If the types changed, we need to replace the entire view
      // BUT keep the same viewId
      debugPrint(
          'ComponentVDOM: Node type changed from ${oldNode.type} to ${newNode.type} but keeping viewId: $viewId');

      // Extract and register event handlers before updating
      final eventHandlers = _extractEventHandlers(newNode.props);
      if (eventHandlers.isNotEmpty) {
        for (final entry in eventHandlers.entries) {
          registerEventHandler(viewId, entry.key, entry.value);
        }
      }

      super.updateView(oldNode, newNode, viewId);
      return;
    }

    // Update props only if they've changed - use our own implementation
    if (!_propsChanged(oldNode.props, newNode.props)) {
      debugPrint('ComponentVDOM: Props changed, updating view');

      // Extract and register event handlers before updating
      final eventHandlers = _extractEventHandlers(newNode.props);
      if (eventHandlers.isNotEmpty) {
        for (final entry in eventHandlers.entries) {
          registerEventHandler(viewId, entry.key, entry.value);
        }
      }

      super.updateView(oldNode, newNode, viewId);
    } else {
      debugPrint('ComponentVDOM: Props unchanged, skipping update');
    }

    // Process children using a more correct approach to maintain stable IDs
    // Map children by their keys for efficient lookup
    final oldChildrenByKey = {
      for (var child in oldNode.children) child.key: child
    };
    final newChildrenByKey = {
      for (var child in newNode.children) child.key: child
    };

    // Set of processed keys
    final processedKeys = <String>{};

    // Final list of child view IDs
    final childIds = <String>[];

    // Update existing children
    for (final newChild in newNode.children) {
      final key = newChild.key;

      if (oldChildrenByKey.containsKey(key)) {
        // This child exists in both old and new trees
        final oldChild = oldChildrenByKey[key]!;
        processedKeys.add(key);

        // Get the view ID for this child
        final childViewId = getViewId(oldChild);

        // Force the same view ID for the new child
        nodeToViewId[newChild.key] = childViewId;

        // Now diff this child
        _diffNodeUpdate(oldChild, newChild, childViewId);

        // Add to our list of final child IDs
        childIds.add(childViewId);
      } else {
        // This is a new child, need to create it
        final childViewId = getViewId(newChild);

        // CRITICAL FIX: Register event handlers for new children
        final eventHandlers = _extractEventHandlers(newChild.props);
        if (eventHandlers.isNotEmpty) {
          for (final entry in eventHandlers.entries) {
            registerEventHandler(childViewId, entry.key, entry.value);
          }
        }

        // Create a copy of props without event handlers but with _eventListeners
        if (eventHandlers.isNotEmpty) {
          final cleanProps = _removeEventHandlersFromProps(newChild.props);
          final listenerNames = eventHandlers.keys
              .map((name) => 'on${name[0].toUpperCase()}${name.substring(1)}')
              .toList();
          cleanProps['_eventListeners'] = listenerNames;

          // Create the view with clean props - fixed VNode constructor
          var tempNode = VNode(
            newChild.type,
            props: cleanProps,
            children: newChild.children,
            key: newChild.key,
          );

          super.createView(tempNode, childViewId);

          // Restore props on original node
          newChild.props.addAll(eventHandlers.map((key, value) =>
              MapEntry('on${key[0].toUpperCase()}${key.substring(1)}', value)));
        } else {
          super.createView(newChild, childViewId);
        }

        childIds.add(childViewId);
      }
    }

    // Remove any children that aren't in the new tree
    for (final key in oldChildrenByKey.keys) {
      if (!processedKeys.contains(key) && !newChildrenByKey.containsKey(key)) {
        final oldChild = oldChildrenByKey[key]!;
        final childViewId = getViewId(oldChild);

        // Remove event handlers for deleted views
        _eventHandlers.remove(childViewId);

        super.deleteView(childViewId);
      }
    }

    // Only update children relationship if needed
    if (childIds.isNotEmpty) {
      final oldChildIds =
          oldNode.children.map((child) => getViewId(child)).toList();
      if (!_listsEqual(oldChildIds, childIds)) {
        debugPrint(
            'ComponentVDOM: Children changed, updating children relationship for $viewId');
        super.setChildren(viewId, childIds);
      }
    }
  }

  // Local implementation of prop comparison to avoid calling super._arePropsEqual
  bool _propsChanged(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return true;

    for (final key in a.keys) {
      // Skip component metadata fields in comparison
      if (key.startsWith('_component')) continue;

      // Skip function comparisons as they can't be reliably compared
      if (a[key] is Function && b[key] is Function) continue;

      if (!b.containsKey(key) || a[key] != b[key]) return true;
    }

    return false;
  }

  // Local implementation of list comparison to avoid calling super._areListsEqual
  bool _listsEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
