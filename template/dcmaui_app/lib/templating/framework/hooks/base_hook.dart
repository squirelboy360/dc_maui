import 'package:dc_test/templating/framework/core/component.dart';
import 'package:flutter/foundation.dart';

/// Base class for all hooks
abstract class BaseHook {
  final String hookId;
  Component? _component;

  BaseHook(this.hookId);

  /// Register the component that owns this hook
  void registerComponent(Component component) {
    _component = component;

    // Mark the component as using hooks for state
    component.useHooksForState();
  }

  /// Trigger a component update
  void triggerUpdate() {
    _component?.updateCallback?.call();
  }

  /// Clean up resources when component unmounts
  void dispose() {
    // Implement in subclasses
  }
}
