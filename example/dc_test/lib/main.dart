import 'package:dc_test/tests/list_view_test/lisview.binder.dart';
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
  final test = ListViewBinder();

  await test.start();
}
