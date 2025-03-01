import 'package:flutter/material.dart';
import '../bridge/controls/scroll_view.dart' as bridge;
import '../bridge/types/view_types/view_styles.dart';
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../ui_composer.dart';

class DCScrollView extends UIComponent<String> {
  final bridge.ScrollViewStyle scrollViewStyle;
  final YogaLayout yogaLayout;
  final void Function(bridge.ScrollMetrics)? onScroll;
  final VoidCallback? onScrollEnd;

  DCScrollView({
    this.scrollViewStyle = const bridge.ScrollViewStyle(),
    this.yogaLayout = const YogaLayout(),
    this.onScroll,
    this.onScrollEnd,
    List<UIComponent> children = const [],
  }) {
    style = scrollViewStyle.toMap();
    layout = yogaLayout.toMap();
    this.children = List.from(children);
  }

  @override
  Future<String?> createComponent() async {
    // Create scroll view with our properties
    final scrollView = bridge.ScrollView(
      style: scrollViewStyle,
      layout: yogaLayout,
      onScroll: onScroll,
      onScrollEnd: onScrollEnd,
    );
    
    return await scrollView.create();
  }
}
