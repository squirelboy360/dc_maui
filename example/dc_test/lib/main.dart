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

  // Create a state manager class instance
  final stateManager = AppStateManager();

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

    // Create button and label as before
    final buttonId = await bridge.createView('Button');
    if (buttonId == null) return;
    await bridge.attachView(stackId, buttonId);
    await bridge.updateView(buttonId, {'title': 'Add Number Box'});
    await bridge.setViewBackgroundColor(buttonId, 'blue');

    final labelId = await bridge.createView('Label');
    if (labelId == null) return;
    await bridge.attachView(stackId, labelId);
    await bridge.updateView(labelId, {'text': 'Total Boxes: 0'});

    // Create scrollable list
    final listViewController = await bridge.createListView(
      direction: ScrollDirection.vertical,
      spacing: 10,
      padding: const EdgeInsets.all(16),
    );

    if (listViewController == null) return;
    await bridge.attachView(stackId, listViewController.viewId);

    // Register button click handler
    final success = await bridge.registerEvent(buttonId, 'onClick', () async {
      try {
        stateManager.incrementClicks();
        _logger.info('Creating new number box: ${stateManager.clicks}');

        // Create new box
        await listViewController.addItem(() async {
          // Create box stack
          final boxStackId = await bridge.createView('StackView');
          if (boxStackId == null) return null;

          // Create colored box
          final boxId = await bridge.createView('View');
          if (boxId == null) return null;
          await bridge.attachView(boxStackId, boxId);
          await bridge.setViewBackgroundColor(boxId, 'red');

          // Create number label
          final numberLabelId = await bridge.createView('Label');
          if (numberLabelId == null) return null;
          await bridge.attachView(boxStackId, numberLabelId);
          await bridge.updateView(numberLabelId, {
            'text': '${stateManager.clicks}',
            'textColor': 'white',
          });

          // Update counter
          await bridge.updateView(
              labelId, {'text': 'Total Boxes: ${stateManager.clicks}'});

          return boxStackId;
        });

        return true;
      } catch (e) {
        _logger.severe('Error handling button click: $e');
        return false;
      }
    });

    if (!success) {
      _logger.severe('Failed to register button click handler');
      return;
    }

    _logger.info('Native UI setup complete');
  } catch (e) {
    _logger.severe('Native UI initialization failed: $e');
    _logger.severe('Error stack trace: ${StackTrace.current}');
  }
}

// State management class
class AppStateManager {
  int _clicks = 0;
  int get clicks => _clicks;

  void incrementClicks() {
    _clicks++;
  }
}
