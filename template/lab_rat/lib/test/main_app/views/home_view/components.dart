part of '../../imports.dart';

abstract class HomeViewComponents {
  // Root container
  final rootView = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      flex: 1,
      alignItems: YGAlign.center,
      justifyContent: YGJustify.flexStart,
      display: YGDisplay.flex,
    ),
    style: ViewStyle(
      backgroundColor: Colors.grey[100],
    ),
  );

  // Header Section
  final header = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      height: LayoutConfig.points(200),
      padding: EdgeInsets.all(16),
      flexDirection: YGFlexDirection.column,
      alignItems: YGAlign.center,
      justifyContent: YGJustify.center,
    ),
    style: ViewStyle(
      backgroundColor: Colors.blue[600],
      cornerRadius: 0,
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.2),
          offset: Offset(0, 4),
          radius: 8,
        ),
      ],
    ),
  );

  final profileImage = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      width: LayoutConfig.points(80),
      height: LayoutConfig.points(80),
      margin: EdgeInsets.only(bottom: 8),
    ),
    style: ViewStyle(
      cornerRadius: 40,
      backgroundColor: Colors.white,
      border: BorderStyle(
        width: 3,
        color: Colors.white,
        style: BorderType.solid,
      ),
    ),
  );

  final userName = bridge.createView(
    ViewType.label,
    layout: LayoutConfig(
      margin: EdgeInsets.only(top: 8),
    ),
    style: ViewStyle(
      textStyle: TextStyle(
        text: "John Doe",
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // Content Section
  // final scrollContent = bridge.createView(
  //   ViewType.listView,
  //   layout: LayoutConfig(
  //     flex: 1,
  //     width: LayoutConfig.percent(100),
  //   ),
  //   style: ViewStyle(
  //     backgroundColor: Colors.grey[100],
  //   ),
  //   scrollEvents: {
  //     ScrollEventType.onScroll: (data) {
  //       print('Scrolled to: ${data.y}');
  //     },
  //   },
  // );

  final itemsList = bridge.createView(
    ViewType.listView,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      height: LayoutConfig.percent(100),
    ),
    items: [
      {'name': 'John Doe', 'id': 1},
      {'name': 'Jane Doe', 'id': 2},
    ], // Pass raw data
    attachedListViewChild: (index, item) => bridge.createView(
      ViewType.label,
      layout: LayoutConfig(
        margin: EdgeInsets.only(top: 8),
      ),
      style: ViewStyle(
        textStyle: TextStyle(
          text: "${item['name']} (person number $index)",
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  // Action Button
  final actionButton = bridge.createView(
    ViewType.button,
    events: {
      NativeEventType.onPress: (eventData) {
        print('Button clicked!');
        
      },
      NativeEventType.onLongPress: (eventData) {
        print('Button long pressed!');
      },
    },
    layout: LayoutConfig(
      position: YGPositionType.absolute,
      width: YGValue.points(56),
      height: YGValue.points(56),
    ),
    style: ViewStyle(
      backgroundColor: Colors.blue[600],
      cornerRadius: 20,
      textStyle: TextStyle(
        text: "+",
        color: Colors.white,
        fontSize: 32,
      ),
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(0, 3),
          radius: 5,
          opacity: 1.0,
        ),
      ],
    ),
  );
}
