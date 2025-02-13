# 🚧 This CLI is Under Development

Its aim is to simplify cross-platform app development for personal future projects.

## ⚠️ Important Notice

If you want to test it, do not use the CLI as it currently does nothing. However, you can run the example to see how it works. The example serves as an experimental implementation and will eventually be broken down, optimized, and integrated into the complete CLI.

## 📌 Key Points

### 1️⃣ Flutter Engine Usage

Developers might notice that the framework is built on Flutter—but in actuality, it is not.  
It is almost impossible to decouple the Dart VM from Flutter. To work around this:

- The framework is built on top of Flutter, but not as a Flutter framework.
- When abstracting the Flutter engine, I separate it into a dedicated package.
- The framework only exposes method channels and essential functions like `runApp()`.
- This allows communication with the Flutter engine in headless mode, letting the native side handle rendering.

### 2️⃣ Current Syntax Needs Improvement 🤦‍♂️

The current syntax is not great, but I will abstract over it later.

## 📝 Dart Example

```dart
import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MainApp');
final NativeUIBridge bridge = NativeUIBridge();

void main() {
  _setupLogging();
  runApp(const SizedBox()); // Run minimal Flutter app
  mainApp();
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });
}

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  var clicks = 0;

  // State management function
  void increase() {
    clicks++;
  }

  try {
    // Ensure the root view is ready
    final rootInfo = await bridge.getRootView();
    _logger.info('Root view ready: ${rootInfo?['viewId']}');

    if (rootInfo == null || rootInfo['viewId'] == null) {
      _logger.severe('Root view not available');
      return;
    }

    final rootViewId = rootInfo['viewId'] as String;

    // Create and attach views directly to the root
    final stackId = await bridge.createView('StackView');
    if (stackId == null) {
      _logger.severe('Failed to create stack view');
      return;
    }
    await bridge.attachView(rootViewId, stackId);

    final buttonId = await bridge.createView('Button');
    if (buttonId == null) {
      _logger.severe('Failed to create button view');
      return;
    }
    await bridge.attachView(stackId, buttonId);
    await bridge.updateView(buttonId, {'title': 'Test Button'});
    await bridge.setViewBackgroundColor(buttonId, 'blue');

    final labelId = await bridge.createView('Label');
    if (labelId == null) {
      _logger.severe('Failed to create label view');
      return;
    }
    await bridge.attachView(stackId, labelId);
    await bridge.updateView(labelId, {'text': 'Click Counter: $clicks'});

    // Register button click event
    await bridge.registerEvent(buttonId, 'onClick', () async {
      increase();
      _logger.info('Button clicked: $clicks times');
      await bridge.updateView(labelId, {'text': 'Click Counter: $clicks'});
    });

    _logger.info('Native UI setup complete');
  } catch (e) {
    _logger.severe('Native UI initialization failed: $e');
    _logger.severe('Error stack trace: ${StackTrace.current}');
  }
}


```


### 3️⃣ Inspired by .NET MAUI

The architecture is loosely inspired by .NET MAUI, but instead of .NET, Flutter serves as the toolset.

### 4️⃣ Hot Reload/Restart Issues ⚡

- Hot Reload does not work ❌.
- Hot Restart works but duplicates the native UIs or stacks them on top of each other, which is annoying. 😕

---

This project is still in early development, and many improvements will be made along the way.  
Contributions, suggestions, and feedback are always welcome! 🚀
