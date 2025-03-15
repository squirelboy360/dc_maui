import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'dart:io' show Platform;

/// Style properties for Checkbox
class CheckboxStyle implements StyleProps {
  final Color? tintColor;
  final Color? checkedColor;
  final double? size;
  final double? borderWidth;
  final EdgeInsets? margin;
  final double? borderRadius;

  const CheckboxStyle({
    this.tintColor,
    this.checkedColor,
    this.size,
    this.borderWidth,
    this.margin,
    this.borderRadius,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (tintColor != null) {
      final colorValue = tintColor!.value.toRadixString(16).padLeft(8, '0');
      map['tintColor'] = '#$colorValue';
    }

    if (checkedColor != null) {
      final colorValue = checkedColor!.value.toRadixString(16).padLeft(8, '0');
      map['checkedColor'] = '#$colorValue';
    }

    if (size != null) map['size'] = size;
    if (borderWidth != null) map['borderWidth'] = borderWidth;
    if (borderRadius != null) map['borderRadius'] = borderRadius;

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

    return map;
  }

  /// Factory to convert a Map to a CheckboxStyle
  factory CheckboxStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return CheckboxStyle(
      tintColor: map['tintColor'] is Color
          ? map['tintColor']
          : hexToColor(map['tintColor']),
      checkedColor: map['checkedColor'] is Color
          ? map['checkedColor']
          : hexToColor(map['checkedColor']),
      size: map['size'] is double ? map['size'] : null,
      borderWidth: map['borderWidth'] is double ? map['borderWidth'] : null,
      borderRadius: map['borderRadius'] is double ? map['borderRadius'] : null,
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
    );
  }

  CheckboxStyle copyWith({
    Color? tintColor,
    Color? checkedColor,
    double? size,
    double? borderWidth,
    EdgeInsets? margin,
    double? borderRadius,
  }) {
    return CheckboxStyle(
      tintColor: tintColor ?? this.tintColor,
      checkedColor: checkedColor ?? this.checkedColor,
      size: size ?? this.size,
      borderWidth: borderWidth ?? this.borderWidth,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

/// Props for Checkbox component
class CheckboxProps implements ControlProps {
  final bool value;
  final Function(bool)? onValueChange;
  final bool? disabled;
  final CheckboxStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const CheckboxProps({
    required this.value,
    this.onValueChange,
    this.disabled,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'value': value,
      ...additionalProps,
    };

    if (onValueChange != null) map['onValueChange'] = onValueChange;
    if (disabled != null) map['disabled'] = disabled;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    // Add platform-specific props and defaults
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific styling
      if (!map.containsKey('cursor')) {
        map['cursor'] = 'pointer';
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS checkboxes are actually custom-styled UIButtons
      if (style?.checkedColor == null && !map.containsKey('checkedColor')) {
        map['checkedColor'] = '#007AFF'; // iOS blue
      }
      if (style?.borderRadius == null && !map.containsKey('borderRadius')) {
        map['borderRadius'] = 4.0; // More rounded for iOS
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android Material design styling
      if (style?.checkedColor == null && !map.containsKey('checkedColor')) {
        map['checkedColor'] = '#009688'; // Material teal
      }
      if (style?.borderRadius == null && !map.containsKey('borderRadius')) {
        map['borderRadius'] = 2.0; // Less rounded for Android
      }
    }

    return map;
  }

  CheckboxProps copyWith({
    bool? value,
    Function(bool)? onValueChange,
    bool? disabled,
    CheckboxStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return CheckboxProps(
      value: value ?? this.value,
      onValueChange: onValueChange ?? this.onValueChange,
      disabled: disabled ?? this.disabled,
      style: style ?? this.style,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Checkbox component
class Checkbox extends Control {
  final CheckboxProps props;

  Checkbox({
    required bool value,
    Function(bool)? onValueChange,
    Color? tintColor,
    Color? checkedColor,
    bool? disabled,
    CheckboxStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
  }) : props = CheckboxProps(
          value: value,
          onValueChange: onValueChange,
          disabled: disabled,
          style: style ??
              (tintColor != null || checkedColor != null
                  ? CheckboxStyle(
                      tintColor: tintColor,
                      checkedColor: checkedColor,
                    )
                  : styleMap != null
                      ? CheckboxStyle.fromMap(styleMap)
                      : null),
          testID: testID,
        );

  Checkbox.custom({required this.props});

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Checkbox',
      props.toMap(),
      [], // Checkbox doesn't have children
    );
  }
}
