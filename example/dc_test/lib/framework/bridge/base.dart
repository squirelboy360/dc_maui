import 'package:dc_test/framework/bridge/core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final bridge = Core();

class Base {
  static Future<void> startApp({required Function bindApp}) async {
    final logger = Logger('Base');
    // Enable detailed logging
    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
    runApp(const SizedBox());
    // Ensure Flutter is initialized before creating native UI
    WidgetsFlutterBinding.ensureInitialized();
    try {
      bindApp();
      logger.info('App started successfully');
    } catch (e, stack) {
      logger.severe('Failed to start app: $e');
      logger.severe('Stack trace: $stack');
    }
  }

  Widget dummyApp() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Platform not supported'),
        ),
      ),
    );
  }
}
