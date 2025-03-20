import 'package:dc_test/templating/framework/core/main/abstractions/utility/performance_monitor.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/controls/low_levels/state_controller.dart';
import 'package:flutter/foundation.dart';

/// Base Component class for function-like components
abstract class Component {
  // Internal properties - only props and lifecycle, no state management
  Map<String, dynamic> _props = {};
  bool _mounted = false;
  Function? _updateCallback;
  String? _componentId;

  // Internal state storage - no need for external access
  final Map<String, dynamic> _state = {};
  final Map<String, StateValue> _stateHooks = {};

  // Performance tracking
  static bool showPerformanceWarnings = kDebugMode;
  static bool _performanceTrackingEnabled = false;

  // Getter for props (read-only)
  Map<String, dynamic> get props => Map.unmodifiable(_props);

  // Setter for props
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

  // Update state and trigger re-render
  void setState(Map<String, dynamic> newState) {
    bool hasChanges = false;

    debugPrint('Component: setState called with $newState');

    // Update state values
    for (final key in newState.keys) {
      final oldValue = _state[key];
      final newValue = newState[key];

      if (oldValue != newValue) {
        debugPrint(
            'Component $componentId: State "$key" changing from $oldValue to $newValue');
        _state[key] = newValue;

        // Update any associated state hooks
        if (_stateHooks.containsKey(key)) {
          _stateHooks[key]!.updateCurrentValue(newValue);
        }

        hasChanges = true;
      }
    }

    // Only trigger update if something actually changed
    if (hasChanges && _updateCallback != null) {
      debugPrint(
          'Component $componentId: Changes detected, triggering update...');
      // CRITICAL FIX: Use direct callback for VDOM updates, not microtask
      _updateCallback!();
    } else if (!hasChanges) {
      debugPrint(
          'Component $componentId: No changes detected, skipping update');
    } else if (_updateCallback == null) {
      debugPrint(
          'Component $componentId: WARNING - No update callback registered!');
    }
  }

  // React-like useState hook - the ONLY way to use state
  StateValue<T> useState<T>(String name, T initialValue) {
    // If we already have this state hook, return it
    if (_stateHooks.containsKey(name)) {
      return _stateHooks[name] as StateValue<T>;
    }

    // Initialize state if needed
    if (!_state.containsKey(name)) {
      _state[name] = initialValue;
    }

    // Create the state controller
    final controller = StateValue<T>(
      name: name,
      initialValue: _state[name] as T,
      componentId: componentId,
      setState: setState,
    );

    // Store for future reference
    _stateHooks[name] = controller;

    return controller;
  }

  // Lifecycle methods - can be overridden in subclasses
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
