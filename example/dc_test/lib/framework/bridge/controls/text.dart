import '../core.dart';
import '../types/text_types/text_styles.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

class Text {
  String? id;
  final TextStyle textStyle;
  final ViewStyle style;
  final YogaLayout layout;

  Text({
    required String text,
    TextStyle? textStyle,
    this.style = const ViewStyle(),
    this.layout = const YogaLayout(),
  }) : this.textStyle = (textStyle ?? TextStyle()).copyWith(text: text);

  Future<String?> create({EventCallback? onEvent}) async {
    id = await Core.createView(
      viewType: 'Label',
      properties: {
        'textStyle': textStyle.toMap(),
        'style': style.toMap(),
        'layout': layout.toMap(),
        if (onEvent != null) 'events': {'onEvent': true},
      },
      onEvent: onEvent,
    );
    return id;
  }
}

extension TextStyleCopyWith on TextStyle {
  TextStyle copyWith({
    String? text,
    double? fontSize,
    FontWeight? fontWeight,
    int? color,
    TextAlignment? textAlignment,
    double? lineHeight,
    double? letterSpacing,
    bool? adjustsFontSizeToFit,
    double? minimumFontSize,
    double? maximumFontSize,
    int? numberOfLines,
    TextDecorationLine? decorationLine,
    int? decorationColor,
    String? fontFamily,
    bool? allowsDefaultTighteningForTruncation,
    Map<String, dynamic>? attributes,
  }) {
    return TextStyle(
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      textAlignment: textAlignment ?? this.textAlignment,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      adjustsFontSizeToFit: adjustsFontSizeToFit ?? this.adjustsFontSizeToFit,
      minimumFontSize: minimumFontSize ?? this.minimumFontSize,
      maximumFontSize: maximumFontSize ?? this.maximumFontSize,
      numberOfLines: numberOfLines ?? this.numberOfLines,
      decorationLine: decorationLine ?? this.decorationLine,
      decorationColor: decorationColor ?? this.decorationColor,
      fontFamily: fontFamily ?? this.fontFamily,
      allowsDefaultTighteningForTruncation: allowsDefaultTighteningForTruncation ?? this.allowsDefaultTighteningForTruncation,
      attributes: attributes ?? this.attributes,
    );
  }
}
