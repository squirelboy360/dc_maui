import 'package:dc_test/framework/bridge/controls/touchable.dart';
import 'package:flutter/material.dart' hide Text, TextStyle;
import '../../framework/index.dart';

class ListViewTestComposer extends UIComposer {
  // Data for list items
  final List<Map<String, dynamic>> items = List.generate(
      100,
      (index) => {
            'id': '$index',
            'title': 'Item $index',
            'description': 'This is the description for item number $index',
            'color': index % 5 == 0
                ? Colors.red.value
                : index % 5 == 1
                    ? Colors.blue.value
                    : index % 5 == 2
                        ? Colors.green.value
                        : index % 5 == 3
                            ? Colors.orange.value
                            : Colors.purple.value,
          });

  // State variables
  final selectedItemState = UIState<int>(-1);
  final loadingState = UIState<bool>(false);

  @override
  Future<void> compose() async {
    debugPrint("ListViewTestComposer: composing UI...");

    final root = DCView(
      viewStyle: ViewStyle(backgroundColor: Colors.white.value),
      yogaLayout: YogaLayout(
        flexDirection: YogaFlexDirection.column,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
      ),
      children: [_buildHeader(), _buildListView()],
    );

    rootComponent = root;
    debugPrint("ListViewTestComposer: UI composed successfully");
  }

  DCView _buildHeader() {
    return DCView(
      viewStyle: ViewStyle(
        backgroundColor: Color(0xFF2196F3).value,
        shadow: ViewShadow(
          color: Colors.black.withOpacity(0.2),
          offset: Offset(0, 2),
          radius: 4,
          opacity: 0.3,
        ),
      ),
      yogaLayout: YogaLayout(
        width: YogaValue(100, YogaUnit.percent),
        padding: EdgeValues(
          top: YogaValue(50, YogaUnit.point),
          bottom: YogaValue(16, YogaUnit.point),
          horizontal: YogaValue(16, YogaUnit.point),
        ),
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.center,
        height: YogaValue(120, YogaUnit.point), // Fixed height for header
      ),
      children: [
        DCText(
          "ListView Example",
          textStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white.value,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  DCListView _buildListView() {
    debugPrint("Building ListView with ${items.length} items");

    return DCListView<Map<String, dynamic>>(
      data: items,
      listViewStyle: ListViewStyle(
        backgroundColor: Color(0xFFF5F5F5).value,
        showsIndicators: true,
        bounces: true,
        itemSpacing: 8,
        initialNumToRender: 10,
      ),
      yogaLayout: YogaLayout(
        flex: 1, // Take remaining space
        width: YogaValue(100, YogaUnit.percent),
      ),
      renderItem: _renderListItem,
      keyExtractor: (item) => item['id'] as String,
      onEndReached: _handleEndReached,
      onScroll: (data) {
        // Add scroll position debugging
        if (data['contentOffset'] != null) {
          final y = data['contentOffset']['y'] ?? 0.0;
          if (y % 100 < 1) {
            // Only log occasionally to reduce noise
            debugPrint('Scrolled to y: $y');
          }
        }
      },
    );
  }

  // Render function for each list item
  Future<UIComponent> _renderListItem(
      Map<String, dynamic> item, int index) async {
    final color = item['color'] as int;
    final title = item['title'] as String;
    final description = item['description'] as String;

    debugPrint("Rendering list item at index $index: $title");

    // Create list item component
    return DCTouchable(
      touchableStyle: TouchableStyle(
        backgroundColor: Color(0xFFFFFFFF).value,
        cornerRadius: 8,
        shadow: ViewShadow(
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 1),
          radius: 3,
          opacity: 0.1,
        ),
      ),
      yogaLayout: YogaLayout(
        margin: EdgeValues(
          horizontal: YogaValue(16, YogaUnit.point),
          vertical: YogaValue(4, YogaUnit.point),
        ),
        padding: EdgeValues(all: YogaValue(16, YogaUnit.point)),
        width:
            YogaValue(92, YogaUnit.percent), // Use 92% width to ensure margins
        minHeight: YogaValue(80, YogaUnit.point),
        flexDirection: YogaFlexDirection.row,
        alignItems: YogaAlign.center,
      ),
      onPress: () => _handleItemPress(index),
      children: [
        // Left color indicator
        DCView(
          viewStyle: ViewStyle(
            backgroundColor: color,
            cornerRadius: 4,
          ),
          yogaLayout: YogaLayout(
            width: YogaValue(6, YogaUnit.point),
            height: YogaValue(50, YogaUnit.point),
            margin: EdgeValues(right: YogaValue(16, YogaUnit.point)),
          ),
        ),
        // Content container
        DCView(
          viewStyle: ViewStyle(backgroundColor: 0),
          yogaLayout: YogaLayout(
            flex: 1,
            flexDirection: YogaFlexDirection.column,
            justifyContent: YogaJustify.center,
          ),
          children: [
            DCText(
              title,
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black.value,
              ),
              yogaLayout: YogaLayout(
                margin: EdgeValues(bottom: YogaValue(4, YogaUnit.point)),
              ),
            ),
            DCText(
              description,
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600]!.value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Event handlers
  void _handleItemPress(int index) {
    debugPrint('Item $index pressed');
    selectedItemState.value = index;
  }

  void _handleEndReached() {
    debugPrint('Reached end of list, loading more items...');
    loadingState.value = true;

    // Simulate loading delay
    Future.delayed(Duration(seconds: 1), () {
      // In a real app, you'd fetch more data here
      debugPrint('More items loaded');
      loadingState.value = false;
    });
  }

  // Root component to attach to native
  UIComponent? rootComponent;

  @override
  Future<void> bind() async {
    try {
      debugPrint("ListViewTestComposer: Binding UI...");
      final rootId = await rootComponent?.create();
      if (rootId != null) {
        debugPrint("Root component created with ID: $rootId");
        await Core.attachView('root', rootId);
        debugPrint("Root component attached successfully");
      } else {
        debugPrint("Failed to create root component");
      }
    } catch (e) {
      debugPrint('Error binding views: $e');
    }
  }
}
