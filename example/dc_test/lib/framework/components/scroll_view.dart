import '../bridge/controls/scroll_view.dart' as bridge;
import '../bridge/types/view_types/view_styles.dart';
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../ui_composer.dart';
import '../bridge/core.dart';
import 'package:flutter/material.dart';

class DCScrollView extends UIComponent<String> {
  final bridge.ScrollViewStyle scrollViewStyle;
  final ViewStyle viewStyle;
  final YogaLayout yogaLayout;
  final bridge.ScrollCallback? onScroll;
  final bridge.ScrollCallback? onScrollBegin;
  final bridge.ScrollCallback? onScrollEnd;
  final bridge.ScrollCallback? onMomentumScrollBegin;
  final bridge.ScrollCallback? onMomentumScrollEnd;
  final bridge.EndReachedCallback? onEndReached;
  final List<UIComponent> listChildren;

  DCScrollView({
    this.scrollViewStyle = const bridge.ScrollViewStyle(),
    this.viewStyle = const ViewStyle(),
    this.yogaLayout = const YogaLayout(),
    this.onScroll,
    this.onScrollBegin,
    this.onScrollEnd,
    this.onMomentumScrollBegin,
    this.onMomentumScrollEnd,
    this.onEndReached,
    this.listChildren = const [],
    List<UIComponent> children = const [],
  }) {
    style = {
      ...viewStyle.toMap(),
      'scrollViewStyle': scrollViewStyle.toMap(),
    };

    // Ensure the layout includes a flex value if not already specified
    Map<String, dynamic> finalLayout = yogaLayout.toMap();
    if (!finalLayout.containsKey('flex') &&
        !finalLayout.containsKey('height')) {
      finalLayout['flex'] = 1;
    }

    layout = finalLayout;
    this.children = List.from(children);
  }

  @override
  Future<String?> createComponent() async {
    // Create the scroll view
    final scrollView = bridge.ScrollView(
      style: scrollViewStyle,
      viewStyle: viewStyle,
      layout: yogaLayout,
      onScroll: onScroll,
      onScrollBegin: onScrollBegin,
      onScrollEnd: onScrollEnd,
      onMomentumScrollBegin: onMomentumScrollBegin,
      onMomentumScrollEnd: onMomentumScrollEnd,
      onEndReached: onEndReached,
    );

    final viewId = await scrollView.create();
    if (viewId == null) return null;

    debugPrint('Created ScrollView with ID: $viewId');

    // Attach scroll-specific list children
    for (var child in listChildren) {
      final childId = await child.create();
      if (childId != null) {
        debugPrint('Attaching child $childId to ScrollView $viewId');
        await Core.attachView(viewId, childId);
      }
    }

    return viewId;
  }
}
