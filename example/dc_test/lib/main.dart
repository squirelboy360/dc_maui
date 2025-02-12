import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MainApp');
final NativeUIBridge bridge = NativeUIBridge();

void main() {
  _setupLogging();
  initializeNativeUI();
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });
}

Future<void> initializeNativeUI() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final rootInfo = await bridge.getRootView();
    _logger.info('Root view ready: ${rootInfo?['viewId']}');

    final containerId = await bridge.createView('Container');
    if (containerId == null) {
      _logger.severe('Failed to create container view');
      return;
    }

    final stackId = await bridge.createView('StackView');
    if (stackId == null) {
      _logger.severe('Failed to create stack view');
      return;
    }
    await bridge.attachView(containerId, stackId);

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
    await bridge.updateView(labelId, {'text': 'Click Counter: 0'});

    var clicks = 0;

    await bridge.registerEvent(buttonId, 'onClick', () async {
      clicks++;
      await bridge.updateView(labelId, {'text': 'Click Counter: $clicks'});
    });
  } catch (e) {
    _logger.severe('Native UI initialization failed: $e');
    _logger.severe('Detailed error in native UI initialization: $e');
    _logger.severe('Error stack trace: ${StackTrace.current}');
  }
}
