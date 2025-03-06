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
  });

  Future<String?> create() async {
    // Create the list view component
    id = await Core.createView(
      viewType: 'ListView',
      properties: {
        'data': data,
        'listViewStyle': style.toMap(),
        'style': viewStyle.toMap(),
        'layout': layout.toMap(),
        'events': {
          if (onScroll != null) 'onScroll': true,
          if (onScrollBegin != null) 'onScrollBegin': true,
          if (onScrollEnd != null) 'onScrollEnd': true,
          if (onEndReached != null) 'onEndReached': true,
        },
      },
      onEvent: _handleEvent,
    );

    if (id == null) return null;

    // Initialize with initial batch of rendered items
    await _renderInitialItems();

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
        if (data is Map && data.containsKey('index')) {
          final int index = data['index'];
          debugPrint("Received request to render item at index $index");
          if (index >= 0 && index < this.data.length) {
            final item = this.data[index];
            final itemId = await renderItem(item, index);
            debugPrint("Rendered item with ID: $itemId");
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
        break;
    }
  }

  Future<void> _renderInitialItems() async {
    if (id == null) return;

    debugPrint("Rendering initial items");
    int initialCount = style.initialNumToRender ?? 10;
    initialCount = initialCount > data.length ? data.length : initialCount;

    for (int i = 0; i < initialCount; i++) {
      final item = data[i];
      debugPrint("Rendering initial item $i");
      final itemId = await renderItem(item, i);

      if (itemId != null) {
        final key = keyExtractor?.call(item) ?? i.toString();
        await Core.invokeMethod('setItem', {
          'listViewId': id!,
          'index': i,
          'itemId': itemId,
          'key': key,
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

    data.clear();
    data.addAll(newData);

    await Core.invokeMethod('refreshData', {
      'listViewId': id!,
      'dataLength': newData.length,
    });

    await _renderInitialItems();
  }
}
