import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/painting.dart';

/// Props for Checkbox component
class CheckboxProps implements ControlProps {
  final bool value;
  final Function(bool)? onValueChange;
  final Color? tintColor;
  final Color? checkedColor;
  final bool? disabled;
  final Map<String, dynamic>? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const CheckboxProps({
    required this.value,
    this.onValueChange,
    this.tintColor,
    this.checkedColor,
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

    if (tintColor != null) {
      final colorValue = tintColor!.value.toRadixString(16).padLeft(8, '0');
      map['tintColor'] = '#$colorValue';
    }

    if (checkedColor != null) {
      final colorValue = checkedColor!.value.toRadixString(16).padLeft(8, '0');
      map['checkedColor'] = '#$colorValue';
    }

    if (disabled != null) map['disabled'] = disabled;
    if (style != null) map['style'] = style;
    if (testID != null) map['testID'] = testID;

    return map;
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
    Map<String, dynamic>? style,
    String? testID,
  }) : props = CheckboxProps(
          value: value,
          onValueChange: onValueChange,
          tintColor: tintColor,
          checkedColor: checkedColor,
          disabled: disabled,
          style: style,
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
