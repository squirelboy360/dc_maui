import 'package:flutter/material.dart' hide TextStyle;

class TextStyle {
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? lineHeight;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final bool? italic;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? text; // Add text property

  const TextStyle({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.decoration,
    this.textAlign,
    this.italic,
    this.maxLines,
    this.overflow,
    this.text, // Add text parameter
  });

  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text,
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (fontSize != null) 'fontSize': fontSize,
        if (fontWeight != null) 'fontWeight': fontWeight!.index,
        if (color != null) 'color': color!.toARGB32(),
        if (letterSpacing != null) 'letterSpacing': letterSpacing,
        if (wordSpacing != null) 'wordSpacing': wordSpacing,
        if (lineHeight != null) 'lineHeight': lineHeight,
        if (decoration != null) 'decoration': decoration!.toString(),
        if (textAlign != null) 'textAlign': textAlign!.name,
        if (italic != null) 'italic': italic,
        if (maxLines != null) 'maxLines': maxLines,
        if (overflow != null) 'overflow': overflow!.name,
      };
}
