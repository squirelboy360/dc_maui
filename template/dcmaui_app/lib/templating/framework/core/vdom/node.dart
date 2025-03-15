/// A virtual DOM node
class VNode {
  /// The node type (e.g., 'view', 'text', 'component')
  final String type;

  /// Props (properties) for this node
  Map<String, dynamic> props;

  /// Unique key for reconciliation
  final String key;

  /// Child nodes
  final List<VNode> children;

  /// Constructor
  VNode(
    this.type, {
    Map<String, dynamic>? props,
    String? key,
    List<VNode>? children,
  })  : props = props ?? {},
        key = key ?? '',
        children = children ?? [];

  @override
  String toString() =>
      'VNode($type, key=$key, props=$props, children=$children)';
}
