import 'package:flutter/material.dart';
import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/renderer/vdom_renderer.dart';
import 'framework/packages/native_bridge/native_bridge.dart';
import 'dart:developer' as developer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startNativeApp();
}

void startNativeApp() async {
  // Create VDOM instance
  final vdom = VDom();

  // Create native bridge directly for testing
  final bridge = NativeBridgeFactory.create();

  developer.log('Initializing native bridge', name: 'App');
  final initialized = await bridge.initialize();
  developer.log('Native bridge initialized: $initialized', name: 'App');

  // Create a simple test view
  final createResult = await bridge.createView("test_view", "Text", {
    "content": "Hello from DCMAUI!",
    "fontSize": 24,
    "color": "#000000",
    "textAlign": "center"
  });

  developer.log('Created test view: $createResult', name: 'App');

  // Attach to root view
  final attachResult = await bridge.attachView("test_view", "root", 0);
  developer.log('Attached test view to root: $attachResult', name: 'App');

  // Register event callback
  bridge.setEventHandler((viewId, eventType, eventData) {
    developer.log('Event received: $viewId - $eventType - $eventData',
        name: 'App');
  });

  developer.log('DCMAUI framework started in headless mode', name: 'App');
}
