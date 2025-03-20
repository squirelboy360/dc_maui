import 'package:flutter/foundation.dart';

/// Simple state controller for components
class StateValue<T> {
  final String name;
  final T initialValue;
  final String componentId;
  final Function(Map<String, dynamic>) setState;
  // Track current value
  T _currentValue;

  StateValue({
    required this.name,
    required this.initialValue,
    required this.componentId,
    required this.setState,
  }) : _currentValue = initialValue;

  /// Get the current value
  T get value => _currentValue;

  /// Set a new value by updating the VDOM
  set value(T newValue) {
    // Record value change
    debugPrint('StateValue: Setting $name from $_currentValue to $newValue');
    _currentValue = newValue;

    // CRITICAL FIX: Create a new Map instance to ensure state update is processed
    final updates = <String, dynamic>{};
    updates[name] = newValue;

    // Call setState directly, without scheduling
    try {
      setState(updates);
      debugPrint(
          'StateValue: State update completed for $name with value $newValue');
    } catch (e) {
      debugPrint('StateValue: ERROR updating state: $e');
    }
  }

  // Update the internally tracked value - called from Component when state changes
  void updateCurrentValue(T newValue) {
    // CRITICAL FIX: Log all state changes for debugging
    debugPrint(
        'StateValue: Internal value for $name updated from $_currentValue to $newValue');
    _currentValue = newValue;
  }
}
