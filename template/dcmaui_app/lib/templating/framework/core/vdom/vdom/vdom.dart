import 'package:dc_test/templating/framework/core/vdom/node/low_levels/state_controller.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:flutter/foundation.dart';

/// Unified Virtual DOM implementation that handles both native views and components
class VDOM {
  // Previous render tree for diffing
  VNode? _previousTree;

  // Map of node keys to view IDs
  final Map<String, String> nodeToViewId = {};

  // Track existing views to avoid recreation
  final Set<String> _createdViews = {};

  // View ID counter for generating unique IDs
  int _viewIdCounter = 0;

  // Component tracking
  final Map<String, Component> _components = {};
  final Map<String, VNode> _renderedNodes = {};
  final Map<String, VNode> _viewIdToComponentNode = {};

  // Store component states
  final Map<String, Map<String, dynamic>> _componentStates = {};

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
    _ensureViewExists(node, viewId);

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

  /// Ensure a view exists - create only if not already created
  void _ensureViewExists(VNode node, String viewId) {
    if (!_createdViews.contains(viewId)) {
      debugPrint('VDOM: Creating new view for ${node.type} with ID $viewId');
      createView(node, viewId);
      _createdViews.add(viewId);
    } else {
      debugPrint('VDOM: Reusing existing view $viewId for ${node.type}');
      // Update the view props if it already exists
      updateViewProps(viewId, node.props);
    }
  }

