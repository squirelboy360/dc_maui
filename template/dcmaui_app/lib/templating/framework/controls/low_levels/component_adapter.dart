import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/foundation.dart';

/// ComponentAdapter bridges between VNode components and Controls
/// This allows Components to be included in the Control tree
class ComponentAdapter extends Control {
  final VNode componentNode;

  ComponentAdapter(this.componentNode);

  @override
  VNode build() {
    // CRITICAL FIX: Make sure the component node has a proper key
    if (componentNode.key.isEmpty || componentNode.key == 'null') {
      debugPrint(
          'ComponentAdapter: WARNING - Component has no key, generating one');
      return VNode(
        componentNode.type,
        props: componentNode.props,
        children: componentNode.children,
        key: 'adapter_${identityHashCode(this)}',
      );
    }

    // Pass through the component node directly
    return componentNode;
  }
}
