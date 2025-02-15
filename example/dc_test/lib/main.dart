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

    // Create main container as VStack
    final mainStackId = await bridge.createVStack(
      spacing: 16,
      alignment: FlexAlignment.center,
      padding: EdgeInsets.all(16)
    );
    if (mainStackId == null) {
      _logger.severe('Failed to create main stack view');
      return;
    }
    await bridge.attachView(rootViewId, mainStackId);

    // Create header with title in HStack
    final headerStackId = await bridge.createHStack(
      spacing: 8,
      alignment: FlexAlignment.center
    );
    if (headerStackId == null) return;
    await bridge.attachView(mainStackId, headerStackId);

    // Create button and label in a HStack for controls
    final controlsStackId = await bridge.createHStack(
      spacing: 16,
      alignment: FlexAlignment.spaceBetween
    );
    if (controlsStackId == null) return;
    await bridge.attachView(mainStackId, controlsStackId);

    // Add button
    final buttonId = await bridge.createView('Button');
    if (buttonId == null) return;
    await bridge.attachView(controlsStackId, buttonId);
    await bridge.updateView(buttonId, {'title': 'Add Number Box'});
    await bridge.setViewBackgroundColor(buttonId, Colors.pink);
    await bridge.setViewLayout(buttonId, width: 150); // Set fixed width for button

    // Add counter label
    final labelId = await bridge.createView('Label');
    if (labelId == null) return;
    await bridge.attachView(controlsStackId, labelId);
    await bridge.updateView(
      labelId, 
      {'text': 'Total Boxes: ${stateManager.clicks}'}
    );

    // Create container for dynamic boxes as VStack
    final boxesStackId = await bridge.createVStack(
      spacing: 8,
      alignment: FlexAlignment.center
    );
    if (boxesStackId == null) return;
    await bridge.attachView(mainStackId, boxesStackId);

    // Register button click handler
    final success = await bridge.registerEvent(buttonId, 'onClick', () async {
      try {
        stateManager.incrementClicks();
        _logger.info('Creating new number box: ${stateManager.clicks}');

        // Create box container as ZStack for layering
        final boxContainerId = await bridge.createZStack(
          alignment: FlexAlignment.center
        );
        if (boxContainerId == null) return false;
        await bridge.attachView(boxesStackId, boxContainerId);
        
        // Set fixed size for box container
        await bridge.setViewLayout(boxContainerId, 
          width: 100, 
          height: 100
        );

        // Create background box
        final boxId = await bridge.createView('View');
        if (boxId == null) return false;
        await bridge.attachView(boxContainerId, boxId);
        await bridge.setViewBackgroundColor(boxId, Colors.grey);
        // Make box fill container
        await bridge.setViewLayout(boxId,
          width: 100,
          height: 100
        );

        // Create number label centered in box
        final numberLabelId = await bridge.createView('Label');
        if (numberLabelId == null) return false;
        await bridge.attachView(boxContainerId, numberLabelId);
        await bridge.updateView(numberLabelId, {
          'text': '${stateManager.clicks}',
          'textColor': Colors.amberAccent,
        });

        // Update counter label
        await bridge.updateView(
          labelId, 
          {'text': 'Total Boxes: ${stateManager.clicks}'}
        );

        // Toggle root background on even/odd
        if (stateManager.clicks % 2 == 0) {
          await bridge.setViewBackgroundColor(rootViewId, Colors.deepPurple);
        } else {
          await bridge.setViewBackgroundColor(rootViewId, Colors.white);
        }

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
