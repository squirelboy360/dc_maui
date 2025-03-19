import 'package:dc_test/templating/framework/core/main/abstractions/utility/state_abstraction.dart';
import 'package:dc_test/templating/framework/core/main/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:flutter/foundation.dart';

/// Unified Virtual DOM implementation that handles both native views and components
/// This implementation combines the functionality of the basic VDOM and ComponentVDOM
class VDOM {
  // Previous render tree for diffing
  VNode? _previousTree;

  // Map of node keys to view IDs
  final Map<String, String> nodeToViewId = {};

  // View ID counter for generating unique IDs
  int _viewIdCounter = 0;

  // Component tracking
  final Map<String, Component> _components = {};
  final Map<String, VNode> _renderedNodes = {};
  final Map<String, VNode> _viewIdToComponentNode = {};

  /// Get a stable view ID for a node
  String getViewId(VNode node) {
    // Use both key AND type for more unique IDs
    final nodeKey = "${node.type}_${node.key}";

    if (!nodeToViewId.containsKey(nodeKey)) {
      nodeToViewId[nodeKey] = 'view_${_viewIdCounter++}';
      debugPrint(
          'VDOM: Created new view ID ${nodeToViewId[nodeKey]} for node key $nodeKey');
    } else {
      debugPrint(
          'VDOM: Reusing view ID ${nodeToViewId[nodeKey]} for node key $nodeKey');
    }

    return nodeToViewId[nodeKey]!;
  }

  /// Main render method - entry point for the VDOM
  void render(VNode newTree) {
    debugPrint('VDOM: Beginning render');
    if (_previousTree == null) {
      debugPrint('VDOM: First render - mounting tree');
      _mount(newTree);
    } else {
      debugPrint('VDOM: Updating previous tree with diff');
      _diff(_previousTree!, newTree);
    }
    _previousTree = newTree;
    _logTree(newTree);
    debugPrint('VDOM: Render completed');
  }

  /// Mount a new tree of nodes
  void _mount(VNode node) {
    final viewId = getViewId(node);
    debugPrint('VDOM: Mounting node ${node.type} with ID $viewId');

    // Critical fix: Check if this is a component
    if (_isComponent(node)) {
      createView(node, viewId);
      return; // Components handle their own children
    }

    // Create the view itself first
    createView(node, viewId);

    // Critical fix: Process children properly
    final childViewIds = <String>[];
    for (var child in node.children) {
      _mount(child);
      childViewIds.add(getViewId(child));
    }

    // Set children relationship if there are any children
    if (childViewIds.isNotEmpty) {
      debugPrint('VDOM: Setting children for $viewId: $childViewIds');
      setChildren(viewId, childViewIds);
    }
  }

  /// Diff two nodes and update the DOM accordingly
  void _diff(VNode oldNode, VNode newNode) {
    // If node types are different, replace the entire subtree
    if (oldNode.type != newNode.type || oldNode.key != newNode.key) {
      _replaceView(oldNode, newNode);
      return;
    }

    // Same type, transfer the view ID
    final viewId = getViewId(oldNode);
    nodeToViewId[newNode.key] = viewId;

    // Update props if needed
    if (!_arePropsEqual(oldNode.props, newNode.props)) {
      debugPrint(
          'VDOM: Updating view props for ${newNode.type} with ID $viewId');
      updateView(oldNode, newNode, viewId);
    }

    // Critical fix: Properly handle components and their children
    if (_isComponent(oldNode) && _isComponent(newNode)) {
      _updateComponentView(oldNode, newNode, viewId);
      return; // Components handle their own children
    }

    // Diff children using key-based reconciliation for non-component nodes
    _diffChildren(oldNode, newNode, viewId);
  }

