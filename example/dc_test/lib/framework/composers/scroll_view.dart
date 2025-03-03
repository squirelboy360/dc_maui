// import 'package:flutter/material.dart';
// import '../bridge/controls/scroll_view.dart' as bridge;
// import '../bridge/types/layout_layouts/yoga_types.dart';
// import '../ui_composer.dart';

// class DCScrollView extends UIComponent<String> {
//   final bridge.ScrollViewStyle scrollViewStyle;
//   final YogaLayout yogaLayout;
//   final void Function(bridge.ScrollMetrics)? onScroll;
//   final List<UIComponent> listChildren;

//   final VoidCallback? onScrollEnd;

//   DCScrollView({
//     this.scrollViewStyle = const bridge.ScrollViewStyle(),
//     this.yogaLayout = const YogaLayout(),
//     this.onScroll,
//     this.onScrollEnd,
//     this.listChildren = const [],
//   }) {
//     style = scrollViewStyle.toMap();
//     layout = yogaLayout.toMap();
//     children = [];
//   }

//   @override
//   Future<String?> createComponent() async {
//     final debugList = listChildren.map((e) => e.id).toList();
//     print("debug lis: $debugList");
//     print(
//         "list children items: ${listChildren.length}  and values:::: ${List.from(listChildren.map((e) => e.id))}");
//     // Create scroll view with our properties
//     final scrollView = bridge.ScrollView(
//         style: scrollViewStyle,
//         layout: yogaLayout,
//         onScroll: onScroll,
//         onScrollEnd: onScrollEnd,
//         // don't consume from children as those are for normal views
//         children: List.from(listChildren.map((e) => e.id)));

//     return await scrollView.create();
//   }
// }
