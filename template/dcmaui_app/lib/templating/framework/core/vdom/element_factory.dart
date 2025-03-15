import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

/// Factory for creating VDOM elements (React-like)
class ElementFactory {
  /// Create a standard element (like a div, View, Text, etc.)
  static VNode createElement(
      String type, Map<String, dynamic> props, List<VNode> children) {
    // Generate a unique key if not provided
    final key = props['key'] as String? ?? _generateKey(type);

    // Create and return the VNode using the proper constructor
    final node = VNode(
      type,
      props: props,
      key: key,
      children: children,
    );
    debugPrint('ElementFactory: Created $type element with key $key');
    return node;
  }

  /// Create a component element (class/function component)
  static VNode createComponent(
      Component Function() constructor, Map<String, dynamic> props) {
    // Generate a unique component ID
    final componentId = _generateComponentId();

    // Generate a unique key if not provided
    final key = props['key'] as String? ?? _generateKey('component');

    // Add component-specific props
    final componentProps = Map<String, dynamic>.from(props)
      ..['_isComponent'] = true
      ..['_componentId'] = componentId
      ..['_componentConstructor'] = constructor;

    // Create and return the VNode using the proper constructor
    final node = VNode(
      'component',
      props: componentProps,
      key: key,
      children: [], // Components don't have direct children in props
    );
    debugPrint(
        'ElementFactory: Created component with ID $componentId and key $key');
    return node;
  }

  // Counter for generating unique keys
  static int _keyCounter = 0;
  static String _generateKey(String prefix) {
    return '${prefix}_el_${_keyCounter++}';
  }

  // Counter for generating unique component IDs
  static int _componentCounter = 0;
  static String _generateComponentId() {
    return 'component_el_${_componentCounter++}';
  }
}

// Add this extension at the end of the file
extension VNodeExtension on VNode {
  // Helper to access the VNode directly
  VNode get vnode => this;
}
