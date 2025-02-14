import 'package:logging/logging.dart';
import '../../components/button.dart';
import '../../components/label.dart';
import '../../components/stack.dart';
import '../../navigation_apis.dart';
import 'package:dc_test/components/component_interface.dart';

final _logger = Logger('MainApp');
final _nav = NavigationAPI();
Future<void> mainApp() async {
  try {
    _logger.info('Initializing app...');
    await Future.delayed(
        Duration(milliseconds: 100)); // Add small delay for native setup

    // Initialize navigation
    final success = await _nav.setupNavigation(NavigationType.stack);
    if (!success) {
      _logger.severe('Failed to setup navigation');
      return;
    }

    // Create main screen
    final mainScreen = await buildMainScreen();
    if (mainScreen != null) {
      await _nav.push(mainScreen);
      _logger.info('Main screen pushed');
    } else {
      _logger.severe('Failed to build main screen');
    }
  } catch (e, stack) {
    _logger.severe('App initialization failed: $e\n$stack');
  }
}

Future<String?> buildMainScreen() async {
  final stack = await Stack.create();
  if (stack == null) return null;

  // Add label
  final label = await Label.create();
  if (label != null) {
    await label.setText('Welcome to Demo').then((lbl) => lbl.style(
          fontSize: 24,
          margin: UIEdgeInsets.all(20),
          textColor: '#000000',
        ));
    await stack.add(label);
  }

  // Add tab navigation button
  final tabButton = await Button.create();
  if (tabButton != null) {
    await tabButton
        .setTitle('Show Tabs')
        .then((btn) => btn.style(
              backgroundColor: '#007AFF',
              padding: UIEdgeInsets.all(16),
              margin: UIEdgeInsets.all(10),
            ))
        .then((btn) => btn.onClick(() async {
              final tabScreen1 = await buildTabScreen1();
              final tabScreen2 = await buildTabScreen2();

              if (tabScreen1 != null && tabScreen2 != null) {
                await _nav.setupNavigation(
                  NavigationType.tab,
                  tabs: [
                    TabInfo(screenId: tabScreen1, title: 'Tab 1'),
                    TabInfo(screenId: tabScreen2, title: 'Tab 2'),
                  ],
                );
              }
            }));
    await stack.add(tabButton);
  }

  // Add modal button
  final modalButton = await Button.create();
  if (modalButton != null) {
    await modalButton
        .setTitle('Show Modal')
        .then((btn) => btn.style(
              backgroundColor: '#FF9500',
              padding: UIEdgeInsets.all(16),
              margin: UIEdgeInsets.all(10),
            ))
        .then((btn) => btn.onClick(() async {
              final modalScreen = await buildModalScreen();
              if (modalScreen != null) {
                await _nav.presentModal(modalScreen);
              }
            }));
    await stack.add(modalButton);
  }

  return stack.id;
}

Future<String?> buildTabScreen1() async {
  final stack = await Stack.create();
  if (stack == null) return null;

  final label = await Label.create();
  if (label != null) {
    await label.setText('Tab 1').then((lbl) => lbl.style(fontSize: 24));
    await stack.add(label);
  }

  return stack.id;
}

Future<String?> buildTabScreen2() async {
  final stack = await Stack.create();
  if (stack == null) return null;

  final label = await Label.create();
  if (label != null) {
    await label.setText('Tab 2').then((lbl) => lbl.style(fontSize: 24));
    await stack.add(label);
  }

  return stack.id;
}

Future<String?> buildModalScreen() async {
  final stack = await Stack.create();
  if (stack == null) return null;

  final label = await Label.create();
  if (label != null) {
    await label.setText('Modal Screen').then((lbl) => lbl.style(fontSize: 24));
    await stack.add(label);
  }

  final closeButton = await Button.create();
  if (closeButton != null) {
    await closeButton
        .setTitle('Close')
        .then((btn) => btn.style(
              backgroundColor: '#FF3B30',
              padding: UIEdgeInsets.all(16),
            ))
        .then((btn) => btn.onClick(() {
              _nav.dismissModal();
            }));
    await stack.add(closeButton);
  }

  return stack.id;
}
