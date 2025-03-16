import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/checkbox.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/switch.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/touchable.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/context.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/error_boundary.dart';
import 'package:dc_test/templating/framework/core/vdom/extensions/native_method_channels+vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/optimized_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/hooks/index.dart';
import 'package:dc_test/templating/framework/utility/flutter.dart';
import 'package:dc_test/templating/framework/utility/performance_monitor.dart';
import 'package:dc_test/test/counter/main_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide TextStyle, View, Text, Checkbox, Switch;
import 'dart:math' as math;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MainViewCoordinatorInterface.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to initialize MainViewCoordinatorInterface: $e');
    }
  }

  // Start performance monitoring
  PerformanceMonitor.instance.takeMemorySnapshot('app_start');

  // Create an optimized VDOM instance with native capabilities
  final vdom = NativeOptimizedVDOM();

  // Create root app component with error boundary
  final errorBoundary = ElementFactory.createComponent(
    () => ErrorBoundary(
      ErrorBoundaryProps(
        id: 'root-error-boundary',
        onError: (error, stack) {
          if (kDebugMode) {
            print('Root Error Boundary caught error: $error');
            if (stack != null) print(stack);
          }
        },
      ),
      [
        ComponentAdapter(ElementFactory.createComponent(
            () => MainApp(), {'key': 'root-app'}))
      ],
    ),
    {'key': 'root-error-boundary'},
  );

  try {
    vdom.render(errorBoundary);
  } catch (e, stack) {
    if (kDebugMode) {
      print('ERROR: Failed to render app: $e');
      print(stack);
    }
  }

  // Log the native view tree
  MainViewCoordinatorInterface.logNativeViewTree();

  // Log initial performance snapshot
  PerformanceMonitor.instance.takeMemorySnapshot('app_rendered');
  if (kDebugMode) {
    Future.delayed(const Duration(seconds: 3), () {
      print(
          'Performance report: ${PerformanceMonitor.instance.getPerformanceReport()}');
    });
  }
}

/// Combines OptimizedVDOM with NativeVDOM
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
