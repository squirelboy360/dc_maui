part of '../../imports.dart';

abstract class HomeViewComponents {
  // root
  final rootView = bridge.createView(ViewType.view,
      layout: LayoutConfig(
          width: YGValue(100, YGUnit.percent),
          height: YGValue(100, YGUnit.percent),
          alignItems: YGAlign.center,
          justifyContent: YGJustify.flexStart,
          display: YGDisplay.flex),
      style: ViewStyle(
        backgroundColor: Colors.indigo,
      ));
  // topbar
// And update appbar layout
final appbar = bridge.createView(
  ViewType.view,
  layout: LayoutConfig(
    width: YGValue(100, YGUnit.percent),
    height: YGValue(10, YGUnit.percent), // Reduced from 40% to more reasonable 10%
    padding: EdgeInsets.symmetric(horizontal: 16),
    flexDirection: YGFlexDirection.row,
    alignItems: YGAlign.center,
    justifyContent: YGJustify.spaceBetween,
    display: YGDisplay.flex
  ),
  style: ViewStyle(
    backgroundColor: Colors.purple,
  )
);

  final title = bridge.createView(ViewType.label,
      style: ViewStyle(backgroundColor: Colors.amber),
      testStyle: TextStyle(
        text: "AppBar",
        color: Colors.black,
        fontSize: 16.0,
      ));
  // Updated HomeViewComponents
final incrementButton = bridge.createView(
  ViewType.button,
  layout: LayoutConfig(
    width: YGValue(40, YGUnit.point),  // Give explicit dimensions
    height: YGValue(40, YGUnit.point),
    alignSelf: YGAlign.center,
  ),
  style: ViewStyle(
    backgroundColor: Colors.grey[200],  // Add background color
    cornerRadius: 20,  // Make it circular
    textStyle: TextStyle(
      text: "➕",
      color: Colors.black,
      fontSize: 24.0,
    )
  )
);

final decrementButton = bridge.createView(
  ViewType.button,
  layout: LayoutConfig(
    width: YGValue(40, YGUnit.point),
    height: YGValue(40, YGUnit.point),
    alignSelf: YGAlign.center,
  ),
  style: ViewStyle(
    backgroundColor: Colors.grey[200],
    cornerRadius: 20,
    textStyle: TextStyle(
      text: "➖",
      color: Colors.black,
      fontSize: 24.0,
    )
  )
);



  // body
  final card = bridge.createView(ViewType.view);
  final count = bridge.createView(ViewType.label);
}
