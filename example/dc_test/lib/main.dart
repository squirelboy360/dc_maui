import 'package:dc_test/tests/view_tests/grid_view_binder.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  final test = GridViewBinder();
  // final viewBinder = TextViewBinder();
  // final touchable = TouchableViewComposer();
  //final test = TextInputTestComposer();

  await test.start();
}
