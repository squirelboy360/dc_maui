import 'package:dc_test/framework/bridge/controls/scroll_view.dart';
import 'package:dc_test/framework/bridge/core.dart';

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

  // Number of items to display
  final int itemCount = 50; // Changed from 10 to 50

  final colors = [
    // Original colors
    0xFF64B5F6, // Blue
    0xFFFFB74D, // Orange
    0xFFBA68C8, // Purple
    0xFF4DB6AC, // Teal
    0xFFFFD54F, // Yellow
    0xFF7986CB, // Indigo

    // Additional 50 unique colors
    0xFFE57373, // Red 300
    0xFFF06292, // Pink 300
    0xFFBA68C8, // Purple 300
    0xFFAB47BC, // Purple 400
    0xFF9575CD, // Deep Purple 300
    0xFF7E57C2, // Deep Purple 400
    0xFF5C6BC0, // Indigo 400
    0xFF42A5F5, // Blue 400
    0xFF29B6F6, // Light Blue 400
    0xFF26C6DA, // Cyan 400
    0xFF26A69A, // Teal 400
    0xFF66BB6A, // Green 400
    0xFF9CCC65, // Light Green 400
    0xFFD4E157, // Lime 400
    0xFFFFEE58, // Yellow 400
    0xFFFFCA28, // Amber 400
    0xFFFFA726, // Orange 400
    0xFFFF7043, // Deep Orange 400
    0xFF8D6E63, // Brown 400
    0xFF78909C, // Blue Grey 400
    0xFF9E9E9E, // Grey 500
    0xFFEF5350, // Red 400
    0xFFEC407A, // Pink 400
    0xFF42A5F5, // Blue 400
    0xFF00BCD4, // Cyan 500
    0xFF009688, // Teal 500
    0xFF4CAF50, // Green 500
    0xFF8BC34A, // Light Green 500
    0xFFCDDC39, // Lime 500
    0xFFFFC107, // Amber 500
    0xFF03A9F4, // Light Blue 500
    0xFF3F51B5, // Indigo 500
    0xFF673AB7, // Deep Purple 500
    0xFF9C27B0, // Purple 500
    0xFFE91E63, // Pink 500
    0xFFF44336, // Red 500
    0xFF795548, // Brown 500
    0xFF607D8B, // Blue Grey 500
    0xFF827717, // Lime 900
    0xFF1B5E20, // Green 900
    0xFF006064, // Cyan 900
    0xFF880E4F, // Pink 900
    0xFFB71C1C, // Red 900
    0xFF4A148C, // Purple 900
    0xFF311B92, // Deep Purple 900
    0xFF01579B, // Light Blue 900
    0xFF263238, // Blue Grey 900
    0xFF33691E, // Light Green 900
    0xFF004D40, // Teal 900
    0xFF3E2723, // Brown 900
    0xFFFF5252, // Red A200
    0xFFFF4081, // Pink A200
    0xFFE040FB, // Purple A200
    0xFF7C4DFF, // Deep Purple A200
    0xFF536DFE, // Indigo A200
    0xFF448AFF, // Blue A200
    0xFF40C4FF, // Light Blue A200
    0xFF18FFFF, // Cyan A200
    0xFF69F0AE, // Green A200
    0xFFB2FF59, // Light Green A200
    0xFFEEFF41, // Lime A200
    0xFFFFFF00, // Yellow A200
    0xFFFFD740, // Amber A200
    0xFFFFAB40, // Orange A200
    0xFFFF6E40, // Deep Orange A200
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

    // Use itemCount instead of hardcoding 10
    for (int i = 0; i < itemCount; i++) {
      final color = colors[i % colors.length]; // Use modulo to ensure we don't go out of bounds
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
        print("Created grid item $i with color: ${color.toRadixString(16)}");
      }
    }

    print("Created ${gridItemIds.length} grid items");

    // Create ScrollView with the children
    scrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.transparent.toARGB32(), // Changed to transparent
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.vertical, // Explicitly set direction
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
        print('Content size: ${metrics.contentSize.width} x ${metrics.contentSize.height}');
        print('Viewport size: ${metrics.viewportSize.width} x ${metrics.viewportSize.height}');
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
    await Core.attachView('root', mainContainer ?? '');
    await Core.attachView(mainContainer ?? '', appbar ?? 'appbar is null');
    await Core.attachView(mainContainer ?? '',
        gridContainerColumn ?? 'gridContainerColumn is null');

    // Attach the ScrollView to its parent - but not the children to the ScrollView
    // The children are already included in the ScrollView creation
    await Core.attachView(gridContainerColumn ?? '', scrollView ?? '');

    await Core.attachView(gridContainerColumn ?? '', bottomButton ?? '');
  }
}
