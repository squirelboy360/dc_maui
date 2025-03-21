import 'dart:convert';
import 'vdom_node.dart';

/// Element node
class VDomElement extends VDomNode {
  final String type;
  final Map<String, dynamic>
      props; // This may contain event handlers like 'onPress', 'onChange'
  final List<VDomNode> children;

  VDomElement({
    required this.type,
    required this.props,
    required this.children,
  });

  @override
  String toString() {
    final propsString = props.isEmpty ? '' : ' props=${jsonEncode(props)}';

    final childrenString = children.isEmpty
        ? ''
        : ' children=[${children.map((c) => c.toString()).join(', ')}]';

    return '<$type$propsString$childrenString>';
  }
}
