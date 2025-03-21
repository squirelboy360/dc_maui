import 'vdom_node.dart';
import 'vdom_component.dart';

/// Base class for stateful components
abstract class StatefulComponent implements VDomComponentClass {
  Map<String, dynamic> props = {};
  Map<String, dynamic> state = {};

  StatefulComponent([Map<String, dynamic>? initialProps]) {
    props = initialProps ?? {};
    initState();
  }

  /// Initialize component state
  void initState() {}

  /// Update state and trigger re-render
  void setState(Map<String, dynamic> newState) {
    state = {...state, ...newState};
    // This is where you would add code to:
    // 1. Call the component's render() method to get a new VDOM tree
    // 2. Pass this new tree to a parent VDOM instance
    // 3. Trigger the diff and patch process
  }

  /// Build component tree
  @override
  VDomNode render();
}
