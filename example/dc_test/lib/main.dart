import 'package:dc_test/tests/scroll_view_test/scroll_view_composer.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  // final viewBinder = GridViewBinder();
  // final viewBinder = TextViewBinder();
  // final touchable = TouchableViewComposer();
  //final test = TextInputTestComposer();
  final test = ScrollViewComposer();

  await test.start();
}
