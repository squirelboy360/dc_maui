import 'package:flutter/material.dart';
import '../ui_composer.dart';
import '../bridge/controls/view.dart' as native;
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../bridge/types/view_types/view_styles.dart';

class DCView extends UIComponent<native.View> {
  // These are just constructor parameters, not overriding anything
  final ViewStyle? viewStyle;
  final YogaLayout? yogaLayout;

  DCView({
    this.viewStyle,
    this.yogaLayout,
    List<UIComponent> children = const [],
  }) {
    if (viewStyle != null) {
      style.addAll(viewStyle!.toMap());
    }
    if (yogaLayout != null) {
      layout.addAll(yogaLayout!.toMap());
    }
    this.children.addAll(children);
  }

  @override
  Future<String?> _createComponent() async {
    final view = native.View(
      style: viewStyle ?? const ViewStyle(),
      layout: yogaLayout ?? const YogaLayout(),
    );
    
    final id = await view.create();
    return id;
  }
}
