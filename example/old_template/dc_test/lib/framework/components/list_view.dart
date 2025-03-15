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
  final EventCallback? onEvent;
  final Map<int, UIComponent> _renderedComponents = {};
  final Set<int> _requestedIndices = {};

  // Bridge instance reference
  bridge.ListView? _listView;

  // Constructor with better defaults and validation
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
    this.onEvent,
    List<UIComponent> children = const [],
  }) {
    // Set style properties
    style = {
      ...viewStyle.toMap(),
      'listViewStyle': listViewStyle.toMap(),
    };

    // Ensure proper layout constraints
    Map<String, dynamic> finalLayout = {...yogaLayout.toMap()};

    // Must have either flex or explicit height
    if (!finalLayout.containsKey('height') &&
        !finalLayout.containsKey('flex')) {
      debugPrint(
          "⚠️ DCListView: No height or flex provided, defaulting to flex: 1");
      finalLayout['flex'] = 1;
    }

    // Must have width
    if (!finalLayout.containsKey('width')) {
      finalLayout['width'] = {'unit': 'percent', 'value': 100};
      debugPrint("⚠️ DCListView: No width provided, defaulting to 100%");
    }

    layout = finalLayout;
    this.children = List.from(children);

    debugPrint("DCListView: Initialized with layout: $finalLayout");
    debugPrint("DCListView: Initial data length: ${data.length}");
  }

  @override
  Future<String?> createComponent() async {
    debugPrint("DCListView: Creating component with ${data.length} items");

    // Always log important parameters for debugging
    debugPrint("DCListView: Layout: $layout");
    debugPrint("DCListView: Style: $style");
    debugPrint("DCListView: ListViewStyle: ${listViewStyle.toMap()}");

    try {
      _listView = bridge.ListView(
        data: data,
        renderItem: _handleRenderItem,
        keyExtractor: keyExtractor != null
            ? (item) => keyExtractor!(item as T)
            : (item) => item.hashCode.toString(),
        style: listViewStyle,
        viewStyle: viewStyle,
        layout: yogaLayout,
        onEndReached: onEndReached,
        onScroll: onScroll,
        onScrollBegin: onScrollBegin,
        onScrollEnd: onScrollEnd,
        onEvent: _handleEvent,
      );

      final listViewId = await _listView!.create();

      if (listViewId != null) {
        debugPrint(
            "✅ DCListView: Component created successfully with ID: $listViewId");
      } else {
        debugPrint("❌ DCListView: Failed to create component");
      }

      return listViewId;
    } catch (e, stackTrace) {
      debugPrint("❌ DCListView: Error creating component: $e");
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  // Handle all events from the native side
  void _handleEvent(String type, dynamic data) {
    debugPrint("DCListView: Received event '$type'");

    if (type == 'requestItem' &&
        data is Map<String, dynamic> &&
        data.containsKey('index')) {
      final index = data['index'] as int;
      _renderItemAtIndex(index);
    } else if (type == 'onEndReached' && onEndReached != null) {
      onEndReached!();
    } else if (type == 'onScroll' &&
        onScroll != null &&
        data is Map<String, dynamic>) {
      onScroll!(data);
    } else if (type == 'onScrollBegin' &&
        onScrollBegin != null &&
        data is Map<String, dynamic>) {
      onScrollBegin!(data);
    } else if (type == 'onScrollEnd' &&
        onScrollEnd != null &&
        data is Map<String, dynamic>) {
      onScrollEnd!(data);
    }

    // Forward event to custom handler if provided
    if (onEvent != null) {
      onEvent!(type, data);
    }
  }

  // Renders an item at the specified index
  Future<void> _renderItemAtIndex(int index) async {
    if (index < 0 || index >= data.length || bridgeId == null) {
      debugPrint("⚠️ DCListView: Invalid index $index or bridgeId is null");
      return;
    }

    // Skip if already rendered or in progress
    if (_renderedComponents.containsKey(index) ||
        _requestedIndices.contains(index)) {
      return;
    }

    _requestedIndices.add(index);
    debugPrint("DCListView: Rendering item at index $index");

    try {
      // Render the component
      final item = data[index];
      final component = await renderItem(item, index);
      _renderedComponents[index] = component;

      // Create the native component
      final componentId = await component.create();
      if (componentId == null) {
        debugPrint("❌ DCListView: Failed to create component for index $index");
        _requestedIndices.remove(index);
        return;
      }

      // Get key for the item
      final key = keyExtractor != null ? keyExtractor!(item) : index.toString();

      // Set the item in the list view
      await Core.invokeMethod('setItem', {
        'listViewId': bridgeId!,
        'index': index,
        'itemId': componentId,
        'key': key,
      });

      debugPrint("✅ DCListView: Set item at index $index with ID $componentId");
    } catch (e) {
      debugPrint("❌ DCListView: Error rendering item at index $index: $e");
    } finally {
      _requestedIndices.remove(index);
    }
  }

  // Bridge callback used during initial rendering
  Future<String?> _handleRenderItem(dynamic item, int index) async {
    debugPrint("DCListView: Bridge requesting render for index $index");

    try {
      final component = await renderItem(item as T, index);
      _renderedComponents[index] = component;

      final componentId = await component.create();
      return componentId;
    } catch (e) {
      debugPrint(
          "❌ DCListView: Error in _handleRenderItem for index $index: $e");
      return null;
    }
  }

  // Get the list view ID
  String? get bridgeId => _listView?.id;

  // Scroll to a specific index
  Future<void> scrollToIndex(int index, {bool animated = true}) async {
    if (bridgeId == null) return;

    debugPrint("DCListView: Scrolling to index $index");
    await Core.invokeMethod('scrollToIndex', {
      'listViewId': bridgeId!,
      'index': index,
      'animated': animated,
    });
  }

  // Refresh the list with new data
  Future<void> refreshData(List<T> newData) async {
    if (bridgeId == null) {
      debugPrint("⚠️ DCListView: Cannot refresh, bridgeId is null");
      return;
    }

    debugPrint("DCListView: Refreshing with ${newData.length} items");

    // Clean up resources
    _renderedComponents.clear();
    _requestedIndices.clear();

    // Update data reference
    data.clear();
    data.addAll(newData);

    // Tell native side about the data change
    await Core.invokeMethod('refreshData', {
      'listViewId': bridgeId!,
      'dataLength': newData.length,
    });

    debugPrint("✅ DCListView: Data refreshed");
  }
}
