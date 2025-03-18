import 'package:dc_test/templating/framework/core/main/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/vdom.dart';
import 'package:flutter/foundation.dart';

/// UnifiedVDOM combines functionality from both event handling and optimization techniques
/// to create an efficient VDOM implementation
class UnifiedVDOM extends VDOM {
  // Event handlers map: viewId -> eventName -> callback
  final Map<String, Map<String, Function>> _eventHandlers = {};

  // Stable handler mapping: controlKey -> {eventName -> handler}
  final Map<String, Map<String, Function>> _stableHandlerMap = {};

  // Bidirectional mappings for reliable handler retrieval
  final Map<String, String> _controlKeyToViewId = {};
  final Map<String, String> _viewIdToControlKey = {};

  // Configuration
  final bool _enableOptimizations;

  // View tracking for optimization
  final Set<String> _unchangedViews = {};
  final Map<String, Map<String, dynamic>> _lastProps = {};

  UnifiedVDOM({bool enableOptimizations = true})
      : _enableOptimizations = enableOptimizations {
    // Listen for events from native side
    MainViewCoordinatorInterface.eventStream.listen(_handleNativeEvent);
    debugPrint(
        'UnifiedVDOM: Initialized with optimizations: $_enableOptimizations');
  }

  // Handle events coming from native side
  void _handleNativeEvent(Map<String, dynamic> event) {
    try {
      final String viewId = event['viewId'];
      final String eventName = event['eventName'];
      final Map<String, dynamic> params =
          Map<String, dynamic>.from(event['params'] ?? {});

      // Convert event names to standard conventions
      String standardEventName = eventName;
      if (!eventName.startsWith("on")) {
        final String capitalizedName =
            eventName[0].toUpperCase() + eventName.substring(1);
        standardEventName = "on$capitalizedName";
      }

      // Ensure target is set in params
      if (!params.containsKey('target')) {
        params['target'] = viewId;
      }

      // Add timestamp if not present
      if (!params.containsKey('timestamp')) {
        params['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      }

      debugPrint(
          'UnifiedVDOM: Processing $standardEventName event for view $viewId');

      // Look up the handler
      if (_eventHandlers.containsKey(viewId) &&
          _eventHandlers[viewId]!.containsKey(standardEventName)) {
        _eventHandlers[viewId]![standardEventName]!(params);
        return;
      }

      // Try alternative event names
      if (standardEventName == "onPress") {
        // Check for other tap event handlers
        if (_eventHandlers.containsKey(viewId) &&
            _eventHandlers[viewId]!.containsKey("onClick")) {
          _eventHandlers[viewId]!["onClick"]!(params);
          return;
        }
      }

      // Handle ScrollView events
      if (standardEventName == "onScroll" &&
          _eventHandlers.containsKey(viewId) &&
          _eventHandlers[viewId]!.containsKey("onScrolled")) {
        _eventHandlers[viewId]!["onScrolled"]!(params);
        return;
      }
    } catch (e, stack) {
      debugPrint('UnifiedVDOM: Error handling event: $e\n$stack');
    }
  }

  // Register standard event handlers
  void registerEventHandler(String viewId, String eventName, Function handler) {
    // Ensure event names follow standard conventions
    String standardEventName = eventName;
    if (!eventName.startsWith("on")) {
      final String capitalizedName =
          eventName[0].toUpperCase() + eventName.substring(1);
      standardEventName = "on$capitalizedName";
    }

    debugPrint(
        'UnifiedVDOM: Registering handler for $standardEventName on view $viewId');

    _eventHandlers.putIfAbsent(viewId, () => {});
    _eventHandlers[viewId]![standardEventName] = handler;

    // Tell native side to track this event
    MainViewCoordinatorInterface.addEventListeners(viewId, [standardEventName]);
  }

  // Register an event handler with improved tracking
  void registerEventHandlerWithProps(
      String viewId, String eventName, Function callback,
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

    debugPrint(
        'UnifiedVDOM: Registered handler for $eventName on view $viewId');
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

    // Always add at least one key
    if (keys.isEmpty) {
      keys.add('view_$viewId');
    }

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
      if (node.key.isNotEmpty) {
        cleanProps['_nodeKey'] = node.key;
      }

      if (eventHandlers.isNotEmpty) {
        debugPrint(
            'UnifiedVDOM: Found ${eventHandlers.length} event handlers: ${eventHandlers.keys.toList()}');

        // Register event handlers on our side
        for (final entry in eventHandlers.entries) {
          registerEventHandlerWithProps(viewId, entry.key, entry.value,
              props: cleanProps);
        }
      }

      // Add event listener prop keys to cleanProps to signal to native side
      final listenerNames = eventHandlers.keys
          .map((name) => 'on${name[0].toUpperCase()}${name.substring(1)}')
          .toList();
      if (listenerNames.isNotEmpty) {
        cleanProps['_eventListeners'] = listenerNames;
      }

      // Pass to parent for normal view creation
      super.createView(node..props = cleanProps, viewId);

      // Restore original props
      node.props.addAll(eventHandlers.map((key, value) =>
          MapEntry('on${key[0].toUpperCase()}${key.substring(1)}', value)));
    } catch (e, stack) {
      debugPrint('UnifiedVDOM: ERROR creating view - $e\n$stack');
    }
  }

  @override
  void updateView(VNode oldNode, VNode newNode, String viewId) {
    try {
      // Skip update if optimizations enabled and props haven't changed substantially
      if (_enableOptimizations && _shouldSkipUpdate(oldNode, newNode, viewId)) {
        _unchangedViews.add(viewId);
        debugPrint('UnifiedVDOM: Skipping unchanged view update for $viewId');
        return;
      }

      // Extract event handlers before sending to native
      final eventHandlers = _extractEventHandlers(newNode.props);

      // Create a copy of props without event handlers
      final cleanProps = _removeEventHandlersFromProps(newNode.props);

      // Add type information for tracking
      cleanProps['_viewType'] = newNode.type;

      // Add node key for better traceability
      if (newNode.key.isNotEmpty) {
        cleanProps['_nodeKey'] = newNode.key;
      }

      // Re-register event handlers with improved tracking
      if (eventHandlers.isNotEmpty) {
        for (final entry in eventHandlers.entries) {
          registerEventHandlerWithProps(viewId, entry.key, entry.value,
              props: cleanProps);
        }
      }

      // Store current props for future comparison
      _lastProps[viewId] = Map<String, dynamic>.from(newNode.props);

      // Use the parent class's updateView implementation
      super.updateView(oldNode, newNode..props = cleanProps, viewId);

      // Restore original props
      newNode.props.addAll(eventHandlers.map((key, value) =>
          MapEntry('on${key[0].toUpperCase()}${key.substring(1)}', value)));
    } catch (e, stack) {
      debugPrint('UnifiedVDOM: ERROR updating view - $e\n$stack');
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
    _lastProps.remove(viewId);
    _unchangedViews.remove(viewId);

    // Proceed with standard view deletion
    super.deleteView(viewId);
  }

  // Logic to determine if an update can be skipped
  bool _shouldSkipUpdate(VNode oldNode, VNode newNode, String viewId) {
    // Skip check if we don't have previous props
    if (!_lastProps.containsKey(viewId)) return false;

    // Get previous props
    final lastProps = _lastProps[viewId]!;
    final newProps = newNode.props;

    // Check for critical props that always require updates
    if (_hasCriticalPropChanges(lastProps, newProps)) {
      return false;
    }

    // If children changed, we must update
    if (oldNode.children.length != newNode.children.length) {
      return false;
    }

    // Compare props using deep equality check
    return _arePropsEssentiallyEqual(lastProps, newProps);
  }

  // Logic for checking critical props that should always trigger updates
  bool _hasCriticalPropChanges(
      Map<String, dynamic> oldProps, Map<String, dynamic> newProps) {
    // Critical prop list - always update if these change
    final criticalProps = [
      'visible',
      'opacity',
      'enabled',
      'selected',
      'active'
    ];

    for (final prop in criticalProps) {
      if (oldProps.containsKey(prop) &&
          newProps.containsKey(prop) &&
          oldProps[prop] != newProps[prop]) {
        return true;
      }
    }

    return false;
  }

  // Deep comparison for props equality
  bool _arePropsEssentiallyEqual(
      Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      // Skip internal keys
      if (key.startsWith('_')) continue;

      // Skip event handlers (they're handled separately)
      if (key.startsWith('on') && a[key] is Function) continue;

      // Check if key exists in b
      if (!b.containsKey(key)) return false;

      // Deep compare values
      if (!_areValuesEssentiallyEqual(a[key], b[key])) return false;
    }

    // Check for any keys in b that aren't in a
    for (final key in b.keys) {
      if (!key.startsWith('_') &&
          !(key.startsWith('on') && b[key] is Function) &&
          !a.containsKey(key)) {
        return false;
      }
    }

    return true;
  }

  // Helper for deep comparison of property values
  bool _areValuesEssentiallyEqual(dynamic a, dynamic b) {
    // Simple equality check for primitives and null
    if (a == b) return true;

    // If one is null but not both
    if (a == null || b == null) return false;

    // Compare maps recursively
    if (a is Map && b is Map) {
      return _arePropsEssentiallyEqual(
          Map<String, dynamic>.from(a), Map<String, dynamic>.from(b));
    }

    // Compare lists
    if (a is List && b is List) {
      if (a.length != b.length) return false;

      for (int i = 0; i < a.length; i++) {
        if (!_areValuesEssentiallyEqual(a[i], b[i])) return false;
      }

      return true;
    }

    // Default to direct comparison
    return a == b;
  }

  // Helper methods for event handling
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
