import 'package:dc_test/templating/framework/core/main/abstractions/bootstrap.dart';
import 'package:dc_test/test/counter/main_app.dart';
import 'package:dc_test/templating/framework/core/main/main_view_coordinator.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize coordinator directly
  await MainViewCoordinatorInterface.initialize();

  // Create a direct test view bypassing the component system
  try {
    print("Creating direct test view...");
    await _createTestView();
    print("Direct test view created successfully");
  } catch (e) {
    print("Error creating test view: $e");
  }

  // Comment out the normal bootstrap for testing
  /*
  await dcBind(
    () => MainApp(),
    enableOptimizations: true,
    enablePerformanceTracking: true,
  );
  */
}

// Create a simple test view directly with the native bridge
Future<void> _createTestView() async {
  // Create a root view
  print("Creating root view (view_0)");
  final rootViewResult =
      await MainViewCoordinatorInterface.createView('view_0', 'DCView', {
    'style': {
      'backgroundColor': '#FF0000', // Bright red background
      'padding': 100.0,
    }
  });
  print("Root view result: $rootViewResult");

  // Create a text label
  print("Creating text view (view_1)");
  final textViewResult =
      await MainViewCoordinatorInterface.createView('view_1', 'DCText', {
    'text': 'Direct Test View',
    'style': {
      'color': '#FFFFFF', // White text
      'fontSize': 24.0,
      'fontWeight': 'bold',
    }
  });
  print("Text view result: $textViewResult");

  // Create a button
  print("Creating button view (view_2)");
  final buttonViewResult =
      await MainViewCoordinatorInterface.createView('view_2', 'DCButton', {
    'title': 'Test Button',
    'style': {
      'marginTop': 10.0,
    }
  });
  print("Button view result: $buttonViewResult");

  // Set up parent-child relationships
  print("Setting up parent-child relationships");
  final childrenResult = await MainViewCoordinatorInterface.setChildren(
      'view_0', ['view_1', 'view_2']);
  print("Children result: $childrenResult");

  // Request the native side to log the view tree
  print("Requesting native view tree");
  await MainViewCoordinatorInterface.logNativeViewTree();
}
