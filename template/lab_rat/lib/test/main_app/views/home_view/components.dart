part of '../../imports.dart';

abstract class HomeViewComponents {
  // Root view with flex column layout
  final rootView = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      height: LayoutConfig.percent(100),
      position: YGPositionType.relative,
      flexDirection: YGFlexDirection.column,
      padding: EdgeInsets.all(16),
    ),
    style: ViewStyle(backgroundColor: Colors.grey[100]),
  );

  // Header section with absolute positioning
  final header = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      position: YGPositionType.absolute,
      width: LayoutConfig.percent(100),
      height: LayoutConfig.points(100),
      left: LayoutConfig.points(0),
      top: LayoutConfig.points(0),
      flexDirection: YGFlexDirection.row,
      justifyContent: YGJustify.spaceBetween,
      alignItems: YGAlign.center,
      padding: EdgeInsets.symmetric(horizontal: 16),
    ),
    style: ViewStyle(
      backgroundColor: Colors.blue,
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 4),
          radius: 8,
        ),
      ],
    ),
  );

  // Main content area with flex layout
  final content = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      margin: EdgeInsets.only(top: 120), // Account for header
      flex: 1,
      flexDirection: YGFlexDirection.row,
      justifyContent: YGJustify.spaceBetween,
      alignItems: YGAlign.stretch,
    ),
    style: ViewStyle(backgroundColor: Colors.white),
  );

  // Left sidebar
  final sidebar = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      width: LayoutConfig.points(200),
      height: LayoutConfig.percent(100),
      padding: EdgeInsets.all(16),
      flexDirection: YGFlexDirection.column,
      justifyContent: YGJustify.spaceBetween,
    ),
    style: ViewStyle(
      backgroundColor: Colors.grey[200],
      cornerRadius: 8,
    ),
  );

  // Main content scrollable area
  final mainArea = bridge.createView(
    ViewType.scrollable,
    layout: LayoutConfig(
      flex: 1,
      margin: EdgeInsets.only(left: 16),
      padding: EdgeInsets.all(16),
      flexDirection: YGFlexDirection.column,
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
  );

  // Floating action button
  final fab = bridge.createView(
    ViewType.button,
    layout: LayoutConfig(
      position: YGPositionType.absolute,
      width: LayoutConfig.points(56),
      height: LayoutConfig.points(56),
      right: LayoutConfig.points(16),
      bottom: LayoutConfig.points(16),
    ),
    style: ViewStyle(
      backgroundColor: Colors.blue[600],
      cornerRadius: 28,
      textStyle: TextStyle(
        text: "+",
        fontSize: 24,
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
  );
}
