import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/painting.dart';

/// Props for Switch component
class SwitchProps implements ControlProps {
  final bool value;
  final Function(bool)? onValueChange;
  final Color? trackColor;
  final Color? thumbColor;
  final Color? activeTrackColor;
  final Color? activeThumbColor;
  final bool? disabled;
  final Map<String, dynamic>? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const SwitchProps({
    required this.value,
    this.onValueChange,
    this.trackColor,
    this.thumbColor,
    this.activeTrackColor,
    this.activeThumbColor,
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

    if (disabled != null) map['disabled'] = disabled;
    if (style != null) map['style'] = style;
    if (testID != null) map['testID'] = testID;

    return map;
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
    Map<String, dynamic>? style,
    String? testID,
  }) : props = SwitchProps(
          value: value,
          onValueChange: onValueChange,
          trackColor: trackColor,
          thumbColor: thumbColor,
          activeTrackColor: activeTrackColor,
          activeThumbColor: activeThumbColor,
          disabled: disabled,
          style: style,
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
