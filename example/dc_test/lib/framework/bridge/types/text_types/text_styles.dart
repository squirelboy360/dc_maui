import 'dart:io';
import 'package:flutter/material.dart';

enum TextAlignment {
  left('left'),
  center('center'),
  right('right'),
  justified('justified'),
  natural('natural');

  final String value;
  const TextAlignment(this.value);
}

enum FontWeight {
  ultraLight('ultraLight'),
  thin('thin'),
  light('light'),
  regular('regular'),
  medium('medium'),
  semibold('semibold'),
  bold('bold'),
  heavy('heavy'),
  black('black');

  final String value;
  const FontWeight(this.value);
}

enum TextDecorationLine {
  none('none'),
  underline('underline'),
  strikethrough('strikethrough'),
  underlineStrikethrough('underlineStrikethrough');

  final String value;
  const TextDecorationLine(this.value);
}

class TextStyle {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? color;
  final TextAlignment? textAlignment;
  final double? lineHeight;
  final double? letterSpacing;
  final bool? adjustsFontSizeToFit;
  final double? minimumFontSize;
  final double? maximumFontSize;
  final int? numberOfLines;
  final TextDecorationLine? decorationLine;
  final int? decorationColor;
  final String? fontFamily;
  final bool? allowsDefaultTighteningForTruncation;
  final Map<String, dynamic>? attributes; // For NSAttributedString

  const TextStyle({
    this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlignment,
    this.lineHeight,
    this.letterSpacing,
    this.adjustsFontSizeToFit,
    this.minimumFontSize,
    this.maximumFontSize,
    this.numberOfLines,
    this.decorationLine,
    this.decorationColor,
    this.fontFamily,
    this.allowsDefaultTighteningForTruncation,
    this.attributes,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) return {};
    
    return {
      if (text != null) 'text': text,
      if (fontSize != null) 'fontSize': fontSize,
      if (fontWeight != null) 'fontWeight': fontWeight!.value,
      if (color != null) 'color': color,
      if (textAlignment != null) 'textAlignment': textAlignment!.value,
      if (lineHeight != null) 'lineHeight': lineHeight,
      if (letterSpacing != null) 'letterSpacing': letterSpacing,
      if (adjustsFontSizeToFit != null) 'adjustsFontSizeToFit': adjustsFontSizeToFit,
      if (minimumFontSize != null) 'minimumFontSize': minimumFontSize,
      if (maximumFontSize != null) 'maximumFontSize': maximumFontSize,
      if (numberOfLines != null) 'numberOfLines': numberOfLines,
      if (decorationLine != null) 'decorationLine': decorationLine!.value,
      if (decorationColor != null) 'decorationColor': decorationColor,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (allowsDefaultTighteningForTruncation != null) 
        'allowsDefaultTighteningForTruncation': allowsDefaultTighteningForTruncation,
      if (attributes != null) 'attributes': attributes,
    };
  }
}
