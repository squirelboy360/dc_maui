import 'package:dc_test/framework/bridge/controls/scroll_view.dart';

import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/view.dart';
import 'package:flutter/material.dart' hide View, ScrollView;
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';

class ScrollViewComposer extends UIComposer {
  String? mainContainer;
  String? appbar;
  String? gridContainerColumn;
  String? bottomButton;
  String? scrollView;
  List<String> gridItemIds = [];

  final colors = [
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
    0xFFE57373,
    0xFF81C784,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
    0xFFE57373,
    0xFF81C784,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
    0xFFE57373,
    0xFF81C784,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
    0xFFE57373,
    0xFF81C784,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
    0xFFE57373,
    0xFF81C784,
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFFFFD54F,
    0xFF7986CB,
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

    // Create grid items first and collect their IDs
    List<String> gridItemIds = [];

    for (var color in colors.take(10)) {
      // Limit to 10 items for testing
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
          width: YogaValue(90, YogaUnit.percent),
          alignSelf: YogaAlign.center,
          height: YogaValue(100, YogaUnit.point),
          margin: EdgeValues(all: YogaValue(8, YogaUnit.point)),
        ),
      ).create();

      if (gridItem != null) {
        gridItemIds.add(gridItem);
        print("Created grid item: $gridItem");
      }
    }

    print("Created ${gridItemIds.length} grid items");

    // Create ScrollView with the children
    scrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.red.toARGB32(),
        showsIndicators: true,
        bounces: true,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
        flexDirection: YogaFlexDirection.column,
        flex: 10,
        padding: EdgeValues(all: YogaValue.point(16)),
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.flexStart,
      ),
      onScroll: (metrics) {
        print('Scrolling - Offset: (${metrics.offsetX}, ${metrics.offsetY})');
      },
      onScrollEnd: () {
        print('Scroll ended');
      },
      children: gridItemIds,
    ).create();

    print(
        "Created ScrollView: $scrollView with ${gridItemIds.length} children");

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
    // This will be overridden by the binder
  }
}
