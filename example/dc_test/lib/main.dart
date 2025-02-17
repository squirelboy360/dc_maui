import 'package:dc_test/core/types/events.dart';
import 'package:flutter/material.dart' hide TextStyle, Border, BorderStyle;
import 'package:logging/logging.dart';
import 'package:dc_test/core/types/layout/yoga_types.dart';
import 'package:dc_test/layout/layout_config.dart';
import 'package:dc_test/style/view_style.dart';
import 'package:dc_test/ui_apis.dart';

final _logger = Logger('ModernApp');
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

  // Configure main layout
  await bridge.setLayout(
    mainContainer,
    LayoutConfig(
      position: YGPositionType.relative,
      display: YGDisplay.flex,
      flexDirection: YGFlexDirection.column,
      width: YGValue(100, YGUnit.percent),
      height: YGValue(100, YGUnit.percent),
      alignItems: YGAlign.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
    ),
  );

  // Apply gradient background
  await bridge.updateView(
      mainContainer,
      ViewStyle(
          gradient: GradientStyle(
        colors: [Color(0xFF1A1A1A), Color(0xFF2E3192)],
        stops: [0.0, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )).toJson());

  // Create header section
  final headerContainer = await bridge.createView('View');
  if (headerContainer == null) return;
  await bridge.attachView(mainContainer, headerContainer);

  await bridge.setLayout(
      headerContainer,
      LayoutConfig(
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.center,
        margin: const EdgeInsets.only(top: 60, bottom: 40),
      ));

  // Title
  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return;
  await bridge.attachView(headerContainer, titleLabel);

  await bridge.updateView(
      titleLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: 'Modern Counter',
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      )).toJson());

  // Subtitle
  final subtitleLabel = await bridge.createView('Label');
  if (subtitleLabel == null) return;
  await bridge.attachView(headerContainer, subtitleLabel);

  await bridge.updateView(
      subtitleLabel,
      ViewStyle(
          textStyle: TextStyle(
        text: 'Tap buttons to count',
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
      )).toJson());

  // Counter card
  final card = await bridge.createView('View');
  if (card == null) return;
  await bridge.attachView(mainContainer, card);

  await bridge.setLayout(
      card,
      LayoutConfig(
          display: YGDisplay.flex,
          flexDirection: YGFlexDirection.column,
          alignItems: YGAlign.center,
          justifyContent: YGJustify.center,
          width: YGValue(100, YGUnit.percent),
          height: YGValue(80, YGUnit.percent)
          // padding: const EdgeInsets.all(32),
          // margin: const EdgeInsets.symmetric(vertical: 40),
          ));

  await bridge.updateView(
      card,
      ViewStyle(backgroundColor: Colors.white, cornerRadius: 24, shadows: [
        ShadowStyle(
          color:
              Colors.black.withOpacity(0.3), // Keep using withOpacity for now
          offset: const Offset(0, 15),
          radius: 30,
        )
      ]).toJson());

  // Counter display
  final counterDisplay = await bridge.createView('View');
  if (counterDisplay == null) return;
  await bridge.attachView(card, counterDisplay);

  await bridge.setLayout(
      counterDisplay,
      LayoutConfig(
        width: YGValue(180, YGUnit.point),
        height: YGValue(180, YGUnit.point),
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        margin: const EdgeInsets.symmetric(vertical: 24),
      ));

  await bridge.updateView(
      counterDisplay,
      ViewStyle(
        backgroundColor: Colors.blueAccent,
        border: BorderStyle(color: Colors.amber, style: BorderType.dotted),
        cornerRadius: 90,
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
        color: Color(0xFF2E3192),
        fontSize: 72,
        fontWeight: FontWeight.bold,
      )).toJson());

  // Buttons container
  final buttonsContainer = await bridge.createView('View');
  if (buttonsContainer == null) return;
  await bridge.attachView(card, buttonsContainer);

  await bridge.setLayout(
      buttonsContainer,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        justifyContent: YGJustify.spaceBetween,
        alignItems: YGAlign.center,
        width: YGValue(100, YGUnit.percent),
        margin: const EdgeInsets.only(top: 24),
      ));

  // Replace the old button creation and event handling with new typed version:
  // Create buttons with their respective colors and widths
  final decrementButton = await bridge.createButton(
    text: '-',
    style: ViewStyle(
      backgroundColor: Color(0xFFFF3B30),
      cornerRadius: 28,
      shadows: [
        ShadowStyle(
          color: Color(0xFFFF3B30).withOpacity(0.3),
          offset: const Offset(0, 4),
          radius: 8,
        )
      ],
    ).toJson(),
    events: {
      ButtonEventType.onClick: () async {
        counter--;
        await bridge.updateView(
          counterLabel,
          ViewStyle(
            textStyle: TextStyle(
              text: counter.toString(),
              color: Color(0xFF2E3192),
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ).toJson(),
        );
      },
    },
  );
  await bridge.setLayout(
      decrementButton!,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        justifyContent: YGJustify.spaceBetween,
        alignItems: YGAlign.center,
        width: YGValue(60, YGUnit.point),
        margin: const EdgeInsets.only(top: 24),
      ));
  

  final resetButton = await bridge.createButton(
    text: '↺',
    style: ViewStyle(   
      backgroundColor: Color(0xFF007AFF),
      cornerRadius: 28,
      shadows: [
        ShadowStyle(
          color: Color(0xFF007AFF).withOpacity(0.3),
          offset: const Offset(0, 4),
          radius: 8,
        )
      ],
    ).toJson(),
    events: {
      ButtonEventType.onClick: () async {
        counter = 0;
        await bridge.updateView(
          counterLabel,
          ViewStyle(
            textStyle: TextStyle(
              text: '0',
              color: Color(0xFF2E3192),
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ).toJson(),
        );
      },
    },
  );

   await bridge.setLayout(
      resetButton!,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        justifyContent: YGJustify.spaceBetween,
        alignItems: YGAlign.center,
        width: YGValue(60, YGUnit.point),
        margin: const EdgeInsets.only(top: 24),
      ));
  

  final incrementButton = await bridge.createButton(
    text: '+',
    style: ViewStyle(
      backgroundColor: Color(0xFF34C759),
      cornerRadius: 28,
      shadows: [
        ShadowStyle(
          color: Color(0xFF34C759).withOpacity(0.3),
          offset: const Offset(0, 4),
          radius: 8,
        )
      ],
    ).toJson(),
    events: {
      ButtonEventType.onClick: () async {
        counter++;
        await bridge.updateView(
          counterLabel,
          ViewStyle(
            textStyle: TextStyle(
              text: counter.toString(),
              color: Color(0xFF2E3192),
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ).toJson(),
        );
      },
    },
  );

   await bridge.setLayout(
      incrementButton!,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        justifyContent: YGJustify.spaceBetween,
        alignItems: YGAlign.center,
        width: YGValue(60, YGUnit.point),
        margin: const EdgeInsets.only(top: 24),
      ));
  

  // Attach buttons (no need for registerEvent anymore)
  if (decrementButton != null) {
    await bridge.attachView(buttonsContainer, decrementButton);
  }
  if (resetButton != null) {
    await bridge.attachView(buttonsContainer, resetButton);
  }
  if (incrementButton != null) {
    await bridge.attachView(buttonsContainer, incrementButton);
  }
}
