import 'package:dc_test/tests/touchable_test/touchable_view_composer.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  // final viewBinder = GridViewBinder();
  // final viewBinder = TextViewBinder();
  final touchable = TouchableViewComposer();
  await touchable.start();
}
