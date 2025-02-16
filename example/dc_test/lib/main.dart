import 'package:flutter/material.dart' hide TextStyle;  // Hide Flutter's TextStyle
import 'package:logging/logging.dart';

// Import our custom types with prefixes to avoid conflicts
import 'package:dc_test/core/types/layout/yoga_types.dart' as yoga;
import 'package:dc_test/layout/layout_config.dart';
import 'package:dc_test/style/view_style.dart';
import 'package:dc_test/ui_apis.dart';

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
  var counter = 0;

  final rootInfo = await bridge.getRootView();
  if (rootInfo == null) return;
  final rootId = rootInfo['viewId'] as String;

  // Main container with gradient background
  final mainContainer = await bridge.createView('View');
  if (mainContainer == null) return;
  await bridge.attachView(rootId, mainContainer);

  // Type-safe layout
  await bridge.setLayout(
      mainContainer,
      LayoutConfig(
        position: yoga.YogaPositionType.relative,
        display: yoga.YogaDisplay.flex,
        flexDirection: yoga.YogaFlexDirection.column,
        width: '100%',
        height: '100%',
        alignItems: yoga.YogaAlign.center,
      ));

  // Type-safe styling
  await bridge.updateView(
      mainContainer,
      ViewStyle(
          gradient: GradientStyle(
        colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
        stops: [0.0, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )).toJson());

  // Card container
  final card = await bridge.createView('View');
  if (card == null) return;
  await bridge.attachView(mainContainer, card);

  await bridge.setLayout(
      card,
      LayoutConfig(
        display: yoga.YogaDisplay.flex,
        flexDirection: yoga.YogaFlexDirection.column,
        alignItems: yoga.YogaAlign.center,
        justifyContent: yoga.YogaJustify.center,
        width: 300,
        margin: const EdgeInsets.only(top: 100),
        padding: const EdgeInsets.all(32),
      ));

  await bridge.updateView(
      card,
      ViewStyle(backgroundColor: Colors.white, cornerRadius: 24, shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0, 10),
          radius: 20,
        )
      ]).toJson());

  // Title label
  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return;
  await bridge.attachView(card, titleLabel);

  await bridge.updateView(
      titleLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: 'Counter',
        color: const Color(0xFF1A1A1A),
        fontSize: 28,
        fontWeight: FontWeight.bold,
      )).toJson());

  await bridge.setLayout(
      titleLabel,
      const LayoutConfig(
        margin: EdgeInsets.only(bottom: 24),
      ));

  // Counter display
  final counterDisplay = await bridge.createView('View');
  if (counterDisplay == null) return;
  await bridge.attachView(card, counterDisplay);

  await bridge.setLayout(
      counterDisplay,
      LayoutConfig(
        width: 160,
        height: 160,
        alignItems: yoga.YogaAlign.center,
        justifyContent: yoga.YogaJustify.center,
        margin: const EdgeInsets.symmetric(vertical: 24),
      ));

  await bridge.updateView(
      counterDisplay,
      ViewStyle(
        backgroundColor: const Color(0xFFF0F7FF),
        cornerRadius: 80,
      ).toJson());

  // Counter label
  final counterLabel = await bridge.createView('Label');
  if (counterLabel == null) return;
  await bridge.attachView(counterDisplay, counterLabel);

  await bridge.updateView(
      counterLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: '0',
        color: const Color(0xFF2E3192),
        fontSize: 64,
        fontWeight: FontWeight.bold,
      )).toJson());

  // Buttons container
  final buttonsContainer = await bridge.createView('View');
  if (buttonsContainer == null) return;
  await bridge.attachView(card, buttonsContainer);

  await bridge.setLayout(
      buttonsContainer,
      LayoutConfig(
        flexDirection: yoga.YogaFlexDirection.row,
        justifyContent: yoga.YogaJustify.spaceBetween,
        width: '100%',
        margin: const EdgeInsets.only(top: 24),
      ));

  // Create button with styling
  Future<String?> createStyledButton(String text, bool isPrimary) async {
    final button = await bridge.createView('Button');
    if (button == null) return null;

    await bridge.setLayout(
        button,
        const LayoutConfig(
          width: 60,
          height: 60,
        ));

    await bridge.updateView(
        button,
        ViewStyle(
            backgroundColor:
                isPrimary ? const Color(0xFF2E3192) : const Color(0xFFF0F7FF),
            cornerRadius: 30,
            textStyle: TextStyle(
              text: text,
              color: isPrimary ? Colors.white : const Color(0xFF2E3192),
              fontSize: 32,
            ),
            shadows: [
              ShadowStyle(
                color:
                    const Color(0xFF2E3192).withOpacity(isPrimary ? 0.3 : 0.1),
                offset: const Offset(0, 4),
                radius: 8,
              )
            ]).toJson());

    return button;
  }

  // Create buttons
  final decrementButton = await createStyledButton('-', false);
  final resetButton = await createStyledButton('↺', false);
  final incrementButton = await createStyledButton('+', true);

  // Attach buttons
  if (decrementButton != null) {
    await bridge.attachView(buttonsContainer, decrementButton);
  }
  if (resetButton != null) {
    await bridge.attachView(buttonsContainer, resetButton);
  }
  if (incrementButton != null) {
    await bridge.attachView(buttonsContainer, incrementButton);
  }

  // Event handlers
  if (incrementButton != null) {
    await bridge.registerEvent(incrementButton, 'onClick', () async {
      counter++;
      await bridge.updateView(
          counterLabel,
          ViewStyle(
              textStyle: TextStyle(
            text: counter.toString(),
          )).toJson());
    });
  }

  if (decrementButton != null) {
    await bridge.registerEvent(decrementButton, 'onClick', () async {
      counter--;
      await bridge.updateView(
          counterLabel,
          ViewStyle(
              textStyle: TextStyle(
            text: counter.toString(),
          )).toJson());
    });
  }

  if (resetButton != null) {
    await bridge.registerEvent(resetButton, 'onClick', () async {
      counter = 0;
      await bridge.updateView(
          counterLabel,
          ViewStyle(
              textStyle: TextStyle(
            text: '0',
          )).toJson());
    });
  }
}
