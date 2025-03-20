import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/foundation.dart';

/// Factory for creating VDOM elements (React-like)
class ElementFactory {
  // Counter for generating unique component IDs
  static int _componentCounter = 0;
  static String _generateComponentId() {
    return 'component_el_${_componentCounter++}';
  }

  // Counter for generating unique node keys
  static int _nodeCounter = 0;

  // Create element with the right type - always use DC prefix
  static VNode createElement(
      String type, Map<String, dynamic> props, List<VNode> children) {
    // CRITICAL FIX: Generate a unique, stable key that includes the type
    final String nodeKey;
    if (props.containsKey('key') &&
        props['key'] != null &&
        props['key'] is String) {
      nodeKey = props['key'] as String;
    } else {
      nodeKey = '${type}_${_nodeCounter++}';
      props = Map<String, dynamic>.from(props)..['key'] = nodeKey;
    }

    // Log element creation with proper key
    if (kDebugMode) {
      debugPrint('ElementFactory: Created $type element with key $nodeKey');
    }

    return VNode(
      type,
      props: Map<String, dynamic>.from(props),
      children: List<VNode>.from(children),
      key: nodeKey,
    );
  }

  // Create component with the right settings
  static VNode createComponent(
    Component Function() constructor,
    Map<String, dynamic> props,
  ) {
    final componentId = _generateComponentId();

    // CRITICAL FIX: Ensure key exists and is preserved
    final nodeKey = props.containsKey('key') && props['key'] != null
        ? props['key'] as String
        : componentId;

    // Create a new props map with the key
    final enhancedProps = Map<String, dynamic>.from(props)
      ..['key'] = nodeKey
      ..['_isComponent'] = true
      ..['_componentId'] = componentId
      ..['_componentConstructor'] = constructor;

    // CRITICAL FIX: Make sure event handlers are properly set up
    final eventKeys = props.keys.where((key) => key.startsWith('on')).toList();
    if (eventKeys.isNotEmpty) {
      enhancedProps['_eventListeners'] = eventKeys;
    }

    // For debug tracing
    if (kDebugMode) {
      debugPrint(
          'ElementFactory: Created component with ID $componentId and key $nodeKey');
    }

    return VNode(
      'component',
      props: enhancedProps,
      children: [],
      key: nodeKey,
    );
  }
}

extension VNodeExtension on VNode {
  // Helper to access the VNode directly
  VNode get vnode => this;
}
