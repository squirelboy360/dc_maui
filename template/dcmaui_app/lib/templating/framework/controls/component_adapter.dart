import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';

/// ComponentAdapter bridges between VNode components and Controls
/// This allows Components to be included in the Control tree
class ComponentAdapter extends Control {
  final VNode componentNode;

  ComponentAdapter(this.componentNode);

  @override
  VNode build() {
    // Simply pass through the component node directly
    return componentNode;
  }
}
