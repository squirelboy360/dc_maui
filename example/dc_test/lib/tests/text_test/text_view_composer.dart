import 'package:dc_test/framework/bridge/core.dart';
import 'package:flutter/material.dart' hide View, Text, TextStyle;
import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/text.dart';
import '../../framework/bridge/controls/view.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';

abstract class TextViewComposer extends UIComposer {
  String? mainContainer;
  String? appbar;
  String? gridContainerColumn;
  String? gridContainer;
  String? centeredText;
  String? bottomButton;

  final colors = [
    0xFFE57373, 0xFF81C784, 0xFF64B5F6, 0xFFFFB74D,
    0xFFBA68C8, 0xFF4DB6AC, 0xFFFFD54F, 0xFFFFD54F,
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
        alignContent: YogaAlign.center,
        height: YogaValue(100, YogaUnit.percent),
        width: YogaValue(100, YogaUnit.percent),
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.spaceBetween,
        flexDirection: YogaFlexDirection.column,
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
        flexWrap: YogaWrap.wrapReverse,
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
      ),
    ).create();

    centeredText = await Text(
      text: "Hello from Grid!",
      textStyle: TextStyle(
        fontSize: 24,
        color: Colors.blue.value,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
      ),
      layout: YogaLayout(
        margin: EdgeValues(all: YogaValue(16, YogaUnit.point)),
      ),
    ).create();

    bottomButton = await View(
      style: ViewStyle(
        backgroundColor: Colors.blueAccent.value,
        cornerRadius: 20,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        flex: 0,
        height: YogaValue(60, YogaUnit.point),
        width: YogaValue(200, YogaUnit.point),
        margin: EdgeValues(all: YogaValue(16, YogaUnit.point)),
        alignSelf: YogaAlign.center,
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
        ),
      ).create();

      await Core.attachView(gridContainer ?? '', gridItem ?? '');
    }
  }
}
