import '../bridge/controls/text.dart' as bridge;
import '../bridge/types/text_types/text_styles.dart';
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../bridge/types/view_types/view_styles.dart';
import '../ui_composer.dart';

class DCText extends UIComponent<String> {
  final String text;
  final TextStyle textStyle;
  final ViewStyle viewStyle;
  final YogaLayout yogaLayout;

  DCText(
    this.text, {
    TextStyle? textStyle,
    this.viewStyle = const ViewStyle(),
    this.yogaLayout = const YogaLayout(),
  }) : textStyle = (textStyle ?? TextStyle()).copyWith(text: text) {
    style = {
      'textStyle': this.textStyle.toMap(),
      'style': viewStyle.toMap(),
    };
    layout = yogaLayout.toMap();
  }

  @override
  Future<String?> createComponent() async {
    final textComponent = bridge.Text(
      text: text,
      textStyle: textStyle,
      style: viewStyle,
      layout: yogaLayout,
    );
    
    return await textComponent.create();
  }
}
