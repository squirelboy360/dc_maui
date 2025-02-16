import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('CounterApp');
final bridge = NativeUIBridge();

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) => debugPrint('${record.level.name}: ${record.message}'));
  runApp(const SizedBox());
  startApp();
}

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  var counter = 0;

  final rootInfo = await bridge.getRootView();
  if (rootInfo == null) return;
  final rootId = rootInfo['viewId'] as String;

  // Main container with gradient background
  final mainContainer = await bridge.createView('View');
  if (mainContainer == null) return;
  await bridge.attachView(rootId, mainContainer);
  await bridge.setLayout(mainContainer, const LayoutConfig(
    type: 'flex',
    flexDirection: 'column',
    width: '100%',
    height: '100%',
    alignItems: 'center',
  ));
  await bridge.updateView(mainContainer, {
    'gradient': {
      'colors': ['#2E3192', '#1BFFFF'],
      'stops': [0.0, 1.0],
      'start': {'x': 0, 'y': 0},
      'end': {'x': 0, 'y': 1}
    }
  });

  // Card container
  final card = await bridge.createView('View');
  if (card == null) return;
  await bridge.attachView(mainContainer, card);
  await bridge.setLayout(card, const LayoutConfig(
    type: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    width: 300,
    margin: EdgeInsets.only(top: 100),
    padding: EdgeInsets.all(32),
  ));
  await bridge.updateView(card, {
    'backgroundColor': '#FFFFFF',
    'cornerRadius': 24,
    'shadow': {
      'color': '#000000',
      'opacity': 0.15,
      'offset': {'x': 0, 'y': 10},
      'radius': 20
    }
  });

  // Title label
  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return;
  await bridge.attachView(card, titleLabel);
  await bridge.updateView(titleLabel, {
    'text': 'Counter',
    'textColor': '#1A1A1A',
    'fontSize': 28,
    'fontWeight': 'bold'
  });
  await bridge.setLayout(titleLabel, const LayoutConfig(
    margin: EdgeInsets.only(bottom: 24),
  ));

  // Counter display
  final counterDisplay = await bridge.createView('View');
  if (counterDisplay == null) return;
  await bridge.attachView(card, counterDisplay);
  await bridge.setLayout(counterDisplay, const LayoutConfig(
    width: 160,
    height: 160,
    alignItems: 'center',
    justifyContent: 'center',
    margin: EdgeInsets.symmetric(vertical: 24),
  ));
  await bridge.updateView(counterDisplay, {
    'backgroundColor': '#F0F7FF',
    'cornerRadius': 80,
  });

  // Counter label
  final counterLabel = await bridge.createView('Label');
  if (counterLabel == null) return;
  await bridge.attachView(counterDisplay, counterLabel);
  await bridge.updateView(counterLabel, {
    'text': '0',
    'textColor': '#2E3192',
    'fontSize': 64,
    'fontWeight': 'bold'
  });

  // Buttons container
  final buttonsContainer = await bridge.createView('View');
  if (buttonsContainer == null) return;
  await bridge.attachView(card, buttonsContainer);
  await bridge.setLayout(buttonsContainer, const LayoutConfig(
    type: 'flex',
    flexDirection: 'row',
    justifyContent: 'spaceBetween',
    width: '100%',
    margin: EdgeInsets.only(top: 24),
  ));

  // Decrement button
  final decrementButton = await bridge.createView('Button');
  if (decrementButton == null) return;
  await bridge.attachView(buttonsContainer, decrementButton);
  await bridge.setLayout(decrementButton, const LayoutConfig(
    width: 60,
    height: 60,
  ));
  await bridge.updateView(decrementButton, {
    'title': '-',
    'backgroundColor': '#F0F7FF',
    'textColor': '#2E3192',
    'fontSize': 32,
    'cornerRadius': 30,
    'shadow': {
      'color': '#2E3192',
      'opacity': 0.1,
      'offset': {'x': 0, 'y': 4},
      'radius': 8
    }
  });

  // Reset button
  final resetButton = await bridge.createView('Button');
  if (resetButton == null) return;
  await bridge.attachView(buttonsContainer, resetButton);
  await bridge.setLayout(resetButton, const LayoutConfig(
    width: 60,
    height: 60,
  ));
  await bridge.updateView(resetButton, {
    'title': '↺',
    'backgroundColor': '#F0F7FF',
    'textColor': '#2E3192',
    'fontSize': 32,
    'cornerRadius': 30,
    'shadow': {
      'color': '#2E3192',
      'opacity': 0.1,
      'offset': {'x': 0, 'y': 4},
      'radius': 8
    }
  });

  // Increment button
  final incrementButton = await bridge.createView('Button');
  if (incrementButton == null) return;
  await bridge.attachView(buttonsContainer, incrementButton);
  await bridge.setLayout(incrementButton, const LayoutConfig(
    width: 60,
    height: 60,
  ));
  await bridge.updateView(incrementButton, {
    'title': '+',
    'backgroundColor': '#2E3192',
    'textColor': '#FFFFFF',
    'fontSize': 32,
    'cornerRadius': 30,
    'shadow': {
      'color': '#2E3192',
      'opacity': 0.3,
      'offset': {'x': 0, 'y': 4},
      'radius': 8
    }
  });

  // Event handlers
  await bridge.registerEvent(incrementButton, 'onClick', () async {
    counter++;
    await bridge.updateView(counterLabel, {'text': counter.toString()});
  });

  await bridge.registerEvent(decrementButton, 'onClick', () async {
    counter--;
    await bridge.updateView(counterLabel, {'text': counter.toString()});
  });

  await bridge.registerEvent(resetButton, 'onClick', () async {
    counter = 0;
    await bridge.updateView(counterLabel, {'text': '0'});
  });
}
