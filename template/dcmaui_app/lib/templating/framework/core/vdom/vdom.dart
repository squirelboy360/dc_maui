import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

class VDOM {
  // Make previousTree protected for subclasses to access
  VNode? _previousTree;

  // Make this accessible to subclasses
  final Map<String, String> nodeToViewId = {};
  int _viewIdCounter = 0;

  // Get a stable view ID for a node - changed to protected (no underscore)
  String getViewId(VNode node) {
    // CRITICAL FIX: Use only the key for stable IDs
    // Using node key alone instead of combining with type gives more stable IDs across renders
    final nodeKey = node.key;

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

  bool _arePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

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

  // Replace an old view with a completely new one
  void _replaceView(VNode oldNode, VNode newNode) {
    final oldViewId = getViewId(oldNode);

    // First delete the old view and all its children
    deleteView(oldViewId);

    // Then mount the new tree
    _mount(newNode);
  }

  // Create a view on the native side
  void createView(VNode node, String viewId) {
    debugPrint(
        'VDOM: Create view: $viewId, type: ${node.type}, props: ${node.props}');
    MainViewCoordinatorInterface.createView(viewId, node.type, node.props);
    debugPrint('VDOM: Create view call sent to native for $viewId');
  }

  // Update a view on the native side
  void updateView(VNode oldNode, VNode newNode, String viewId) {
    debugPrint(
        'VDOM: Update view: $viewId, type: ${newNode.type}, props: ${newNode.props}');
    MainViewCoordinatorInterface.updateView(viewId, newNode.props);
  }

  // Directly update props on a view without full diff
  void updateViewProps(String viewId, Map<String, dynamic> props) {
    debugPrint('VDOM: Directly updating props for $viewId');
    MainViewCoordinatorInterface.updateView(viewId, props);
  }

  // Delete a view on the native side
  void deleteView(String viewId) {
    debugPrint('VDOM: Delete view: $viewId');
    MainViewCoordinatorInterface.deleteView(viewId);
  }

  // Set children relationship on the native side
  void setChildren(String parentId, List<String> childIds) {
    debugPrint('VDOM: Set children for $parentId: $childIds');
    MainViewCoordinatorInterface.setChildren(parentId, childIds);
  }

  // Log the VDOM tree (for debugging)
  void _logTree(VNode node, [int depth = 0]) {
    final indent = ' ' * (depth * 2);
    final viewId = getViewId(node);
    debugPrint('$indent$viewId: ${node.type} (props: ${node.props})');

    for (final child in node.children) {
      _logTree(child, depth + 1);
    }
  }
}
