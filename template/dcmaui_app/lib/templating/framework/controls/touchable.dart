import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/controls/control.dart';

/// Props for Touchable component
class TouchableProps implements ControlProps {
  final Function()? onPress;
  final Function()? onLongPress;
  final Function(bool)? onPressIn;
  final Function(bool)? onPressOut;
  final bool? disabled;
  final int? delayLongPress;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const TouchableProps({
    this.onPress,
    this.onLongPress,
    this.onPressIn,
    this.onPressOut,
    this.disabled,
    this.delayLongPress,
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
    if (testID != null) map['testID'] = testID;

    return map;
  }

  TouchableProps copyWith({
    Function()? onPress,
    Function()? onLongPress,
    Function(bool)? onPressIn,
    Function(bool)? onPressOut,
    bool? disabled,
    int? delayLongPress,
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
    String? testID,
  }) : props = TouchableProps(
          onPress: onPress,
          onLongPress: onLongPress,
          onPressIn: onPressIn,
          onPressOut: onPressOut,
          disabled: disabled,
          delayLongPress: delayLongPress,
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
