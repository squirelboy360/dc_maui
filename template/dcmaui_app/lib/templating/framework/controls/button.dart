import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Style properties for DCButton
class DCButtonStyle implements StyleProps {
  final Color? backgroundColor;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? elevation; // Shadow depth
  final double? width;
  final double? height;
  final double? minWidth;
  final double? minHeight;
  final TextAlign? textAlign;
  final double? opacity;
  final EdgeInsets? margin;

  // New properties matching iOS implementation
  final double? activeOpacity;
  final double? shadowOpacity;
  final double? shadowRadius;
  final Offset? shadowOffset;
  final Color? shadowColor;

  const DCButtonStyle({
    this.backgroundColor,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.padding,
    this.elevation,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.textAlign,
    this.opacity,
    this.margin,
    this.activeOpacity,
    this.shadowOpacity,
    this.shadowRadius,
    this.shadowOffset,
    this.shadowColor,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight.toString();
    if (borderRadius != null) map['borderRadius'] = borderRadius;
    if (borderWidth != null) map['borderWidth'] = borderWidth;

    if (borderColor != null) {
      final colorValue = borderColor!.value.toRadixString(16).padLeft(8, '0');
      map['borderColor'] = '#$colorValue';
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

    if (elevation != null) map['elevation'] = elevation;
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (minWidth != null) map['minWidth'] = minWidth;
    if (minHeight != null) map['minHeight'] = minHeight;
    if (textAlign != null) map['textAlign'] = textAlign.toString();
    if (opacity != null) map['opacity'] = opacity;
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

    // Add new iOS-specific properties for shadows
    if (shadowColor != null) {
      final colorValue = shadowColor!.value.toRadixString(16).padLeft(8, '0');
      map['shadowColor'] = '#$colorValue';
    }

    if (shadowOpacity != null) map['shadowOpacity'] = shadowOpacity;
    if (shadowRadius != null) map['shadowRadius'] = shadowRadius;

    if (shadowOffset != null) {
      map['shadowOffsetWidth'] = shadowOffset!.dx;
      map['shadowOffsetHeight'] = shadowOffset!.dy;
    }

    if (activeOpacity != null) map['activeOpacity'] = activeOpacity;

    return map;
  }

  /// Factory to convert a Map to a DCButtonStyle
  factory DCButtonStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return DCButtonStyle(
      backgroundColor: map['backgroundColor'] is Color
          ? map['backgroundColor']
          : hexToColor(map['backgroundColor']),
      color: map['color'] is Color ? map['color'] : hexToColor(map['color']),
      fontSize: map['fontSize'] is double ? map['fontSize'] : null,
      fontWeight: map['fontWeight'] is String
          ? FontWeight.values.firstWhere(
              (e) => e.toString() == map['fontWeight'],
              orElse: () => FontWeight.normal,
            )
          : null,
      borderRadius: map['borderRadius'] is double ? map['borderRadius'] : null,
      borderWidth: map['borderWidth'] is double ? map['borderWidth'] : null,
      borderColor: map['borderColor'] is Color
          ? map['borderColor']
          : hexToColor(map['borderColor']),
      padding: map['padding'] is EdgeInsets
          ? map['padding']
          : map['padding'] is double
              ? EdgeInsets.all(map['padding'])
              : null,
      elevation: map['elevation'] is double ? map['elevation'] : null,
      width: map['width'] is double ? map['width'] : null,
      height: map['height'] is double ? map['height'] : null,
      minWidth: map['minWidth'] is double ? map['minWidth'] : null,
      minHeight: map['minHeight'] is double ? map['minHeight'] : null,
      textAlign: map['textAlign'] is String
          ? TextAlign.values.firstWhere(
              (e) => e.toString() == map['textAlign'],
              orElse: () => TextAlign.start,
            )
          : null,
      opacity: map['opacity'] is double ? map['opacity'] : null,
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
      activeOpacity:
          map['activeOpacity'] is double ? map['activeOpacity'] : null,
      shadowOpacity:
          map['shadowOpacity'] is double ? map['shadowOpacity'] : null,
      shadowRadius: map['shadowRadius'] is double ? map['shadowRadius'] : null,
      shadowOffset: map['shadowOffsetWidth'] is double &&
              map['shadowOffsetHeight'] is double
          ? Offset(map['shadowOffsetWidth'], map['shadowOffsetHeight'])
          : null,
      shadowColor: map['shadowColor'] is Color
          ? map['shadowColor']
          : hexToColor(map['shadowColor']),
    );
  }

  DCButtonStyle copyWith({
    Color? backgroundColor,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    EdgeInsets? padding,
    double? elevation,
    double? width,
    double? height,
    double? minWidth,
    double? minHeight,
    TextAlign? textAlign,
    double? opacity,
    EdgeInsets? margin,
    double? activeOpacity,
    double? shadowOpacity,
    double? shadowRadius,
    Offset? shadowOffset,
    Color? shadowColor,
  }) {
    return DCButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      width: width ?? this.width,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      textAlign: textAlign ?? this.textAlign,
      opacity: opacity ?? this.opacity,
      margin: margin ?? this.margin,
      activeOpacity: activeOpacity ?? this.activeOpacity,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowRadius: shadowRadius ?? this.shadowRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
}

/// Props for DCButton component
class DCButtonProps implements ControlProps {
  final String? title;
  final Function()? onPress;
  final DCButtonStyle? style;
  final bool? disabled;
  final double? delayLongPress; // Aligns with iOS implementation
  final bool? loading; // Add loading state support
  final String? testID;
  final Map<String, dynamic> additionalProps;

  // New props matching iOS implementation
  final double? activeOpacity;
  final double? delayPressIn;
  final double? delayPressOut;

  const DCButtonProps({
    this.title,
    this.onPress,
    this.style,
    this.disabled,
    this.delayLongPress,
    this.loading,
    this.testID,
    this.additionalProps = const {},
    this.activeOpacity,
    this.delayPressIn,
    this.delayPressOut,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (title != null) map['title'] = title;
    if (onPress != null) map['onPress'] = onPress;
    if (style != null) map['style'] = style!.toMap();
    if (disabled != null) map['disabled'] = disabled;
    if (delayLongPress != null) map['delayLongPress'] = delayLongPress;
    if (loading != null) map['loading'] = loading;
    if (testID != null) map['testID'] = testID;

    // Add new iOS-specific properties
    if (activeOpacity != null) map['activeOpacity'] = activeOpacity;
    if (delayPressIn != null) map['delayPressIn'] = delayPressIn;
    if (delayPressOut != null) map['delayPressOut'] = delayPressOut;

    return map;
  }

  DCButtonProps copyWith({
    String? title,
    Function()? onPress,
    DCButtonStyle? style,
    bool? disabled,
    double? delayLongPress,
    bool? loading,
    String? testID,
    Map<String, dynamic>? additionalProps,
    double? activeOpacity,
    double? delayPressIn,
    double? delayPressOut,
  }) {
    return DCButtonProps(
      title: title ?? this.title,
      onPress: onPress ?? this.onPress,
      style: style ?? this.style,
      disabled: disabled ?? this.disabled,
      delayLongPress: delayLongPress ?? this.delayLongPress,
      loading: loading ?? this.loading,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
      activeOpacity: activeOpacity ?? this.activeOpacity,
      delayPressIn: delayPressIn ?? this.delayPressIn,
      delayPressOut: delayPressOut ?? this.delayPressOut,
    );
  }
}

/// Button component
class DCButton extends Control {
  final DCButtonProps props;

  DCButton({
    String? title,
    Function()? onPress,
    DCButtonStyle? style,
    bool? disabled,
    double? delayLongPress,
    bool? loading,
    String? testID,
    double? activeOpacity,
    double? delayPressIn,
    double? delayPressOut,
  }) : props = DCButtonProps(
          title: title,
          onPress: onPress,
          style: style,
          disabled: disabled,
          delayLongPress: delayLongPress,
          loading: loading,
          testID: testID,
          activeOpacity: activeOpacity,
          delayPressIn: delayPressIn,
          delayPressOut: delayPressOut,
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCButton',
      props.toMap(),
      [],
    );
  }
}
