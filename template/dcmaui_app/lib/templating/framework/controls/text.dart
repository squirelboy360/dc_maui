import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Style properties for DCText
class DCTextStyle implements StyleProps {
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final double? lineHeight;
  final TextDecorationLine? textDecorationLine;
  final Color? textDecorationColor;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? textShadowRadius;
  final Offset? textShadowOffset;
  final Color? textShadowColor;
  final bool? includeFontPadding;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const DCTextStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.textAlign,
    this.lineHeight,
    this.textDecorationLine,
    this.textDecorationColor,
    this.fontStyle,
    this.letterSpacing,
    this.textShadowRadius,
    this.textShadowOffset,
    this.textShadowColor,
    this.includeFontPadding,
    this.padding,
    this.margin,
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
      switch (fontWeight) {
        case FontWeight.bold:
          map['fontWeight'] = 'bold';
          break;
        case FontWeight.w100:
          map['fontWeight'] = '100';
          break;
        case FontWeight.w200:
          map['fontWeight'] = '200';
          break;
        case FontWeight.w300:
          map['fontWeight'] = '300';
          break;
        case FontWeight.w400:
          map['fontWeight'] = '400';
          break;
        case FontWeight.w500:
          map['fontWeight'] = '500';
          break;
        case FontWeight.w600:
          map['fontWeight'] = '600';
          break;
        case FontWeight.w700:
          map['fontWeight'] = '700';
          break;
        case FontWeight.w800:
          map['fontWeight'] = '800';
          break;
        case FontWeight.w900:
          map['fontWeight'] = '900';
          break;
        default:
          map['fontWeight'] = 'normal';
          break;
      }
    }

    if (fontFamily != null) map['fontFamily'] = fontFamily;

    if (textAlign != null) {
      switch (textAlign) {
        case TextAlign.left:
          map['textAlign'] = 'left';
          break;
        case TextAlign.right:
          map['textAlign'] = 'right';
          break;
        case TextAlign.center:
          map['textAlign'] = 'center';
          break;
        case TextAlign.justify:
          map['textAlign'] = 'justify';
          break;
        default:
          map['textAlign'] = 'auto';
          break;
      }
    }

    if (lineHeight != null) map['lineHeight'] = lineHeight;

    if (textDecorationLine != null) {
      switch (textDecorationLine) {
        case TextDecorationLine.underline:
          map['textDecorationLine'] = 'underline';
          break;
        case TextDecorationLine.lineThrough:
          map['textDecorationLine'] = 'line-through';
          break;
        case TextDecorationLine.overline:
          map['textDecorationLine'] = 'overline';
          break;
        case TextDecorationLine.none:
          map['textDecorationLine'] = 'none';
          break;
      }
    }

    if (textDecorationColor != null) {
      final colorValue =
          textDecorationColor!.value.toRadixString(16).padLeft(8, '0');
      map['textDecorationColor'] = '#$colorValue';
    }

    if (fontStyle != null) {
      switch (fontStyle) {
        case FontStyle.italic:
          map['fontStyle'] = 'italic';
          break;
        case FontStyle.normal:
        default:
          map['fontStyle'] = 'normal';
          break;
      }
    }

    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;

    if (textShadowRadius != null) map['textShadowRadius'] = textShadowRadius;

    if (textShadowOffset != null) {
      map['textShadowOffset'] = {
        'width': textShadowOffset!.dx,
        'height': textShadowOffset!.dy,
      };
    }

    if (textShadowColor != null) {
      final colorValue =
          textShadowColor!.value.toRadixString(16).padLeft(8, '0');
      map['textShadowColor'] = '#$colorValue';
    }

    if (includeFontPadding != null) {
      map['includeFontPadding'] = includeFontPadding;
    }

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

    return map;
  }

  DCTextStyle copyWith({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    TextAlign? textAlign,
    double? lineHeight,
    TextDecorationLine? textDecorationLine,
    Color? textDecorationColor,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? textShadowRadius,
    Offset? textShadowOffset,
    Color? textShadowColor,
    bool? includeFontPadding,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return DCTextStyle(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      textAlign: textAlign ?? this.textAlign,
      lineHeight: lineHeight ?? this.lineHeight,
      textDecorationLine: textDecorationLine ?? this.textDecorationLine,
      textDecorationColor: textDecorationColor ?? this.textDecorationColor,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      textShadowRadius: textShadowRadius ?? this.textShadowRadius,
      textShadowOffset: textShadowOffset ?? this.textShadowOffset,
      textShadowColor: textShadowColor ?? this.textShadowColor,
      includeFontPadding: includeFontPadding ?? this.includeFontPadding,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }
}

/// Enum for text decoration line options
enum TextDecorationLine {
  none,
  underline,
  lineThrough,
  overline,
}

/// Props for DCText component
class DCTextProps implements ControlProps {
  final String text;
  final int? numberOfLines;
  final bool? selectable;
  final bool? adjustsFontSizeToFit;
  final double? minimumFontScale;
  final DCTextStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCTextProps({
    required this.text,
    this.numberOfLines,
    this.selectable,
    this.adjustsFontSizeToFit,
    this.minimumFontScale,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'text': text,
      ...additionalProps,
    };

    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;
    if (selectable != null) map['selectable'] = selectable;
    if (adjustsFontSizeToFit != null)
      map['adjustsFontSizeToFit'] = adjustsFontSizeToFit;
    if (minimumFontScale != null) map['minimumFontScale'] = minimumFontScale;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// Text component for displaying text
class DCText extends Control {
  final DCTextProps props;

  DCText({
    required String text,
    int? numberOfLines,
    bool? selectable,
    bool? adjustsFontSizeToFit,
    double? minimumFontScale,
    DCTextStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCTextProps(
          text: text,
          numberOfLines: numberOfLines,
          selectable: selectable,
          adjustsFontSizeToFit: adjustsFontSizeToFit,
          minimumFontScale: minimumFontScale,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCText',
      props.toMap(),
      [], // DCText doesn't have children
    );
  }

  /// Create a heading text
  static DCText heading(
    String text, {
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight = FontWeight.bold,
    double? fontSize = 24.0,
  }) {
    return DCText(
      text: text,
      style: DCTextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textAlign: textAlign,
      ),
    );
  }

  /// Create a body text
  static DCText body(
    String text, {
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize = 16.0,
    int? numberOfLines,
  }) {
    return DCText(
      text: text,
      numberOfLines: numberOfLines,
      style: DCTextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textAlign: textAlign,
      ),
    );
  }

  /// Create a caption text (small)
  static DCText caption(
    String text, {
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return DCText(
      text: text,
      style: DCTextStyle(
        fontSize: 12.0,
        fontWeight: fontWeight,
        color: color,
        textAlign: textAlign,
      ),
    );
  }
}
