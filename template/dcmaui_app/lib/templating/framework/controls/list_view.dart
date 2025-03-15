import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';

/// Style properties for ListView
class ListViewStyle implements StyleProps {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? scrollIndicatorThickness;
  final double? height;
  final double? width;
  final double? contentSpacing;
  final double? scrollPadding;

  const ListViewStyle({
    this.padding,
    this.margin,
    this.backgroundColor,
    this.scrollIndicatorThickness,
    this.height,
    this.width,
    this.contentSpacing,
    this.scrollPadding,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (padding != null) {
      if (padding!.left == padding!.right &&
          padding!.top == padding!.bottom &&
          padding!.left == padding!.top) {
        map['padding'] = padding!.top;
      } else {
        map['paddingLeft'] = padding!.left;
        map['paddingRight'] = padding!.right;
        map['paddingTop'] = padding!.top;
        map['paddingBottom'] = padding!.bottom;
      }
    }

    if (margin != null) {
      if (margin!.left == margin!.right &&
          margin!.top == margin!.bottom &&
          margin!.left == margin!.top) {
        map['margin'] = margin!.top;
      } else {
        map['marginLeft'] = margin!.left;
        map['marginRight'] = margin!.right;
        map['marginTop'] = margin!.top;
        map['marginBottom'] = margin!.bottom;
      }
    }

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (scrollIndicatorThickness != null) {
      map['scrollIndicatorThickness'] = scrollIndicatorThickness;
    }
    if (height != null) map['height'] = height;
    if (width != null) map['width'] = width;
    if (contentSpacing != null) map['contentSpacing'] = contentSpacing;
    if (scrollPadding != null) map['scrollPadding'] = scrollPadding;

    return map;
  }

  factory ListViewStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }
      return Color(int.parse(hexString, radix: 16));
    }

    EdgeInsets? convertPadding(dynamic padding) {
      if (padding is EdgeInsets) return padding;
      if (padding is double) return EdgeInsets.all(padding);
      return null;
    }

    // Convert map to ListViewStyle
    return ListViewStyle(
      padding: convertPadding(map['padding']),
      margin: convertPadding(map['margin']),
      backgroundColor: map['backgroundColor'] is Color
          ? map['backgroundColor']
          : hexToColor(map['backgroundColor']),
      scrollIndicatorThickness: map['scrollIndicatorThickness'] is double
          ? map['scrollIndicatorThickness']
          : null,
      height: map['height'] is double ? map['height'] : null,
      width: map['width'] is double ? map['width'] : null,
      contentSpacing:
          map['contentSpacing'] is double ? map['contentSpacing'] : null,
      scrollPadding:
          map['scrollPadding'] is double ? map['scrollPadding'] : null,
    );
  }

  ListViewStyle copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? scrollIndicatorThickness,
    double? height,
    double? width,
    double? contentSpacing,
    double? scrollPadding,
  }) {
    return ListViewStyle(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      scrollIndicatorThickness:
          scrollIndicatorThickness ?? this.scrollIndicatorThickness,
      height: height ?? this.height,
      width: width ?? this.width,
      contentSpacing: contentSpacing ?? this.contentSpacing,
      scrollPadding: scrollPadding ?? this.scrollPadding,
    );
  }
}

