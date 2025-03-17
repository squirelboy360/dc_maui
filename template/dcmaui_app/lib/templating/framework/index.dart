// DC Framework Main Index
// Import this file to get access to the entire framework

// Core modules
import 'core/core.dart';

export 'core/index.dart';
export 'core/vdom/index.dart';
export 'core/context.dart'; // Export context directly for easy access
export 'core/error_boundary.dart'; // Export error boundary directly

// UI Controls - with consistent DC prefixed naming
export 'controls/index.dart';
export 'controls/view.dart'; // Export controls directly for convenience
export 'controls/text.dart';
export 'controls/button.dart';
export 'controls/modal.dart';

// State and hooks
export 'hooks/index.dart';
export 'hooks/use_state.dart'; // Export commonly used hooks directly
export 'hooks/use_effect.dart';
export 'hooks/use_memo.dart';

// Utilities
export 'utility/index.dart';
export 'utility/state_abstraction.dart'; // Export state management directly
export 'utility/performance_monitor.dart';

// Animation
export 'animation/index.dart';

/// DC Framework Version
const String dcFrameworkVersion = '0.1.1'; // Updated version

// Add debugging helpers for common framework issues
class DCFrameworkDebug {
  /// Check if native bridge is properly connected
  static Future<bool> checkNativeBridge() async {
    try {
      // Try to create a simple view to test the bridge
      await MainViewCoordinatorInterface.createView(
          'debug_test_view', 'DCView', {
        'style': {'backgroundColor': '#FFFFFF'}
      });
      return true;
    } catch (e) {
      print('DC Framework: Native bridge test failed - $e');
      return false;
    }
  }

  /// Log the active view registry for debugging
  static void logViewRegistry() {
    MainViewCoordinatorInterface.logNativeViewTree();
  }

  /// Reset the view registry if views become unresponsive
  static Future<bool> resetRegistry() async {
    try {
      await MainViewCoordinatorInterface.resetViewRegistry();
      return true;
    } catch (e) {
      print('DC Framework: Reset registry failed - $e');
      return false;
    }
  }
}
