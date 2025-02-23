import 'package:flutter/material.dart';
import 'tests/touchable_test/touchable_view_binder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  final viewBinder = TouchableViewBinder();
  await viewBinder.start();
}
