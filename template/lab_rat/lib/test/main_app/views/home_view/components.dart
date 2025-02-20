part of '../../imports.dart';

abstract class HomeViewComponents {
  // Root container
  final rootView = bridge.createView(
    ViewType.view,
    layout: LayoutConfig(
      flexDirection: YGFlexDirection.column,
      flex: 1,
      alignItems: YGAlign.center,
      justifyContent: YGJustify.flexStart,
      right: LayoutConfig.points(0),
    ),
    style: ViewStyle(backgroundColor: Colors.red[100]),
  );

  final appBar = bridge.createView(ViewType.view,
      layout: LayoutConfig(
        width: LayoutConfig.points(100),
        height: LayoutConfig.points(100),
        top: LayoutConfig.points(0),
      ),
      style: ViewStyle(backgroundColor: Colors.cyan));

  final appBarTitle = bridge.createView(ViewType.label,
      layout: LayoutConfig(
        width: LayoutConfig.percent(100),
        height: LayoutConfig.points(100),
        top: LayoutConfig.points(0),
      ),
      style: ViewStyle(backgroundColor: Colors.cyan));

  // List items
  final itemsList = bridge.createView(
    ViewType.listView,
    layout: LayoutConfig(
      width: LayoutConfig.percent(100),
      height: LayoutConfig.percent(100),
      flex: 1,
      padding: EdgeInsets.symmetric(horizontal: 16),
    ),
    items: List.generate(20, (i) => {'id': i, 'title': 'Item ${i + 1}'}),
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
