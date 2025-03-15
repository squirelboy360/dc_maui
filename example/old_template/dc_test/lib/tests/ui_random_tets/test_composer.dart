import 'package:dc_test/framework/bridge/controls/touchable.dart';
import 'package:dc_test/framework/components/text.dart';
import 'package:dc_test/framework/components/text_input.dart';
import 'package:dc_test/framework/components/touchable.dart';
import 'package:dc_test/framework/components/view.dart';
import 'package:dc_test/framework/components/scroll_view.dart'; // Add this import
import 'package:flutter/material.dart' hide ScrollView, Text, TextStyle;
import '../../framework/ui_composer.dart';

import '../../framework/bridge/core.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';
import '../../framework/bridge/controls/text_input.dart'
    show ContentType, TextInputStyle;
import '../../framework/bridge/controls/scroll_view.dart' // Add this import
    show
        ScrollDirection,
        ScrollViewStyle;

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

  // Main content area with ScrollView
  UIComponent _buildMainContent() {
    return DCScrollView(
      scrollViewStyle: ScrollViewStyle(
        contentInset: EdgeInsets.all(0),
        backgroundColor: Colors.amber.value,
        showsIndicators: true,
        bounces: true,
        direction: ScrollDirection.vertical,
        initialScrollY: 0,
      ),
      yogaLayout: YogaLayout(
          padding: EdgeValues(
              top: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
        flex: 1,
        width: YogaValue(100, YogaUnit.percent),
      ),
      listChildren: [
        // Content item 1
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.red.value, // Bright red for visibility
            cornerRadius: 12,
            shadow: ViewShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 2),
              radius: 4,
              opacity: 0.2,
            ),
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(100, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "Scrollable Content Item 1",
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Content item 2
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.blue.value, // Bright blue
            cornerRadius: 12,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(30, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(200, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "Try scrolling up and down",
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Content item 3 (taller to enable scrolling)
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.green.value, // Bright green
            cornerRadius: 12,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(30, YogaUnit.point),
              bottom: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(400, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "This is a taller content area\nto enable scrolling",
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.yellow.value, // Bright green
            cornerRadius: 12,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(30, YogaUnit.point),
              bottom: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(400, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "This is a taller content area\nto enable scrolling",
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

          DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.indigo.value, // Bright green
            cornerRadius: 12,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(30, YogaUnit.point),
              bottom: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(400, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "This is a taller content area\nto enable scrolling",
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

          DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.orange.value, // Bright green
            cornerRadius: 12,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(30, YogaUnit.point),
              bottom: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(400, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "This is a taller content area\nto enable scrolling",
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

          DCView(
          viewStyle: ViewStyle(
            backgroundColor: Colors.black.value, // Bright green
            cornerRadius: 12,
          ),
          yogaLayout: YogaLayout(
            margin: EdgeValues(
              top: YogaValue(30, YogaUnit.point),
              bottom: YogaValue(20, YogaUnit.point),
              left: YogaValue(16, YogaUnit.point),
              right: YogaValue(16, YogaUnit.point),
            ),
            padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
            // Use percentage width that will actually work
            width: YogaValue(100, YogaUnit.percent),
            height: YogaValue(400, YogaUnit.point),
            alignSelf: YogaAlign.center,
            justifyContent: YogaJustify.center,
            alignItems: YogaAlign.center,
          ),
          children: [
            DCText(
              "This is a taller content area\nto enable scrolling",
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
      onEndReached: () {
        print("Reached the end of the scroll content!");
      },
      onScroll: (data) {
        // Add some scroll position debugging
        if (data['contentOffset'] != null) {
          final y = data['contentOffset']['y'] ?? 0.0;
          debugPrint('Scrolled to y: $y');
        }
      },
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
