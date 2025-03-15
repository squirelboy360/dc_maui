import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Style properties for GestureDetector
class GestureDetectorStyle implements StyleProps {
  final Color? rippleColor; // Android specific
  final Color? highlightColor;
  final EdgeInsets? hitSlop;
  final bool? cancelOnHorizontalDrag;
  final double? pressedOpacity; // iOS specific

  const GestureDetectorStyle({
    this.rippleColor,
    this.highlightColor,
    this.hitSlop,
    this.cancelOnHorizontalDrag,
    this.pressedOpacity,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (rippleColor != null) {
      final colorValue = rippleColor!.value.toRadixString(16).padLeft(8, '0');
      map['rippleColor'] = '#$colorValue';
    }

    if (highlightColor != null) {
      final colorValue = highlightColor!.value.toRadixString(16).padLeft(8, '0');
      map['highlightColor'] = '#$colorValue';
    }

    if (hitSlop != null) {
      map['hitSlopTop'] = hitSlop!.top;
      map['hitSlopBottom'] = hitSlop!.bottom;
      map['hitSlopLeft'] = hitSlop!.left;
      map['hitSlopRight'] = hitSlop!.right;
    }

    if (cancelOnHorizontalDrag != null) {
      map['cancelOnHorizontalDrag'] = cancelOnHorizontalDrag;
    }

    if (pressedOpacity != null) {
      map['pressedOpacity'] = pressedOpacity;
    }

    return map;
  }

  factory GestureDetectorStyle.fromMap(Map<String, dynamic> map) {
    // Helper to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return GestureDetectorStyle(
      rippleColor: map['rippleColor'] is Color
          ? map['rippleColor']
          : hexToColor(map['rippleColor']),
      highlightColor: map['highlightColor'] is Color
          ? map['highlightColor']
          : hexToColor(map['highlightColor']),
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
      cancelOnHorizontalDrag: map['cancelOnHorizontalDrag'],
      pressedOpacity: map['pressedOpacity'] is double ? map['pressedOpacity'] : null,
    );
  }

  GestureDetectorStyle copyWith({
    Color? rippleColor,
    Color? highlightColor,
    EdgeInsets? hitSlop,
    bool? cancelOnHorizontalDrag,
    double? pressedOpacity,
  }) {
    return GestureDetectorStyle(
      rippleColor: rippleColor ?? this.rippleColor,
      highlightColor: highlightColor ?? this.highlightColor,
      hitSlop: hitSlop ?? this.hitSlop,
      cancelOnHorizontalDrag: cancelOnHorizontalDrag ?? this.cancelOnHorizontalDrag,
      pressedOpacity: pressedOpacity ?? this.pressedOpacity,
    );
  }
}

/// Props for GestureDetector control
class GestureDetectorProps implements ControlProps {
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function(Map<String, dynamic>)? onPan;
  final Function(Map<String, dynamic>)? onPanStart;
  final Function(Map<String, dynamic>)? onPanUpdate;
  final Function(Map<String, dynamic>)? onPanEnd;
  final Function(Map<String, dynamic>)? onPinch;
  final Function(double)? onPinchStart;
  final Function(double)? onPinchUpdate;
  final Function(double)? onPinchEnd;
  final Function(double)? onRotate;
  final bool? enabled;
  final String? testID;
  final GestureDetectorStyle? style;
  final Map<String, dynamic> additionalProps;

