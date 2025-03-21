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

  @override
  String toString() {
    return 'Component(${component.runtimeType}): ${renderedNode?.toString() ?? 'Not Rendered'}';
  }
}
