import 'dart:developer' as developer;
import 'vdom.dart';
import 'vdom_node.dart';
import 'vdom_component.dart';

/// Base class for stateful components
abstract class StatefulComponent implements VDomComponentClass {
  Map<String, dynamic> props = {};
  Map<String, dynamic> state = {};

  // Reference to parent VDOM instance for re-rendering
  VDom? _parentVDom;
  // Reference to the component node in the VDOM tree
  VDomComponent? _componentNode;

  StatefulComponent([Map<String, dynamic>? initialProps]) {
    props = initialProps ?? {};
    initState();
  }

  /// Initialize component state
  void initState() {}

  /// Register this component with a parent VDOM instance and component node
  void registerWithVDom(VDom vdom, VDomComponent componentNode) {
    _parentVDom = vdom;
    _componentNode = componentNode;
  }

  /// Update state and trigger re-render
  void setState(Map<String, dynamic> newState) {
    // Update the state directly without creating an unused oldState variable
    state = {...state, ...newState};

    // If we have a parent VDOM instance, trigger a re-render
    if (_parentVDom != null && _componentNode != null) {
      // Get the new rendered tree
      final newRenderedTree = render();

      // Update the component's rendered node
      final oldRenderedNode = _componentNode!.renderedNode;
      _componentNode!.renderedNode = newRenderedTree;

      // Diff the old and new rendered trees
      if (oldRenderedNode != null) {
        final patches = _parentVDom!
            .diffComponent(oldRenderedNode, newRenderedTree, _componentNode!);

        // Apply the patches
        if (patches.isNotEmpty) {
          _parentVDom!.patchComponent(patches);
        }
      }
    } else {
      developer.log(
          'Warning: setState called but component is not connected to a VDOM instance',
          name: 'StatefulComponent');
    }
  }

  /// Build component tree
  @override
  VDomNode render();
}
