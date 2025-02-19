// keeps code clean and organized
// part of 'imports.dart';


import 'package:dc_test/framework/bridge/base.dart';
import 'package:dc_test/test/main_app/imports.dart';

void app() {
  Base.startApp(bindApp: () async {
    final binder = HomeViewBinder();
    await binder.bindComponents();
  });
}