  const GestureDetectorProps({
    this.onTap,
    this.onDoubleTap,
    this.onPan,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPinch,
    this.onPinchStart,
    this.onPinchUpdate,
    this.onPinchEnd,
    this.onRotate,
    this.enabled,
    this.testID,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (onTap != null) map['onTap'] = onTap;
    if (onDoubleTap != null) map['onDoubleTap'] = onDoubleTap;
    if (onPan != null) map['onPan'] = onPan;
    if (onPanStart != null) map['onPanStart'] = onPanStart;
    if (onPanUpdate != null) map['onPanUpdate'] = onPanUpdate;
    if (onPanEnd != null) map['onPanEnd'] = onPanEnd;
    if (onPinch != null) map['onPinch'] = onPinch;
    if (onPinchStart != null) map['onPinchStart'] = onPinchStart;
    if (onPinchUpdate != null) map['onPinchUpdate'] = onPinchUpdate;
    if (onPinchEnd != null) map['onPinchEnd'] = onPinchEnd;
    if (onRotate != null) map['onRotate'] = onRotate;
    if (enabled != null) map['enabled'] = enabled;
    if (testID != null) map['testID'] = testID;
    if (style != null) map['style'] = style!.toMap();

    // Add platform-specific properties
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific gesture handling
      if (onTap != null && !map.containsKey('cursor')) {
        map['cursor'] = 'pointer';
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific gesture handling
      if (style?.pressedOpacity == null && onTap != null && !map.containsKey('pressedOpacity')) {
        map['pressedOpacity'] = 0.2; // Standard iOS touch feedback
      }
      if (!map.containsKey('delaysContentTouches')) {
        map['delaysContentTouches'] = true; // iOS behavior
      }
      if (!map.containsKey('cancelsTouchesInView') && onPan != null) {
        map['cancelsTouchesInView'] = true; // iOS gesture behavior
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific gesture handling
      if (style?.rippleColor == null && onTap != null && !map.containsKey('rippleColor')) {
        map['rippleColor'] = '#20000000'; // Standard Android ripple
      }
      if (!map.containsKey('useForeground') && onTap != null) {
        map['useForeground'] = true; // Android ripple foreground
      }
    }

    return map;
  }

  GestureDetectorProps copyWith({
    Function()? onTap,
    Function()? onDoubleTap,
    Function(Map<String, dynamic>)? onPan,
    Function(Map<String, dynamic>)? onPanStart,
    Function(Map<String, dynamic>)? onPanUpdate,
    Function(Map<String, dynamic>)? onPanEnd,
    Function(Map<String, dynamic>)? onPinch,
    Function(double)? onPinchStart,
    Function(double)? onPinchUpdate,
    Function(double)? onPinchEnd,
    Function(double)? onRotate,
    bool? enabled,
    String? testID,
    GestureDetectorStyle? style,
    Map<String, dynamic>? additionalProps,
  }) {
    return GestureDetectorProps(
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onPan: onPan ?? this.onPan,
      onPanStart: onPanStart ?? this.onPanStart,
      onPanUpdate: onPanUpdate ?? this.onPanUpdate,
      onPanEnd: onPanEnd ?? this.onPanEnd,
      onPinch: onPinch ?? this.onPinch,
      onPinchStart: onPinchStart ?? this.onPinchStart,
      onPinchUpdate: onPinchUpdate ?? this.onPinchUpdate,
      onPinchEnd: onPinchEnd ?? this.onPinchEnd,
      onRotate: onRotate ?? this.onRotate,
      enabled: enabled ?? this.enabled,
      testID: testID ?? this.testID,
      style: style ?? this.style,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// GestureDetector control
class GestureDetector extends Control {
  final GestureDetectorProps props;
  final Control child;

  GestureDetector({
    required this.child,
    Function()? onTap,
    Function()? onDoubleTap,
    Function(Map<String, dynamic>)? onPan,
    Function(Map<String, dynamic>)? onPanStart,
    Function(Map<String, dynamic>)? onPanUpdate,
    Function(Map<String, dynamic>))? onPanEnd,
    Function(Map<String, dynamic>)? onPinch,
    Function(double)? onPinchStart,
    Function(double)? onPinchUpdate,
    Function(double)? onPinchEnd,
    Function(double)? onRotate,
    bool? enabled,
    GestureDetectorStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
  }) : props = GestureDetectorProps(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onPan: onPan,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          onPinch: onPinch,
          onPinchStart: onPinchStart,
          onPinchUpdate: onPinchUpdate,
          onPinchEnd: onPinchEnd,
          onRotate: onRotate,
          enabled: enabled,
          style: style ?? (styleMap != null ? GestureDetectorStyle.fromMap(styleMap) : null),
          testID: testID,
        );

  GestureDetector.custom({
    required this.child,
    required this.props,
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'GestureDetector',
      props.toMap(),
      [child.build()],
    );
  }
}
