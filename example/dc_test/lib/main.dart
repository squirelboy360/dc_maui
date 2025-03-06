import 'package:dc_test/framework/bridge/core.dart';
import 'package:dc_test/tests/list_view_test/list_view_test_composer.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  debugPrint("Starting ListView test application...");

  // Initialize Core
  await Core.initialize();

  // Create and start the ListView test composer
  final test = ListViewTestComposer();
  await test.start();

  debugPrint("ListView test application started successfully");
}
