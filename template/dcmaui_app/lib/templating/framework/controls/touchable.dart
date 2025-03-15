import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'dart:io' show Platform;

/// Style properties for Touchable
class TouchableStyle implements StyleProps {
  final Color? highlightColor;
  final Color? rippleColor;
  final EdgeInsets? hitSlop;
  final bool? useForeground;
  final double? pressedOpacity;
  final Duration? pressedDuration;

  const TouchableStyle({
    this.highlightColor,
    this.rippleColor,
    this.hitSlop,
    this.useForeground,
    this.pressedOpacity,
    this.pressedDuration,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (highlightColor != null) {
      final colorValue =
          highlightColor!.value.toRadixString(16).padLeft(8, '0');
      map['highlightColor'] = '#$colorValue';
    }

    if (rippleColor != null) {
      final colorValue = rippleColor!.value.toRadixString(16).padLeft(8, '0');
      map['rippleColor'] = '#$colorValue';
    }

    if (hitSlop != null) {
      map['hitSlopTop'] = hitSlop!.top;
      map['hitSlopBottom'] = hitSlop!.bottom;
      map['hitSlopLeft'] = hitSlop!.left;
      map['hitSlopRight'] = hitSlop!.right;
    }

    if (useForeground != null) map['useForeground'] = useForeground;
    if (pressedOpacity != null) map['pressedOpacity'] = pressedOpacity;

    if (pressedDuration != null) {
      map['pressedDuration'] = pressedDuration!.inMilliseconds;
    }

    return map;
  }

  factory TouchableStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return TouchableStyle(
      highlightColor: map['highlightColor'] is Color
          ? map['highlightColor']
          : hexToColor(map['highlightColor']),
      rippleColor: map['rippleColor'] is Color
          ? map['rippleColor']
          : hexToColor(map['rippleColor']),
      hitSlop: map.containsKey('hitSlopTop') ||
              map.containsKey('hitSlopBottom') ||
              map.containsKey('hitSlopLeft') ||
              map.containsKey('hitSlopRight')
          ? EdgeInsets.only(
              top: map['hitSlopTop'] ?? 0.0,
              bottom: map['hitSlopBottom'] ?? 0.0,
              left: map['hitSlopLeft'] ?? 0.0,
              right: map['hitSlopRight'] ?? 0.0,
            )
          : null,
      useForeground: map['useForeground'],
      pressedOpacity:
          map['pressedOpacity'] is double ? map['pressedOpacity'] : null,
      pressedDuration: map['pressedDuration'] != null
          ? Duration(milliseconds: map['pressedDuration'])
          : null,
    );
  }

  TouchableStyle copyWith({
    Color? highlightColor,
    Color? rippleColor,
    EdgeInsets? hitSlop,
    bool? useForeground,
    double? pressedOpacity,
    Duration? pressedDuration,
  }) {
    return TouchableStyle(
      highlightColor: highlightColor ?? this.highlightColor,
      rippleColor: rippleColor ?? this.rippleColor,
      hitSlop: hitSlop ?? this.hitSlop,
      useForeground: useForeground ?? this.useForeground,
      pressedOpacity: pressedOpacity ?? this.pressedOpacity,
      pressedDuration: pressedDuration ?? this.pressedDuration,
    );
  }
}

/// Props for Touchable component
class TouchableProps implements ControlProps {
  final Function()? onPress;
  final Function()? onLongPress;
  final Function(bool)? onPressIn;
  final Function(bool)? onPressOut;
  final bool? disabled;
  final int? delayLongPress;
  final TouchableStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const TouchableProps({
    this.onPress,
    this.onLongPress,
    this.onPressIn,
    this.onPressOut,
    this.disabled,
    this.delayLongPress,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (onPress != null) map['onPress'] = onPress;
    if (onLongPress != null) map['onLongPress'] = onLongPress;
    if (onPressIn != null) map['onPressIn'] = onPressIn;
    if (onPressOut != null) map['onPressOut'] = onPressOut;
    if (disabled != null) map['disabled'] = disabled;
    if (delayLongPress != null) map['delayLongPress'] = delayLongPress;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    // Add platform-specific props and defaults
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific styling
      if (!map.containsKey('cursor') &&
          !additionalProps.containsKey('cursor')) {
        map['cursor'] = 'pointer';
      }
      if (style?.highlightColor == null && !map.containsKey('highlightColor')) {
        map['highlightColor'] = 'rgba(0, 0, 0, 0.1)'; // CSS format for web
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific defaults
      if (style?.pressedOpacity == null && !map.containsKey('pressedOpacity')) {
        map['pressedOpacity'] = 0.2; // iOS standard touch opacity
      }
      if (style?.pressedDuration == null &&
          !map.containsKey('pressedDuration')) {
        map['pressedDuration'] = 100; // Faster animation for iOS
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific defaults
      if (style?.useForeground == null && !map.containsKey('useForeground')) {
        map['useForeground'] = true; // Android ripple foreground
      }
      if (style?.rippleColor == null && !map.containsKey('rippleColor')) {
        map['rippleColor'] = '#20000000'; // Semi-transparent black ripple
      }
      if (style?.pressedDuration == null &&
          !map.containsKey('pressedDuration')) {
        map['pressedDuration'] = 300; // Standard Material Design duration
      }
    }

    return map;
  }

  TouchableProps copyWith({
    Function()? onPress,
    Function()? onLongPress,
    Function(bool)? onPressIn,
    Function(bool)? onPressOut,
    bool? disabled,
    int? delayLongPress,
    TouchableStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return TouchableProps(
      onPress: onPress ?? this.onPress,
      onLongPress: onLongPress ?? this.onLongPress,
      onPressIn: onPressIn ?? this.onPressIn,
      onPressOut: onPressOut ?? this.onPressOut,
      disabled: disabled ?? this.disabled,
      delayLongPress: delayLongPress ?? this.delayLongPress,
      style: style ?? this.style,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Touchable component
class Touchable extends Control {
  final TouchableProps props;
  final Control child;

  Touchable({
    required this.child,
    Function()? onPress,
    Function()? onLongPress,
    Function(bool)? onPressIn,
    Function(bool)? onPressOut,
    bool? disabled,
    int? delayLongPress,
    TouchableStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
  }) : props = TouchableProps(
          onPress: onPress,
          onLongPress: onLongPress,
          onPressIn: onPressIn,
          onPressOut: onPressOut,
          disabled: disabled,
          delayLongPress: delayLongPress,
          style: style ??
              (styleMap != null ? TouchableStyle.fromMap(styleMap) : null),
          testID: testID,
        );

  Touchable.custom({
    required this.child,
    required this.props,
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Touchable',
      props.toMap(),
      [child.build()],
    );
  }
}
