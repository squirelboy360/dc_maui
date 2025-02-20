part of '../../imports.dart';

abstract class HomeViewComponents {
  // Root container
  final rootView = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      flex: 1,
      alignItems: YGAlign.center,
      justifyContent: YGJustify.flexStart,
    ),
    style: ViewStyle(backgroundColor: Colors.grey[100]),
  );

  // Header with gradient
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
      gradient: GradientStyle(
        colors: [Colors.blue[700]!, Colors.blue[500]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.2),
          offset: Offset(0, 4),
          radius: 8,
        ),
      ],
    ),
  );

  // Counter display
  final counterDisplay = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      padding: EdgeInsets.all(16),
      width: LayoutConfig.percent(90),
      margin: EdgeInsets.symmetric(vertical: 16),
    ),
    style: ViewStyle(
      backgroundColor: Colors.white,
      cornerRadius: 12,
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 2),
          radius: 4,
        ),
      ],
    ),
  );

  // Counter text
  final counterText = bridge.createView(
    ViewType.label,
    style: ViewStyle(
      textStyle: TextStyle(
        text: "0",
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
    ),
  );

  // List items
  final itemsList = bridge.createView(
    ViewType.listView,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      flex: 1,
      padding: EdgeInsets.symmetric(horizontal: 16),
    ),
    items: List.generate(20, (i) => {'id': i, 'title': 'Item ${i + 1}'}),
    attachedListViewChild: (index, item) => bridge.createView(
      ViewType.view,
      layout: LayoutConfig(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        flexDirection: YGFlexDirection.row,
        alignItems: YGAlign.center,
        justifyContent: YGJustify.spaceBetween,
      ),
      style: ViewStyle(
        backgroundColor: Colors.white,
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

  // FAB
  final fab = bridge.createView(
    ViewType.button,
    layout: LayoutConfig(
      position: YGPositionType.absolute,
      width: LayoutConfig.points(56),
      height: LayoutConfig.points(56),
      left: LayoutConfig.points(16),
      bottom: LayoutConfig.points(16),
    ),
    style: ViewStyle(
      backgroundColor: Colors.blue[600],
      cornerRadius: 28,
      textStyle: TextStyle(
        text: "+",
        fontSize: 32,
        color: Colors.white,
      ),
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(0, 3),
          radius: 5,
        ),
      ],
    ),
    events: {
      NativeEventType.onPress: (event) {
        print("FAB pressed!");
      },
    },
  );
}
