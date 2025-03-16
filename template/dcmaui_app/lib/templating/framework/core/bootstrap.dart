import 'package:dc_test/templating/framework/controls/low_levels/component_adapter.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/error_boundary.dart';
import 'package:dc_test/templating/framework/core/vdom/extensions/native_method_channels+vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/core/vdom/optimized_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/utility/performance_monitor.dart';
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

  // Create VDOM instance based on configuration
  final vdom = enableOptimizations ? NativeOptimizedVDOM() : NativeVDOM();

  // Set up error boundary props
  final errorProps = errorBoundaryProps ??
      ErrorBoundaryProps(
        id: 'root-error-boundary',
        onError: (error, stack) {
          if (kDebugMode) {
            print('DC Framework root error boundary caught error: $error');
            if (stack != null) print(stack);
          }
        },
      );

  // Create root app component with error boundary
  final errorBoundary = ElementFactory.createComponent(
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
    vdom.render(errorBoundary);

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

/// Combines OptimizedVDOM with NativeVDOM for performance
class NativeOptimizedVDOM extends OptimizedVDOM {
  final NativeVDOM _nativeVDOM = NativeVDOM();

  @override
  void createView(VNode node, String viewId) {
    _nativeVDOM.createView(node, viewId);
  }

  @override
  void updateView(VNode oldNode, VNode newNode, String viewId) {
    _nativeVDOM.updateView(oldNode, newNode, viewId);
  }

  @override
  void deleteView(String viewId) {
    _nativeVDOM.deleteView(viewId);
  }

  @override
  void setChildren(String parentId, List<String> childIds) {
    _nativeVDOM.setChildren(parentId, childIds);
  }
}
