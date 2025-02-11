import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';


// Bridge instance
final NativeUIBridge bridge = NativeUIBridge();

void main() {
  // Initialize native side
  initializeNativeUI();
}

Future<void> initializeNativeUI() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Get root view
    final rootInfo = await bridge.getRootView();
    print('Root view ready: ${rootInfo?['viewId']}');

    // Create main container
    final containerId = await bridge.createView('Container');
    if (containerId == null) return;

    // Create stack view for layout
    final stackId = await bridge.createView('StackView');
    await bridge.attachView(containerId, stackId);

    // Add a button
    final buttonId = await bridge.createView('Button', properties: {
      'title': 'Test Button'
    });
    await bridge.attachView(stackId, buttonId);
    await bridge.setViewBackgroundColor(buttonId, 'blue');

    // Add a label
    final labelId = await bridge.createView('Label', properties: {
      'text': 'Click Counter: 0'
    });
    await bridge.attachView(stackId, labelId);

    // Track clicks
    var clicks = 0;
    
    // Register button click handler
    await bridge.registerEvent(buttonId, 'onClick', () async {
      clicks++;
      await bridge.updateView(labelId, {
        'text': 'Click Counter: $clicks'
      });
    });

  } catch (e) {
    print('Native UI initialization failed: $e');
  }
}