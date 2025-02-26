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
  String? horizontalScrollView;
  String? verticalScrollView;
  final List<int> colors = [
    0xFF64B5F6, // Blue
    0xFFFFB74D, // Orange
    0xFFBA68C8, // Purple
    0xFF4DB6AC, // Teal
    0xFFFFD54F, // Yellow
    0xFF81C784, // Green
    0xFF7986CB, // Indigo
    0xFFE57373, // Red
    0xFFF06292, // Pink
    0xFFA1887F, // Brown
    0xFF90A4AE, // Blue Grey
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
        height: YogaValue(80, YogaUnit.point), // Make smaller
      ),
    ).create();

    // Create container for both scroll views
    gridContainerColumn = await View(
      style: ViewStyle(backgroundColor: Colors.black.withOpacity(0.1).toARGB32()),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        alignContent: YogaAlign.center,
        height: YogaValue(100, YogaUnit.percent),
        width: YogaValue(100, YogaUnit.percent),
        justifyContent: YogaJustify.flexStart,
        alignItems: YogaAlign.center,
        flexDirection: YogaFlexDirection.column,
        padding: EdgeValues(all: YogaValue(8, YogaUnit.point)),
      ),
    ).create();

    // Create items for horizontal scroll
    final horizontalItems = await createScrollItems(
        itemCount: colors.length,
        width: 150,
        height: 100,
        radius: 8,
        margin: 8);

    print("Created ${horizontalItems.length} horizontal scroll items");

    // Create horizontal ScrollView
    horizontalScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.blue.withOpacity(0.1).toARGB32(),
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.horizontal,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(
            150, YogaUnit.point), // Fixed height for horizontal scroll
        flexDirection: YogaFlexDirection.row, // Row for horizontal layout
        padding: EdgeValues(all: YogaValue(12, YogaUnit.point)),
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.flexStart,
        margin: EdgeValues(bottom: YogaValue(20, YogaUnit.point)),
      ),
      onScroll: (metrics) {
        print(
            'Horizontal scrolling - Offset: (${metrics.offsetX}, ${metrics.offsetY})');
      },
      onScrollEnd: () {
        print('Horizontal scroll ended');
      },
      children: horizontalItems,
    ).create();

    // Create items for vertical scroll
    final verticalItems = await createScrollItems(
        itemCount: colors.length,
        width: 300,
        height: 80,
        radius: 12,
        margin: 10);

    print("Created ${verticalItems.length} vertical scroll items");

    // Create vertical ScrollView
    verticalScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.green.withOpacity(0.1).toARGB32(),
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.vertical, // Explicitly set vertical
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        flex: 1, // Take remaining space
        flexDirection: YogaFlexDirection.column, // Column for vertical layout
        padding: EdgeValues(all: YogaValue(12, YogaUnit.point)),
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.flexStart,
      ),
      onScroll: (metrics) {
        print(
            'Vertical scrolling - Offset: (${metrics.offsetX}, ${metrics.offsetY})');
      },
      onScrollEnd: () {
        print('Vertical scroll ended');
      },
      children: verticalItems,
    ).create();

    bottomButton = await View(
      style: ViewStyle(
        backgroundColor: Colors.blueAccent.toARGB32(),
        cornerRadius: 20,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        height: YogaValue(60, YogaUnit.point),
        width: YogaValue(200, YogaUnit.point),
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
        margin: EdgeValues(top: YogaValue(20, YogaUnit.point)),
      ),
    ).create();
  }

  // Helper method to create scroll items
  Future<List<String>> createScrollItems({
    required int itemCount,
    required double width,
    required double height,
    double radius = 8.0,
    double margin = 8.0,
  }) async {
    List<String> itemIds = [];

    for (var i = 0; i < itemCount; i++) {
      final item = await View(
        style: ViewStyle(
          backgroundColor: colors[i % colors.length],
          cornerRadius: radius,
          shadow: ViewShadow(
            color: Color.fromARGB(255, 0, 0, 0),
            opacity: 0.2,
            offset: Offset(0, 3),
            radius: 5,
          ),
        ),
        layout: YogaLayout(
          width: YogaValue(width, YogaUnit.point),
          height: YogaValue(height, YogaUnit.point),
          margin: EdgeValues(all: YogaValue(margin, YogaUnit.point)),
        ),
      ).create();

      if (item != null) {
        itemIds.add(item);
      }
    }

    return itemIds;
  }

  @override
  Future<void> bind() async {
    // This will be overridden by the binder
  }
}
