import 'package:dc_test/framework/bridge/controls/touchable.dart';
import 'package:flutter/material.dart' hide ScrollView, Text, TextStyle;
import '../../framework/ui_composer.dart';
import '../../framework/composers/view.dart';
import '../../framework/composers/text.dart';
import '../../framework/composers/text_input.dart';
import '../../framework/composers/touchable.dart';
import '../../framework/bridge/core.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';
import '../../framework/bridge/controls/text_input.dart'
    show ContentType, TextInputStyle;
import '../../framework/bridge/controls/scroll_view.dart'
    show ScrollDirection, ScrollViewStyle;

class ScrollViewComposer extends UIComposer {
  // States
  final buttonTextState = UIState<String>("Load More");
  final buttonOpacityState = UIState<double>(1.0);
  final visibleCountState = UIState<int>(10);
  final searchQueryState = UIState<String>("");

  // Colors for styling
  final colors = [
    0xFF64B5F6,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF4DB6AC,
    0xFFFFD54F,
    0xFF7986CB,
    0xFFE57373,
    0xFF9CCC65,
    0xFF4CAF50,
    0xFFF44336,
  ];

  @override
  Future<void> compose() async {
    // Create the UI tree just once - no need to manually track components
    final root = DCView(
      viewStyle: ViewStyle(backgroundColor: Colors.white.value),
      yogaLayout: YogaLayout(
        flexDirection: YogaFlexDirection.column,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
      ),
      children: [_buildAppBar(), _buildMainContent(), _buildLoadMoreButton()],
    );

    // Save the root component so we can create it in bind()
    rootComponent = root;
  }

