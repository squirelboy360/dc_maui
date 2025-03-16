import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:flutter/services.dart' hide TextInputType;

/// Custom DCTextInputType enum
enum DCTextInputType {
  text,
  number,
  phone,
  emailAddress,
  url,
  visiblePassword,
  none
}

/// Props for DCTextInput component
class DCTextInputProps implements ControlProps {
  final String? value;
  final String? placeholder;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final bool? autoFocus;
  final bool? editable;
  final DCTextInputType? keyboardType;
  final bool? multiline;
  final int? maxLength;
  final bool? secureTextEntry;
  final TextAlign? textAlign;
  final String? testID;
  final Function(String)? onChangeText;
  final Function(String)? onSubmitEditing;
  final Function()? onFocus;
  final Function()? onBlur;
  final Map<String, dynamic> additionalProps;

  const DCTextInputProps({
    this.value,
    this.placeholder,
    this.style,
    this.placeholderStyle,
    this.autoFocus,
    this.editable,
    this.keyboardType,
    this.multiline,
    this.maxLength,
    this.secureTextEntry,
    this.textAlign,
    this.testID,
    this.onChangeText,
    this.onSubmitEditing,
    this.onFocus,
    this.onBlur,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (value != null) map['value'] = value;
    if (placeholder != null) map['placeholder'] = placeholder;
    if (style != null) map['style'] = style!.toMap();
    if (placeholderStyle != null) {
      map['placeholderStyle'] = placeholderStyle!.toMap();
    }
    if (autoFocus != null) map['autoFocus'] = autoFocus;
    if (editable != null) map['editable'] = editable;

    if (keyboardType != null) {
      map['keyboardType'] = _keyboardTypeToString(keyboardType!);
    }

    if (multiline != null) map['multiline'] = multiline;
    if (maxLength != null) map['maxLength'] = maxLength;
    if (secureTextEntry != null) map['secureTextEntry'] = secureTextEntry;

    if (textAlign != null) {
      map['textAlign'] = _textAlignToString(textAlign!);
    }

    if (testID != null) map['testID'] = testID;
    if (onChangeText != null) map['onChangeText'] = onChangeText;
    if (onSubmitEditing != null) map['onSubmitEditing'] = onSubmitEditing;
    if (onFocus != null) map['onFocus'] = onFocus;
    if (onBlur != null) map['onBlur'] = onBlur;

    return map;
  }

  String _keyboardTypeToString(DCTextInputType type) {
    switch (type) {
      case DCTextInputType.number:
        return 'numeric';
      case DCTextInputType.phone:
        return 'phone-pad';
      case DCTextInputType.emailAddress:
        return 'email-address';
      case DCTextInputType.url:
        return 'url';
      case DCTextInputType.visiblePassword:
        return 'visible-password';
      case DCTextInputType.none:
        return 'none';
      default:
        return 'default';
    }
  }

  String _textAlignToString(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return 'left';
      case TextAlign.right:
        return 'right';
      case TextAlign.center:
        return 'center';
      default:
        return 'auto';
    }
  }

  DCTextInputProps copyWith({
    String? value,
    String? placeholder,
    TextStyle? style,
    TextStyle? placeholderStyle,
    bool? autoFocus,
    bool? editable,
    DCTextInputType? keyboardType,
    bool? multiline,
    int? maxLength,
    bool? secureTextEntry,
    TextAlign? textAlign,
    String? testID,
    Function(String)? onChangeText,
    Function(String)? onSubmitEditing,
    Function()? onFocus,
    Function()? onBlur,
    Map<String, dynamic>? additionalProps,
  }) {
    return DCTextInputProps(
      value: value ?? this.value,
      placeholder: placeholder ?? this.placeholder,
      style: style ?? this.style,
      placeholderStyle: placeholderStyle ?? this.placeholderStyle,
      autoFocus: autoFocus ?? this.autoFocus,
      editable: editable ?? this.editable,
      keyboardType: keyboardType ?? this.keyboardType,
      multiline: multiline ?? this.multiline,
      maxLength: maxLength ?? this.maxLength,
      secureTextEntry: secureTextEntry ?? this.secureTextEntry,
      textAlign: textAlign ?? this.textAlign,
      testID: testID ?? this.testID,
      onChangeText: onChangeText ?? this.onChangeText,
      onSubmitEditing: onSubmitEditing ?? this.onSubmitEditing,
      onFocus: onFocus ?? this.onFocus,
      onBlur: onBlur ?? this.onBlur,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// DCTextInput component
class DCTextInput extends Control {
  final DCTextInputProps props;

  DCTextInput({
    String? value,
    String? placeholder,
    TextStyle? style,
    TextStyle? placeholderStyle,
    bool? autoFocus,
    bool? editable,
    DCTextInputType? keyboardType,
    bool? multiline,
    int? maxLength,
    bool? secureTextEntry,
    TextAlign? textAlign,
    String? testID,
    Function(String)? onChangeText,
    Function(String)? onSubmitEditing,
    Function()? onFocus,
    Function()? onBlur,
  }) : props = DCTextInputProps(
          value: value,
          placeholder: placeholder,
          style: style,
          placeholderStyle: placeholderStyle,
          autoFocus: autoFocus,
          editable: editable,
          keyboardType: keyboardType,
          multiline: multiline,
          maxLength: maxLength,
          secureTextEntry: secureTextEntry,
          textAlign: textAlign,
          testID: testID,
          onChangeText: onChangeText,
          onSubmitEditing: onSubmitEditing,
          onFocus: onFocus,
          onBlur: onBlur,
        );

  DCTextInput.custom({required this.props});

  @override
  VNode build() {
    final nodeType = props.multiline == true ? 'TextArea' : 'DCTextInput';

    return ElementFactory.createElement(
      nodeType,
      props.toMap(),
      [], // DCTextInput doesn't have children
    );
  }
}
