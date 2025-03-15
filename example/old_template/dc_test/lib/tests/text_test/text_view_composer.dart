import 'package:dc_test/framework/bridge/core.dart';
import 'package:flutter/material.dart' hide View, Text, TextStyle;
import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/text.dart';
import '../../framework/bridge/controls/view.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/controls/touchable.dart';

abstract class TextViewComposer extends UIComposer {
  String? mainContainer;
  String? appbar;
  String? gridContainerColumn;
  String? gridContainer;
  String? textContainer; // Add this
  String? centeredText;
  String? bottomButton;
  String? bottomButtonText;

  final colors = [
    0xFFE57373,
    0xFF81C784,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
  ];

  @override
  Future<void> compose() async {
    mainContainer = await View(
      style: ViewStyle(backgroundColor: Colors.white.value),
      layout: YogaLayout(
        flex: 1,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    appbar = await View(
      style: ViewStyle(backgroundColor: Colors.amber.value),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.point),
      ),
    ).create();

    gridContainerColumn = await View(
      style: ViewStyle(backgroundColor: Colors.black.withOpacity(0.1).value),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        flex: 1,
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    // Add a specific container for text
    textContainer = await View(
      style: ViewStyle(backgroundColor: Colors.white.withOpacity(0.8).value),
      layout: YogaLayout(
        width: YogaValue(300, YogaUnit.point), // Add explicit width
        height: YogaValue(100, YogaUnit.point), // Add explicit height
        alignItems: YogaAlign.center,

        justifyContent: YogaJustify.center,
        alignContent: YogaAlign.center,
      ),
    ).create();

    centeredText = await Text(
      text: "Hello from Grid!",
      textStyle: TextStyle(
        fontSize: 24,
        color: Colors.pink.value,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
      ),
    ).create();


    gridContainer = await View(
      style: ViewStyle(backgroundColor: Colors.red.withOpacity(0.1).value),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
        flexDirection: YogaFlexDirection.row,
        flex: 10,
        padding: EdgeValues(all: YogaValue.point(16)),
        flexWrap: YogaWrap.wrap,
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
      ),
    ).create();

    bottomButton = await Touchable(
      style: TouchableStyle(
        activeOpacity: 0.6,
        backgroundColor: Colors.blueAccent.value,
        cornerRadius: 20,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        height: YogaValue(60, YogaUnit.point),
        width: YogaValue(200, YogaUnit.point),
        alignSelf: YogaAlign.center,
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
      ),
      onPress: () {
        print('Bottom button pressed!');
      },
      onPressIn: () {
        print('Bottom button press started');
      },
      onPressOut: () {
        print('Bottom button press ended');
      },
    ).create();

    bottomButtonText = await Text(
      text: 'Bottom Button',
      textStyle: TextStyle(
        fontSize: 15,
        color: Colors.white.value,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
      ),
    ).create();

    await createGridItems();
  }

  Future<void> createGridItems() async {
    for (var color in colors) {
      final gridItem = await View(
        style: ViewStyle(
          backgroundColor: color,
          cornerRadius: 8,
          shadow: ViewShadow(
            color: Color.fromARGB(255, 28, 213, 65),
            opacity: 0.2,
            offset: Offset(0, 4),
            radius: 8,
          ),
        ),
        layout: YogaLayout(
            padding: EdgeValues(all: YogaValue(8, YogaUnit.point)),
            width: YogaValue(100, YogaUnit.point),
            height: YogaValue(100, YogaUnit.point),
            margin: EdgeValues(all: YogaValue(8, YogaUnit.point)),
            alignItems: YogaAlign.center, // Add this
            justifyContent: YogaJustify.center // Add this
            ),
      ).create();

      // Add text showing the color value
      final colorText = await Text(
        text: '#${color.toRadixString(16).toUpperCase()}',
        textStyle: TextStyle(
          fontSize: 12,
          color: _isColorDark(color) ? Colors.white.value : Colors.black.value,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
        ),
        layout: YogaLayout(
          alignSelf: YogaAlign.center,
        ),
      ).create();

      // Attach text to grid item
      await Core.attachView(gridItem ?? '', colorText ?? '');
      // Attach grid item to grid container
      await Core.attachView(gridContainer ?? '', gridItem ?? '');
    }
  }

  // Helper method to determine if a color is dark
  bool _isColorDark(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;

    // Calculate relative luminance
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance < 0.5;
  }
}
