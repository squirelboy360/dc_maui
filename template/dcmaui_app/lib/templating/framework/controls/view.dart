import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/painting.dart' hide TextStyle;
import 'package:flutter/widgets.dart';

/// Style properties for View
class ViewStyle implements StyleProps {
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Border? border;
  final Alignment? alignment;
  final BoxConstraints? constraints;
  final List<BoxShadow>? boxShadow;

  const ViewStyle({
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.border,
    this.alignment,
    this.constraints,
    this.boxShadow,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

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

    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;

    if (borderRadius != null) {
      if (borderRadius!.topLeft == borderRadius!.topRight &&
          borderRadius!.topLeft == borderRadius!.bottomLeft &&
          borderRadius!.topLeft == borderRadius!.bottomRight) {
        map['borderRadius'] = borderRadius!.topLeft.x;
      } else {
        map['borderTopLeftRadius'] = borderRadius!.topLeft.x;
        map['borderTopRightRadius'] = borderRadius!.topRight.x;
        map['borderBottomLeftRadius'] = borderRadius!.bottomLeft.x;
        map['borderBottomRightRadius'] = borderRadius!.bottomRight.x;
      }
    }

    if (border != null) {
      // Simplifying to just handle uniform borders for now
      final side = border!.top;
      if (side.width > 0) {
        map['borderWidth'] = side.width;
        map['borderColor'] =
            '#${side.color.value.toRadixString(16).padLeft(8, '0')}';
      }
    }

    if (alignment != null) {
      // Convert Flutter alignment to flexbox alignment
      if (alignment == Alignment.center) {
        map['justifyContent'] = 'center';
        map['alignItems'] = 'center';
      } else if (alignment == Alignment.centerLeft) {
        map['justifyContent'] = 'flex-start';
        map['alignItems'] = 'center';
      }
      // Add more alignment mappings as needed
    }

    return map;
  }

  ViewStyle copyWith({
    Color? backgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Border? border,
    Alignment? alignment,
    BoxConstraints? constraints,
    List<BoxShadow>? boxShadow,
  }) {
    return ViewStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      alignment: alignment ?? this.alignment,
      constraints: constraints ?? this.constraints,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}

/// Props for View component
class ViewProps implements ControlProps {
  final String? id;
  final ViewStyle? style;
  final bool? pointerEvents;
  final Function()? onLayout;
  final double? opacity;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const ViewProps({
    this.id,
    this.style,
    this.pointerEvents,
    this.onLayout,
    this.opacity,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (id != null) map['id'] = id;
    if (style != null) map['style'] = style!.toMap();
    if (pointerEvents != null) map['pointerEvents'] = pointerEvents;
    if (onLayout != null) map['onLayout'] = onLayout;
    if (opacity != null) map['opacity'] = opacity;
    if (testID != null) map['testID'] = testID;

    return map;
  }

  ViewProps copyWith({
    String? id,
    ViewStyle? style,
    bool? pointerEvents,
    Function()? onLayout,
    double? opacity,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return ViewProps(
      id: id ?? this.id,
      style: style ?? this.style,
      pointerEvents: pointerEvents ?? this.pointerEvents,
      onLayout: onLayout ?? this.onLayout,
      opacity: opacity ?? this.opacity,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// View component (container)
class View extends Control {
  final ViewProps props;
  final List<Control> children;

  View({
    ViewProps? props,
    this.children = const [],
  }) : props = props ?? const ViewProps();

  @override
  VNode build() {
    return ElementFactory.createElement(
      'View',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a View with style
  static View styled({
    required ViewStyle style,
    List<Control> children = const [],
    ViewProps? props,
  }) {
    return View(
      props: (props ?? const ViewProps()).copyWith(style: style),
      children: children,
    );
  }
}
