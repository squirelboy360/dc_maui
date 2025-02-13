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
  // state
  void increase() {
    clicks++;
  }

  try {
    // First get the root view to ensure it's ready
    final rootInfo = await bridge.getRootView();
    _logger.info('Root view ready: ${rootInfo?['viewId']}');

    if (rootInfo == null || rootInfo['viewId'] == null) {
      _logger.severe('Root view not available');
      return;
    }

    final rootViewId = rootInfo['viewId'] as String;

    // Create and attach views directly to root
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

    // var clicks = 0;

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
