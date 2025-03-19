import 'package:dc_test/templating/framework/core/main/abstractions/hooks/component_hooks.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/hooks/use_state.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/utility/performance_monitor.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/foundation.dart';

/// Base Component class for function-like components
abstract class Component {
  // Internal state
  Map<String, dynamic> _state = {};
  Map<String, dynamic> _props = {};
  bool _mounted = false;
  Function? _updateCallback;
  String? _componentId;
  ComponentHooks? _hooks;

  // Performance tracking
  static bool showPerformanceWarnings = kDebugMode;
  static bool _performanceTrackingEnabled = false;

  // Getter for state (read-only)
  Map<String, dynamic> get state => Map.unmodifiable(_state);

  // Getter for props (read-only)
  Map<String, dynamic> get props => Map.unmodifiable(_props);

  // Modified: Add a setter for props to address the analyzer error
  set props(Map<String, dynamic> newProps) {
    _props = Map<String, dynamic>.from(newProps);
  }

  // Getter/setter for mounted state
  bool get mounted => _mounted;
  set mounted(bool value) => _mounted = value;

  // Getter/setter for update callback
  Function? get updateCallback => _updateCallback;
  set updateCallback(Function? callback) => _updateCallback = callback;

  // Getter for component ID
  String get componentId =>
      _componentId ?? 'component_${identityHashCode(this)}';

  // Initialize component with props
  void initProps(Map<String, dynamic> props) {
    _props = Map<String, dynamic>.from(props);
  }

  // Initialize component state
  void initializeState(Map<String, dynamic> initialState) {
    _state = Map<String, dynamic>.from(initialState);

    // Initialize component ID if needed
    _componentId ??= 'component_${identityHashCode(this)}';

    // Initialize hooks system if not already
    _hooks ??= ComponentHooks(this);
    _hooks!.syncStateToComponent();
  }

  // Update component state
  void setState(Map<String, dynamic> newState) {
    if (!_mounted) {
      debugPrint('WARNING: setState called on unmounted component');
      return;
    }

    // Make a copy of the current state for comparison
    final oldState = Map<String, dynamic>.from(_state);

    // Update state with new values
    _state.addAll(newState);

    // Check if state actually changed
    bool stateChanged = false;
    for (final key in newState.keys) {
      if (oldState[key] != newState[key]) {
        stateChanged = true;
        break;
      }
    }

    // CRITICAL FIX: Only trigger update if state actually changed
    if (stateChanged) {
      debugPrint(
          'Component: State changed, triggering update for $componentId');

      // Call update callback to trigger re-render
      if (_updateCallback != null) {
        _updateCallback!();
      }
    }
  }

  // Create a new hook
  UseState<T> useState<T>(String name, T initialValue) {
    _hooks ??= ComponentHooks(this);
    return _hooks!.useState<T>(name, initialValue);
  }

  // Get initial state - override in subclasses
  Map<String, dynamic> getInitialState() {
    return {};
  }

  // Clean up component resources
  void dispose() {
    if (_hooks != null) {
      _hooks!.dispose();
    }
  }

  // Lifecycle methods - can be overridden in subclasses
  void componentWillMount() {}
  void componentDidMount() {}
  void componentWillUnmount() {}
  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {}

  // Should component update - can be overridden for optimization
  bool shouldComponentUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState) {
    return true;
  }

  // Build the render tree - must be implemented by subclasses
  VNode buildRender();

  // Public render method with performance tracking
  VNode render() {
    if (_performanceTrackingEnabled && showPerformanceWarnings) {
      final stopwatch = Stopwatch()..start();
      final result = buildRender();
      stopwatch.stop();

      // Track performance
      PerformanceMonitor.instance.trackRender(
          componentId, runtimeType.toString(), stopwatch.elapsedMicroseconds);

      return result;
    } else {
      return buildRender();
    }
  }

  // Helper for deferred rendering
  String toTreeString() {
    return "Component(${runtimeType.toString()})";
  }

  // Enable or disable performance tracking
  static void enablePerformanceTracking(bool enabled) {
    _performanceTrackingEnabled = enabled;
  }
}