/// Props for ListView control
class ListViewProps implements ControlProps {
  final bool horizontal;
  final bool? showsScrollIndicator;
  final Function(double)? onScroll;
  final Function()? onEndReached;
  final double? onEndReachedThreshold;
  final bool? bounces;
  final int? initialScrollIndex;
  final String? testID;
  final ListViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const ListViewProps({
    this.horizontal = false,
    this.showsScrollIndicator,
    this.onScroll,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.bounces,
    this.initialScrollIndex,
    this.testID,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'horizontal': horizontal,
      ...additionalProps,
    };

    if (showsScrollIndicator != null) {
      map['showsScrollIndicator'] = showsScrollIndicator;
    }

    if (onScroll != null) {
      map['onScroll'] = onScroll;
    }

    if (onEndReached != null) {
      map['onEndReached'] = onEndReached;
    }

    if (onEndReachedThreshold != null) {
      map['onEndReachedThreshold'] = onEndReachedThreshold;
    }

    if (bounces != null) {
      map['bounces'] = bounces;
    }

    if (initialScrollIndex != null) {
      map['initialScrollIndex'] = initialScrollIndex;
    }

    if (testID != null) {
      map['testID'] = testID;
    }

    if (style != null) {
      map['style'] = style!.toMap();
    }

    // Add platform-specific props
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific ListView properties
      if (!map.containsKey('overflowY') && horizontal == false) {
        map['overflowY'] = 'auto';
      }
      if (!map.containsKey('overflowX') && horizontal == true) {
        map['overflowX'] = 'auto';
      }
      if (!map.containsKey('display')) {
        map['display'] = 'flex';
      }
      if (!map.containsKey('flexDirection')) {
        map['flexDirection'] = horizontal ? 'row' : 'column';
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific properties
      if (bounces == null &&
          !map.containsKey('bounces') &&
          !additionalProps.containsKey('bounces')) {
        map['bounces'] = true; // iOS usually allows bouncing
      }
      if (!map.containsKey('alwaysBounceVertical') && horizontal == false) {
        map['alwaysBounceVertical'] = true;
      }
      if (!map.containsKey('decelerationRate')) {
        map['decelerationRate'] = 'normal'; // iOS deceleration rate
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific properties
      if (bounces == null &&
          !map.containsKey('bounces') &&
          !additionalProps.containsKey('bounces')) {
        map['bounces'] = false; // Android typically doesn't bounce
      }
      if (!map.containsKey('overScrollMode')) {
        map['overScrollMode'] = 'never'; // Android over-scroll behavior
      }
      if (!map.containsKey('fadingEdgeLength') &&
          !additionalProps.containsKey('fadingEdgeLength')) {
        map['fadingEdgeLength'] = 16.0; // Fading edge for Android lists
      }
    }

    return map;
  }

  ListViewProps copyWith({
    bool? horizontal,
    bool? showsScrollIndicator,
    Function(double)? onScroll,
    Function()? onEndReached,
    double? onEndReachedThreshold,
    bool? bounces,
    int? initialScrollIndex,
    String? testID,
    ListViewStyle? style,
    Map<String, dynamic>? additionalProps,
  }) {
    return ListViewProps(
      horizontal: horizontal ?? this.horizontal,
      showsScrollIndicator: showsScrollIndicator ?? this.showsScrollIndicator,
      onScroll: onScroll ?? this.onScroll,
      onEndReached: onEndReached ?? this.onEndReached,
      onEndReachedThreshold:
          onEndReachedThreshold ?? this.onEndReachedThreshold,
      bounces: bounces ?? this.bounces,
      initialScrollIndex: initialScrollIndex ?? this.initialScrollIndex,
      testID: testID ?? this.testID,
      style: style ?? this.style,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// ListView control
class ListView extends Control {
  final ListViewProps props;
  final List<Control> children;

  ListView({
    ListViewProps? props,
    required this.children,
    bool? horizontal,
    bool? showsScrollIndicator,
    Function(double)? onScroll,
    Function()? onEndReached,
    double? onEndReachedThreshold,
    bool? bounces,
    int? initialScrollIndex,
    String? testID,
    ListViewStyle? style,
    Map<String, dynamic>? styleMap,
  }) : props = props ??
            ListViewProps(
              horizontal: horizontal ?? false,
              showsScrollIndicator: showsScrollIndicator,
              onScroll: onScroll,
              onEndReached: onEndReached,
              onEndReachedThreshold: onEndReachedThreshold,
              bounces: bounces,
              initialScrollIndex: initialScrollIndex,
              testID: testID,
              style: style ??
                  (styleMap != null ? ListViewStyle.fromMap(styleMap) : null),
            );

  ListView.custom({
    required this.props,
    required this.children,
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'ListView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a horizontal ListView
  static ListView horizontal({
    required List<Control> children,
    ListViewProps? props,
    bool? showsScrollIndicator,
    Function(double)? onScroll,
    Function()? onEndReached,
    double? onEndReachedThreshold,
    bool? bounces,
    int? initialScrollIndex,
    String? testID,
    ListViewStyle? style,
    Map<String, dynamic>? styleMap,
  }) {
    return ListView(
      props: props?.copyWith(horizontal: true) ??
          ListViewProps(
            horizontal: true,
            showsScrollIndicator: showsScrollIndicator,
            onScroll: onScroll,
            onEndReached: onEndReached,
            onEndReachedThreshold: onEndReachedThreshold,
            bounces: bounces,
            initialScrollIndex: initialScrollIndex,
            testID: testID,
            style: style ??
                (styleMap != null ? ListViewStyle.fromMap(styleMap) : null),
          ),
      children: children,
    );
  }
}
