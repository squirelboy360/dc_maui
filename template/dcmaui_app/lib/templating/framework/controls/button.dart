import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' hide TextStyle;
import 'package:dc_test/templating/framework/controls/text.dart';
import 'dart:io' show Platform;

/// Style properties for Button
class ButtonStyle implements StyleProps {
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final double? minWidth;
  final double? minHeight;
  final double? elevation;

  const ButtonStyle({
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.minWidth,
    this.minHeight,
    this.elevation,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (textColor != null) {
      final colorValue = textColor!.value.toRadixString(16).padLeft(8, '0');
      map['textColor'] = '#$colorValue';
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

    if (borderRadius != null) map['borderRadius'] = borderRadius;
    if (borderWidth != null) map['borderWidth'] = borderWidth;

    if (borderColor != null) {
      final colorValue = borderColor!.value.toRadixString(16).padLeft(8, '0');
      map['borderColor'] = '#$colorValue';
    }

    if (minWidth != null) map['minWidth'] = minWidth;
    if (minHeight != null) map['minHeight'] = minHeight;
    if (elevation != null) map['elevation'] = elevation;

    return map;
  }

  /// Factory to convert a Map to a ButtonStyle
  factory ButtonStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return ButtonStyle(
      backgroundColor: map['backgroundColor'] is Color
          ? map['backgroundColor']
          : hexToColor(map['backgroundColor']),
      textColor: map['textColor'] is Color
          ? map['textColor']
          : hexToColor(map['textColor']),
      padding: map['padding'] is EdgeInsets
          ? map['padding']
          : map['padding'] is double
              ? EdgeInsets.all(map['padding'])
              : null,
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
      borderRadius: map['borderRadius'] is double ? map['borderRadius'] : null,
      borderWidth: map['borderWidth'] is double ? map['borderWidth'] : null,
      borderColor: map['borderColor'] is Color
          ? map['borderColor']
          : hexToColor(map['borderColor']),
      minWidth: map['minWidth'] is double ? map['minWidth'] : null,
      minHeight: map['minHeight'] is double ? map['minHeight'] : null,
      elevation: map['elevation'] is double ? map['elevation'] : null,
    );
  }

  ButtonStyle copyWith({
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    double? minWidth,
    double? minHeight,
    double? elevation,
  }) {
    return ButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      elevation: elevation ?? this.elevation,
    );
  }
}

/// Props for Button control
class ButtonProps implements ControlProps {
  final String title;
  final Function(Map<String, dynamic>)? onPress;
  final bool? disabled;
  final ButtonStyle? style;
  final TextStyle? titleStyle;
  final String? testID;
  final String? accessibilityLabel;
  final bool? showsLoading;
  final Map<String, dynamic> additionalProps;

  const ButtonProps({
    required this.title,
    this.onPress,
    this.disabled,
    this.style,
    this.titleStyle,
    this.testID,
    this.accessibilityLabel,
    this.showsLoading,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      ...additionalProps,
    };

    if (onPress != null) map['onPress'] = onPress;
    if (disabled != null) map['disabled'] = disabled;
    if (style != null) map['style'] = style!.toMap();
    if (titleStyle != null) map['titleStyle'] = titleStyle!.toMap();
    if (testID != null) map['testID'] = testID;
    if (accessibilityLabel != null)
      map['accessibilityLabel'] = accessibilityLabel;
    if (showsLoading != null) map['showsLoading'] = showsLoading;

    // Add platform-specific props and behavior
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific defaults
      if (!map.containsKey('cursor') &&
          !additionalProps.containsKey('cursor')) {
        map['cursor'] = 'pointer';
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific defaults for buttons
      if (!map.containsKey('pressedOpacity')) {
        map['pressedOpacity'] = 0.2;
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific defaults
      if (!map.containsKey('rippleColor') &&
          !additionalProps.containsKey('rippleColor')) {
        map['rippleColor'] = '#20FFFFFF'; // Semi-transparent white ripple
      }
    }

    return map;
  }

  ButtonProps copyWith({
    String? title,
    Function(Map<String, dynamic>)? onPress,
    bool? disabled,
    ButtonStyle? style,
    TextStyle? titleStyle,
    String? testID,
    String? accessibilityLabel,
    bool? showsLoading,
    Map<String, dynamic>? additionalProps,
  }) {
    return ButtonProps(
      title: title ?? this.title,
      onPress: onPress ?? this.onPress,
      disabled: disabled ?? this.disabled,
      style: style ?? this.style,
      titleStyle: titleStyle ?? this.titleStyle,
      testID: testID ?? this.testID,
      accessibilityLabel: accessibilityLabel ?? this.accessibilityLabel,
      showsLoading: showsLoading ?? this.showsLoading,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Button control
class Button extends Control {
  final ButtonProps props;

  Button({
    required String title,
    Function(Map<String, dynamic>)? onPress,
    bool? disabled,
    ButtonStyle? style,
    Map<String, dynamic>? styleMap,
    TextStyle? titleStyle,
    String? testID,
    String? accessibilityLabel,
    bool? showsLoading,
  }) : props = ButtonProps(
          title: title,
          onPress: onPress,
          disabled: disabled,
          style: style ??
              (styleMap != null ? ButtonStyle.fromMap(styleMap) : null),
          titleStyle: titleStyle,
          testID: testID,
          accessibilityLabel: accessibilityLabel,
          showsLoading: showsLoading,
        );

  Button.custom({required this.props});

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Button',
      props.toMap(),
      [], // Button doesn't have children in the traditional sense
    );
  }
}
