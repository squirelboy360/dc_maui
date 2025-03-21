import 'vdom_node.dart';
import 'vdom_element.dart';
import 'vdom_patch.dart';

/// VDOM root node
class VDomRoot {
  VDomNode? _mountedNode;

  void mountNode(VDomNode node) {
    _mountedNode = node;
  }

  void applyPatch(VDomPatch patch, List<String> pathParts) {
    // Skip the first '0' which refers to the root
    final realPathParts = pathParts.sublist(1);
    _applyPatchToNode(_mountedNode!, patch, realPathParts);
  }

  void _applyPatchToNode(
      VDomNode node, VDomPatch patch, List<String> pathParts) {
    // Implementation would apply patches to actual native UI
    // For now we'll just modify the VDOM
    if (pathParts.isEmpty) {
      // Apply patch directly to this node
      switch (patch.type) {
        case PatchType.replace:
          // Would replace the actual node implementation
          break;
        case PatchType.props:
          if (node is VDomElement) {
            final propChanges = patch.payload as Map<String, dynamic>;
            propChanges.forEach((key, value) {
              if (value == null) {
                node.props.remove(key);
              } else {
                node.props[key] = value;
              }
            });
          }
          break;
        // Additional patch handling...
        default:
          break;
      }
    } else {
      // Navigate to child node
      final index = int.parse(pathParts[0]);
      if (node is VDomElement && index < node.children.length) {
        _applyPatchToNode(node.children[index], patch, pathParts.sublist(1));
      }
    }
  }

  @override
  String toString() {
    return _mountedNode?.toString() ?? 'Empty Root';
  }
}
