import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/painting.dart' hide TextStyle;
import 'package:dc_test/templating/framework/controls/text.dart';

/// Props for Button control
class ButtonProps implements ControlProps {
  final String? title;
  final Function(Map<String, dynamic>)? onPress;
  final bool? disabled;
  final Color? color;
  final TextStyle? titleStyle;
  final Map<String, dynamic>? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const ButtonProps({
    this.title,
    this.onPress,
    this.disabled,
    this.color,
    this.titleStyle,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (title != null) map['title'] = title;
    if (onPress != null) map['onPress'] = onPress;
    if (disabled != null) map['disabled'] = disabled;

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (titleStyle != null) map['titleStyle'] = titleStyle?.toMap();
    if (style != null) map['style'] = style;
    if (testID != null) map['testID'] = testID;

    return map;
  }

  ButtonProps copyWith({
    String? title,
    Function(Map<String, dynamic>)? onPress,
    bool? disabled,
    Color? color,
    TextStyle? titleStyle,
    Map<String, dynamic>? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return ButtonProps(
      title: title ?? this.title,
      onPress: onPress ?? this.onPress,
      disabled: disabled ?? this.disabled,
      color: color ?? this.color,
      titleStyle: titleStyle ?? this.titleStyle,
      style: style ?? this.style,
      testID: testID ?? this.testID,
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
    Color? color,
    TextStyle? titleStyle,
    Map<String, dynamic>? style,
    String? testID,
  }) : props = ButtonProps(
          title: title,
          onPress: onPress,
          disabled: disabled,
          color: color,
          titleStyle: titleStyle,
          style: style,
          testID: testID,
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