  /// Replace an old view with a completely new one
  void _replaceView(VNode oldNode, VNode newNode) {
    final oldViewId = getViewId(oldNode);
    debugPrint(
        'VDOM: Replacing view ${oldNode.type} with ${newNode.type}, ID: $oldViewId');

    // First delete the old view and all its children
    deleteView(oldViewId);

    // Create the new view with the same ID
    nodeToViewId[newNode.key] = oldViewId;

    // Then mount the new tree
    _mount(newNode);
  }

  /// Diff the children of two nodes - completely rewritten for correctness
  void _diffChildren(VNode oldNode, VNode newNode, String parentViewId) {
    final oldChildren = oldNode.children;
    final newChildren = newNode.children;

    debugPrint(
        'VDOM: Diffing children for $parentViewId, old count: ${oldChildren.length}, new count: ${newChildren.length}');

    // Create maps for O(1) lookups by key
    final oldKeyToIndex = <String, int>{};
    for (int i = 0; i < oldChildren.length; i++) {
      oldKeyToIndex[oldChildren[i].key] = i;
    }

    // Track already processed children to avoid duplicates
    final processedIndices = <int>{};

    // Final list of child view IDs in correct order
    final updatedChildViewIds = <String>[];

    // First pass: Update existing children and create new ones
    for (int newIndex = 0; newIndex < newChildren.length; newIndex++) {
      final newChild = newChildren[newIndex];

      if (oldKeyToIndex.containsKey(newChild.key)) {
        // Child exists in both trees - update it
        final oldIndex = oldKeyToIndex[newChild.key]!;
        final oldChild = oldChildren[oldIndex];

        processedIndices.add(oldIndex);
        _diff(oldChild, newChild);

        // Add to updated child list
        updatedChildViewIds.add(getViewId(newChild));
      } else {
        // New child - mount it
        _mount(newChild);
        updatedChildViewIds.add(getViewId(newChild));
      }
    }

    // Second pass: Remove children that don't exist in new tree
    for (int oldIndex = 0; oldIndex < oldChildren.length; oldIndex++) {
      if (!processedIndices.contains(oldIndex)) {
        final oldChild = oldChildren[oldIndex];
        final oldChildViewId = getViewId(oldChild);

        debugPrint(
            'VDOM: Removing child ${oldChild.type} with ID $oldChildViewId');
        deleteView(oldChildViewId);
      }
    }

    // Critical fix: Always update children order in parent
    setChildren(parentViewId, updatedChildViewIds);
  }

  /// Compare props for equality
  bool _arePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      // Skip component metadata fields in comparison
      if (key.startsWith('_component')) continue;

      // Skip function comparisons as they can't be reliably compared
      if (a[key] is Function && b[key] is Function) continue;

      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  // ========== COMPONENT-SPECIFIC FUNCTIONALITY ==========

  /// Check if a VNode represents a component
  bool _isComponent(VNode node) {
    return node.props['_isComponent'] == true;
  }

  /// Get a component instance from a node
  Component? _getComponentInstance(VNode node) {
    final componentId = _getComponentId(node);
    return _components[componentId];
  }

  /// Get the component ID from a node
  String _getComponentId(VNode node) {
    return node.props['_componentId'] as String;
  }

  // ========== VIEW MANAGEMENT METHODS ==========

