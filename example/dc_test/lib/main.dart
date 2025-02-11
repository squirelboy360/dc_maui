import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Start the Flutter engine without calling runApp
  runAppAsynchronously();
}

Future<void> runAppAsynchronously() async {
  // Make sure WidgetsFlutterBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create a method channel to communicate with native side
  const platform = MethodChannel('com.example.channel');

  try {
    // Send a message to the native side
    await platform.invokeMethod(
        'sendMessage', "Hello from native side of things !");

    // You can trigger further actions after this, like navigation or any updates
    print("Message sent to native side");
  } on PlatformException catch (e) {
    print("Failed to send message to native side: ${e.message}");
  }

  // Run any further logic after this asynchronous block
  // The Flutter UI is not needed in this case since the native side is controlling the UI
}
