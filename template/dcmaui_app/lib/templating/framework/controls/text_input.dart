import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:flutter/material.dart' hide TextStyle,TextInputType;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Custom TextInputType enum
enum TextInputType {
  text,
  number,
  phone,
  emailAddress,
  url,
  visiblePassword,
  none
}

/// Style properties for TextInput
class TextInputStyle implements StyleProps {
  final TextStyle? textStyle;
  final TextStyle? placeholderStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;

  const TextInputStyle({
    this.textStyle,
    this.placeholderStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.margin,
    this.height,
    this.width,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (textStyle != null) map['textStyle'] = textStyle!.toMap();
    if (placeholderStyle != null)
      map['placeholderStyle'] = placeholderStyle!.toMap();

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (borderColor != null) {
      final colorValue = borderColor!.value.toRadixString(16).padLeft(8, '0');
      map['borderColor'] = '#$colorValue';
    }

    if (borderWidth != null) map['borderWidth'] = borderWidth;
    if (borderRadius != null) map['borderRadius'] = borderRadius;

    if (padding != null) {
      if (padding!.left == padding!.right &&
          padding!.top == padding!.bottom &&
          padding!.left == padding!.top) {
        map['padding'] = padding!.top;
      } else {
        map['paddingLeft'] = padding!.left;
        map['paddingRight'] = padding!.right;
        map['paddingTop'] = padding!.top;
        map['paddingBottom'] = padding!.bottom;
      }
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

    if (height != null) map['height'] = height;
    if (width != null) map['width'] = width;

    return map;
  }

  factory TextInputStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return TextInputStyle(
      textStyle:
          map['textStyle'] is Map ? TextStyle.fromMap(map['textStyle']) : null,
      placeholderStyle: map['placeholderStyle'] is Map
          ? TextStyle.fromMap(map['placeholderStyle'])
          : null,
      backgroundColor: map['backgroundColor'] is Color
          ? map['backgroundColor']
          : hexToColor(map['backgroundColor']),
      borderColor: map['borderColor'] is Color
          ? map['borderColor']
          : hexToColor(map['borderColor']),
      borderWidth: map['borderWidth'] is double ? map['borderWidth'] : null,
      borderRadius: map['borderRadius'] is double ? map['borderRadius'] : null,
      padding: map['padding'] is EdgeInsets
          ? map['padding']
          : map['padding'] is double
              ? EdgeInsets.all(map['padding'])
              : null,
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
      height: map['height'] is double ? map['height'] : null,
      width: map['width'] is double ? map['width'] : null,
    );
  }

  TextInputStyle copyWith({
    TextStyle? textStyle,
    TextStyle? placeholderStyle,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? height,
    double? width,
  }) {
    return TextInputStyle(
      textStyle: textStyle ?? this.textStyle,
      placeholderStyle: placeholderStyle ?? this.placeholderStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }
}

/// Props for TextInput component
class TextInputProps implements ControlProps {
  final String? value;
  final String? placeholder;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final bool? autoFocus;
  final bool? editable;
  final TextInputType? keyboardType;
  final bool? multiline;
  final int? maxLength;
  final bool? secureTextEntry;
  final TextAlign? textAlign;
  final String? testID;
  final Function(String)? onChangeText;
  final Function(String)? onSubmitEditing;
  final Function()? onFocus;
  final Function()? onBlur;
  final TextInputStyle? inputStyle;
  final Map<String, dynamic> additionalProps;

  const TextInputProps({
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
    this.inputStyle,
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
    if (inputStyle != null) map['inputStyle'] = inputStyle!.toMap();

    // Add platform-specific props
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific input properties
      if (!map.containsKey('autoComplete') &&
          !additionalProps.containsKey('autoComplete')) {
        map['autoComplete'] = 'on'; // Default autocomplete behavior
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific input properties
      if (!map.containsKey('clearButtonMode') &&
          !additionalProps.containsKey('clearButtonMode')) {
        map['clearButtonMode'] =
            'while-editing'; // iOS default clear button behavior
      }
      if (!map.containsKey('returnKeyType') &&
          !additionalProps.containsKey('returnKeyType')) {
        map['returnKeyType'] = 'done'; // Default return key type
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific input properties
      if (!map.containsKey('underlineColorAndroid') &&
          !additionalProps.containsKey('underlineColorAndroid')) {
        map['underlineColorAndroid'] = 'transparent'; // Hide default underline
      }
      if (!map.containsKey('numberOfLines') && multiline == true) {
        map['numberOfLines'] = 4; // Default number of lines for multiline
      }
    }

    return map;
  }

  String _keyboardTypeToString(TextInputType type) {
    switch (type) {
      case TextInputType.number:
        return 'numeric';
      case TextInputType.phone:
        return 'phone-pad';
      case TextInputType.emailAddress:
        return 'email-address';
      case TextInputType.url:
        return 'url';
      case TextInputType.visiblePassword:
        return 'visible-password';
      case TextInputType.none:
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

  TextInputProps copyWith({
    String? value,
    String? placeholder,
    TextStyle? style,
    TextStyle? placeholderStyle,
    bool? autoFocus,
    bool? editable,
    TextInputType? keyboardType,
    bool? multiline,
    int? maxLength,
    bool? secureTextEntry,
    TextAlign? textAlign,
    String? testID,
    Function(String)? onChangeText,
    Function(String)? onSubmitEditing,
    Function()? onFocus,
    Function()? onBlur,
    TextInputStyle? inputStyle,
    Map<String, dynamic>? additionalProps,
  }) {
    return TextInputProps(
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
      inputStyle: inputStyle ?? this.inputStyle,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// TextInput component
class TextInput extends Control {
  final TextInputProps props;

  TextInput({
    String? value,
    String? placeholder,
    TextStyle? style,
    TextStyle? placeholderStyle,
    bool? autoFocus,
    bool? editable,
    TextInputType? keyboardType,
    bool? multiline,
    int? maxLength,
    bool? secureTextEntry,
    TextAlign? textAlign,
    String? testID,
    Function(String)? onChangeText,
    Function(String)? onSubmitEditing,
    Function()? onFocus,
    Function()? onBlur,
    TextInputStyle? inputStyle,
    Map<String, dynamic>? styleMap,
  }) : props = TextInputProps(
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
          inputStyle: inputStyle ??
              (styleMap != null ? TextInputStyle.fromMap(styleMap) : null),
        );

  TextInput.custom({required this.props});

  /// Create a multiline text input
  static TextInput multiline({
    String? value,
    String? placeholder,
    TextStyle? style,
    TextStyle? placeholderStyle,
    bool? autoFocus,
    bool? editable,
    TextInputType? keyboardType,
    int? maxLength,
    TextAlign? textAlign,
    String? testID,
    Function(String)? onChangeText,
    Function(String)? onSubmitEditing,
    Function()? onFocus,
    Function()? onBlur,
    TextInputStyle? inputStyle,
    Map<String, dynamic>? styleMap,
  }) {
    return TextInput(
      value: value,
      placeholder: placeholder,
      style: style,
      placeholderStyle: placeholderStyle,
      autoFocus: autoFocus,
      editable: editable,
      keyboardType: keyboardType,
      multiline: true,
      maxLength: maxLength,
      textAlign: textAlign,
      testID: testID,
      onChangeText: onChangeText,
      onSubmitEditing: onSubmitEditing,
      onFocus: onFocus,
      onBlur: onBlur,
      inputStyle: inputStyle ??
          (styleMap != null ? TextInputStyle.fromMap(styleMap) : null),
    );
  }

  @override
  VNode build() {
    final nodeType = props.multiline == true ? 'TextArea' : 'TextInput';

    return ElementFactory.createElement(
      nodeType,
      props.toMap(),
      [], // TextInput doesn't have children
    );
  }
}
