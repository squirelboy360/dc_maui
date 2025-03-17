import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Props for ScrollView component
class DCScrollViewProps implements ControlProps {
  final bool? horizontal;
  final bool? showsVerticalScrollIndicator;
  final bool? showsHorizontalScrollIndicator;
  final bool? pagingEnabled;
  final bool? bounces;
  final double? contentOffset;
  final bool? scrollToOffsetAnimated;
  final EdgeInsets? contentInset;
  final EdgeInsets? scrollIndicatorInsets;
  final String? keyboardDismissMode;
  final bool? refreshing;
  final Function()? onRefresh;
  final Function(Map<String, dynamic>)? onScroll;
  final Function()? onMomentumScrollBegin;
  final Function()? onMomentumScrollEnd;
  final Function()? onScrollBeginDrag;
  final Function()? onScrollEndDrag;
  final double? onEndReachedThreshold;
  final Function(Map<String, dynamic>)? onEndReached;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCScrollViewProps({
    this.horizontal,
    this.showsVerticalScrollIndicator,
    this.showsHorizontalScrollIndicator,
    this.pagingEnabled,
    this.bounces,
    this.contentOffset,
    this.scrollToOffsetAnimated,
    this.contentInset,
    this.scrollIndicatorInsets,
    this.keyboardDismissMode,
    this.refreshing,
    this.onRefresh,
    this.onScroll,
    this.onMomentumScrollBegin,
    this.onMomentumScrollEnd,
    this.onScrollBeginDrag,
    this.onScrollEndDrag,
    this.onEndReachedThreshold,
    this.onEndReached,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (horizontal != null) map['horizontal'] = horizontal;
    if (showsVerticalScrollIndicator != null)
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    if (showsHorizontalScrollIndicator != null)
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (bounces != null) map['bounces'] = bounces;
    if (contentOffset != null) map['contentOffset'] = contentOffset;
    if (scrollToOffsetAnimated != null)
      map['scrollToOffsetAnimated'] = scrollToOffsetAnimated;

    // Convert EdgeInsets to maps
    if (contentInset != null) {
      map['contentInset'] = {
        'top': contentInset!.top,
        'left': contentInset!.left,
        'bottom': contentInset!.bottom,
        'right': contentInset!.right,
      };
    }

    if (scrollIndicatorInsets != null) {
      map['scrollIndicatorInsets'] = {
        'top': scrollIndicatorInsets!.top,
        'left': scrollIndicatorInsets!.left,
        'bottom': scrollIndicatorInsets!.bottom,
        'right': scrollIndicatorInsets!.right,
      };
    }

    if (keyboardDismissMode != null)
      map['keyboardDismissMode'] = keyboardDismissMode;
    if (refreshing != null) map['refreshing'] = refreshing;
    if (onRefresh != null) map['onRefresh'] = onRefresh;
    if (onScroll != null) map['onScroll'] = onScroll;
    if (onMomentumScrollBegin != null)
      map['onMomentumScrollBegin'] = onMomentumScrollBegin;
    if (onMomentumScrollEnd != null)
      map['onMomentumScrollEnd'] = onMomentumScrollEnd;
    if (onScrollBeginDrag != null) map['onScrollBeginDrag'] = onScrollBeginDrag;
    if (onScrollEndDrag != null) map['onScrollEndDrag'] = onScrollEndDrag;
    if (onEndReachedThreshold != null)
      map['onEndReachedThreshold'] = onEndReachedThreshold;
    if (onEndReached != null) map['onEndReached'] = onEndReached;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// ScrollView component
class DCScrollView extends Control {
  final DCScrollViewProps props;
  final List<Control> children;

  DCScrollView({
    bool? horizontal,
    bool? showsVerticalScrollIndicator,
    bool? showsHorizontalScrollIndicator,
    bool? pagingEnabled,
    bool? bounces,
    double? contentOffset,
    bool? scrollToOffsetAnimated,
    EdgeInsets? contentInset,
    EdgeInsets? scrollIndicatorInsets,
    String? keyboardDismissMode,
    bool? refreshing,
    Function()? onRefresh,
    Function(Map<String, dynamic>)? onScroll,
    Function()? onMomentumScrollBegin,
    Function()? onMomentumScrollEnd,
    Function()? onScrollBeginDrag,
    Function()? onScrollEndDrag,
    double? onEndReachedThreshold,
    Function(Map<String, dynamic>)? onEndReached,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCScrollViewProps(
          horizontal: horizontal,
          showsVerticalScrollIndicator: showsVerticalScrollIndicator,
          showsHorizontalScrollIndicator: showsHorizontalScrollIndicator,
          pagingEnabled: pagingEnabled,
          bounces: bounces,
          contentOffset: contentOffset,
          scrollToOffsetAnimated: scrollToOffsetAnimated,
          contentInset: contentInset,
          scrollIndicatorInsets: scrollIndicatorInsets,
          keyboardDismissMode: keyboardDismissMode,
          refreshing: refreshing,
          onRefresh: onRefresh,
          onScroll: onScroll,
          onMomentumScrollBegin: onMomentumScrollBegin,
          onMomentumScrollEnd: onMomentumScrollEnd,
          onScrollBeginDrag: onScrollBeginDrag,
          onScrollEndDrag: onScrollEndDrag,
          onEndReachedThreshold: onEndReachedThreshold,
          onEndReached: onEndReached,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCScrollView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Convenience constructor for a vertical scrollview
  static DCScrollView vertical({
    List<Control> children = const [],
    bool? showsIndicator,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onScroll,
  }) {
    return DCScrollView(
      horizontal: false,
      showsVerticalScrollIndicator: showsIndicator,
      style: style,
      onScroll: onScroll,
      children: children,
    );
  }

  /// Convenience constructor for a horizontal scrollview
  static DCScrollView horizontal({
    List<Control> children = const [],
    bool? showsIndicator,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onScroll,
  }) {
    return DCScrollView(
      horizontal: true,
      showsHorizontalScrollIndicator: showsIndicator,
      style: style,
      onScroll: onScroll,
      children: children,
    );
  }
}
