import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';

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
    Function(Map<String, dynamic>)? onPanEnd,
    Function(Map<String, dynamic>)? onPinch,
    Function(double)? onPinchStart,
    Function(double)? onPinchUpdate,
    Function(double)? onPinchEnd,
    Function(double)? onRotate,
    bool? enabled,
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
