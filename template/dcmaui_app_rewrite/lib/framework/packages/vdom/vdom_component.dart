import 'package:dc_test/framework/packages/vdom/component.dart';

import 'vdom_node.dart';

/// Component class interface
abstract class VDomComponentClass {
  VDomNode render();
}

/// Component node
class VDomComponent extends VDomNode {
  final VDomComponentClass component;
  final Map<String, dynamic> props;
  // Changed to public to allow access from renderer
  VDomNode? renderedNode;

  VDomComponent({
    required this.component,
    required this.props,
  }) {
    renderedNode = component.render();
  }

  /// Update this component's props and re-render
  void updateProps(Map<String, dynamic> newProps) {
    // Update individual props
    newProps.forEach((key, value) {
      if (value == null) {
        props.remove(key);
      } else {
        props[key] = value;
      }
    });

    // If the component is stateful, update its props
    if (component is StatefulComponent) {
      (component as StatefulComponent).props = Map.from(props);
    }

    // Re-render the component
    renderedNode = component.render();
  }

  @override
  String toString() {
    return 'Component(${component.runtimeType}): ${renderedNode?.toString() ?? 'Not Rendered'}';
  }
}
