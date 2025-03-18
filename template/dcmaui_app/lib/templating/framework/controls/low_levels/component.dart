import 'package:dc_test/templating/framework/core/vdom/node/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/utility/state_abstraction.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/hooks/component_hooks.dart';
import 'package:flutter/foundation.dart';

/// Base Component class providing lifecycle hooks similar to React components
abstract class Component {
  // Component properties
  late Map<String, dynamic> props = {};

  // Component ID used for state tracking
  late String _componentId;
  String get componentId => _componentId;

  // Component state with improved change tracking
  late Map<String, dynamic> _state = {};
  final Map<String, dynamic> _previousState = {}; // Track previous state values
  Map<String, dynamic> get state => Map.unmodifiable(_state);

  // Context API implementation
  final Map<String, dynamic> _context = {};
  Map<String, dynamic> get context => Map.unmodifiable(_context);

  // Reference to the VDOM renderer - public for ComponentVDOM access
  Function? updateCallback;

  // Flag to track if component is mounted - public for ComponentVDOM access
  bool mounted = false;

  // Improved state update handling
  bool _isUpdating = false;
  final List<Map<String, dynamic>> _pendingStateUpdates = [];
  bool _hasScheduledUpdate = false;

  // Track if updates are suspended (for batch processing)
  bool _updatesSuspended = false;

  // Allow tracking of which state keys actually changed
  final Set<String> _changedStateKeys = {};

  // Error handling fields
  bool _hasError = false;
  dynamic _lastError;
  StackTrace? _lastErrorStack;

  // Performance tracking
  final Map<String, _LifecycleMetrics> _lifecycleMetrics = {};
  static bool _enablePerfTracking =
      true; // Enable performance tracking by default

  // Maximum allowed render time before warning (in milliseconds)
  static const int _warnRenderTimeThresholdMs = 16; // ~1 frame at 60fps

  // Class-level settings
  static bool showPerformanceWarnings = true;

  // Hooks integration
  late final ComponentHooks hooks;

  Component() {
    // Generate a unique ID for this component instance
    _componentId = 'component_${identityHashCode(this)}';

    // Initialize hooks
    hooks = ComponentHooks(this);
  }

  // Enable or disable performance tracking globally
  static void enablePerformanceTracking(bool enabled) {
    _enablePerfTracking = enabled;
  }

  // Get performance metrics for all lifecycle methods
  Map<String, Map<String, dynamic>> getPerformanceMetrics() {
    final result = <String, Map<String, dynamic>>{};

    for (final entry in _lifecycleMetrics.entries) {
      final metrics = entry.value;
      result[entry.key] = {
        'totalTime': metrics.totalTime,
        'callCount': metrics.callCount,
        'averageTime':
            metrics.callCount > 0 ? metrics.totalTime / metrics.callCount : 0,
        'maxTime': metrics.maxTime,
        'lastTime': metrics.lastTime,
      };
    }

    return result;
  }

  // Set state and trigger a re-render with improved batching
  void setState(Map<String, dynamic> partialState) {
    if (!mounted) {
      if (kDebugMode) {
        print(
            'Warning: setState called on unmounted component ${runtimeType.toString()}');
      }
      return;
    }

    // Queue updates during a render cycle for batching
    if (_isUpdating) {
      debugPrint('Component: Queueing state update during render cycle');
      _pendingStateUpdates.add(Map<String, dynamic>.from(partialState));
      return;
    }

    _isUpdating = true;
    debugPrint('Component: Setting state: $partialState');

    // Apply state update
    _applyStateUpdate(partialState);

    // Schedule the update if not already scheduled
    _scheduleUpdate();

    _isUpdating = false;
  }

  // Helper method to actually apply state changes
  void _applyStateUpdate(Map<String, dynamic> partialState) {
    // Track which keys actually changed values
    for (final entry in partialState.entries) {
      final key = entry.key;
      final newValue = entry.value;

      // Store previous state for comparison in lifecycle methods
      if (!_previousState.containsKey(key)) {
        _previousState[key] = _state.containsKey(key) ? _state[key] : null;
      }

      // Check if the value actually changed
      if (!_state.containsKey(key) || _state[key] != newValue) {
        _state[key] = newValue;
        _changedStateKeys.add(key);

        // Also update in the global state manager
        GlobalStateManager.instance.setState(_componentId, key, newValue);
      }
    }
  }

