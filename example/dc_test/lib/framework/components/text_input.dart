import '../bridge/controls/text_input.dart' as bridge;
import '../bridge/types/view_types/view_styles.dart';
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../ui_composer.dart';

class DCTextInput extends UIComponent<String> {
  final bridge.TextInputStyle inputStyle;
  final ViewStyle viewStyle;
  final YogaLayout yogaLayout;
  final void Function(String)? onTextChange;
  final void Function(String)? onSubmit;
  final void Function()? onFocus;
  final void Function()? onBlur;

  DCTextInput({
    this.inputStyle = const bridge.TextInputStyle(),
    this.viewStyle = const ViewStyle(),
    this.yogaLayout = const YogaLayout(),
    this.onTextChange,
    this.onSubmit,
    this.onFocus,
    this.onBlur,
  }) {
    style = {
      ...viewStyle.toMap(),
      'inputStyle': inputStyle.toMap(),
    };
    layout = yogaLayout.toMap();
  }

  @override
  Future<String?> createComponent() async {
    final textInput = bridge.TextInput(
      inputStyle: inputStyle,
      style: viewStyle,
      layout: yogaLayout,
      onTextChange: onTextChange,
      onSubmit: onSubmit,
      onFocus: onFocus,
      onBlur: onBlur,
    );
    
    return await textInput.create();
  }
}
