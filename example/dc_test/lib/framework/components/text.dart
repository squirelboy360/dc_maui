import '../ui_composer.dart';
import '../bridge/controls/text.dart' as native;
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../bridge/types/view_types/view_styles.dart';
import '../bridge/types/text_types/text_styles.dart';

class DCText extends UIComponent<native.Text> {
  final String text;
  final TextStyle? textStyle;
  final ViewStyle? viewStyle;
  final YogaLayout? yogaLayout;

  DCText(
    this.text, {
    this.textStyle,
    this.viewStyle,
    this.yogaLayout,
  }) {
    properties['text'] = text;
    properties['textStyle'] = textStyle?.toMap() ?? TextStyle(text: text).toMap();
    
    if (viewStyle != null) {
      style.addAll(viewStyle!.toMap());
    }
    if (yogaLayout != null) {
      layout.addAll(yogaLayout!.toMap());
    }
  }

  @override
  Future<String?> _createComponent() async {
    final textComponent = native.Text(
      text: text,
      textStyle: textStyle ?? TextStyle(text: text),
      style: viewStyle ?? const ViewStyle(),
      layout: yogaLayout ?? const YogaLayout(),
    );
    
    final id = await textComponent.create();
    return id;
  }
}