  // Schedule an update (if not already scheduled)
  void _scheduleUpdate() {
    if (_hasScheduledUpdate || _updatesSuspended) return;

    _hasScheduledUpdate = true;

    // Use microtask to batch multiple setState calls
    Future.microtask(() {
      if (!mounted) return;

      _hasScheduledUpdate = false;

      // Process any pending updates first
      while (_pendingStateUpdates.isNotEmpty) {
        _applyStateUpdate(_pendingStateUpdates.removeAt(0));
      }

      // If any states actually changed and shouldComponentUpdate agrees
      if (_changedStateKeys.isNotEmpty &&
          shouldComponentUpdate(props, _state)) {
        // Call lifecycle method with previous state
        final prevState = Map<String, dynamic>.from(_previousState);
        componentDidUpdate(props, prevState);

        // Clear tracked changes after update
        _previousState.clear();

        // Reset changed keys after update
        _changedStateKeys.clear();

        // Trigger VDOM update
        updateCallback?.call();
      }
    });
  }

  // New method to batch multiple state updates efficiently
  void batchUpdates(void Function() updateFunction) {
    final wasSuspended = _updatesSuspended;
    _updatesSuspended = true;

    try {
      updateFunction();
    } finally {
      _updatesSuspended = wasSuspended;

      // Process batched updates if this is the outermost batch
      if (!wasSuspended) {
        _scheduleUpdate();
      }
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
  VNode render() {
    // Start timing the render method
    final startTime = DateTime.now().microsecondsSinceEpoch;
    VNode result;

    try {
      // Call the actual component implementation
      result = buildRender();
    } catch (error, stackTrace) {
      // Handle render errors
      if (kDebugMode) {
        print('ERROR rendering component ${runtimeType.toString()}: $error');
        print(stackTrace);
      }

      _hasError = true;
      _lastError = error;
      _lastErrorStack = stackTrace;

      // Return a placeholder error node
      return ElementFactory.createElement(
        'DCText',
        {
          'content': 'Error rendering component: $error',
          'style': {'color': '#FF0000', 'padding': 16.0},
        },
        [],
      );
    } finally {
      // Measure render time
      final endTime = DateTime.now().microsecondsSinceEpoch;
      final renderTimeMs = (endTime - startTime) / 1000;

      // Track render performance
      _trackLifecyclePerformance('render', renderTimeMs);

      // Warn if render is too slow
      if (showPerformanceWarnings &&
          renderTimeMs > _warnRenderTimeThresholdMs) {
        debugPrint('PERFORMANCE WARNING: Component ${runtimeType.toString()} ' +
            'render took ${renderTimeMs.toStringAsFixed(2)}ms ' +
            '(threshold: ${_warnRenderTimeThresholdMs}ms)');
      }
    }

    return result;
  }

  // Actual render implementation - to be overridden by subclasses
  // The old render() method is replaced by this method
  VNode buildRender() {
    // Default implementation for backward compatibility
    // This method should be overridden by subclasses
    throw UnimplementedError(
        'buildRender() not implemented in ${runtimeType.toString()}. '
        'Override this method or continue using the legacy render() method.');
  }

  // Initialize state - called before first render
  Map<String, dynamic> getInitialState() => {};

  // LIFECYCLE METHODS WITH PERFORMANCE MONITORING

  // Called before component mounts
  void componentWillMount() {
    _startLifecycleTimer('componentWillMount');

    try {
      // Sync any hook state to component state
      hooks.syncStateToComponent();
    } finally {
      _stopLifecycleTimer('componentWillMount');
    }
  }

  // Called after component mounts
  void componentDidMount() {
    _startLifecycleTimer('componentDidMount');
    try {
      // Default empty implementation - to be overridden
    } finally {
      _stopLifecycleTimer('componentDidMount');
    }
  }

  // Called before component updates
  bool shouldComponentUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState) {
    _startLifecycleTimer('shouldComponentUpdate');
    try {
      // Default behavior: always update
      return true;
    } finally {
      _stopLifecycleTimer('shouldComponentUpdate');
    }
  }

  // Called after component updates
  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {
    _startLifecycleTimer('componentDidUpdate');
    try {
      // Default empty implementation - to be overridden
    } finally {
      _stopLifecycleTimer('componentDidUpdate');
    }
  }

  // Called before component unmounts
  void componentWillUnmount() {
    _startLifecycleTimer('componentWillUnmount');
    try {
      // Clean up hooks
      hooks.dispose();

      // Clean up any state in the global state manager
      GlobalStateManager.instance.cleanupState(_componentId);
    } finally {
      _stopLifecycleTimer('componentWillUnmount');
    }
  }

  // Error handling lifecycle method
  void componentDidCatch(dynamic error, StackTrace? stackTrace) {
    _startLifecycleTimer('componentDidCatch');
    try {
      // Default implementation - can be overridden
      if (kDebugMode) {
        print('Component: Error caught in ${runtimeType.toString()}: $error');
        if (stackTrace != null) print(stackTrace);
      }

      _hasError = true;
      _lastError = error;
      _lastErrorStack = stackTrace;
    } finally {
      _stopLifecycleTimer('componentDidCatch');
    }
  }

  // PERFORMANCE TRACKING METHODS

  // Start timing a lifecycle method
  void _startLifecycleTimer(String methodName) {
    if (!_enablePerfTracking) return;

    _lifecycleMetrics.putIfAbsent(methodName, () => _LifecycleMetrics());
    _lifecycleMetrics[methodName]!.startTime =
        DateTime.now().microsecondsSinceEpoch;
  }

  // Stop timing a lifecycle method and record metrics
  void _stopLifecycleTimer(String methodName) {
    if (!_enablePerfTracking) return;
    if (!_lifecycleMetrics.containsKey(methodName)) return;

    final metrics = _lifecycleMetrics[methodName]!;
    if (metrics.startTime == null) return;

    final endTime = DateTime.now().microsecondsSinceEpoch;
    final duration = endTime - metrics.startTime!;
    final durationMs = duration / 1000.0;

    // Update metrics
    metrics.lastTime = durationMs;
    metrics.totalTime += durationMs;
    metrics.callCount++;
    if (durationMs > metrics.maxTime) {
      metrics.maxTime = durationMs;
    }

    // Reset start time
    metrics.startTime = null;
  }

  // Track lifecycle method performance without using start/stop
  void _trackLifecyclePerformance(String methodName, double timeMs) {
    if (!_enablePerfTracking) return;

    _lifecycleMetrics.putIfAbsent(methodName, () => _LifecycleMetrics());
    final metrics = _lifecycleMetrics[methodName]!;

    // Update metrics
    metrics.lastTime = timeMs;
    metrics.totalTime += timeMs;
    metrics.callCount++;
    if (timeMs > metrics.maxTime) {
      metrics.maxTime = timeMs;
    }
  }

  // Force a component to update regardless of shouldComponentUpdate
  void forceUpdate() {
    if (!mounted) return;

    debugPrint('Component: Force update called');
    updateCallback?.call();
  }

  // Reset error state
  void resetError() {
    _hasError = false;
    _lastError = null;
    _lastErrorStack = null;

    // If the component uses error state, update it
    if (_state.containsKey('hasError')) {
      setState({
        'hasError': false,
        'error': null,
      });
    }
  }

  // Set context values
  void setContext(Map<String, dynamic> contextValues) {
    _context.addAll(contextValues);
  }

  // Apply referentially stable props - useful for skipping updates when props are the same
  static Map<String, dynamic> stableProps(Map<String, dynamic> props) {
    return Map.unmodifiable(props);
  }
}

// Helper class for tracking lifecycle method performance
class _LifecycleMetrics {
  int? startTime;
  double totalTime = 0;
  int callCount = 0;
  double maxTime = 0;
  double lastTime = 0;

  _LifecycleMetrics();
}
