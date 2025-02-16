import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('CounterApp');
final bridge = NativeUIBridge();

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(
      (record) => debugPrint('${record.level.name}: ${record.message}'));
  runApp(const SizedBox());
  startApp();
}

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App state
  var counter = 0;

  final rootInfo = await bridge.getRootView();
  if (rootInfo == null) return;
  final rootId = rootInfo['viewId'] as String;

  // Main container with flex column layout
  final mainContainer = await bridge.createView('View');
  if (mainContainer == null) return;
  await bridge.attachView(rootId, mainContainer);
  await bridge.setLayout(
      mainContainer,
      const LayoutConfig(
        type: 'flex',
        flexDirection: 'column',
        width: '100%',
        height: '100%',
      ));
  await bridge.setViewBackgroundColor(mainContainer, '#F5F5F5');

  // Create app bar with gradient background
  final appBar = await bridge.createView('View');
  if (appBar == null) return;
  await bridge.attachView(mainContainer, appBar);
  await bridge.setLayout(
      appBar,
      const LayoutConfig(
        height: 88,
        width: '100%',
        padding: EdgeInsets.fromLTRB(16, 44, 16, 0),
      ));
  await bridge.updateView(appBar, {
    'backgroundColor': '#2196F3',
    'cornerRadius': 0,
    'shadow': {
      'color': '#000000',
      'opacity': 0.1,
      'offset': {'x': 0, 'y': 2},
      'radius': 4
    }
  });

  // App bar content container
  final appBarContent = await bridge.createView('View');
  if (appBarContent == null) return;
  await bridge.attachView(appBar, appBarContent);
  await bridge.setLayout(
      appBarContent,
      const LayoutConfig(
        type: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'spaceBetween',
        width: '100%',
        height: '100%',
      ));

  // Title in app bar
  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return;
  await bridge.attachView(appBarContent, titleLabel);
  await bridge.updateView(titleLabel, {
    'text': 'Counter App',
    'textColor': '#FFFFFF',
    'fontSize': 20,
    'fontWeight': 'bold'
  });

  // Increment button in app bar
  final incrementButton = await bridge.createView('Button');
  if (incrementButton == null) return;
  await bridge.attachView(appBarContent, incrementButton);
  await bridge.updateView(incrementButton, {
    'title': '+',
    'backgroundColor': '#FFFFFF',
    'textColor': '#2196F3',
    'cornerRadius': 20,
  });
  await bridge.setLayout(
      incrementButton,
      const LayoutConfig(
        width: 40,
        height: 40,
        alignItems: 'center',
        justifyContent: 'center',
      ));

  // Content container
  final content = await bridge.createView('View');
  if (content == null) return;
  await bridge.attachView(mainContainer, content);
  await bridge.setLayout(
      content,
      const LayoutConfig(
        type: 'flex',
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
      ));

  // Counter label
  final counterLabel = await bridge.createView('Label');
  if (counterLabel == null) return;
  await bridge.attachView(content, counterLabel);
  await bridge.updateView(counterLabel, {
    'text': '0',
    'textColor': '#333333',
    'fontSize': 48,
    'fontWeight': 'bold'
  });
  await bridge.setLayout(
      counterLabel,
      const LayoutConfig(
        margin: EdgeInsets.all(16),
      ));

  // Add increment button click handler
  await bridge.registerEvent(incrementButton, 'onClick', () async {
    counter++;
    await bridge.updateView(counterLabel, {
      'text': counter.toString(),
    });
  });
}
