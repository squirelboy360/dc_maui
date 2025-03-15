import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/hooks/base_hook.dart';
import 'package:flutter/foundation.dart';

/// Effect hook similar to React's useEffect
class UseEffect extends BaseHook {
  Function? _cleanup;
  List<dynamic>? _lastDeps;

  UseEffect(String effectId, {Component? component})
      : super('effect_$effectId') {
    if (component != null) {
      registerComponent(component);
    }
  }

  /// Run the effect function with optional dependencies
  void run(Function() effect, [List<dynamic>? dependencies]) {
    // If no dependencies provided, run every time
    final shouldRun = dependencies == null ||
        _lastDeps == null ||
        !_areListsEqual(_lastDeps!, dependencies);

    if (shouldRun) {
      // Run cleanup from previous effect if it exists
      if (_cleanup != null) {
        if (kDebugMode) {
          print('UseEffect: Running cleanup for $hookId');
        }
        _cleanup!();
      }

      // Run the effect and capture cleanup function
      if (kDebugMode) {
        print('UseEffect: Running effect for $hookId');
      }

      _cleanup = effect();
      _lastDeps = dependencies;
    }
  }

  /// Clean up resources when component unmounts
  @override
  void dispose() {
    if (_cleanup != null) {
      if (kDebugMode) {
        print('UseEffect: Running cleanup during dispose for $hookId');
      }
      _cleanup!();
      _cleanup = null;
    }
  }

  // Helper function to compare dependency lists
  bool _areListsEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
