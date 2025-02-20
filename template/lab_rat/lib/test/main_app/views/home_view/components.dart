part of '../../imports.dart';

abstract class HomeViewComponents {
  // Root container with explicit dimensions
  final rootView = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      height: LayoutConfig.percent(100),
      position: YGPositionType.relative,
      flexDirection: YGFlexDirection.column,
    ),
    style: ViewStyle(backgroundColor: Colors.red[100]),
  );

  // Fixed size app bar with absolute positioning
  final appBar = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      position: YGPositionType.absolute,
      width: LayoutConfig.points(200),     // Fixed width
      height: LayoutConfig.points(80),     // Fixed height
      left: LayoutConfig.points(16),      // Right padding
      top: LayoutConfig.points(40),        // Top padding
      display: YGDisplay.flex,             // Important!
      flexDirection: YGFlexDirection.row,  // For label alignment
      alignItems: YGAlign.center,          // Center children vertically
      justifyContent: YGJustify.center,    // Center children horizontally
    ),
    style: ViewStyle(
      backgroundColor: Colors.cyan,
      cornerRadius: 8,
    ),
  );

  // Title that fills appBar
  final appBarTitle = bridge.createView(
    ViewType.label,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),   // Fill parent width
      height: LayoutConfig.percent(100),  // Fill parent height
      alignSelf: YGAlign.center,         // Center in parent
      margin: EdgeInsets.all(8),         // Add some padding
    ),
    style: ViewStyle(
      backgroundColor: Colors.transparent,
      textStyle: TextStyle(
        text: "Title",
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  );

  // List items
  final itemsList = bridge.createView(
    ViewType.listView,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      height: LayoutConfig.percent(100),
      flex: 1,
      padding: EdgeInsets.symmetric(horizontal: 16),
      position: YGPositionType.relative, // Explicitly set relative positioning
      flexDirection: YGFlexDirection.column, // Ensure vertical layout
    ),
    items: List.generate(20, (i) => {'id': i, 'title': 'Item ${i + 5}'}),
    attachedListViewChild: (index, item) => bridge.createView(
      ViewType.view,
      layout: LayoutConfig(
        height: LayoutConfig.points(100),
        width: LayoutConfig.percent(100),
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        flexDirection: YGFlexDirection.row,
        alignItems: YGAlign.center,
        justifyContent: YGJustify.spaceBetween,
      ),
      style: ViewStyle(
        textStyle: TextStyle(
          text: item['title'],
          fontSize: 24,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        cornerRadius: 8,
        shadows: [
          ShadowStyle(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            radius: 4,
          ),
        ],
      ),
    ),
  );

  // // FAB
  // final fab = bridge.createView(
  //   ViewType.button,
  //   layout: LayoutConfig(
  //     position: YGPositionType.absolute,
  //     width: LayoutConfig.points(56),
  //     height: LayoutConfig.points(56),
  //     left: LayoutConfig.points(16),
  //     bottom: LayoutConfig.points(16),
  //   ),
  //   style: ViewStyle(
  //     backgroundColor: Colors.blue[600],
  //     cornerRadius: 28,
  //     textStyle: TextStyle(
  //       text: "+",
  //       fontSize: 32,
  //       color: Colors.white,
  //     ),
  //     shadows: [
  //       ShadowStyle(
  //         color: Colors.black.withOpacity(0.3),
  //         offset: Offset(0, 3),
  //         radius: 5,
  //       ),
  //     ],
  //   ),
  //   events: {
  //     NativeEventType.onPress: (event) {
  //       print("FAB pressed!");
  //     },
  //   },
  // );
}
