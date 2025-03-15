import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/utility/state_abstraction.dart';
import 'package:flutter/foundation.dart';

/// Base Component class providing lifecycle hooks similar to React components
abstract class Component {
  // Component properties
  late Map<String, dynamic> props = {};

  // Component ID used for state tracking
  late String _componentId;
  String get componentId => _componentId;

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

  // Flag to prevent multiple state updates in rapid succession
  bool _isUpdating = false;

  Component() {
    // Generate a unique ID for this component instance
    _componentId = 'component_${identityHashCode(this)}';
  }

  // Set state and trigger a re-render
  void setState(Map<String, dynamic> partialState) {
    if (!mounted) {
      if (kDebugMode) {
        print('Warning: setState called on unmounted component');
      }
      return;
    }

    // Prevent reentrant state updates during a render cycle
    if (_isUpdating) {
      if (kDebugMode) {
        print('Warning: setState called during update cycle, deferring update');
      }
      // Defer the state update until after current update finishes
      Future.microtask(() => setState(partialState));
      return;
    }

    _isUpdating = true;
    debugPrint('Component: Setting state: $partialState');

    final prevState = Map<String, dynamic>.from(_state);
    _state.addAll(partialState);

    // Also update in the global state manager
    for (final entry in partialState.entries) {
      GlobalStateManager.instance
          .setState(_componentId, entry.key, entry.value);
    }

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

        // Schedule update callback to avoid potential recursive updates
        Future.microtask(() {
          if (mounted) {
            updateCallback?.call();
          }
          _isUpdating = false;
        });
      } else {
        debugPrint(
            'Component: shouldComponentUpdate returned false, skipping update');
        _isUpdating = false;
      }
    } else {
      debugPrint('Component: No state changes detected, skipping update');
      _isUpdating = false;
    }
  }

  // Initialize state with values
  void initializeState(Map<String, dynamic> initialState) {
    _state.clear();
    _state.addAll(initialState);

    // Also initialize in the global state manager
    GlobalStateManager.instance.initializeState(_componentId, initialState);
  }

  // Register an event handler with proper state isolation
  void registerEventHandler(String eventName, Function handler) {
    GlobalStateManager.instance
        .registerEventHandler(_componentId, eventName, handler);
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
  void componentWillUnmount() {
    // Clean up any state in the global state manager
    GlobalStateManager.instance.cleanupState(_componentId);
  }
}