  /// Create a view for a node
  void createView(VNode node, String viewId) {
    try {
      debugPrint('VDOM: Creating view for ${node.type} with ID $viewId');

      if (_isComponent(node)) {
        debugPrint(
            'VDOM: Creating component view for ${node.props['_componentId']}');
        _createComponentView(node, viewId);
        // Store node reference for later use in deleteView
        _viewIdToComponentNode[viewId] = node;
      } else {
        debugPrint('VDOM: Creating regular view for ${node.type}');

        // Critical fix: Properly handle event handlers and avoid sending functions
        final cleanProps = Map<String, dynamic>.from(node.props);
        final eventHandlers = <String, Function>{};

        // Extract event handlers for registration
        cleanProps.keys.toList().forEach((key) {
          if (key.startsWith('on') && cleanProps[key] is Function) {
            eventHandlers[key] = cleanProps[key] as Function;
            cleanProps.remove(key);
          }
        });

        // CRITICAL FIX: Support for non-prefixed events too (for backwards compatibility)
        // Common event types to check
        final commonEvents = [
          'press',
          'click',
          'change',
          'focus',
          'blur',
          'scroll'
        ];
        for (final eventName in commonEvents) {
          if (cleanProps.containsKey(eventName) &&
              cleanProps[eventName] is Function) {
            // Get standardized name
            final standardName =
                'on${eventName.substring(0, 1).toUpperCase()}${eventName.substring(1)}';

            // Register with standardized name for consistency
            eventHandlers[standardName] = cleanProps[eventName] as Function;
            cleanProps.remove(eventName);

            debugPrint(
                'VDOM: Standardized event "$eventName" to "$standardName"');
          }
        }

        // Create the view with clean props
        MainViewCoordinatorInterface.createView(viewId, node.type, cleanProps);

        // Register event handlers if there are any
        if (eventHandlers.isNotEmpty) {
          debugPrint(
              'VDOM: Registering ${eventHandlers.length} event handlers for $viewId: ${eventHandlers.keys}');

          // Store event handlers in global state manager
          for (final entry in eventHandlers.entries) {
            GlobalStateManager.instance
                .registerEventHandler(viewId, entry.key, entry.value);
          }

          MainViewCoordinatorInterface.addEventListeners(
              viewId, eventHandlers.keys.toList());
        }
      }
    } catch (e, stackTrace) {
      debugPrint('VDOM: ERROR in createView - $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Create a component view
  void _createComponentView(VNode node, String viewId) {
    try {
      final componentConstructor =
          node.props['_componentConstructor'] as Component Function();
      final componentInstance = componentConstructor();
      final componentId = viewId;

      debugPrint(
          'VDOM: Creating component ${componentInstance.runtimeType} with ID $componentId');

      // Store the component instance
      _components[componentId] = componentInstance;

      // Update props before mounting
      final cleanProps = Map<String, dynamic>.from(node.props)
        ..remove('_isComponent')
        ..remove('_componentId')
        ..remove('_componentConstructor');

      componentInstance.props = cleanProps;

      // Set up component's update mechanism
      componentInstance.updateCallback = () {
        _handleComponentUpdate(componentId);
      };

      // Initialize state with values from getInitialState
      componentInstance.initializeState(componentInstance.getInitialState());

      // Call lifecycle methods
      componentInstance.componentWillMount();
      componentInstance.mounted = true;

      // Render the component
      debugPrint('VDOM: Rendering component ${componentInstance.runtimeType}');
      final renderedNode = componentInstance.render();
      _renderedNodes[componentId] = renderedNode;

      debugPrint(
          'VDOM: Component $componentId rendered node of type ${renderedNode.type} with key ${renderedNode.key}');

      // Handle cases where component returns another component vs. a native view
      if (_isComponent(renderedNode)) {
        debugPrint(
            'VDOM: Component returned another component - creating nested component view');

        // Create the nested component with its own view ID
        final nestedViewId = getViewId(renderedNode);
        _createComponentView(renderedNode, nestedViewId);

        // Set parent-child relationship to ensure proper view hierarchy
        debugPrint(
            'VDOM: Setting parent-child relationship: $viewId -> $nestedViewId');
        setChildren(viewId, [nestedViewId]);
      } else {
        // Component returned a regular view - create it directly
        debugPrint(
            'VDOM: Component returned a regular view - creating with ID $viewId');
        MainViewCoordinatorInterface.createView(
            viewId, renderedNode.type, renderedNode.props);

        // Process children
        final childViewIds = <String>[];
        for (var child in renderedNode.children) {
          final childViewId = getViewId(child);
          createView(child, childViewId);
          childViewIds.add(childViewId);
        }

        // Set children relationship
        if (childViewIds.isNotEmpty) {
          setChildren(viewId, childViewIds);
        }
      }

      // Call didMount callback
      componentInstance.componentDidMount();
    } catch (e, stackTrace) {
      debugPrint('VDOM: ERROR in _createComponentView - $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Update a view
  void updateView(VNode oldNode, VNode newNode, String viewId) {
    if (_isComponent(oldNode) && _isComponent(newNode)) {
      _updateComponentView(oldNode, newNode, viewId);
      // Update node reference for later use
      _viewIdToComponentNode[viewId] = newNode;
      return;
    }

    // Only update regular views here
    if (!_isComponent(oldNode) && !_isComponent(newNode)) {
      debugPrint('VDOM: Update view: $viewId, type: ${newNode.type}');

      // Critical fix: Handle event handlers properly
      final oldProps = oldNode.props;
      final newProps = newNode.props;
      final cleanProps = Map<String, dynamic>.from(newProps);

      // Extract event handlers for separate registration
      final oldEventHandlers = <String>{};
      final newEventHandlers = <String, Function>{};

      // Gather old event handlers to remove if needed
      oldProps.keys.forEach((key) {
        if (key.startsWith('on') && oldProps[key] is Function) {
          oldEventHandlers.add(key);
        }
      });

      // Gather new event handlers to register
      cleanProps.keys.toList().forEach((key) {
        if (key.startsWith('on') && cleanProps[key] is Function) {
          newEventHandlers[key] = cleanProps[key] as Function;
          cleanProps.remove(key);
        }
      });

      // Update the view with clean props
      MainViewCoordinatorInterface.updateView(viewId, cleanProps);

      // Handle event handler changes
      final handlersToRemove = oldEventHandlers
          .where((e) => !newEventHandlers.containsKey(e))
          .toList();

      if (handlersToRemove.isNotEmpty) {
        MainViewCoordinatorInterface.removeEventListeners(
            viewId, handlersToRemove);
      }

      if (newEventHandlers.isNotEmpty) {
        MainViewCoordinatorInterface.addEventListeners(
            viewId, newEventHandlers.keys.toList());
      }
    } else {
      // Component type changed, replace the entire view
      deleteView(viewId);
      createView(newNode, viewId);
    }
  }

  /// Update a component view
  void _updateComponentView(VNode oldNode, VNode newNode, String viewId) {
    final component = _getComponentInstance(oldNode);
    if (component == null) {
      debugPrint('VDOM: Error: Component instance not found for update');
      return;
    }

    // Clean the props
    final newProps = Map<String, dynamic>.from(newNode.props)
      ..remove('_isComponent')
      ..remove('_componentId')
      ..remove('_componentConstructor');

    // Check if we should update
    if (!component.shouldComponentUpdate(newProps, component.state)) {
      return;
    }

    // Update props and trigger lifecycle
    final prevProps = Map<String, dynamic>.from(component.props);
    component.props = newProps;

    // Get previous rendered node
    final prevRenderedNode = _renderedNodes[viewId];
    if (prevRenderedNode == null) {
      debugPrint('VDOM: Warning: Previous rendered node not found');
      return;
    }

    // Re-render component
    final newRenderedNode = component.render();
    _renderedNodes[viewId] = newRenderedNode;

    // Update the rendered view
    _diffNodeUpdate(prevRenderedNode, newRenderedNode, viewId);

    // Call lifecycle method
    if (component.mounted) {
      component.componentDidUpdate(prevProps, component.state);
    }
  }

  /// Delete a view
  void deleteView(String viewId) {
    // Check if this viewId corresponds to a component
    if (_viewIdToComponentNode.containsKey(viewId)) {
      _deleteComponentView(_viewIdToComponentNode[viewId]!, viewId);
    } else {
      debugPrint('VDOM: Delete view: $viewId');
      MainViewCoordinatorInterface.deleteView(viewId);
    }
  }

  /// Delete a component view
  void _deleteComponentView(VNode node, String viewId) {
    final component = _getComponentInstance(node);
    if (component != null) {
      // Call lifecycle method directly
      component.componentWillUnmount();
      component.mounted = false;

      // Remove component
      _components.remove(_getComponentId(node));

      // Get the rendered node
      final renderedNode = _renderedNodes.remove(viewId);
      if (renderedNode != null) {
        debugPrint('VDOM: Deleting view for component: $viewId');
        MainViewCoordinatorInterface.deleteView(viewId);
      }

      // Clean up the reference
      _viewIdToComponentNode.remove(viewId);
    } else {
      debugPrint('VDOM: Deleting regular view: $viewId');
      MainViewCoordinatorInterface.deleteView(viewId);
    }
  }

  /// Set children relationship on the native side
  void setChildren(String parentId, List<String> childIds) {
    debugPrint('VDOM: Set children for $parentId: $childIds');
    MainViewCoordinatorInterface.setChildren(parentId, childIds);
  }

  /// Handle component update when setState is called
  void _handleComponentUpdate(String componentId) {
    final component = _components[componentId];
    if (component == null || !component.mounted) {
      debugPrint(
          'VDOM: Cannot update component $componentId - not found or unmounted');
      return;
    }

    debugPrint('VDOM: Handling state update for $componentId');

    // Get previous rendered node
    final prevRenderedNode = _renderedNodes[componentId];
    if (prevRenderedNode == null) {
      debugPrint(
          'VDOM: Error: No previous rendered node found for $componentId');
      return;
    }

    try {
      // CRITICAL FIX: Call componentWillUpdate if implemented
      if (component.props.containsKey('componentWillUpdate')) {
        final updateCallback = component.props['componentWillUpdate'];
        if (updateCallback is Function) {
          updateCallback(component.props, component.state);
        }
      }

      // CRITICAL FIX: Force re-render the component
      final newRenderedNode = component.render();
      _renderedNodes[componentId] = newRenderedNode;

      // Debug the update with more details
      debugPrint(
          'VDOM: Component $componentId rendered new node: ${newRenderedNode.type}');
      debugPrint('VDOM: Component state is now: ${component.state}');

      // CRITICAL FIX: Ensure stable viewIds between renders
      nodeToViewId[newRenderedNode.key] = componentId;

      // Update the view by properly diffing
      _diffNodeUpdate(prevRenderedNode, newRenderedNode, componentId);

      // CRITICAL FIX: Call componentDidUpdate
      component.componentDidUpdate(component.props, component.state);
    } catch (e, stack) {
      debugPrint('VDOM: Error updating component: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Handle diffing during state updates
  void _diffNodeUpdate(VNode oldNode, VNode newNode, String viewId) {
    debugPrint('VDOM: Diffing node update for $viewId');

    // Critical fix: Ensure components preserve viewIds
    if (oldNode.key != newNode.key) {
      nodeToViewId[newNode.key] = viewId;
    }

    // If types are different but IDs must be preserved
    if (oldNode.type != newNode.type) {
      debugPrint(
          'VDOM: Node type changed from ${oldNode.type} to ${newNode.type} but keeping viewId: $viewId');

      // Actually replace the view while preserving ID
      MainViewCoordinatorInterface.deleteView(viewId);
      createView(newNode, viewId);
      return;
    }

    // Update props only if they've changed
    if (!_arePropsEqual(oldNode.props, newNode.props)) {
      debugPrint('VDOM: Props changed, updating view');
      updateView(oldNode, newNode, viewId);
    }

    // Critical fix: Properly update children
    _diffChildren(oldNode, newNode, viewId);
  }

  /// Log the VDOM tree (for debugging)
  void _logTree(VNode node, [int depth = 0]) {
    final indent = ' ' * (depth * 2);
    final viewId = getViewId(node);
    debugPrint('$indent$viewId: ${node.type} (props: ${node.props})');

    for (final child in node.children) {
      _logTree(child, depth + 1);
    }
  }
}
