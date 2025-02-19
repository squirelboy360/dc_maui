part of '../../imports.dart';

abstract class HomeViewComponents {
  // root
  final rootView = bridge.createView(ViewType.view,
      layout: LayoutConfig(
          width: YGValue(100, YGUnit.percent),
          height: YGValue(100, YGUnit.percent),
          alignItems: YGAlign.flexStart,
          justifyContent: YGJustify.center,
          padding: const EdgeInsets.all(16),
          display: YGDisplay.flex),
      style: ViewStyle(backgroundColor: Colors.indigo,));
  // topbar
  final appbar = bridge.createView(ViewType.view,layout: LayoutConfig(
          width: YGValue(100, YGUnit.percent),
          height: YGValue(10, YGUnit.percent),
          alignItems: YGAlign.spaceBetween,
          justifyContent: YGJustify.center,
          display: YGDisplay.flex),
      style: ViewStyle(backgroundColor: Colors.indigo,));
  final title = bridge.createView(ViewType.label,style: TextStyle());
  final incrementButton = bridge.createView(ViewType.button);
  final decrementButton = bridge.createView(ViewType.button);
// body
  final card = bridge.createView(ViewType.view);
  final count = bridge.createView(ViewType.label);
}
