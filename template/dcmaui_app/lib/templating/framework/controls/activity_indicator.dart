import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'dart:io' show Platform;

/// Style properties for ActivityIndicator
class ActivityIndicatorStyle implements StyleProps {
  final Color? color;
  final double? size;
  final EdgeInsets? margin;
  final bool? hidesWhenStopped;

  const ActivityIndicatorStyle({
    this.color,
    this.size,
    this.margin,
    this.hidesWhenStopped,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (size != null) map['size'] = size;

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

    if (hidesWhenStopped != null) map['hidesWhenStopped'] = hidesWhenStopped;

    return map;
  }

  /// Factory to convert a Map to a ActivityIndicatorStyle
  factory ActivityIndicatorStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return ActivityIndicatorStyle(
      color: map['color'] is Color ? map['color'] : hexToColor(map['color']),
      size: map['size'] is double ? map['size'] : null,
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
      hidesWhenStopped:
          map['hidesWhenStopped'] is bool ? map['hidesWhenStopped'] : null,
    );
  }

  ActivityIndicatorStyle copyWith({
    Color? color,
    double? size,
    EdgeInsets? margin,
    bool? hidesWhenStopped,
  }) {
    return ActivityIndicatorStyle(
      color: color ?? this.color,
      size: size ?? this.size,
      margin: margin ?? this.margin,
      hidesWhenStopped: hidesWhenStopped ?? this.hidesWhenStopped,
    );
  }
}

/// Props for ActivityIndicator
class ActivityIndicatorProps implements ControlProps {
  final bool? animating;
  final String? type;
  final String? testID;
  final ActivityIndicatorStyle? style;
  final Map<String, dynamic> additionalProps;

  const ActivityIndicatorProps({
    this.animating,
    this.type,
    this.testID,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (animating != null) map['animating'] = animating;
    if (type != null) map['type'] = type;
    if (testID != null) map['testID'] = testID;
    if (style != null) map['style'] = style!.toMap();

    // Add platform-specific props and defaults
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific indicator properties
      if (!map.containsKey('type') && !additionalProps.containsKey('type')) {
        map['type'] = 'border'; // CSS border spinner is common on web
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific indicator properties
      if (!map.containsKey('hidesWhenStopped') &&
          !additionalProps.containsKey('hidesWhenStopped') &&
          style?.hidesWhenStopped == null) {
        map['hidesWhenStopped'] = true; // iOS standard behavior
      }

      if (!map.containsKey('type') && !additionalProps.containsKey('type')) {
        map['type'] = 'medium'; // Default iOS size
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific indicator properties
      if (!map.containsKey('type') && !additionalProps.containsKey('type')) {
        map['type'] = 'normal'; // Default Android size
      }

      // For Android Material Design, set default color if not provided
      if (style?.color == null && !map.containsKey('color')) {
        map['color'] = '#6200EE'; // Default primary color for Material
      }
    }

    return map;
  }

  ActivityIndicatorProps copyWith({
    bool? animating,
    String? type,
    String? testID,
    ActivityIndicatorStyle? style,
    Map<String, dynamic>? additionalProps,
  }) {
    return ActivityIndicatorProps(
      animating: animating ?? this.animating,
      type: type ?? this.type,
      testID: testID ?? this.testID,
      style: style ?? this.style,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// ActivityIndicator (loading spinner) control
class ActivityIndicator extends Control {
  final ActivityIndicatorProps props;

  ActivityIndicator({
    bool? animating = true,
    String? type,
    String? testID,
    Color? color,
    double? size,
    ActivityIndicatorStyle? style,
    Map<String, dynamic>? styleMap,
  }) : props = ActivityIndicatorProps(
          animating: animating,
          type: type,
          testID: testID,
          style: style ??
              (color != null || size != null
                  ? ActivityIndicatorStyle(color: color, size: size)
                  : styleMap != null
                      ? ActivityIndicatorStyle.fromMap(styleMap)
                      : null),
        );

  ActivityIndicator.custom({required this.props});

  /// Create a large activity indicator
  static ActivityIndicator large({
    bool? animating = true,
    Color? color,
    String? testID,
    ActivityIndicatorStyle? style,
    Map<String, dynamic>? styleMap,
  }) {
    return ActivityIndicator(
      animating: animating,
      type: 'large',
      color: color,
      testID: testID,
      style: style,
      styleMap: styleMap,
    );
  }

  /// Create a small activity indicator
  static ActivityIndicator small({
    bool? animating = true,
    Color? color,
    String? testID,
    ActivityIndicatorStyle? style,
    Map<String, dynamic>? styleMap,
  }) {
    return ActivityIndicator(
      animating: animating,
      type: 'small',
      color: color,
      testID: testID,
      style: style,
      styleMap: styleMap,
    );
  }

  @override
  VNode build() {
    return ElementFactory.createElement(
      'ActivityIndicator',
      props.toMap(),
      [], // ActivityIndicator doesn't have children
    );
  }
}
