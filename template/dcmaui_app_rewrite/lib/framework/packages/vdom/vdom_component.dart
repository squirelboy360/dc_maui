import 'vdom_node.dart';

/// Component class interface
abstract class VDomComponentClass {
  VDomNode render();
}

/// Component node
class VDomComponent extends VDomNode {
  final VDomComponentClass component;
  final Map<String, dynamic> props;
  VDomNode? _renderedNode;

  VDomComponent({
    required this.component,
    required this.props,
  }) {
    _renderedNode = component.render();
  }

  @override
  String toString() {
    return 'Component(${component.runtimeType}): ${_renderedNode?.toString() ?? 'Not Rendered'}';
  }
}
