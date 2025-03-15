import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/view.dart';
import 'package:flutter/material.dart' hide View;
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';

class GridViewComposer extends UIComposer {
  String? mainContainer;
  String? appbar;
  String? gridContainerColumn;
  String? gridContainer;
  String? bottomButton;

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
      style: ViewStyle(backgroundColor: Colors.white.toARGB32()),
      layout: YogaLayout(
        flex: 1,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    appbar = await View(
      style: ViewStyle(backgroundColor: Colors.amber.toARGB32()),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.point),
      ),
    ).create();

    gridContainerColumn = await View(
      style: ViewStyle(backgroundColor: Colors.black.toARGB32()),
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
      style: ViewStyle(backgroundColor: Colors.red.toARGB32()),
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

    bottomButton = await View(
      style: ViewStyle(
          backgroundColor: Colors.blueAccent.toARGB32(), cornerRadius: 20),
      layout: YogaLayout(
          display: YogaDisplay.flex,
          flex: 2.5,
          margin: EdgeValues(all: YogaValue(5, YogaUnit.point)),
          alignSelf: YogaAlign.center,
          height: YogaValue(60, YogaUnit.point),
          width: YogaValue(200, YogaUnit.point),
          alignContent: YogaAlign.center,
          justifyContent: YogaJustify.center,
          alignItems: YogaAlign.center),
    ).create();
  }

  @override
  Future<void> bind() async {
    // This will be overridden by GridViewBinder
  }
}
