import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/foundation.dart';

/// Factory for creating VDOM elements (React-like)
class ElementFactory {
  // Counter for generating unique component IDs
  static int _componentCounter = 0;
  static String _generateComponentId() {
    return 'component_el_${_componentCounter++}';
  }

  // Create element with the right type - always use DC prefix
  static VNode createElement(
      String type, Map<String, dynamic> props, List<VNode> children) {
    // Log element creation in debug mode
    if (kDebugMode) {
      debugPrint(
          'ElementFactory: Created $type element with key ${props['key'] ?? 'unknown'}');
    }
    // Log element creation in debug mode
    if (kDebugMode) {
      debugPrint(
          'ElementFactory: Created  element with key ${props['key'] ?? 'unknown'}');
    }

    final nodeKey = props['key'] as String? ?? '${type}_el_${_nodeCounter++}';

    return VNode(
      type,
      props: Map<String, dynamic>.from(props),
      children: List<VNode>.from(children),
      key: nodeKey,
    );
  }

  // Counter for generating unique node keys
  static int _nodeCounter = 0;

  // Create component with the right settings
  static VNode createComponent(
    Component Function() constructor,
    Map<String, dynamic> props,
  ) {
    final componentId = _generateComponentId();

    // For debug tracing
    if (kDebugMode) {
      debugPrint(
          'ElementFactory: Created component with ID $componentId and key ${props['key'] ?? 'unknown'}');
    }

    final nodeKey = props['key'] as String? ?? componentId;

    return VNode(
      'component',
      props: {
        ...props,
        '_isComponent': true,
        '_componentId': componentId,
        '_componentConstructor': constructor,
      },
      children: [],
      key: nodeKey,
    );
  }
}

extension VNodeExtension on VNode {
  // Helper to access the VNode directly
  VNode get vnode => this;
}
