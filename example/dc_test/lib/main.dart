import 'package:dc_test/tests/ui_random_tets/test_composer.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  final test = TestViewComposer();
  // final viewBinder = TextViewBinder();
  // final touchable = TouchableViewComposer();
  //final test = TextInputTestComposer();

  await test.start();
}
