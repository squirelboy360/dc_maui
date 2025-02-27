import 'package:dc_test/framework/bridge/controls/scroll_view.dart';
import 'package:dc_test/framework/bridge/controls/text.dart';
import 'package:dc_test/framework/bridge/controls/touchable.dart';
import 'package:dc_test/framework/bridge/types/text_types/text_styles.dart';

import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/view.dart';
import 'package:flutter/material.dart' hide View, ScrollView, Text, TextStyle;
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/core.dart';

class ScrollViewComposer extends UIComposer {
  String? rootViewId;
  String? mainContainer;
  //
  String? appbar;
  String? appBarTitle;
  String? appBarIcon;
  String? appBarTouchable;
  //
  String? gridContainerColumn;
  String? bottomButton;
  String? bottomButtonText;
  String? horizontalScrollView;
  String? verticalScrollView;
  // Section titles
  String? horizontalSectionTitle;
  String? verticalSectionTitle;

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
    // Main container with white background
    mainContainer = await View(
      style: ViewStyle(backgroundColor: Colors.white.toARGB32()),
      layout: YogaLayout(
        flex: 1,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    // Improved app bar with better styling
    appbar = await View(
      style: ViewStyle(
        backgroundColor: Color(0xFF3F51B5).toARGB32(), // Material indigo
        shadow: ViewShadow(
          color: Colors.black,
          opacity: 0.3,
          offset: Offset(0, 2),
          radius: 4,
        ),
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        flexDirection: YogaFlexDirection.row,
        justifyContent: YogaJustify.center, // Center the title
        alignItems: YogaAlign.center,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(80, YogaUnit.point), // Slightly smaller height
      ),
    ).create();

    // App bar title with improved styling
    appBarTitle = await Text(
      layout: YogaLayout(
        alignSelf: YogaAlign.center,
      ),
      text: "Scroll View Demo",
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white.toARGB32(),
        textAlign: TextAlign.center,
      ),
    ).create();

    // Section titles
    horizontalSectionTitle = await Text(
      layout: YogaLayout(
        alignSelf: YogaAlign.flexStart,
        margin: EdgeValues(
          left: YogaValue(16, YogaUnit.point),
          top: YogaValue(16, YogaUnit.point),
          bottom: YogaValue(8, YogaUnit.point),
        ),
      ),
      text: "Horizontal Scroll",
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87.toARGB32(),
      ),
    ).create();

