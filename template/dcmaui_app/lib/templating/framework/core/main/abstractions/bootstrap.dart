import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/main/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/error_boundary.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/native_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/optimized_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node/element_factory.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/utility/performance_monitor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide DCTextStyle;

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

  // Create VDOM instance based on configuration
  final vdom = enableOptimizations ? NativeOptimizedVDOM() : NativeVDOM();

  // Set up error boundary props
  final errorProps = errorBoundaryProps ??
      ErrorBoundaryProps(
        id: 'root-error-boundary',
        fallback: (error, reset) => DCView(
          children: [
            DCText(
              text: 'Something went wrong',
              style: DCTextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight,
              ),
            ),
            DCText(
              style: DCTextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              error.toString(),
            ),
            DCButton(
              title: 'Try Again',
              onPress: (_) => reset(),
            ),
          ],
        ),
        onError: (error, stack) {
          if (kDebugMode) {
            print('DC Framework root error boundary caught error: $error');
            if (stack != null) print(stack);
          }
        },
      );

  // Always wrap app in error boundary for protection
  final rootComponent = ElementFactory.createComponent(
    () => ErrorBoundary(
      errorProps,
      [
        ComponentAdapter(ElementFactory.createComponent(
            appComponentConstructor, appProps ?? {'key': 'root-app'}))
      ],
    ),
    {'key': 'root-error-boundary'},
  );

  try {
    // Render the app
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
