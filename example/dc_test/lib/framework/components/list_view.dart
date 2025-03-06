import 'package:flutter/material.dart';

import '../bridge/controls/list_view.dart' as bridge;
import '../bridge/types/view_types/view_styles.dart';
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../ui_composer.dart';
import '../bridge/core.dart';

class DCListView<T> extends UIComponent<String> {
  final List<T> data;
  final Future<UIComponent> Function(T item, int index) renderItem;
  final String Function(T item)? keyExtractor;
  final bridge.ListViewStyle listViewStyle;
  final ViewStyle viewStyle;
  final YogaLayout yogaLayout;
  final bridge.ListEndReachedCallback? onEndReached;
  final bridge.ListScrollCallback? onScroll;
  final bridge.ListScrollCallback? onScrollBegin;
  final bridge.ListScrollCallback? onScrollEnd;
  final Map<int, UIComponent> _renderedComponents = {};

  DCListView({
    required this.data,
    required this.renderItem,
    this.keyExtractor,
    this.listViewStyle = const bridge.ListViewStyle(),
    this.viewStyle = const ViewStyle(),
    this.yogaLayout = const YogaLayout(),
    this.onEndReached,
    this.onScroll,
    this.onScrollBegin,
    this.onScrollEnd,
    List<UIComponent> children = const [],
  }) {
    style = {
      ...viewStyle.toMap(),
      'listViewStyle': listViewStyle.toMap(),
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
    debugPrint("DCListView: Creating component with ${data.length} items");

    final listView = bridge.ListView(
      data: data,
      renderItem: _handleRenderItem,
      keyExtractor:
          keyExtractor != null ? (item) => keyExtractor!(item as T) : null,
      style: listViewStyle,
      viewStyle: viewStyle,
      layout: yogaLayout,
      onEndReached: onEndReached,
      onScroll: onScroll,
      onScrollBegin: onScrollBegin,
      onScrollEnd: onScrollEnd,
    );

    final id = await listView.create();
    debugPrint("DCListView: Component created with ID: $id");
    return id;
  }

  Future<String?> _handleRenderItem(dynamic item, int index) async {
    debugPrint("DCListView: Rendering item at index $index");

    // Render the component for this item
    final component = await renderItem(item as T, index);
    _renderedComponents[index] = component;

    // Create the component and return its ID
    final componentId = await component.create();
    debugPrint("DCListView: Item $index rendered with ID: $componentId");
    return componentId;
  }

  // Use Core API for invoking methods
  Future<void> scrollToIndex(int index, {bool animated = true}) async {
    if (id == null) return;

    await Core.invokeMethod('scrollToIndex', {
      'listViewId': id!,
      'index': index,
      'animated': animated,
    });
  }

  Future<void> refreshData(List<T> newData) async {
    if (id == null) return;

    // Clear previously rendered components
    _renderedComponents.clear();

    // Update data
    data.clear();
    data.addAll(newData);

    // Tell native side about new data length
    await Core.invokeMethod('refreshData', {
      'listViewId': id!,
      'dataLength': newData.length,
    });
  }
}
