import 'package:dc_test/framework/bridge/base.dart';
import 'package:dc_test/main_app/views/imports.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ModernApp');
final bridge = NativeUIBridge();

void main() {
  // Enable detailed logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const SizedBox());

  // Ensure Flutter is initialized before creating native UI
  WidgetsFlutterBinding.ensureInitialized();
  startApp();
}

Future<void> startApp() async {
  try {
    final binder = HomeViewBinder(bridge);
    await binder.navigateToHomeScreen().then((_) {
      print("Called");
    });

    _logger.info('App started successfully');
  } catch (e, stack) {
    _logger.severe('Failed to start app: $e');
    _logger.severe('Stack trace: $stack');
  }
}
