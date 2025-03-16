import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/component_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

// NativeVDOM combines ComponentVDOM functionality with native event handling
class NativeVDOM extends ComponentVDOM {
  // Event handlers map: viewId -> eventName -> callback
  final Map<String, Map<String, Function>> _eventHandlers = {};

  // Stable handler mapping: controlKey -> {eventName -> handler}
  // This helps maintain handler references even when view IDs change
  final Map<String, Map<String, Function>> _stableHandlerMap = {};

  // Bidirectional mappings for reliable handler retrieval
  final Map<String, String> _controlKeyToViewId = {};
  final Map<String, String> _viewIdToControlKey = {};

  NativeVDOM() {
    // Listen for events from native side
    MainViewCoordinatorInterface.eventStream.listen(_handleNativeEvent);
    debugPrint('NativeVDOM: Initialized and listening for native events');
  }

  // Handle events coming from native side - simplified approach
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

      // IMPROVED HANDLER LOOKUP STRATEGY

      // Step 1: Try direct handler lookup (fastest path)
      if (_eventHandlers.containsKey(viewId) &&
          _eventHandlers[viewId]!.containsKey(eventName)) {
        _eventHandlers[viewId]![eventName]!(eventData);
        return;
      }

      // Step 2: Try to find via control key mapping (reliable path for recreated views)
      final controlKey = _viewIdToControlKey[viewId];
      if (controlKey != null && _stableHandlerMap.containsKey(controlKey)) {
        final handlers = _stableHandlerMap[controlKey]!;
        if (handlers.containsKey(eventName)) {
          // Update the direct handler for faster future lookups
          _eventHandlers.putIfAbsent(viewId, () => {});
          _eventHandlers[viewId]![eventName] = handlers[eventName]!;

          // Execute the handler
          handlers[eventName]!(eventData);
          return;
        }
      }

      // Step 3: Last resort - try to find by control attributes from event data
      final buttonTitle = eventData['title'];
      final controlId = eventData['id'];

      // Generate possible control keys from event data
      final possibleKeys = <String>[];
      if (buttonTitle != null) possibleKeys.add('btn:$buttonTitle');
      if (controlId != null) possibleKeys.add('id:$controlId');

      for (final key in possibleKeys) {
        if (_stableHandlerMap.containsKey(key) &&
            _stableHandlerMap[key]!.containsKey(eventName)) {
          // Link this view ID to the found control key for faster future lookups
          _viewIdToControlKey[viewId] = key;
          _controlKeyToViewId[key] = viewId;

          // Update the direct handler
          _eventHandlers.putIfAbsent(viewId, () => {});
          _eventHandlers[viewId]![eventName] =
              _stableHandlerMap[key]![eventName]!;

          // Execute the handler
          _stableHandlerMap[key]![eventName]!(eventData);
          return;
        }
      }

      debugPrint('NativeVDOM: No handler found for $eventName on view $viewId');
    } catch (e, stack) {
      debugPrint('NativeVDOM: ERROR handling native event - $e');
      debugPrint('NativeVDOM: Stack trace: $stack');
    }
  }

  // Register an event handler with improved tracking
  void registerEventHandler(String viewId, String eventName, Function callback,
      {Map<String, dynamic>? props}) {
    // Initialize the map for this view if needed
    _eventHandlers.putIfAbsent(viewId, () => {});
    _eventHandlers[viewId]![eventName] = callback;

    // Create stable control keys for handler persistence across re-renders
    if (props != null) {
      final stableKeys = _createStableControlKeys(props, viewId);

      for (final key in stableKeys) {
        // Store in stable handler map
        _stableHandlerMap.putIfAbsent(key, () => {});
        _stableHandlerMap[key]![eventName] = callback;

        // Update bidirectional mappings
        _controlKeyToViewId[key] = viewId;
        _viewIdToControlKey[viewId] = key;
      }
    }

    debugPrint('NativeVDOM: Registered handler for $eventName on view $viewId');
  }

  // Helper method to create stable control keys from props
  List<String> _createStableControlKeys(
      Map<String, dynamic> props, String viewId) {
    final keys = <String>[];

    // Extract identifiable properties for consistent key generation
    final title = props['title'];
    final id = props['id'] ?? props['style']?['id'];
    final type = props['_type'] ?? props['_viewType'] ?? '';

    // Create hierarchical keys with increasing specificity
    if (title != null) {
      keys.add('btn:$title'); // For buttons with titles
      if (type.isNotEmpty) keys.add('$type:$title');
    }

    if (id != null) {
      keys.add('id:$id'); // For elements with IDs
      if (type.isNotEmpty) keys.add('$type:id:$id');
    }

    // Include type+viewId as fallback
    if (type.isNotEmpty) keys.add('$type:$viewId');

    // Add a unique key based on props hash if possible
    final propsKey = _generatePropsHash(props);
    if (propsKey.isNotEmpty) keys.add('props:$propsKey');

    return keys;
  }

  // Generate a simple hash from stable props for identification
  String _generatePropsHash(Map<String, dynamic> props) {
    final identifiers = <String>[];

    // Use stable properties that don't change between renders
    if (props.containsKey('id')) identifiers.add('id:${props['id']}');
    if (props.containsKey('title')) identifiers.add('title:${props['title']}');
    if (props.containsKey('key')) identifiers.add('key:${props['key']}');

    return identifiers.join('|');
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

      // Add node key for better traceability
      if (node.key != null && node.key.isNotEmpty) {
        cleanProps['_nodeKey'] = node.key;
      }

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

      // Add node key for better traceability
      if (newNode.key != null && newNode.key.isNotEmpty) {
        cleanProps['_nodeKey'] = newNode.key;
      }

      // Add any event listener prop keys to cleanProps to signal to native side
      final listenerNames = eventHandlers.keys
          .map((name) => 'on${name[0].toUpperCase()}${name.substring(1)}')
          .toList();
      if (listenerNames.isNotEmpty) {
        cleanProps['_eventListeners'] = listenerNames;
      }

      // Re-register event handlers with improved tracking
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

  @override
  void deleteView(String viewId) {
    // Clean up event handler mappings before deleting
    final controlKey = _viewIdToControlKey[viewId];
    if (controlKey != null) {
      // Don't remove from stable handler map as other views might need it
      _controlKeyToViewId.remove(controlKey);
    }

    _viewIdToControlKey.remove(viewId);
    _eventHandlers.remove(viewId);

    // Proceed with standard view deletion
    super.deleteView(viewId);
  }

  // Helper methods remain the same
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
