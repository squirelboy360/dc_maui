import 'package:flutter/material.dart';
import '../ui_composer.dart';
import '../bridge/controls/scroll_view.dart' as native;
import '../bridge/types/layout_layouts/yoga_types.dart';

class DCScrollView extends UIComponent<native.ScrollView> {
  final native.ScrollViewStyle? scrollViewStyle;
  final YogaLayout? yogaLayout;
  final void Function(native.ScrollMetrics)? onScroll;
  final VoidCallback? onScrollEnd;

  DCScrollView({
    this.scrollViewStyle,
    this.yogaLayout,
    this.onScroll,
    this.onScrollEnd,
    List<UIComponent> children = const [],
  }) {
    if (scrollViewStyle != null) {
      style.addAll(scrollViewStyle!.toMap());
    }
    if (yogaLayout != null) {
      layout.addAll(yogaLayout!.toMap());
    }
    
    properties['events'] = {
      if (onScroll != null) 'onScroll': true,
      if (onScrollEnd != null) 'onScrollEnd': true,
    };
    
    this.children.addAll(children);
  }

  @override
  Future<String?> _createComponent() async {
    // We need to create the scroll view without children first
    // since the children will be attached later via the UIComponent structure
    final scrollView = native.ScrollView(
      style: scrollViewStyle ?? const native.ScrollViewStyle(),
      layout: yogaLayout ?? const YogaLayout(),
      onScroll: onScroll,
      onScrollEnd: onScrollEnd,
      // Not passing children here - they'll be handled by UIComponent
    );
    
    final id = await scrollView.create();
    return id;
  }
}
