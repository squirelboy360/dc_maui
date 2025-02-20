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
  final scrollContent = bridge.createView(
    ViewType.scrollable,
    layout: LayoutConfig(
      flex: 1,
      width: LayoutConfig.percent(100),
    ),
    style: ViewStyle(
      backgroundColor: Colors.grey[100],
    ),
    scrollEvents: {
      ScrollEventType.onScroll: (data) {
        print('Scrolled to: ${data.y}');
      },
    },
  );

  final itemsList = bridge.createView(
    ViewType.listView,
    layout: LayoutConfig(
      flex: 1,
      width: LayoutConfig.percent(100),
      padding: EdgeInsets.all(16),
    ),
    style: ViewStyle(
      backgroundColor: Colors.transparent,
    ),
    listViewData: List.generate(
      20,
      (index) => ListViewItem(
        viewType: ViewType.view,
        style: ViewStyle(
          backgroundColor: Colors.white,
          cornerRadius: 8.0,
          shadows: [
            ShadowStyle(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 2),
              radius: 4.0,
            )
          ],
          // Add content to each list item
          textStyle: TextStyle(
            text: "Item ${index + 1}",
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        layout: LayoutConfig(
          height: LayoutConfig.points(80),
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          justifyContent: YGJustify.center,
          alignItems: YGAlign.center,
        ),
      ),
    ),
  );

  // Action Button
  final actionButton = bridge.createView(
    ViewType.button,
    layout: LayoutConfig(
      position: YGPositionType.absolute,
      width: LayoutConfig.points(56),
      height: LayoutConfig.points(56),
    ),
    style: ViewStyle(
      backgroundColor: Colors.blue[600],
      cornerRadius: 28,
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
        ),
      ],
    ),
  );
}
