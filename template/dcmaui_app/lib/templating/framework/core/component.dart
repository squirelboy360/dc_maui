import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

/// Base Component class providing lifecycle hooks similar to React components
abstract class Component {
  // Component properties
  late Map<String, dynamic> props = {};

  // Component state - needs to be accessed by ComponentVDOM, so using public field with getter
  late Map<String, dynamic> _state = {};
  Map<String, dynamic> get state => Map.unmodifiable(_state);

  // Context API implementation
  final Map<String, dynamic> _context = {};
  Map<String, dynamic> get context => Map.unmodifiable(_context);

  // Reference to the VDOM renderer - public for ComponentVDOM access
  Function? updateCallback;

  // Flag to track if component is mounted - public for ComponentVDOM access
  bool mounted = false;

  Component();

  // Set state and trigger a re-render
  void setState(Map<String, dynamic> partialState) {
    if (!mounted) {
      if (kDebugMode) {
        print('Warning: setState called on unmounted component');
      }
      return;
    }

    debugPrint('Component: Setting state: $partialState');

    final prevState = Map<String, dynamic>.from(_state);
    _state.addAll(partialState);

    // Only trigger componentDidUpdate if something actually changed
    bool stateChanged = false;
    for (final key in partialState.keys) {
      if (!prevState.containsKey(key) || prevState[key] != _state[key]) {
        stateChanged = true;
        break;
      }
    }

    if (stateChanged) {
      if (shouldComponentUpdate(props, _state)) {
        debugPrint('Component: State changed, triggering update');
        componentDidUpdate(props, prevState);
        updateCallback?.call(); // Trigger VDOM update
      } else {
        debugPrint(
            'Component: shouldComponentUpdate returned false, skipping update');
      }
    } else {
      debugPrint('Component: No state changes detected, skipping update');
    }
  }

  // Initialize state with values
  void initializeState(Map<String, dynamic> initialState) {
    _state.clear();
    _state.addAll(initialState);
  }

  // Create the VNode tree that represents this component
  VNode render();

  // Initialize state - called before first render
  Map<String, dynamic> getInitialState() => {};

  // LIFECYCLE METHODS

  // Called before component mounts
  void componentWillMount() {}

  // Called after component mounts
  void componentDidMount() {}

  // Called before component updates
  bool shouldComponentUpdate(
          Map<String, dynamic> nextProps, Map<String, dynamic> nextState) =>
      true;

  // Called after component updates
  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {}

  // Called before component unmounts
  void componentWillUnmount() {}
}