    verticalSectionTitle = await Text(
      layout: YogaLayout(
        alignSelf: YogaAlign.flexStart,
        margin: EdgeValues(
          left: YogaValue(16, YogaUnit.point),
          top: YogaValue(16, YogaUnit.point),
          bottom: YogaValue(8, YogaUnit.point),
        ),
      ),
      text: "Vertical Scroll",
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87.toARGB32(),
      ),
    ).create();

    // Create container for both scroll views with improved styling
    gridContainerColumn = await View(
      style: ViewStyle(
        backgroundColor: Color(0xFFF5F5F5).toARGB32(), // Light grey background
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        flex: 1,
        width: YogaValue(100, YogaUnit.percent),
        justifyContent: YogaJustify.flexStart,
        alignItems: YogaAlign.center,
        flexDirection: YogaFlexDirection.column,
        padding: EdgeValues(
          top: YogaValue(0, YogaUnit.point),
          bottom: YogaValue(16, YogaUnit.point),
        ),
      ),
    ).create();

    // Create items for horizontal scroll
    final horizontalItems = await createScrollItems(
        itemCount: colors.length,
        width: 160,
        height: 120,
        radius: 10,
        margin: 8);

    // Create horizontal ScrollView with improved styling
    horizontalScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.white.toARGB32(),
        showsIndicators: false, // Hide indicators for cleaner look
        bounces: true,
        direction: ScrollDirection.horizontal,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(150, YogaUnit.point),
        flexDirection: YogaFlexDirection.row,
        padding: EdgeValues(
          left: YogaValue(8, YogaUnit.point),
          right: YogaValue(8, YogaUnit.point),
          top: YogaValue(8, YogaUnit.point),
          bottom: YogaValue(8, YogaUnit.point),
        ),
        margin: EdgeValues(bottom: YogaValue(16, YogaUnit.point)),
      ),
      onScroll: (metrics) {
        print(
            'Horizontal scrolling - Offset: (${metrics.offsetX}, ${metrics.offsetY})');
      },
      children: horizontalItems,
    ).create();

    // Create items for vertical scroll with improved styling
    final verticalItems = await createScrollItems(
        itemCount: colors.length,
        width: 90,
        widthUnit: YogaUnit.percent,
        height: 100,
        heightUnit: YogaUnit.point,
        radius: 12,
        margin: 8);

    // Create vertical ScrollView with improved styling
    verticalScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.white.toARGB32(),
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.vertical,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        flex: 1,
        flexDirection: YogaFlexDirection.column,
        padding: EdgeValues(
          left: YogaValue(16, YogaUnit.point),
          right: YogaValue(16, YogaUnit.point),
        ),
        margin: EdgeValues(bottom: YogaValue(16, YogaUnit.point)),
      ),
      onScroll: (metrics) {
        print(
            'Vertical scrolling - Offset: (${metrics.offsetX}, ${metrics.offsetY})');
      },
      children: verticalItems,
    ).create();

    // Create button touchable with proper styling
    bottomButton = await Touchable(
      style: TouchableStyle(
        backgroundColor: Color(0xFF3F51B5).toARGB32(), // Match app bar color
        cornerRadius: 24,
        shadow: ViewShadow(
          color: Colors.black,
          opacity: 0.2,
          offset: Offset(0, 2),
          radius: 4,
        ),
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        height: YogaValue(56, YogaUnit.point),
        width: YogaValue(200, YogaUnit.point),
        alignItems: YogaAlign.center,
        justifyContent: YogaJustify.center,
        margin: EdgeValues(
          top: YogaValue(16, YogaUnit.point),
          bottom: YogaValue(24, YogaUnit.point),
        ),
      ),
      onPress: () {
        print("Button pressed");
      },
    ).create();

    // Add text to the button
    bottomButtonText = await Text(
      text: "Continue",
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white.toARGB32(),
        textAlign: TextAlign.center,
      ),
    ).create();
  }

  Future<List<String>> createScrollItems({
    required int itemCount,
    required double width,
    required double height,
    YogaUnit widthUnit = YogaUnit.point,
    YogaUnit heightUnit = YogaUnit.point,
    double radius = 8.0,
    double margin = 8.0,
  }) async {
    List<String> itemIds = [];

    for (var i = 0; i < itemCount; i++) {
      // Create container view for the item
      final item = await View(
        style: ViewStyle(
          backgroundColor: colors[i % colors.length],
          cornerRadius: radius,
          shadow: ViewShadow(
            color: Colors.black,
            opacity: 0.15,
            offset: Offset(0, 2),
            radius: 4,
          ),
        ),
        layout: YogaLayout(
          alignSelf: YogaAlign.center,
          width: YogaValue(width, widthUnit),
          height: YogaValue(height, heightUnit),
          margin: EdgeValues(all: YogaValue(margin, YogaUnit.point)),
          justifyContent: YogaJustify.center,
          alignItems: YogaAlign.center,
        ),
      ).create();

      // Add a label to each item
      final itemLabel = await Text(
        text: "Item ${i + 1}",
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white.toARGB32(),
          textAlign: TextAlign.center,
        ),
      ).create();

      // Attach the label to the item
      if (item != null && itemLabel != null) {
        await Core.attachView(item, itemLabel);
        itemIds.add(item);
      }
    }

    return itemIds;
  }

  @override
  Future<void> bind() async {
    // Get root view info

    rootViewId = 'root';

    if (rootViewId == null || mainContainer == null) {
      print('Cannot bind views: Root view or main container is null');
      return;
    }

    // Attach main container to root view
    await Core.attachView(rootViewId!, mainContainer!);

    // Attach app bar to main container
    if (appbar != null) {
      await Core.attachView(mainContainer!, appbar!);

      // Attach title to app bar
      if (appBarTitle != null) {
        await Core.attachView(appbar!, appBarTitle!);
      }
    }

    // Attach grid container to main container
    if (gridContainerColumn != null) {
      await Core.attachView(mainContainer!, gridContainerColumn!);

      // Attach horizontal section components
      if (horizontalSectionTitle != null) {
        await Core.attachView(gridContainerColumn!, horizontalSectionTitle!);
      }

      if (horizontalScrollView != null) {
        await Core.attachView(gridContainerColumn!, horizontalScrollView!);
      }

      // Attach vertical section components
      if (verticalSectionTitle != null) {
        await Core.attachView(gridContainerColumn!, verticalSectionTitle!);
      }

      if (verticalScrollView != null) {
        await Core.attachView(gridContainerColumn!, verticalScrollView!);
      }

      // Attach bottom button and its text
      if (bottomButton != null) {
        await Core.attachView(gridContainerColumn!, bottomButton!);

        if (bottomButtonText != null) {
          await Core.attachView(bottomButton!, bottomButtonText!);
        }
      }
    }

    print('All views bound successfully');
  }
}
