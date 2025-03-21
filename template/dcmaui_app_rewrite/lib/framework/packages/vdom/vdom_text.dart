import 'vdom_node.dart';

/// Text node
/// This is a special type of VDomNode that represents pure text content
/// Unlike components, text nodes don't have children or internal logic
/// They are terminal/leaf nodes in the VDOM tree
class VDomText extends VDomNode {
  final String content;

  VDomText({required this.content});

  @override
  String toString() {
    return '"$content"';
  }
}
