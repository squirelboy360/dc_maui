import 'package:flutter/material.dart';

import '../core.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';
import 'dart:ui';

enum ScrollDirection {
  vertical,
  horizontal,
  both;

  String toValue() {
    return name;
  }
}

enum DecelerationRate {
  normal,
  fast;

  String toValue() {
    return name;
  }
}

class ScrollViewStyle {
  final int? backgroundColor;
  final bool? showsIndicators;
  final bool? bounces;
  final ScrollDirection? direction;
  final double? initialScrollX;
  final double? initialScrollY;
  final bool? scrollEnabled;
  final DecelerationRate? decelerationRate;
  final EdgeInsets? contentInset;
  final bool? pagingEnabled;

  const ScrollViewStyle({
    this.backgroundColor,
    this.showsIndicators,
    this.bounces,
    this.direction,
    this.initialScrollX,
    this.initialScrollY,
    this.scrollEnabled,
    this.decelerationRate,
    this.contentInset,
    this.pagingEnabled,
  });

  Map<String, dynamic> toMap() => {
        if (backgroundColor != null) 'backgroundColor': backgroundColor,
        if (showsIndicators != null) 'showsIndicators': showsIndicators,
        if (bounces != null) 'bounces': bounces,
        if (direction != null) 'direction': direction!.toValue(),
        if (initialScrollX != null) 'initialScrollX': initialScrollX,
        if (initialScrollY != null) 'initialScrollY': initialScrollY,
        if (scrollEnabled != null) 'scrollEnabled': scrollEnabled,
        if (decelerationRate != null)
          'decelerationRate': decelerationRate!.toValue(),
        if (contentInset != null)
          'contentInset': {
            'top': contentInset!.top,
            'left': contentInset!.left,
            'bottom': contentInset!.bottom,
            'right': contentInset!.right,
          },
        if (pagingEnabled != null) 'pagingEnabled': pagingEnabled,
      };
}

typedef ScrollCallback = void Function(Map<String, dynamic> offsetData);
typedef EndReachedCallback = void Function();

class ScrollView {
  String? id;
  final ScrollViewStyle style;
  final ViewStyle viewStyle;
  final YogaLayout layout;
  final ScrollCallback? onScroll;
  final ScrollCallback? onScrollBegin;
  final ScrollCallback? onScrollEnd;
  final ScrollCallback? onMomentumScrollBegin;
  final ScrollCallback? onMomentumScrollEnd;
  final EndReachedCallback? onEndReached;

  ScrollView({
    this.style = const ScrollViewStyle(),
    this.viewStyle = const ViewStyle(),
    this.layout = const YogaLayout(),
    this.onScroll,
    this.onScrollBegin,
    this.onScrollEnd,
    this.onMomentumScrollBegin,
    this.onMomentumScrollEnd,
    this.onEndReached,
  });

  Future<String?> create() async {
    id = await Core.createView(
      viewType: 'ScrollView',
      properties: {
        'scrollViewStyle': style.toMap(),
        'style': viewStyle.toMap(),
        'layout': layout.toMap(),
        'events': {
          if (onScroll != null) 'onScroll': true,
          if (onScrollBegin != null) 'onScrollBegin': true,
          if (onScrollEnd != null) 'onScrollEnd': true,
          if (onMomentumScrollBegin != null) 'onMomentumScrollBegin': true,
          if (onMomentumScrollEnd != null) 'onMomentumScrollEnd': true,
          if (onEndReached != null) 'onEndReached': true,
        },
      },
      onEvent: _handleEvent,
    );
    return id;
  }

  void _handleEvent(String type, dynamic data) {
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
      case 'onMomentumScrollBegin':
        onMomentumScrollBegin?.call(data);
        break;
      case 'onMomentumScrollEnd':
        onMomentumScrollEnd?.call(data);
        break;
      case 'onEndReached':
        onEndReached?.call();
        break;
    }
  }
}
