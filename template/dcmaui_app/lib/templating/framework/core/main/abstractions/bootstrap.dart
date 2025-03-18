import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/main/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/error_boundary.dart';
import 'package:dc_test/templating/framework/core/vdom/unified_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node/element_factory.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/utility/performance_monitor.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/vdom.dart';
import 'package:flutter/foundation.dart';

/// DC Framework bootstrap function - initializes the framework and renders the app
///
/// Example usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await dcBind(() => MyApp());
/// }
/// ```
Future<void> dcBind(
  Component Function() appComponentConstructor, {
  bool enableOptimizations = true,
  bool enablePerformanceTracking = kDebugMode,
  ErrorBoundaryProps? errorBoundaryProps,
  Map<String, dynamic>? appProps,
}) async {
  try {
    // Initialize native bridge
    await MainViewCoordinatorInterface.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to initialize DC Framework native bridge: $e');
    }
  }

  // Configure performance monitoring
  PerformanceMonitor.instance.trackingEnabled = enablePerformanceTracking;
  if (enablePerformanceTracking) {
    PerformanceMonitor.instance.takeMemorySnapshot('app_start');
    Component.showPerformanceWarnings = true;
    Component.enablePerformanceTracking(true);
  }

  // Create VDOM instance with optimization toggle
  final vdom = VDOM();

  // Set up error boundary props

  // CRITICAL FIX: Ensure both ErrorBoundary and MainApp have proper keys
  final appPropsWithKey = appProps ?? {};
  if (!appPropsWithKey.containsKey('key')) {
    appPropsWithKey['key'] = 'root-app';
  }

  // Create the app component first
  final appComponent =
      ElementFactory.createComponent(appComponentConstructor, appPropsWithKey);

  // Debug output for component creation
  debugPrint(
      'Bootstrap: Created app component with key ${appPropsWithKey["key"]}');

  // Then wrap it in ErrorBoundary
  final rootComponent = ElementFactory.createComponent(
    () => ErrorBoundary(
        errorBoundaryProps ?? ErrorBoundaryProps(id: 'root-error-boundary'),
        [ComponentAdapter(appComponent)]),
    {'key': 'root-error-boundary'},
  );

  try {
    // Render the app with extra debugging
    debugPrint('DC Bootstrap: Rendering root component (ErrorBoundary)');
    vdom.render(rootComponent);

    // Log debug information
    if (kDebugMode) {
      MainViewCoordinatorInterface.logNativeViewTree();

      if (enablePerformanceTracking) {
        PerformanceMonitor.instance.takeMemorySnapshot('app_rendered');

        // Log initial performance report after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          final report = PerformanceMonitor.instance.getPerformanceReport();
          debugPrint('DC Framework Performance Report: $report');
        });
      }
    }
  } catch (e, stack) {
    if (kDebugMode) {
      print('ERROR: Failed to render DC app: $e');
      print(stack);
    }
  }

  return Future.value();
}
