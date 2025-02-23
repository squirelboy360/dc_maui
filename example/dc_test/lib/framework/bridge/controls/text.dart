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
    final properties = {
      'textStyle': textStyle.toMap(),
      'style': style.toMap(),
      'layout': layout.toMap(),
      if (onEvent != null) 'events': {'onEvent': true},
    };
    
    print("Creating Text with properties: $properties"); // Add this debug log

    id = await Core.createView(
      viewType: 'Label',
      properties: properties,
      onEvent: onEvent,
    );
    return id;
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle copyWith({
    String? text,
    double? fontSize,
    FontWeight? fontWeight,
    int? color,
    TextAlign? textAlign,
    double? letterSpacing,
    double? lineHeight,
    bool? adjustsFontSize,
    double? minimumFontSize,
    int? numberOfLines,
    String? fontFamily,
    bool? allowsDefaultTighteningForTruncation,
    Map<String, dynamic>? attributes,
  }) {
    return TextStyle(
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      adjustsFontSize: adjustsFontSize ?? this.adjustsFontSize,
      minimumFontSize: minimumFontSize ?? this.minimumFontSize,
      numberOfLines: numberOfLines ?? this.numberOfLines,
      fontFamily: fontFamily ?? this.fontFamily,
      allowsDefaultTighteningForTruncation:
          allowsDefaultTighteningForTruncation ??
              this.allowsDefaultTighteningForTruncation,
      attributes: attributes ?? this.attributes,
    );
  }
}
