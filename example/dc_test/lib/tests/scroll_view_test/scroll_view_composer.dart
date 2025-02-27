import 'package:dc_test/framework/bridge/controls/scroll_view.dart';
import 'package:dc_test/framework/bridge/core.dart';
import 'package:dc_test/framework/bridge/controls/text.dart';

import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/view.dart';
import 'package:flutter/material.dart' hide View, ScrollView, Text, TextStyle;
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';

class ScrollViewComposer extends UIComposer {
  String? mainContainer;
  String? appbar;
  String? appBarTitle;
  String? appBarIcon;
  String? appBarTouchable;
  String? gridContainerColumn;
  String? bottomButton;
  String? bottomButtonText;
  String? scrollView;
  String? horizontalScrollView;

  List<String> gridItemIds = [];
  List<String> horizontalItemIds = [];

  final int itemCount = 20; // Number of vertical items
  final int horizontalItemCount = 7; // Number of horizontal items

  final colors = [
    // Original colors
    0xFF64B5F6, // Blue
    0xFFFFB74D, // Orange
    0xFFBA68C8, // Purple
    0xFF4DB6AC, // Teal
    0xFFFFD54F, // Yellow
    0xFF7986CB, // Indigo

    // Additional unique colors (shortened for brevity)
    0xFFE57373, // Red 300
    0xFF9CCC65, // Light Green 400
    0xFF4CAF50, // Green 500
    0xFFF44336, // Red 500
  ];

  @override
  Future<void> compose() async {
    // Main container
    mainContainer = await View(
      style: ViewStyle(backgroundColor: Colors.white.value),
      layout: YogaLayout(
        flex: 1,
        flexDirection: YogaFlexDirection.column,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
      ),
    ).create();

    // App bar
    appbar = await View(
      style: ViewStyle(backgroundColor: Colors.amber.value),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(60, YogaUnit.point),
        flexDirection: YogaFlexDirection.row,
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
      ),
    ).create();

