import 'dart:io';

enum TextAlign {
  left('left'),
  center('center'),
  right('right'),
  justify('justify');

  final String value;
  const TextAlign(this.value);
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

class TextStyle {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? color;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final double? lineHeight;
  final bool? adjustsFontSize;
  final double? minimumFontSize;
  final int? numberOfLines;
  final String? fontFamily;
  final bool? allowsDefaultTighteningForTruncation;
  final Map<String, dynamic>? attributes;

  const TextStyle({
    this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.letterSpacing,
    this.lineHeight,
    this.adjustsFontSize,
    this.minimumFontSize,
    this.numberOfLines,
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
      if (textAlign != null) 'textAlignment': textAlign!.value,
      if (letterSpacing != null) 'letterSpacing': letterSpacing,
      if (lineHeight != null) 'lineHeight': lineHeight,
      if (adjustsFontSize != null) 'adjustsFontSizeToFit': adjustsFontSize,
      if (minimumFontSize != null) 'minimumFontSize': minimumFontSize,
      if (numberOfLines != null) 'numberOfLines': numberOfLines,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (allowsDefaultTighteningForTruncation != null)
        'allowsDefaultTighteningForTruncation':
            allowsDefaultTighteningForTruncation,
      if (attributes != null) 'attributes': attributes,
    };
  }
}
