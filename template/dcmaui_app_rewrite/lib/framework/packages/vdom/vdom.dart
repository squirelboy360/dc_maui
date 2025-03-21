import 'vdom_node.dart';
import 'vdom_root.dart';
import 'vdom_element.dart';
import 'vdom_text.dart';
import 'vdom_component.dart';
import 'vdom_patch.dart';

/// Virtual DOM implementation for Flutter/MAUI
class VDom {
  VDomNode? _currentTree;
  VDomRoot? _root;

  /// Create a root node for the VDOM
  VDomRoot createRoot() {
    _root = VDomRoot();
    return _root!;
  }

  /// Create a VDOM element with type, props and children
  static VDomElement createElement(String type,
      {Map<String, dynamic>? props, List<VDomNode>? children}) {
    return VDomElement(
      type: type,
      props: props ?? {},
      children: children ?? [],
    );
  }

  /// Create a text node
  static VDomText createText(String content) {
    return VDomText(content: content);
  }

  /// Create a component node
  static VDomComponent createComponent(VDomComponentClass component,
      {Map<String, dynamic>? props}) {
    return VDomComponent(
      component: component,
      props: props ?? {},
    );
  }

  /// Render a tree to the root
  void render(VDomNode newTree) {
    if (_root == null) {
      throw Exception('Root not created. Call createRoot() first');
    }

    if (_currentTree == null) {
      // First render
      _currentTree = newTree;
      _root!.mountNode(newTree);
    } else {
      // Diff and patch
      final patches = _diff(_currentTree!, newTree);
      _patch(_root!, patches);
      _currentTree = newTree;
    }
  }

  /// Diff two VDOM trees and return a list of patches
  List<VDomPatch> _diff(VDomNode oldNode, VDomNode newNode,
      [String path = '0']) {
    final patches = <VDomPatch>[];

    // Different node types
    if (oldNode.runtimeType != newNode.runtimeType) {
      patches.add(
          VDomPatch(type: PatchType.replace, path: path, payload: newNode));
      return patches;
    }

    // Text nodes
    if (oldNode is VDomText && newNode is VDomText) {
      if (oldNode.content != newNode.content) {
        patches.add(VDomPatch(
            type: PatchType.text, path: path, payload: newNode.content));
      }
      return patches;
    }

    // Element nodes
    if (oldNode is VDomElement && newNode is VDomElement) {
      // Different element types
      if (oldNode.type != newNode.type) {
        patches.add(
            VDomPatch(type: PatchType.replace, path: path, payload: newNode));
        return patches;
      }

      // Props changed
      final propPatches = _diffProps(oldNode.props, newNode.props);
      if (propPatches.isNotEmpty) {
        patches.add(
            VDomPatch(type: PatchType.props, path: path, payload: propPatches));
      }

      // Children changed
      final oldChildren = oldNode.children;
      final newChildren = newNode.children;

      // Find the minimum length to compare
      final minLength = oldChildren.length < newChildren.length
          ? oldChildren.length
          : newChildren.length;

      // Check each child
      for (var i = 0; i < minLength; i++) {
        patches.addAll(_diff(oldChildren[i], newChildren[i], '$path.$i'));
      }

      // Added children
      if (oldChildren.length < newChildren.length) {
        for (var i = oldChildren.length; i < newChildren.length; i++) {
          patches.add(VDomPatch(
              type: PatchType.add, path: '$path.$i', payload: newChildren[i]));
        }
      }

      // Removed children
      if (oldChildren.length > newChildren.length) {
        for (var i = newChildren.length; i < oldChildren.length; i++) {
          patches.add(VDomPatch(
              type: PatchType.remove,
              path: '$path.${oldChildren.length - i - 1}'));
        }
      }

      return patches;
    }

    // Component nodes
    if (oldNode is VDomComponent && newNode is VDomComponent) {
      if (oldNode.component.runtimeType != newNode.component.runtimeType) {
        patches.add(
            VDomPatch(type: PatchType.replace, path: path, payload: newNode));
        return patches;
      }

      // Props changed
      final propPatches = _diffProps(oldNode.props, newNode.props);
      if (propPatches.isNotEmpty) {
        patches.add(VDomPatch(
            type: PatchType.componentProps, path: path, payload: propPatches));
      }

      return patches;
    }

    return patches;
  }

  /// Compare props and return changes
  Map<String, dynamic> _diffProps(
      Map<String, dynamic> oldProps, Map<String, dynamic> newProps) {
    final propPatches = <String, dynamic>{};

    // Check for changed and added props
    newProps.forEach((key, value) {
      if (!oldProps.containsKey(key) || !_deepEquals(oldProps[key], value)) {
        propPatches[key] = value;
      }
    });

    // Check for removed props
    for (var key in oldProps.keys) {
      if (!newProps.containsKey(key)) {
        propPatches[key] = null;
      }
    }

    return propPatches;
  }

  /// Apply patches to the VDOM
  void _patch(VDomRoot root, List<VDomPatch> patches) {
    for (final patch in patches) {
      final pathParts = patch.path.split('.');
      root.applyPatch(patch, pathParts);
    }
  }

  /// Deep equality check for objects
  bool _deepEquals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return false;
  }
}
