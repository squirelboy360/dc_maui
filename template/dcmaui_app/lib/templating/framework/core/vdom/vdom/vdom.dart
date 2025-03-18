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
    createView(node, viewId);

    // Track parent-child relationships
    final childViewIds = <String>[];
    for (var child in node.children) {
      _mount(child);
      childViewIds.add(getViewId(child));
    }

    // Set children relationship
    if (childViewIds.isNotEmpty) {
      setChildren(viewId, childViewIds);
    }
  }

  /// Diff two nodes and update the DOM accordingly
  void _diff(VNode oldNode, VNode newNode) {
    // If node types are different, replace the entire subtree
    if (oldNode.type != newNode.type) {
      _replaceView(oldNode, newNode);
      return;
    }

    // Same type, transfer the view ID
    final viewId = getViewId(oldNode);
    nodeToViewId[newNode.key] = viewId;

    // Update props if needed
    if (!_arePropsEqual(oldNode.props, newNode.props)) {
      updateView(oldNode, newNode, viewId);
    }

    // Diff children using key-based reconciliation
    _diffChildren(oldNode, newNode);
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

  /// Diff the children of two nodes
  void _diffChildren(VNode oldNode, VNode newNode) {
    final oldChildren = oldNode.children;
    final newChildren = newNode.children;
    final parentViewId = getViewId(oldNode);

    // Create maps for O(1) lookups
    final oldKeyToChild = {for (var child in oldChildren) child.key: child};

    // Track which old children have been processed
    final processed = <String>{};

    // Final list of child view IDs to be set on the parent
    final finalChildViewIds = <String>[];

    // First pass: Update existing children and create new ones
    for (final newChild in newChildren) {
      final key = newChild.key;

      if (oldKeyToChild.containsKey(key)) {
        // Child exists in both old and new trees, update it
        final oldChild = oldKeyToChild[key]!;
        processed.add(key);
        _diff(oldChild, newChild);
        finalChildViewIds.add(getViewId(newChild));
      } else {
        // New child, mount it
        _mount(newChild);
        finalChildViewIds.add(getViewId(newChild));
      }
    }

    // Second pass: Remove children that don't exist in the new tree
    for (final oldChild in oldChildren) {
      final key = oldChild.key;
      if (!processed.contains(key)) {
        // Child was removed, delete the view
        final viewId = getViewId(oldChild);
        deleteView(viewId);
      }
    }

    // Update the parent's children
    if (finalChildViewIds.isNotEmpty) {
      setChildren(parentViewId, finalChildViewIds);
    }
  }

  /// Replace an old view with a completely new one
  void _replaceView(VNode oldNode, VNode newNode) {
    final oldViewId = getViewId(oldNode);

    // First delete the old view and all its children
    deleteView(oldViewId);

    // Then mount the new tree
    _mount(newNode);
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
        MainViewCoordinatorInterface.createView(viewId, node.type, node.props);
        debugPrint('VDOM: Create view call sent to native for $viewId');
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
    } else if (!_isComponent(oldNode) && !_isComponent(newNode)) {
      debugPrint(
          'VDOM: Update view: $viewId, type: ${newNode.type}, props: ${newNode.props}');
      MainViewCoordinatorInterface.updateView(viewId, newNode.props);
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
    if (component == null || !component.mounted) return;

    debugPrint('VDOM: Handling state update for $componentId');

    // Get previous rendered node
    final prevRenderedNode = _renderedNodes[componentId];
    if (prevRenderedNode == null) return;

    // Render the updated component
    final newRenderedNode = component.render();
    _renderedNodes[componentId] = newRenderedNode;

    // Debug the update
    debugPrint('VDOM: Component rendered new node: ${newRenderedNode.type}');

    // Update the view by properly diffing
    _diffNodeUpdate(prevRenderedNode, newRenderedNode, componentId);
  }

  /// Handle diffing during state updates
  void _diffNodeUpdate(VNode oldNode, VNode newNode, String viewId) {
    debugPrint('VDOM: Diffing node update for $viewId');

    // Force same viewId for the new node by using the old node's key
    // Ensure stable view IDs across re-renders
    final nodeKey = oldNode.key;
    if (!nodeToViewId.containsKey(nodeKey)) {
      nodeToViewId[nodeKey] = viewId;
    }

    if (oldNode.type != newNode.type) {
      // If the types changed, we need to replace the entire view
      // BUT keep the same viewId
      debugPrint(
          'VDOM: Node type changed from ${oldNode.type} to ${newNode.type} but keeping viewId: $viewId');
      MainViewCoordinatorInterface.updateView(viewId, newNode.props);
      return;
    }

    // Update props only if they've changed
    if (!_arePropsEqual(oldNode.props, newNode.props)) {
      debugPrint('VDOM: Props changed, updating view');
      MainViewCoordinatorInterface.updateView(viewId, newNode.props);
    } else {
      debugPrint('VDOM: Props unchanged, skipping update');
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
        createView(newChild, childViewId);
        childIds.add(childViewId);
      }
    }

    // Remove any children that aren't in the new tree
    for (final key in oldChildrenByKey.keys) {
      if (!processedKeys.contains(key) && !newChildrenByKey.containsKey(key)) {
        final oldChild = oldChildrenByKey[key]!;
        final childViewId = getViewId(oldChild);
        deleteView(childViewId);
      }
    }

    // Only update children relationship if needed
    if (childIds.isNotEmpty) {
      final oldChildIds =
          oldNode.children.map((child) => getViewId(child)).toList();
      if (!_areListsEqual(oldChildIds, childIds)) {
        debugPrint(
            'VDOM: Children changed, updating children relationship for $viewId');
        setChildren(viewId, childIds);
      }
    }
  }

  /// Helper method to compare lists for equality
  bool _areListsEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