  // App bar with title and search
  DCView _buildAppBar() {
    return DCView(
      viewStyle: ViewStyle(
        backgroundColor: Colors.pink.value,
      ),
      yogaLayout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(150, YogaUnit.point),
        flexDirection: YogaFlexDirection.column,
        justifyContent: YogaJustify.flexEnd,
        alignItems: YogaAlign.center,
      ),
      children: [
        DCText(
          "Instagram-style Feed",
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.value,
            textAlign: TextAlign.center,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(bottom: YogaValue(16, YogaUnit.point)),
          ),
        ),
        DCTextInput(
          inputStyle: TextInputStyle(
            placeholder: "Search",
            contentType: ContentType.url,
            textColor: Colors.white.value,
          ),
          viewStyle: ViewStyle(
            backgroundColor: Colors.grey.withAlpha(50).value,
            cornerRadius: 24,
          ),
          yogaLayout: YogaLayout(
            alignSelf: YogaAlign.flexEnd,
            width: YogaValue(80, YogaUnit.percent),
            height: YogaValue(40, YogaUnit.point),
            margin: EdgeValues(
              top: YogaValue(16, YogaUnit.point),
              bottom: YogaValue(16, YogaUnit.point),
            ),
          ),
          onTextChange: _handleSearchInput,
        ),
      ],
    );
  }

  // Main scroll view containing stories and posts
  UIComponent _buildMainContent() {
    return DCView(
      viewStyle: ViewStyle(
        backgroundColor: Color(0xFFF0F0F0).value,
      ),
      yogaLayout: YogaLayout(
        flex: 1,
        width: YogaValue(100, YogaUnit.percent),
      ),
    ).makeScrollable(
      style: ScrollViewStyle(
        showsIndicators: true,
        initialScrollY: 5,
        bounces: true,
        direction: ScrollDirection.vertical,
      ),
      scrollChildren: [
        _buildStoriesSection(),
        ...List.generate(
          visibleCountState.value,
          (i) => _buildPostItem(i),
        ),
      ],
    );
  }

  // Stories horizontal scrolling section
  DCView _buildStoriesSection() {
    return DCView(
      viewStyle: ViewStyle(
        backgroundColor: Colors.white.value,
      ),
      yogaLayout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        flexDirection: YogaFlexDirection.column,
        margin: EdgeValues(bottom: YogaValue(20, YogaUnit.point)),
      ),
      children: [
        DCText(
          "Stories",
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87.value,
            textAlign: TextAlign.left,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              left: YogaValue(16, YogaUnit.point),
              top: YogaValue(12, YogaUnit.point),
              bottom: YogaValue(8, YogaUnit.point),
            ),
          ),
        ),
        // Horizontal scrolling stories container
        DCView(
          yogaLayout: YogaLayout(
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(120, YogaUnit.point),
          ),
        ).makeScrollable(
          style: ScrollViewStyle(
            direction: ScrollDirection.horizontal,
            backgroundColor: Colors.transparent.value,
            showsIndicators: false,
            bounces: true,
          ),
          scrollChildren: List.generate(15, (index) => _buildStoryItem(index)),
        ),
      ],
    );
  }

  // A single story item
  DCView _buildStoryItem(int index) {
    return DCView(
      viewStyle: ViewStyle(backgroundColor: Colors.transparent.value),
      yogaLayout: YogaLayout(
        width: YogaValue(90, YogaUnit.point),
        alignItems: YogaAlign.center,
        margin: EdgeValues(
          left: index == 0
              ? YogaValue(16, YogaUnit.point)
              : YogaValue(12, YogaUnit.point),
          right: YogaValue(0, YogaUnit.point),
        ),
      ),
      children: [
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Color(colors[index % colors.length]).value,
            cornerRadius: 35, // Makes it circular
          ),
          yogaLayout: YogaLayout(
            width: YogaValue(70, YogaUnit.point),
            height: YogaValue(70, YogaUnit.point),
            margin: EdgeValues(bottom: YogaValue(8, YogaUnit.point)),
          ),
        ),
        DCText(
          "Story ${index + 1}",
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.black.value,
            textAlign: TextAlign.center,
          ),
          yogaLayout: YogaLayout(
            width: YogaValue(70, YogaUnit.point),
          ),
        ),
      ],
    );
  }

  // A single post item
  DCView _buildPostItem(int index) {
    return DCView(
      viewStyle: ViewStyle(
        backgroundColor: Colors.white.value,
      ),
      yogaLayout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        margin: EdgeValues(bottom: YogaValue(10, YogaUnit.point)),
      ),
      children: [
        // Post header with avatar and username
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.transparent.value,
          ),
          yogaLayout: YogaLayout(
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(60, YogaUnit.point),
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            padding: EdgeValues(
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
          ),
          children: [
            DCView(
              viewStyle: ViewStyle(
                backgroundColor:
                    Color(colors[(index + 3) % colors.length]).value,
                cornerRadius: 20,
              ),
              yogaLayout: YogaLayout(
                width: YogaValue(40, YogaUnit.point),
                height: YogaValue(40, YogaUnit.point),
                margin: EdgeValues(right: YogaValue(12, YogaUnit.point)),
              ),
            ),
            DCText(
              "user_${index}",
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black.value,
                textAlign: TextAlign.left,
              ),
              yogaLayout: YogaLayout(
                flex: 1,
              ),
            ),
          ],
        ),

        // Post image
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Color(colors[index % colors.length]).value,
          ),
          yogaLayout: YogaLayout(
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(300, YogaUnit.point),
          ),
        ),

        // Post caption
        DCText(
          "This is post ${index} caption with some text to demonstrate wrapping.",
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.black87.value,
            textAlign: TextAlign.left,
          ),
          yogaLayout: YogaLayout(
            padding: EdgeValues(
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
              top: YogaValue(12, YogaUnit.point),
              bottom: YogaValue(16, YogaUnit.point),
            ),
          ),
        ),
      ],
    );
  }

  // Load more button
  DCTouchable _buildLoadMoreButton() {
    return DCTouchable(
      touchableStyle: TouchableStyle(
        backgroundColor: Color(0xFF3F51B5).value,
        cornerRadius: 24,
      ),
      yogaLayout: YogaLayout(
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
      onPress: _handleLoadMore,
      children: [
        DCText(
          "Load More",
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white.value,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Event handlers
  void _handleSearchInput(String text) {
    searchQueryState.value = text;
  }

  void _handleLoadMore() {
    // Update the number of visible posts
    visibleCountState.value += 5;
    print("Loading more posts, now showing ${visibleCountState.value}");
  }

  // Root component to attach to native
  UIComponent? rootComponent;

  @override
  Future<void> bind() async {
    try {
      // Create the component tree and attach the root to native root
      final rootId = await rootComponent?.create();
      if (rootId != null) {
        await Core.attachView('root', rootId);
      }
    } catch (e) {
      debugPrint('Error binding views: $e');
    }
  }
}
