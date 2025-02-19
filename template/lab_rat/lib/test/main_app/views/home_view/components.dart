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
  final appbar = bridge.createView(ViewType.view,
      layout: LayoutConfig(
          width: YGValue(100, YGUnit.percent),
          height: YGValue(40, YGUnit.percent),
          flexDirection: YGFlexDirection.row,
          alignItems: YGAlign.center,
          justifyContent: YGJustify.spaceBetween,
          display: YGDisplay.flex),
      style: ViewStyle(
        backgroundColor: Colors.purple,
      ));
  final title = bridge.createView(ViewType.label,
      style: ViewStyle(backgroundColor: Colors.amber),
      testStyle: TextStyle(
        text: "AppBar",
        color: Colors.black,
        fontSize: 16.0,
      ));
  final incrementButton = bridge.createView(ViewType.button,
      style: ViewStyle(
          textStyle: TextStyle(
        text: "➕",
        color: Colors.black,
        fontSize: 24.0,
      )));

  final decrementButton = bridge.createView(ViewType.button,
      style: ViewStyle(
          textStyle: TextStyle(
        text: "➖",
        color: Colors.black,
        fontSize: 24.0,
      )));

  // body
  final card = bridge.createView(ViewType.view);
  final count = bridge.createView(ViewType.label);
}
