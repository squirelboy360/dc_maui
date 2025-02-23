import 'package:flutter/material.dart';
import 'tests/view_tests/grid_view_binder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  final viewBinder = GridViewBinder();
  await viewBinder.start();
}
