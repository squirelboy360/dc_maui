import 'package:dc_test/framework/bridge/controls/touchable.dart';
import 'package:dc_test/framework/components/text.dart';
import 'package:dc_test/framework/components/text_input.dart';
import 'package:dc_test/framework/components/touchable.dart';
import 'package:dc_test/framework/components/view.dart';
import 'package:flutter/material.dart' hide ScrollView, Text, TextStyle;
import '../../framework/ui_composer.dart';

import '../../framework/bridge/core.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';
import '../../framework/bridge/controls/text_input.dart'
    show ContentType, TextInputStyle;

class TestViewComposer extends UIComposer {
  // States
  final buttonTextState = UIState<String>("Load More");
  final buttonOpacityState = UIState<double>(1.0);
  final visibleCountState = UIState<int>(10);
  final searchQueryState = UIState<String>("");

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
        children: [
        
      ]
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