    // App bar title
    appBarTitle = await Text(
      text: "Instagram-style Feed",
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white.value,
      ),
    ).create();

    // Container for the main vertical scroll view
    gridContainerColumn = await View(
      style: ViewStyle(backgroundColor: Colors.black.withOpacity(0.05).value),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        flex: 1,
        width: YogaValue(100, YogaUnit.percent),
        justifyContent: YogaJustify.flexStart,
        alignItems: YogaAlign.center,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    // Create horizontal scroll view for stories (to be inserted as first item)
    horizontalScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.white.value,
        showsIndicators: false,
        bounces: true,
        direction: ScrollDirection.horizontal,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(110, YogaUnit.point),
        flexDirection: YogaFlexDirection.row,
        padding: EdgeValues(
          vertical: YogaValue(10, YogaUnit.point),
        ),
      ),
      onScroll: (metrics) {
        print('Stories scrolling - X offset: ${metrics.offsetX}');
      },
    ).create();

    // Create story items for the horizontal scroll view
    for (int i = 0; i < horizontalItemCount; i++) {
      // Create container for story
      final storyContainer = await View(
        style: ViewStyle(
          backgroundColor: Colors.transparent.value,
        ),
        layout: YogaLayout(
          width: YogaValue(80, YogaUnit.point),
          margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
          alignItems: YogaAlign.center,
          flexDirection: YogaFlexDirection.column,
        ),
      ).create();

      // Create circle avatar for story
      final storyAvatar = await View(
        style: ViewStyle(
          backgroundColor: Color(colors[i % colors.length]).value,
          cornerRadius: 35, // Make it a circle
          shadow: ViewShadow(
            color: Colors.black,
            opacity: 0.1,
            offset: Offset(0, 2),
            radius: 3,
          ),
        ),
        layout: YogaLayout(
          width: YogaValue(70, YogaUnit.point),
          height: YogaValue(70, YogaUnit.point),
          margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
        ),
      ).create();

      // Create label for story
      final storyLabel = await Text(
        text: "Story ${i + 1}",
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87.value,
        ),
      ).create();

      if (storyContainer != null && storyAvatar != null && storyLabel != null) {
        await Core.attachView(storyContainer, storyAvatar);
        await Core.attachView(storyContainer, storyLabel);
        horizontalItemIds.add(storyContainer);
      }
    }

    // Attach stories to horizontal scroll view
    if (horizontalScrollView != null) {
      for (String item in horizontalItemIds) {
        await Core.attachView(horizontalScrollView!, item);
      }
    }

    // Create main grid items for vertical scrolling (feed posts)
    for (int i = 0; i < itemCount; i++) {
      // Skip creating the first item since we'll insert our horizontal scrollview there
      if (i == 0) {
        // Create a container for the horizontal scroll section
        final storiesContainer = await View(
          style: ViewStyle(
            backgroundColor: Colors.white.value,
            shadow: ViewShadow(
              color: Colors.black,
              opacity: 0.05,
              offset: Offset(0, 2),
              radius: 3,
            ),
          ),
          layout: YogaLayout(
            width: YogaValue(100, YogaUnit.percent),
            margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
          ),
        ).create();

        // Create a header for stories section
        final storiesHeader = await Text(
          text: "Stories",
          layout: YogaLayout(
            margin: EdgeValues(
              left: YogaValue(10, YogaUnit.point),
              top: YogaValue(10, YogaUnit.point),
              bottom: YogaValue(5, YogaUnit.point),
            ),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87.value,
          ),
        ).create();

        if (storiesContainer != null &&
            storiesHeader != null &&
            horizontalScrollView != null) {
          await Core.attachView(storiesContainer, storiesHeader);
          await Core.attachView(storiesContainer, horizontalScrollView!);
          gridItemIds.add(storiesContainer);
        }
        continue;
      }

      // Create regular feed post items
      final gridItem = await View(
        style: ViewStyle(
          backgroundColor: Colors.white.value,
          shadow: ViewShadow(
            color: Colors.black,
            opacity: 0.05,
            offset: Offset(0, 2),
            radius: 3,
          ),
        ),
        layout: YogaLayout(
          padding: EdgeValues(vertical: YogaValue(10, YogaUnit.point)),
          width: YogaValue(100, YogaUnit.percent),
          margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
          flexDirection: YogaFlexDirection.column,
        ),
      ).create();

      // Create username header for post
      final userHeader = await View(
        style: ViewStyle(backgroundColor: Colors.transparent.value),
        layout: YogaLayout(
          flexDirection: YogaFlexDirection.row,
          alignItems: YogaAlign.center,
          padding: EdgeValues(
            horizontal: YogaValue(10, YogaUnit.point),
            bottom: YogaValue(8, YogaUnit.point),
          ),
        ),
      ).create();

      // User avatar
      final userAvatar = await View(
        style: ViewStyle(
          backgroundColor: Color(colors[(i + 2) % colors.length]).value,
          cornerRadius: 15,
        ),
        layout: YogaLayout(
          width: YogaValue(30, YogaUnit.point),
          height: YogaValue(30, YogaUnit.point),
          margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
        ),
      ).create();

      // Username
      final username = await Text(
        text: "user_${i + 1}",
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black.value,
        ),
      ).create();

      // Post content (image)
      final postImage = await View(
        style: ViewStyle(
          backgroundColor: Color(colors[i % colors.length]).value,
        ),
        layout: YogaLayout(
          width: YogaValue(100, YogaUnit.percent),
          height: YogaValue(300, YogaUnit.point),
        ),
      ).create();

      // Post caption
      final caption = await Text(
        text: "This is post caption #${i + 1}",
        layout: YogaLayout(
          padding: EdgeValues(
            horizontal: YogaValue(10, YogaUnit.point),
            top: YogaValue(10, YogaUnit.point),
          ),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          color: Colors.black87.value,
        ),
      ).create();

      // Assemble post components
      if (userHeader != null && userAvatar != null && username != null) {
        await Core.attachView(userHeader, userAvatar);
        await Core.attachView(userHeader, username);
      }

      if (gridItem != null &&
          userHeader != null &&
          postImage != null &&
          caption != null) {
        await Core.attachView(gridItem, userHeader);
        await Core.attachView(gridItem, postImage);
        await Core.attachView(gridItem, caption);
        gridItemIds.add(gridItem);
      }
    }

    // Create main ScrollView for vertical scrolling
    scrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.transparent.value,
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.vertical,
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        flex: 1,
        flexDirection: YogaFlexDirection.column,
      ),
      onScroll: (metrics) {
        print('Feed scrolling - Y offset: ${metrics.offsetY}');
        print('Content size: ${metrics.contentSize.height}');
      },
      onScrollEnd: () {
        print('Feed scroll ended');
      },
    ).create();

    // Bottom button
    bottomButton = await View(
      style: ViewStyle(backgroundColor: Colors.amber.value, cornerRadius: 20),
      layout: YogaLayout(
        height: YogaValue(50, YogaUnit.point),
        width: YogaValue(200, YogaUnit.point),
        alignSelf: YogaAlign.center,
        margin: EdgeValues(vertical: YogaValue(10, YogaUnit.point)),
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
      ),
    ).create();

    bottomButtonText = await Text(
      text: "Load More",
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white.value,
      ),
    ).create();
  }

  @override
  Future<void> bind() async {
    try {
      // Attach main container to root
      await Core.attachView('root', mainContainer ?? '');

      // Attach app bar and title
      if (appbar != null && mainContainer != null) {
        await Core.attachView(mainContainer!, appbar!);
        if (appBarTitle != null) {
          await Core.attachView(appbar!, appBarTitle!);
        }
      }

      // Attach grid container to main container
      if (gridContainerColumn != null && mainContainer != null) {
        await Core.attachView(mainContainer!, gridContainerColumn!);

        // Attach scrollview to grid container
        if (scrollView != null) {
          await Core.attachView(gridContainerColumn!, scrollView!);

          // Attach all grid items to the scrollview
          for (String item in gridItemIds) {
            await Core.attachView(scrollView!, item);
          }
        }
      }

      // Attach bottom button
      if (bottomButton != null && mainContainer != null) {
        await Core.attachView(mainContainer!, bottomButton!);
        if (bottomButtonText != null) {
          await Core.attachView(bottomButton!, bottomButtonText!);
        }
      }

      print('All views bound successfully');
      print('Created ${gridItemIds.length} feed items');
      print(
          'Created ${horizontalItemIds.length} story items in horizontal scroll');
    } catch (e) {
      print('Error binding views: $e');
    }
  }
}
