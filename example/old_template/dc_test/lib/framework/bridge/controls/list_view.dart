import 'package:flutter/material.dart';
import '../core.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

/// Defines how to render each item in the list
typedef RenderItemCallback = Future<String?> Function(dynamic item, int index);

/// Callback for when list has reached end during scrolling
typedef ListEndReachedCallback = void Function();

/// Called when list is scrolled
typedef ListScrollCallback = void Function(Map<String, dynamic> offsetData);

/// Style properties specific to ListView
class ListViewStyle {
  final int? backgroundColor;
  final bool? showsIndicators;
  final bool? bounces;
  final double? initialScrollY;
  final bool? scrollEnabled;
  final bool? horizontal;
  final double? itemSpacing;
  final EdgeInsets? contentInset;
  final bool? pagingEnabled;
  final int? initialNumToRender;
  final int? windowSize;

  const ListViewStyle({
    this.backgroundColor,
    this.showsIndicators,
    this.bounces,
    this.horizontal = false,
    this.initialScrollY,
    this.scrollEnabled,
    this.itemSpacing,
    this.contentInset,
    this.pagingEnabled,
    this.initialNumToRender = 10,
    this.windowSize = 21, // Should be odd, centered around visible items
  });

  Map<String, dynamic> toMap() => {
        if (backgroundColor != null) 'backgroundColor': backgroundColor,
        if (showsIndicators != null) 'showsIndicators': showsIndicators,
        if (bounces != null) 'bounces': bounces,
        if (horizontal != null) 'horizontal': horizontal,
        if (initialScrollY != null) 'initialScrollY': initialScrollY,
        if (scrollEnabled != null) 'scrollEnabled': scrollEnabled,
        if (itemSpacing != null) 'itemSpacing': itemSpacing,
        if (contentInset != null)
          'contentInset': {
            'top': contentInset!.top,
            'left': contentInset!.left,
            'bottom': contentInset!.bottom,
            'right': contentInset!.right,
          },
        if (pagingEnabled != null) 'pagingEnabled': pagingEnabled,
        if (initialNumToRender != null)
          'initialNumToRender': initialNumToRender,
        if (windowSize != null) 'windowSize': windowSize,
      };
}

/// The bridge class for ListView native component
class ListView {
  String? id;
  final List<dynamic> data;
  final RenderItemCallback renderItem;
  final String Function(dynamic item)? keyExtractor;
  final ListViewStyle style;
  final ViewStyle viewStyle;
  final YogaLayout layout;
  final ListEndReachedCallback? onEndReached;
  final ListScrollCallback? onScroll;
  final ListScrollCallback? onScrollBegin;
  final ListScrollCallback? onScrollEnd;
  final EventCallback? onEvent;

  ListView({
    required this.data,
    required this.renderItem,
    this.keyExtractor,
    this.style = const ListViewStyle(),
    this.viewStyle = const ViewStyle(),
    this.layout = const YogaLayout(),
    this.onEndReached,
    this.onScroll,
    this.onScrollBegin,
    this.onScrollEnd,
    this.onEvent,
  });

  Future<String?> create() async {
    // Create the list view component
    id = await Core.createView(
      viewType: 'ListView',
      properties: {
        'data': data
            .map((item) => item is Map ? Map<String, dynamic>.from(item) : item)
            .toList(),
        'listViewStyle': style.toMap(),
        'style': viewStyle.toMap(),
        'layout': layout.toMap(),
        'events': {
          if (onScroll != null) 'onScroll': true,
          if (onScrollBegin != null) 'onScrollBegin': true,
          if (onScrollEnd != null) 'onScrollEnd': true,
          if (onEndReached != null) 'onEndReached': true,
          'requestItem': true, // Always listen for item requests
        },
      },
      onEvent: _handleEvent,
    );

    if (id == null) return null;

    debugPrint("Created ListView with ID: $id and ${data.length} items");

    return id;
  }

  void _handleEvent(String type, dynamic data) async {
    switch (type) {
      case 'onScroll':
        onScroll?.call(data);
        break;
      case 'onScrollBegin':
        onScrollBegin?.call(data);
        break;
      case 'onScrollEnd':
        onScrollEnd?.call(data);
        break;
      case 'onEndReached':
        onEndReached?.call();
        break;
      case 'requestItem':
        if (onEvent != null) {
          // Pass the request to the custom event handler
          onEvent!(type, data);
        } else {
          // Default handler if no custom event handler
          _handleItemRequest(data);
        }
        break;
      default:
        // Pass any other events to the custom handler
        onEvent?.call(type, data);
        break;
    }
  }

  Future<void> _handleItemRequest(Map<String, dynamic> data) async {
    if (data['index'] == null) return;

    final int index = data['index'];
    debugPrint("Handling request to render item at index $index");

    if (index >= 0 && index < this.data.length) {
      final item = this.data[index];
      final itemId = await renderItem(item, index);

      if (itemId != null && id != null) {
        await Core.invokeMethod('setItem', {
          'listViewId': id!,
          'index': index,
          'itemId': itemId,
          'key': keyExtractor?.call(item) ?? index.toString(),
        });
      }
    }
  }

  Future<void> scrollToIndex(int index, {bool animated = true}) async {
    if (id == null) return;

    await Core.invokeMethod('scrollToIndex', {
      'listViewId': id!,
      'index': index,
      'animated': animated,
    });
  }

  Future<void> refreshData(List<dynamic> newData) async {
    if (id == null) return;

    // Update data reference
    data.clear();
    data.addAll(newData);

    // Tell native side about new data
    await Core.invokeMethod('refreshData', {
      'listViewId': id!,
      'dataLength': newData.length,
    });
  }
}
