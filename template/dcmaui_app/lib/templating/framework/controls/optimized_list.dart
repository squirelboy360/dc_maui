import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Props for DCOptimizedList component
class DCOptimizedListProps<T> implements ControlProps {
  /// The items to render in the list
  final List<T> items;

  /// Function to get a unique key for an item
  final String Function(T item, int index) keyExtractor;

  /// Function to render an item
  final Control Function(T item, int index) renderItem;

  /// Maximum number of items to render at once (for windowing)
  final int? windowSize;

  /// Initial index to render at
  final int initialScrollIndex;

  /// Spacing between items
  final double? itemSpacing;

  /// Direction of the list (horizontal or vertical)
  final Axis direction;

  /// Additional props
  final Map<String, dynamic> additionalProps;

  const DCOptimizedListProps({
    required this.items,
    required this.keyExtractor,
    required this.renderItem,
    this.windowSize,
    this.initialScrollIndex = 0,
    this.itemSpacing,
    this.direction = Axis.vertical,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'itemCount': items.length,
      'direction': direction == Axis.vertical ? 'vertical' : 'horizontal',
      ...additionalProps,
    };

    if (windowSize != null) map['windowSize'] = windowSize;
    if (itemSpacing != null) map['itemSpacing'] = itemSpacing;
    if (initialScrollIndex != 0) map['initialScrollIndex'] = initialScrollIndex;

    return map;
  }
}

/// Optimized list component with efficient rendering for large datasets
class DCOptimizedList<T> extends Control {
  final DCOptimizedListProps<T> props;

  DCOptimizedList({
    required this.props,
  });

  @override
  VNode build() {
    // Create the list container node
    final listNode = ElementFactory.createElement(
      'DCOptimizedList',
      props.toMap(),
      [], // Children built separately for optimization
    );

    // For large lists, only create a subset of the VNodes at a time
    final items = props.items;
    final windowSize = props.windowSize ?? items.length;
    final visibleCount = windowSize < items.length ? windowSize : items.length;
    final startIndex = props.initialScrollIndex;
    final endIndex = (startIndex + visibleCount).clamp(0, items.length);

    // Create the visible children with stable keys
    final children = <VNode>[];
    if (kDebugMode) {
      print(
          'DCOptimizedList: Rendering items $startIndex to $endIndex of ${items.length}');
    }

    for (int i = startIndex; i < endIndex; i++) {
      final item = items[i];
      // Get a stable key for this item
      final key = props.keyExtractor(item, i);
      // Render the item with its key
      final itemControl = props.renderItem(item, i);
      final itemVNode = itemControl.build();

      // Ensure the item has a stable key
      final nodeWithKey = VNode(
        itemVNode.type,
        props: {...itemVNode.props},
        key: key,
        children: itemVNode.children,
      );

      children.add(nodeWithKey);
    }

    // Add the children to the list node
    listNode.children.addAll(children);

    return listNode;
  }
}
