import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Base class for all UI controls
abstract class Control {
  /// Convert this control to a VNode for rendering
  VNode build();

  /// Utility method to create node list from children controls
  List<VNode> buildChildren(List<Control> children) {
    return children.map((child) => child.build()).toList();
  }
}

/// Base class for all style properties
abstract class StyleProps {
  Map<String, dynamic> toMap();
}

/// Base class for all control props
abstract class ControlProps {
  Map<String, dynamic> toMap();
}
