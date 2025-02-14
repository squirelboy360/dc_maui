
import 'package:dc_test/app/screens/home.dart';
import 'package:flutter/material.dart' hide Stack;
import 'package:logging/logging.dart'; // Hide Flutter's Stack



void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  _setupLogging();
  runApp(const MaterialApp(
    color: Colors.white,
    home: Center(
      child: Text("Initializing..."), // Change this to show loading state
    ),
  ));
  mainApp();
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });
}


