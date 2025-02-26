import 'package:flutter/material.dart';

import '../core.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

enum ScrollDirection {
  vertical,
  horizontal,
  both;

  String toValue() => name;
}

class ScrollViewStyle extends ViewStyle {
  final bool? showsIndicators;
  final bool? bounces;
  final bool? pagingEnabled;
  final ScrollDirection? direction;
  final bool? scrollEnabled;
  final double? initialScrollX;
  final double? initialScrollY;
  final bool? alwaysBounceVertical;
  final bool? alwaysBounceHorizontal;
  final bool? keyboardDismissMode;

  const ScrollViewStyle({
    this.showsIndicators = true,
    this.bounces = true,
    this.pagingEnabled = false,
    this.direction = ScrollDirection.vertical, // Default is vertical
    this.scrollEnabled = true,
    this.initialScrollX,
    this.initialScrollY,
    this.alwaysBounceVertical,
    this.alwaysBounceHorizontal,
    this.keyboardDismissMode = true,
    super.backgroundColor,
    super.cornerRadius,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'scrollStyle': {
        if (showsIndicators != null) 'showsIndicators': showsIndicators,
        if (bounces != null) 'bounces': bounces,
        if (pagingEnabled != null) 'pagingEnabled': pagingEnabled,
        if (direction != null) 'direction': direction!.toValue(),
        if (scrollEnabled != null) 'scrollEnabled': scrollEnabled,
        if (initialScrollX != null) 'initialScrollX': initialScrollX,
        if (initialScrollY != null) 'initialScrollY': initialScrollY,
        if (alwaysBounceVertical != null)
          'alwaysBounceVertical': alwaysBounceVertical,
        if (alwaysBounceHorizontal != null)
          'alwaysBounceHorizontal': alwaysBounceHorizontal,
        if (keyboardDismissMode != null)
          'keyboardDismissMode': keyboardDismissMode,
      }
    };
  }
}

class ScrollView {
  String? id;
  final ScrollViewStyle style;
  final YogaLayout layout;
  final void Function(ScrollMetrics)? onScroll;
  final VoidCallback? onScrollEnd;
  final List<String> children; // Changed from dynamic to String

  ScrollView({
    this.style = const ScrollViewStyle(),
    this.layout = const YogaLayout(),
    this.onScroll,
    this.onScrollEnd,
    this.children = const [],
  });

  Future<String?> create() async {
    id = await Core.createView(
      viewType: 'ScrollView',
      properties: {
        'style': style.toMap(),
        'layout': layout.toMap(),
        'events': {
          if (onScroll != null) 'onScroll': true,
          if (onScrollEnd != null) 'onScrollEnd': true,
        },
      },
      onEvent: _handleEvent,
      children: children.isNotEmpty ? children : null, // Pass children directly
    );
    return id;
  }

  void _handleEvent(String type, dynamic data) {
    switch (type) {
      case 'onScroll':
        if (onScroll != null && data != null) {
          final metrics = ScrollMetrics.fromMap(data);
          onScroll!(metrics);
        }
        break;
      case 'onScrollEnd':
        onScrollEnd?.call();
        break;
    }
  }
}

class ScrollMetrics {
  final double offsetX;
  final double offsetY;
  final double velocityX;
  final double velocityY;
  final Size contentSize;
  final Size viewportSize;

  ScrollMetrics({
    required this.offsetX,
    required this.offsetY,
    required this.velocityX,
    required this.velocityY,
    required this.contentSize,
    required this.viewportSize,
  });

  factory ScrollMetrics.fromMap(Map<String, dynamic> map) {
    final offset = map['offset'] as Map<String, dynamic>;
    final velocity = map['velocity'] as Map<String, dynamic>;
    final content = map['contentSize'] as Map<String, dynamic>;
    final viewport = map['viewportSize'] as Map<String, dynamic>;

    return ScrollMetrics(
      offsetX: offset['x'] as double,
      offsetY: offset['y'] as double,
      velocityX: velocity['x'] as double,
      velocityY: velocity['y'] as double,
      contentSize:
          Size(content['width'] as double, content['height'] as double),
      viewportSize:
          Size(viewport['width'] as double, viewport['height'] as double),
    );
  }
}
