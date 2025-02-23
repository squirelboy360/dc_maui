import 'package:flutter/material.dart';
import 'view_tests/grid_view_binder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  final viewBinder = GridViewBinder();
  await viewBinder.start(); // Use start() instead of execute()
}
