import 'package:flutter/material.dart';
// import 'tests/view_tests/grid_view_binder.dart';  // Comment out grid view
import 'tests/text_test/text_view_binder.dart'; // Import text view

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  // final viewBinder = GridViewBinder();
  final viewBinder = TextViewBinder(); // Use text view instead
  await viewBinder.start();
}
