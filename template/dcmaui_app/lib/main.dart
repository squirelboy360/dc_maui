import 'package:dc_test/templating/framework/core/bootstrap.dart';
import 'package:dc_test/test/counter/main_app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap the DC application
  await dcBind(
    () => MainApp(),
    enableOptimizations: true,
    enablePerformanceTracking: true,
  );
}
