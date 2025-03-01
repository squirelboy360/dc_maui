import 'package:dc_test/framework/bridge/controls/scroll_view.dart';
import 'package:dc_test/framework/bridge/controls/text_input.dart';
import 'package:dc_test/framework/bridge/controls/touchable.dart';
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
  String? appbarTitle;
  String? mainScrollView;
  String? searchbar;
  String? storiesContainer;
  String? storiesHeader;
  String? horizontalScrollView;
  String? bottomButton;
  String? bottomButtonText;

  List<String> mainScrollItems = [];
  List<String> storyItems = [];
  List<String> allPosts = [];

  // Create shared state variables
  final buttonTextState = StateValue("Load More");
  final buttonOpacityState = StateValue(1.0);
  final visibleCountState = StateValue(10);
  final searchQueryState = StateValue("");

  final int mainItemCount = 50;
  final int horizontalItemCount = 50;
  final int loadMoreIncrement = 10;

  final colors = [
    0xFF64B5F6, // Blue
    0xFFFFB74D, // Orange
    0xFFBA68C8, // Purple
    0xFF4DB6AC, // Teal
    0xFFFFD54F, // Yellow
    0xFF7986CB, // Indigo
    0xFFE57373, // Red 300
    0xFF9CCC65, // Light Green 400
    0xFF4CAF50, // Green 500
    0xFFF44336, // Red 500,
  ];

  @override
  Future<void> compose() async {
    // Main container
    mainContainer = await View(
      style: ViewStyle(backgroundColor: Colors.white.value),
      layout: YogaLayout(
        flexDirection: YogaFlexDirection.column,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
      ),
    ).create();

    // App bar
    appbar = await View(
      style: ViewStyle(
        backgroundColor: Color(0xFF3F51B5).value,
      ),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(150, YogaUnit.point),
        flexDirection: YogaFlexDirection.column,
        justifyContent: YogaJustify.flexEnd,
        alignItems: YogaAlign.center,
      ),
    ).create();

    // App bar title
    appbarTitle = await Text(
      text: "Instagram-style Feed",
      layout:
          YogaLayout(margin: EdgeValues(bottom: YogaValue(16, YogaUnit.point))),
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white.value,
        textAlign: TextAlign.center,
      ),
    ).create();

    // Search bar with text change handling
    searchbar = await TextInput(
      inputStyle: TextInputStyle(
        placeholder: "Search",
        contentType: ContentType.url,
        textColor: Colors.white.value,
      ),
      style: ViewStyle(
        backgroundColor: Colors.grey.withAlpha(50).value,
        cornerRadius: 24,
      ),
      layout: YogaLayout(
        alignSelf: YogaAlign.flexEnd,
        width: YogaValue(80, YogaUnit.percent),
        height: YogaValue(40, YogaUnit.point),
        margin: EdgeValues(
          top: YogaValue(16, YogaUnit.point),
          bottom: YogaValue(16, YogaUnit.point),
        ),
      ),
      onTextChange: (text) {
        // Update search query state
        searchQueryState.setValue(text);

        // Update visible count based on search
        if (text.isEmpty) {
          visibleCountState.setValue(10); // Default count when not searching
        } else {
          // Simulate filtering by showing fewer items
          visibleCountState.setValue(5);
        }

        // Update button state accordingly
        updateButtonState();
      },
    ).create();

    // Main vertical scroll view
    mainScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Color(0xFFF0F0F0).value,
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.vertical,
      ),
      layout: YogaLayout(
        flex: 1,
        width: YogaValue(100, YogaUnit.percent),
      ),
    ).create();

    // Stories container
    storiesContainer = await View(
      style: ViewStyle(
        backgroundColor: Colors.white.value,
      ),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        flexDirection: YogaFlexDirection.column,
        margin: EdgeValues(bottom: YogaValue(20, YogaUnit.point)),
      ),
    ).create();

    // Stories header
    storiesHeader = await Text(
      text: "Stories",
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87.value,
        textAlign: TextAlign.left,
      ),
      layout: YogaLayout(
        margin: EdgeValues(
          left: YogaValue(16, YogaUnit.point),
          top: YogaValue(12, YogaUnit.point),
          bottom: YogaValue(8, YogaUnit.point),
        ),
      ),
    ).create();

    // Horizontal scroll view for stories
    horizontalScrollView = await ScrollView(
      style: ScrollViewStyle(
        backgroundColor: Colors.transparent.value,
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.horizontal,
      ),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(120, YogaUnit.point),
      ),
    ).create();

    // Create story items
    for (int i = 0; i < horizontalItemCount; i++) {
      final storyItem = await createStoryItem(i);
      if (storyItem != null) {
        storyItems.add(storyItem);
      }
    }

    // Create all feed posts
    for (int i = 0; i < mainItemCount; i++) {
      if (i == 0) {
        mainScrollItems.add(storiesContainer!);
        continue;
      }

      final postContainer = await createPostItem(i);
      if (postContainer != null) {
        allPosts.add(postContainer);

        // Only add initial batch to visible items
        if (i <= 10) {
          // Initial visible count
          mainScrollItems.add(postContainer);
        }
      }
    }

    // Bottom button
    bottomButton = await Touchable(
      style: TouchableStyle(
        backgroundColor: Color(0xFF3F51B5).value,
        cornerRadius: 24,
      ),
      layout: YogaLayout(
        alignSelf: YogaAlign.center,
        width: YogaValue(180, YogaUnit.point),
        height: YogaValue(50, YogaUnit.point),
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
        margin: EdgeValues(
          top: YogaValue(16, YogaUnit.point),
          bottom: YogaValue(16, YogaUnit.point),
        ),
      ),
      onPress: handleLoadMore,
    ).create();

    // Button text
    bottomButtonText = await Text(
      text: "Load More",
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white.value,
        textAlign: TextAlign.center,
      ),
    ).create();

    // Register state with components
    if (bottomButtonText != null) {
      buttonTextState.register(bottomButtonText!);
    }

    if (bottomButton != null) {
      buttonOpacityState.register(bottomButton!);
    }

    // Set initial button text with remaining count
    int remaining = allPosts.length - 10;
    buttonTextState.setValue("Load More ($remaining)");
  }

  // Helper to create a story item
  Future<String?> createStoryItem(int i) async {
    // Story container
    final storyContainer = await View(
      style: ViewStyle(backgroundColor: Colors.transparent.value),
      layout: YogaLayout(
        width: YogaValue(90, YogaUnit.point),
        alignItems: YogaAlign.center,
        margin: EdgeValues(
          left: i == 0
              ? YogaValue(16, YogaUnit.point)
              : YogaValue(12, YogaUnit.point),
          right: YogaValue(0, YogaUnit.point),
        ),
      ),
    ).create();

    // Story avatar - circle
    final storyAvatar = await View(
      style: ViewStyle(
        backgroundColor: Color(colors[i % colors.length]).value,
        cornerRadius: 35, // Makes it circular
      ),
      layout: YogaLayout(
        width: YogaValue(70, YogaUnit.point),
        height: YogaValue(70, YogaUnit.point),
        margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
      ),
    ).create();

    // Story label
    final storyLabel = await Text(
      text: "Story ${i + 1}",
      textStyle: TextStyle(
        fontSize: 14,
        color: Colors.black.value,
        textAlign: TextAlign.center, // Center align the text
      ),
      layout: YogaLayout(
        width: YogaValue(70, YogaUnit.point),
      ),
    ).create();

    // Attach components
    if (storyContainer != null && storyAvatar != null && storyLabel != null) {
      await Core.attachView(storyContainer, storyAvatar);
      await Core.attachView(storyContainer, storyLabel);
      return storyContainer;
    }

    return null;
  }

  // Helper to create a post item
  Future<String?> createPostItem(int i) async {
    // Post container
    final postContainer = await View(
      style: ViewStyle(
        backgroundColor: Colors.white.value,
      ),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        margin: EdgeValues(bottom: YogaValue(10, YogaUnit.point)),
      ),
    ).create();

    // Post header container
    final postHeader = await View(
      style: ViewStyle(
        backgroundColor: Colors.transparent.value,
      ),
      layout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(60, YogaUnit.point),
        flexDirection: YogaFlexDirection.row,
        alignItems: YogaAlign.center,
        padding: EdgeValues(
          left: YogaValue(16, YogaUnit.point),
          right: YogaValue(16, YogaUnit.point),
        ),
      ),
    ).create();

    // User avatar
    final userAvatar = await View(
      style: ViewStyle(
        backgroundColor: Color(colors[(i + 3) % colors.length]).value,
        cornerRadius: 20, // Makes it circular
      ),
      layout: YogaLayout(
        width: YogaValue(40, YogaUnit.point),
        height: YogaValue(40, YogaUnit.point),
        margin: EdgeValues(right: YogaValue(12, YogaUnit.point)),
      ),
    ).create();

    // Username
    final userName = await Text(
      text: "user_${i}",
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black.value,
        textAlign: TextAlign.left,
      ),
      layout: YogaLayout(
        flex: 1,
      ),
    ).create();

    // Post image
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
    final postCaption = await Text(
      text: "This is post ${i} caption with some text to demonstrate wrapping.",
      textStyle: TextStyle(
        fontSize: 14,
        color: Colors.black87.value,
        textAlign: TextAlign.left,
      ),
      layout: YogaLayout(
        padding: EdgeValues(
          left: YogaValue(16, YogaUnit.point),
          right: YogaValue(16, YogaUnit.point),
          top: YogaValue(12, YogaUnit.point),
          bottom: YogaValue(16, YogaUnit.point),
        ),
      ),
    ).create();

    // Assemble post
    if (postContainer != null && postHeader != null) {
      await Core.attachView(postContainer, postHeader);

      if (userAvatar != null) {
        await Core.attachView(postHeader, userAvatar);
      }

      if (userName != null) {
        await Core.attachView(postHeader, userName);
      }

      if (postImage != null) {
        await Core.attachView(postContainer, postImage);
      }

      if (postCaption != null) {
        await Core.attachView(postContainer, postCaption);
      }

      return postContainer;
    }

    return null;
  }

  // Handle load more button press
  void handleLoadMore() {
    // Get current visible count
    int currentVisible = visibleCountState.initialValue;
    int newCount = currentVisible + loadMoreIncrement;

    // Cap at maximum number of posts
    if (newCount > allPosts.length) {
      newCount = allPosts.length;
    }

    // Update the state value - this will notify all consumers
    visibleCountState.setValue(newCount);

    // Add additional items to the scroll view
    for (int i = currentVisible; i < newCount; i++) {
      if (i < allPosts.length) {
        String postId = allPosts[i];
        mainScrollItems.add(postId);
        Core.attachView(mainScrollView!, postId);
      }
    }

    // Update button state
    updateButtonState();
  }

  // Update button text and appearance based on current state
  void updateButtonState() {
    int currentVisible = visibleCountState.initialValue;
    int remaining = allPosts.length - currentVisible;

    if (remaining <= 0) {
      buttonTextState.setValue("All Posts Loaded");
      buttonOpacityState.setValue(0.5);
    } else {
      buttonTextState.setValue("Load More ($remaining)");
      buttonOpacityState.setValue(1.0);
    }
  }

  @override
  Future<void> bind() async {
    try {
      // Root structure
      await Core.attachView('root', mainContainer!);
      await Core.attachView(mainContainer!, appbar!);
      await Core.attachView(appbar!, appbarTitle!);
      await Core.attachView(appbar!, searchbar!);

      await Core.attachView(mainContainer!, mainScrollView!);

      // Connect stories components
      await Core.attachView(storiesContainer!, storiesHeader!);
      await Core.attachView(storiesContainer!, horizontalScrollView!);

      // Attach all stories to horizontal scroll view
      print("Attaching ${storyItems.length} stories to horizontal scroll");
      for (String item in storyItems) {
        await Core.attachView(horizontalScrollView!, item);
      }

      // Attach all feed items to main scroll view
      print("Attaching ${mainScrollItems.length} feed items to main scroll");
      for (String item in mainScrollItems) {
        await Core.attachView(mainScrollView!, item);
      }

      // Attach button
      await Core.attachView(mainContainer!, bottomButton!);
      await Core.attachView(bottomButton!, bottomButtonText!);

      print('All views bound successfully');
    } catch (e) {
      print('Error binding views: $e');
    }
  }
}
