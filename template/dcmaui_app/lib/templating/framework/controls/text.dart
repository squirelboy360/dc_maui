import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:flutter/painting.dart' hide TextStyle;

/// Style properties for Text
class TextStyle implements StyleProps {
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final double? lineHeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;

  const TextStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.textAlign,
    this.decoration,
    this.lineHeight,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (fontSize != null) map['fontSize'] = fontSize;

    if (fontWeight != null) {
      map['fontWeight'] = _fontWeightToString(fontWeight!);
    }

    if (fontFamily != null) map['fontFamily'] = fontFamily;

    if (textAlign != null) {
      map['textAlign'] = _textAlignToString(textAlign!);
    }

    if (decoration != null) {
      map['textDecorationLine'] = _textDecorationToString(decoration!);
    }

    if (lineHeight != null) map['lineHeight'] = lineHeight;
    if (maxLines != null) map['maxLines'] = maxLines;

    if (overflow != null) {
      map['textOverflow'] = _textOverflowToString(overflow!);
    }

    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;

    return map;
  }

  // Helper methods to convert Flutter enums to string values
  String _fontWeightToString(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100:
        return '100';
      case FontWeight.w200:
        return '200';
      case FontWeight.w300:
        return '300';
      case FontWeight.w400:
        return 'normal';
      case FontWeight.w500:
        return '500';
      case FontWeight.w600:
        return '600';
      case FontWeight.w700:
        return 'bold';
      case FontWeight.w800:
        return '800';
      case FontWeight.w900:
        return '900';
      default:
        return 'normal';
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
      case TextAlign.justify:
        return 'justify';
      default:
        return 'auto';
    }
  }

  String _textDecorationToString(TextDecoration decoration) {
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.lineThrough) return 'line-through';
    if (decoration == TextDecoration.overline) return 'overline';
    return 'none';
  }

  String _textOverflowToString(TextOverflow overflow) {
    if (overflow == TextOverflow.ellipsis) return 'ellipsis';
    if (overflow == TextOverflow.fade) return 'fade';
    if (overflow == TextOverflow.visible) return 'visible';
    return 'clip';
  }

  TextStyle copyWith({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    TextAlign? textAlign,
    TextDecoration? decoration,
    double? lineHeight,
    int? maxLines,
    TextOverflow? overflow,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      textAlign: textAlign ?? this.textAlign,
      decoration: decoration ?? this.decoration,
      lineHeight: lineHeight ?? this.lineHeight,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }
}

/// Props for Text component
class TextProps implements ControlProps {
  final String text;
  final TextStyle? style;
  final bool? selectable;
  final Function(String)? onPress;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const TextProps({
    required this.text,
    this.style,
    this.selectable,
    this.onPress,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'text': text,
      ...additionalProps,
    };

    if (style != null) map['style'] = style!.toMap();
    if (selectable != null) map['selectable'] = selectable;
    if (onPress != null) map['onPress'] = onPress;
    if (testID != null) map['testID'] = testID;

    return map;
  }

  TextProps copyWith({
    String? text,
    TextStyle? style,
    bool? selectable,
    Function(String)? onPress,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return TextProps(
      text: text ?? this.text,
      style: style ?? this.style,
      selectable: selectable ?? this.selectable,
      onPress: onPress ?? this.onPress,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Text control
class Text extends Control {
  final TextProps props;

  Text(
    String text, {
    TextStyle? style,
    bool? selectable,
    Function(String)? onPress,
    String? testID,
  }) : props = TextProps(
          text: text,
          style: style,
          selectable: selectable,
          onPress: onPress,
          testID: testID,
        );

  Text.custom({required this.props});

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Text',
      props.toMap(),
      [], // Text doesn't have children
    );
  }

  /// Create text with a style
  static Text styled({
    required String text,
    required TextStyle style,
    bool? selectable,
    Function(String)? onPress,
    String? testID,
  }) {
    return Text.custom(
      props: TextProps(
        text: text,
        style: style,
        selectable: selectable,
        onPress: onPress,
        testID: testID,
      ),
    );
  }
}
