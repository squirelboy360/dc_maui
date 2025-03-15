import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'dart:io' show Platform;

/// Style properties for Switch
class SwitchStyle implements StyleProps {
  final Color? trackColor;
  final Color? thumbColor;
  final Color? activeTrackColor;
  final Color? activeThumbColor;
  final EdgeInsets? margin;
  final double? scale;

  const SwitchStyle({
    this.trackColor,
    this.thumbColor,
    this.activeTrackColor,
    this.activeThumbColor,
    this.margin,
    this.scale,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (trackColor != null) {
      final colorValue = trackColor!.value.toRadixString(16).padLeft(8, '0');
      map['trackColor'] = '#$colorValue';
    }

    if (thumbColor != null) {
      final colorValue = thumbColor!.value.toRadixString(16).padLeft(8, '0');
      map['thumbColor'] = '#$colorValue';
    }

    if (activeTrackColor != null) {
      final colorValue =
          activeTrackColor!.value.toRadixString(16).padLeft(8, '0');
      map['activeTrackColor'] = '#$colorValue';
    }

    if (activeThumbColor != null) {
      final colorValue =
          activeThumbColor!.value.toRadixString(16).padLeft(8, '0');
      map['activeThumbColor'] = '#$colorValue';
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

    if (scale != null) map['scale'] = scale;

    return map;
  }

  /// Factory to convert a Map to a SwitchStyle
  factory SwitchStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return SwitchStyle(
      trackColor: map['trackColor'] is Color
          ? map['trackColor']
          : hexToColor(map['trackColor']),
      thumbColor: map['thumbColor'] is Color
          ? map['thumbColor']
          : hexToColor(map['thumbColor']),
      activeTrackColor: map['activeTrackColor'] is Color
          ? map['activeTrackColor']
          : hexToColor(map['activeTrackColor']),
      activeThumbColor: map['activeThumbColor'] is Color
          ? map['activeThumbColor']
          : hexToColor(map['activeThumbColor']),
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
      scale: map['scale'] is double ? map['scale'] : null,
    );
  }

  SwitchStyle copyWith({
    Color? trackColor,
    Color? thumbColor,
    Color? activeTrackColor,
    Color? activeThumbColor,
    EdgeInsets? margin,
    double? scale,
  }) {
    return SwitchStyle(
      trackColor: trackColor ?? this.trackColor,
      thumbColor: thumbColor ?? this.thumbColor,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      activeThumbColor: activeThumbColor ?? this.activeThumbColor,
      margin: margin ?? this.margin,
      scale: scale ?? this.scale,
    );
  }
}

/// Props for Switch component
class SwitchProps implements ControlProps {
  final bool value;
  final Function(bool)? onValueChange;
  final bool? disabled;
  final SwitchStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const SwitchProps({
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
      // iOS switches have a different appearance
      if (style?.activeTrackColor == null &&
          !map.containsKey('activeTrackColor')) {
        map['activeTrackColor'] = '#34C759'; // iOS green color
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android Material design styling
      if (style?.activeTrackColor == null &&
          !map.containsKey('activeTrackColor')) {
        map['activeTrackColor'] = '#009688'; // Material teal
      }
      if (style?.thumbColor == null && !map.containsKey('thumbColor')) {
        map['thumbColor'] = '#FFFFFF'; // White thumb
      }
    }

    return map;
  }

  SwitchProps copyWith({
    bool? value,
    Function(bool)? onValueChange,
    bool? disabled,
    SwitchStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return SwitchProps(
      value: value ?? this.value,
      onValueChange: onValueChange ?? this.onValueChange,
      disabled: disabled ?? this.disabled,
      style: style ?? this.style,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Switch component - Toggle switch control
class Switch extends Control {
  final SwitchProps props;

  Switch({
    required bool value,
    Function(bool)? onValueChange,
    Color? trackColor,
    Color? thumbColor,
    Color? activeTrackColor,
    Color? activeThumbColor,
    bool? disabled,
    SwitchStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
  }) : props = SwitchProps(
          value: value,
          onValueChange: onValueChange,
          disabled: disabled,
          style: style ??
              (trackColor != null ||
                      thumbColor != null ||
                      activeTrackColor != null ||
                      activeThumbColor != null
                  ? SwitchStyle(
                      trackColor: trackColor,
                      thumbColor: thumbColor,
                      activeTrackColor: activeTrackColor,
                      activeThumbColor: activeThumbColor,
                    )
                  : styleMap != null
                      ? SwitchStyle.fromMap(styleMap)
                      : null),
          testID: testID,
        );

  Switch.custom({required this.props});

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Switch',
      props.toMap(),
      [], // Switch doesn't have children
    );
  }
}