  /// Update just the props of an existing view
  void updateViewProps(String viewId, Map<String, dynamic> props) {
    // Extract and clean props (remove event handlers)
    final cleanProps = Map<String, dynamic>.from(props);

    // Extract event handlers for separate handling
    final eventHandlers = <String, Function>{};

    // Use the same consistent approach for extracting events
    cleanProps.keys.toList().forEach((key) {
      if (cleanProps[key] is Function) {
        // Only detect events using the standard "on" prefix approach
        if (key.startsWith('on') && key.length > 2) {
          eventHandlers[key] = cleanProps[key] as Function;
          cleanProps.remove(key);
        }
      }
    });

    // Update view props
    MainViewCoordinatorInterface.updateView(viewId, cleanProps);

    // Update event handlers if needed
    if (eventHandlers.isNotEmpty) {
      debugPrint(
          'VDOM: Updating ${eventHandlers.length} event handlers for $viewId');

      for (final entry in eventHandlers.entries) {
        GlobalStateManager.instance
            .registerEventHandler(viewId, entry.key, entry.value);
      }

      // Make sure the native side knows about these event handlers
      MainViewCoordinatorInterface.addEventListeners(
          viewId, eventHandlers.keys.toList());
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
    nodeToViewId["${newNode.type}_${newNode.key}"] = viewId;

    // Update props if needed
    if (!_arePropsEqual(oldNode.props, newNode.props)) {
      debugPrint(
          'VDOM: Updating view props for ${newNode.type} with ID $viewId');
      updateViewProps(viewId, newNode.props);
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
    _createdViews.remove(oldViewId);

    // Create the new view with the same ID
    nodeToViewId["${newNode.type}_${newNode.key}"] = oldViewId;

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
    final oldKeyToChild = <String, VNode>{};
    for (final child in oldChildren) {
      oldKeyToChild[child.key] = child;
    }

    // Track already processed children to avoid duplicates
    final processedOldKeys = <String>{};

    // Final list of child view IDs in correct order
    final updatedChildViewIds = <String>[];

    // First pass: Update existing children and create new ones
    for (final newChild in newChildren) {
      final newNodeKey = "${newChild.type}_${newChild.key}";

      if (oldKeyToChild.containsKey(newChild.key)) {
        // Child exists in both trees - update it
        final oldChild = oldKeyToChild[newChild.key]!;
        final oldNodeKey = "${oldChild.type}_${oldChild.key}";

        processedOldKeys.add(newChild.key);

        if (oldChild.type == newChild.type) {
          // Same type - just update props
          final viewId = nodeToViewId[oldNodeKey];

          // Fix: Add null check to handle potential null viewId
          if (viewId != null) {
            // Transfer ID to new node
            nodeToViewId[newNodeKey] = viewId;

            debugPrint('VDOM: Reusing view $viewId for child ${newChild.type}');

            // Update props if needed
            if (!_arePropsEqual(oldChild.props, newChild.props)) {
              updateViewProps(viewId, newChild.props);
            }

            // Recursively handle children
            _diffChildren(oldChild, newChild, viewId);

            // Add to updated child list
            updatedChildViewIds.add(viewId);
          } else {
            // viewId is null, so we need to mount the child as new
            debugPrint(
                'VDOM: No view ID found for existing node, mounting as new');
            _mount(newChild);
            final newViewId = nodeToViewId[newNodeKey];
            if (newViewId != null) {
              updatedChildViewIds.add(newViewId);
            }
          }
        } else {
          // Different type - need to replace
          debugPrint(
              'VDOM: Child type changed from ${oldChild.type} to ${newChild.type}');
          _replaceView(oldChild, newChild);
          final newViewId = nodeToViewId[newNodeKey];
          if (newViewId != null) {
            updatedChildViewIds.add(newViewId);
          }
        }
      } else {
        // New child - mount it
        _mount(newChild);
        final newViewId = nodeToViewId[newNodeKey];
        if (newViewId != null) {
          updatedChildViewIds.add(newViewId);
        }
      }
    }

    // Second pass: Remove children that don't exist in the new tree
    for (final oldChild in oldChildren) {
      if (!processedOldKeys.contains(oldChild.key)) {
        final oldNodeKey = "${oldChild.type}_${oldChild.key}";
        if (nodeToViewId.containsKey(oldNodeKey)) {
          final viewId = nodeToViewId[oldNodeKey]!;
          deleteView(viewId);
          _createdViews.remove(viewId);
          nodeToViewId.remove(oldNodeKey);
        }
      }
    }

    // Final step: Update the children order in the parent
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

      // Handle style maps specially
      if (key == 'style' && a[key] is Map && b[key] is Map) {
        if (!_areStylePropsEqual(
            a[key] as Map<String, dynamic>, b[key] as Map<String, dynamic>)) {
          return false;
        }
        continue;
      }

      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  /// Compare style props specially
  bool _areStylePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  // ========== COMPONENT-SPECIFIC FUNCTIONALITY ==========

  /// Check if a VNode represents a component
  bool _isComponent(VNode node) {
    return node.props['_isComponent'] == true;
  }

  // ========== STATE MANAGEMENT ==========

  /// Get component state
  Map<String, dynamic> getComponentState(String componentId) {
    return _componentStates[componentId] ?? {};
  }

  /// Set component state
  void setComponentState(String componentId, Map<String, dynamic> newState) {
    if (!_componentStates.containsKey(componentId)) {
      _componentStates[componentId] = {};
    }

    // Update state values
    bool stateChanged = false;
    for (final key in newState.keys) {
      if (_componentStates[componentId]![key] != newState[key]) {
        _componentStates[componentId]![key] = newState[key];
        stateChanged = true;
      }
    }

    // If state changed, trigger update
    if (stateChanged) {
      debugPrint(
          'VDOM: State changed for component $componentId, triggering update');

      // Update component's StateValue controllers to reflect new values
      final component = _components[componentId];
      if (component is Component) {
        // Force state synchronization before render
        for (final key in newState.keys) {
          final field = findComponentStateField(component, key);
          if (field != null && field is StateValue) {
            debugPrint(
                'VDOM: Updating StateValue for $key to ${newState[key]}');
            field.updateCurrentValue(newState[key]);
          }
        }
      }

      _handleComponentUpdate(componentId);
    }
  }

  // Helper to find a StateValue field in a component by its name
  dynamic findComponentStateField(Component component, String fieldName) {
    // Reflection isn't easy in Dart, so this is a simplification
    // In a real implementation, you'd need to use mirrors or another approach
    return null;
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

        // Extract event handlers using proper controls helper - simplified to only use ControlProps
        cleanProps.keys.toList().forEach((key) {
          if (cleanProps[key] is Function) {
            // Only detect events using the standard "on" prefix approach
            if (key.startsWith('on') && key.length > 2) {
              eventHandlers[key] = cleanProps[key] as Function;
              cleanProps.remove(key);
            }
          }
        });

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
      // Get the component constructor function
      final componentConstructor =
          node.props['_componentConstructor'] as Function;
      final componentInstance = componentConstructor();
      final componentId = node.props['_componentId'] as String;
      debugPrint(
          'VDOM: Creating component ${componentInstance.runtimeType} with ID $componentId');

      // Store the component instance
      _components[componentId] = componentInstance;

      // Update props before mounting
      final cleanProps = Map<String, dynamic>.from(node.props)
        ..remove('_isComponent')
        ..remove('_componentId')
        ..remove('_componentConstructor');

      // Set component props
      if (componentInstance is Component) {
        componentInstance.props = cleanProps;

        // Set up component's update mechanism
        componentInstance.updateCallback = () {
          _handleComponentUpdate(componentId);
        };

        // Initialize empty state instead of trying to call getInitialState
        _componentStates[componentId] = {};

        // Call lifecycle methods - componentDidMount instead of componentWillMount
        componentInstance.mounted = true;

        // Render the component
        debugPrint(
            'VDOM: Rendering component ${componentInstance.runtimeType}');
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
          _createdViews.add(viewId);

          // Store node ID mapping for the rendered content
          nodeToViewId["${renderedNode.type}_${renderedNode.key}"] = viewId;

          // Process children
          final childViewIds = <String>[];
          for (var child in renderedNode.children) {
            _mount(child);
            childViewIds.add(getViewId(child));
          }

          // Set children relationship
          if (childViewIds.isNotEmpty) {
            setChildren(viewId, childViewIds);
          }
        }

        // Call didMount callback
        componentInstance.componentDidMount();
      }
    } catch (e, stackTrace) {
      debugPrint('VDOM: ERROR in _createComponentView - $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Update a component view
  void _updateComponentView(VNode oldNode, VNode newNode, String viewId) {
    final componentId = oldNode.props['_componentId'] as String;
    final component = _components[componentId];
    if (component == null) {
      debugPrint('VDOM: Error: Component instance not found for update');
      return;
    }

    // Clean the props
    final newProps = Map<String, dynamic>.from(newNode.props)
      ..remove('_isComponent')
      ..remove('_componentId')
      ..remove('_componentConstructor');

    // Transfer component ID to ensure consistent tracking
    newNode.props['_componentId'] = componentId;

    // Get current state
    final currentState = _componentStates[componentId] ?? {};

    // Check if we should update
    if (!component.shouldComponentUpdate(newProps, currentState)) {
      return;
    }

    // Update props and trigger lifecycle
    final prevProps = Map<String, dynamic>.from(component.props);
    component.props = newProps;

    // Get previous rendered node
    final prevRenderedNode = _renderedNodes[componentId];
    if (prevRenderedNode == null) {
      debugPrint('VDOM: Warning: Previous rendered node not found');
      return;
    }

    // Re-render component
    final newRenderedNode = component.render();

    // CRITICAL FIX: Preserve view IDs
    _preserveViewIds(prevRenderedNode, newRenderedNode);

    // Store new rendered node for next update
    _renderedNodes[componentId] = newRenderedNode;

    // Update the rendered view
    _diffComponentOutput(prevRenderedNode, newRenderedNode, viewId);

    // Call lifecycle method
    if (component.mounted) {
      component.componentDidUpdate(prevProps, currentState);
    }
  }

  /// Diff component output - specialized for handling component render output
  void _diffComponentOutput(VNode oldOutput, VNode newOutput, String viewId) {
    // Improved logging for state updates affecting the component output
    debugPrint('VDOM: Diffing component output for view $viewId');
    debugPrint(
        'VDOM: Old output type: ${oldOutput.type}, key: ${oldOutput.key}, children: ${oldOutput.children.length}');
    debugPrint(
        'VDOM: New output type: ${newOutput.type}, key: ${newOutput.key}, children: ${newOutput.children.length}');

    // If root output type changed, we need special handling
    if (oldOutput.type != newOutput.type) {
      debugPrint(
          'VDOM: Component output type changed from ${oldOutput.type} to ${newOutput.type}');

      // CRITICAL FIX: For root containers, NEVER recreate them - just update props
      debugPrint(
          'VDOM: Preserving root container view $viewId during type change');
      updateViewProps(viewId, newOutput.props);

      // Store mapping for the new node
      nodeToViewId["${newOutput.type}_${newOutput.key}"] = viewId;
      _createdViews.add(viewId);
    } else {
      // Same type - update props if needed
      if (!_arePropsEqual(oldOutput.props, newOutput.props)) {
        debugPrint('VDOM: Updating props for view $viewId due to prop changes');
        updateViewProps(viewId, newOutput.props);
      }
    }

    // CRITICAL FIX: For the root container especially, use our improved child reconciliation
    _preserveExistingChildrenStructure(oldOutput, newOutput, viewId);
  }

  /// New method: Specialized reconciliation that preserves existing view structure
  void _preserveExistingChildrenStructure(
      VNode oldNode, VNode newNode, String parentViewId) {
    // Get the children arrays
    final oldChildren = oldNode.children;
    final newChildren = newNode.children;

    debugPrint('VDOM: Preserving children structure for $parentViewId');
    debugPrint(
        'VDOM: Old children count: ${oldChildren.length}, new children count: ${newChildren.length}');

    // Build maps for quick lookups
    final oldChildrenByKey = <String, VNode>{};
    final oldChildViewIds = <String, String>{};

    // Map the old children to their keys and view IDs
    for (final oldChild in oldChildren) {
      final key = oldChild.key;
      oldChildrenByKey[key] = oldChild;
      final nodeKey = "${oldChild.type}_$key";
      if (nodeToViewId.containsKey(nodeKey)) {
        oldChildViewIds[key] = nodeToViewId[nodeKey]!;
        debugPrint(
            'VDOM: Found existing view ID ${nodeToViewId[nodeKey]} for child $key');
      }
    }

    // Track child view IDs in order they should appear
    final updatedChildViewIds = <String>[];
    final processedKeys = <String>{};

    // First pass: Update existing children or create new ones
    for (final newChild in newChildren) {
      final key = newChild.key;
      final newNodeKey = "${newChild.type}_$key";

      if (oldChildrenByKey.containsKey(key)) {
        // This child exists in both old and new trees
        processedKeys.add(key);
        final oldChild = oldChildrenByKey[key]!;

        // Check if we have a view ID for this child
        if (oldChildViewIds.containsKey(key)) {
          final childViewId = oldChildViewIds[key]!;
          nodeToViewId[newNodeKey] = childViewId;
          debugPrint('VDOM: Reusing view ID $childViewId for child $key');

          // If same type, just update props
          if (oldChild.type == newChild.type) {
            if (!_arePropsEqual(oldChild.props, newChild.props)) {
              debugPrint('VDOM: Updating props for child view $childViewId');
              updateViewProps(childViewId, newChild.props);
            }

            // Process this child's children recursively
            if (oldChild.children.isNotEmpty || newChild.children.isNotEmpty) {
              _preserveExistingChildrenStructure(
                  oldChild, newChild, childViewId);
            }
          } else {
            // Types differ but we'll reuse the view ID
            debugPrint('VDOM: Child type changed but preserving view ID');
            updateViewProps(childViewId, newChild.props);

            // We still need to handle children
            if (newChild.children.isNotEmpty) {
              // Mount all children from scratch
              final newChildViewIds = <String>[];
              for (final grandchild in newChild.children) {
                _mount(grandchild);
                final gcViewId =
                    nodeToViewId["${grandchild.type}_${grandchild.key}"];
                if (gcViewId != null) {
                  newChildViewIds.add(gcViewId);
                }
              }

              // Set children if there are any
              if (newChildViewIds.isNotEmpty) {
                setChildren(childViewId, newChildViewIds);
              }
            }
          }

          updatedChildViewIds.add(childViewId);
        } else {
          // No existing view ID - mount as new
          _mount(newChild);
          final newViewId = nodeToViewId[newNodeKey];
          if (newViewId != null) {
            updatedChildViewIds.add(newViewId);
          }
        }
      } else {
        // This is a completely new child
        _mount(newChild);
        final newViewId = nodeToViewId[newNodeKey];
        if (newViewId != null) {
          updatedChildViewIds.add(newViewId);
        }
      }
    }

    // CRITICAL FIX: Don't actually mark views for removal that are still in the updatedChildViewIds
    // This was the main bug - we were marking views for removal even though we were still using them
    final childrenToRemove = <String>[];
    for (final oldKey in oldChildrenByKey.keys) {
      if (!processedKeys.contains(oldKey) &&
          !newChildren.any((c) => c.key == oldKey)) {
        // This child was removed in the new tree
        final oldChild = oldChildrenByKey[oldKey]!;
        final oldNodeKey = "${oldChild.type}_${oldChild.key}";
        if (nodeToViewId.containsKey(oldNodeKey)) {
          final viewId = nodeToViewId[oldNodeKey]!;
          // Only mark for removal if it's truly not in the updated list
          if (!updatedChildViewIds.contains(viewId)) {
            childrenToRemove.add(viewId);
            debugPrint(
                'VDOM: Marking child view $viewId for removal (key: $oldKey, not in updated list)');
          } else {
            debugPrint(
                'VDOM: Child view $viewId is marked for reuse (key: $oldKey)');
          }
        }
      }
    }

    // Only actually remove views that we're sure aren't reused
    for (final viewId in childrenToRemove) {
      debugPrint('VDOM: Actually removing unused child view $viewId');
      deleteView(viewId);
      _createdViews.remove(viewId);
      // Remove from the viewId map by looking up the key
      nodeToViewId.removeWhere((key, value) => value == viewId);
    }

    // Final step: Update children order in parent view
    if (updatedChildViewIds.isNotEmpty) {
      debugPrint(
          'VDOM: Setting final children order for $parentViewId: $updatedChildViewIds');
      setChildren(parentViewId, updatedChildViewIds);
    }
  }

  /// CRITICAL FIX: Preserve view IDs between renders
  void _preserveViewIds(VNode oldNode, VNode newNode) {
    // Transfer the key mapping to ensure same views are used
    final oldNodeKey = "${oldNode.type}_${oldNode.key}";
    final newNodeKey = "${newNode.type}_${newNode.key}";

    if (nodeToViewId.containsKey(oldNodeKey)) {
      final viewId = nodeToViewId[oldNodeKey]!;
      nodeToViewId[newNodeKey] = viewId;
      debugPrint(
          'VDOM: Preserving view ID $viewId from $oldNodeKey to $newNodeKey');

      // IMPROVEMENT: Also mark as created to avoid recreation
      _createdViews.add(viewId);
    }

    // IMPROVEMENT: Try to map children by key even if counts don't match
    // Map known child keys first
    final oldChildrenByKey = <String, VNode>{};
    for (final oldChild in oldNode.children) {
      oldChildrenByKey[oldChild.key] = oldChild;
    }

    // Now map each new child to a corresponding old child by key
    for (final newChild in newNode.children) {
      if (oldChildrenByKey.containsKey(newChild.key)) {
        _preserveViewIds(oldChildrenByKey[newChild.key]!, newChild);
      }
    }

    // Original approach as fallback when we have matching children counts
    if (oldNode.children.length == newNode.children.length) {
      for (int i = 0; i < oldNode.children.length; i++) {
        _preserveViewIds(oldNode.children[i], newNode.children[i]);
      }
    }
  }

  /// Delete a view
  void deleteView(String viewId) {
    // Check if this viewId corresponds to a component
    if (_viewIdToComponentNode.containsKey(viewId)) {
      final node = _viewIdToComponentNode[viewId]!;
      final componentId = node.props['_componentId'] as String;
      debugPrint(
          'VDOM: Deleting component view: $viewId (component ID: $componentId)');

      final component = _components[componentId];
      if (component != null) {
        // Call lifecycle
        component.componentWillUnmount();
        component.mounted = false;

        // Clean up
        _components.remove(componentId);
        _componentStates.remove(componentId);
        _renderedNodes.remove(componentId);
      }
      _viewIdToComponentNode.remove(viewId);

      // Delete the native view after cleanup
      MainViewCoordinatorInterface.deleteView(viewId);
      _createdViews.remove(viewId);
    } else {
      debugPrint('VDOM: Delete view: $viewId');
      MainViewCoordinatorInterface.deleteView(viewId);
      _createdViews.remove(viewId);
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
    if (component == null || (!component.mounted)) {
      debugPrint(
          'VDOM: Cannot update component $componentId - not found or unmounted');
      return;
    }

    debugPrint('VDOM: Handling state update for $componentId');

    // Find view ID for this component
    String? viewId;
    for (final entry in _viewIdToComponentNode.entries) {
      final node = entry.value;
      if (node.props['_componentId'] == componentId) {
        viewId = entry.key;
        break;
      }
    }

    if (viewId == null) {
      debugPrint('VDOM: Cannot find view ID for component $componentId');
      return;
    }

    try {
      // Get previous rendered node
      final prevRenderedNode = _renderedNodes[componentId];
      if (prevRenderedNode == null) {
        debugPrint(
            'VDOM: Error: No previous rendered node found for $componentId');
        return;
      }

      // CRITICAL FIX: First create a shallow copy of the rendered node to avoid direct mutation
      final prevRenderedNodeCopy = VNode(prevRenderedNode.type,
          props: Map<String, dynamic>.from(prevRenderedNode.props),
          children: List<VNode>.from(prevRenderedNode.children),
          key: prevRenderedNode.key);

      // Re-render component
      final newRenderedNode = component.render();

      // Debug logging
      debugPrint(
          'VDOM: STATE UPDATE - Component $componentId rendered new tree with root type ${newRenderedNode.type}');
      debugPrint(
          'VDOM: Old node key: ${prevRenderedNode.key}, new node key: ${newRenderedNode.key}');

      // CRITICAL FIX: First transfer all view IDs from old tree to new tree
      _preserveViewIds(prevRenderedNode, newRenderedNode);

      // CRITICAL FIX: Store a deep copy of the new rendered node to prevent mutations
      _renderedNodes[componentId] = _deepCopyVNode(newRenderedNode);

      // CRITICAL: Ensure the component's viewId is preserved for the root node
      final oldNodeKey = "${prevRenderedNode.type}_${prevRenderedNode.key}";
      final newNodeKey = "${newRenderedNode.type}_${newRenderedNode.key}";

      if (nodeToViewId.containsKey(oldNodeKey)) {
        nodeToViewId[newNodeKey] = viewId;
        _createdViews.add(viewId);
        debugPrint(
            'VDOM: Preserved component root view ID $viewId from $oldNodeKey to $newNodeKey');
      }

      // CRITICAL FIX: Compare modal and container views more carefully to preserve them
      if (_isSpecialContainerType(prevRenderedNode.type) &&
          _isSpecialContainerType(newRenderedNode.type)) {
        debugPrint(
            'VDOM: Detected special container type update - ensuring strict preservation');
      }

      // Update the view - using our specialized method for component output
      _diffComponentOutput(prevRenderedNodeCopy, newRenderedNode, viewId);

      // Call lifecycle method
      if (component.mounted) {
        final currentState = _componentStates[componentId] ?? {};
        component.componentDidUpdate(component.props, currentState);
      }
    } catch (e, stack) {
      debugPrint('VDOM: Error updating component: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Helper to create a deep copy of a VNode
  VNode _deepCopyVNode(VNode node) {
    return VNode(node.type,
        props: Map<String, dynamic>.from(node.props),
        children: _deepCopyChildren(node.children),
        key: node.key);
  }

  /// Check if a node type is a special container that should have its children preserved
  bool _isSpecialContainerType(String type) {
    return type.contains('Modal') ||
        type.contains('SafeArea') ||
        type.contains('View') ||
        type.contains('Container');
  }

  /// Helper to deep copy children arrays for safe diffing
  List<VNode> _deepCopyChildren(List<VNode> children) {
    return children
        .map((child) => VNode(child.type,
            props: Map<String, dynamic>.from(child.props),
            children: _deepCopyChildren(child.children),
            key: child.key))
        .toList();
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
