import 'package:dc_test/tests/text_input_test/text_input_composer.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  // final viewBinder = GridViewBinder();
  // final viewBinder = TextViewBinder();
  // final touchable = TouchableViewComposer();
  final test = TextInputTestComposer();
  await test.start();
}
