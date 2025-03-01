import '../ui_composer.dart';
import '../bridge/controls/text_input.dart' as native;
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../bridge/types/view_types/view_styles.dart';

class DCTextInput extends UIComponent<native.TextInput> {
  final native.TextInputStyle? inputStyle;
  final ViewStyle? viewStyle;
  final YogaLayout? yogaLayout;
  final void Function(String)? onTextChange;
  final void Function(String)? onSubmit;
  final void Function()? onFocus;
  final void Function()? onBlur;

  DCTextInput({
    this.inputStyle,
    this.viewStyle,
    this.yogaLayout,
    this.onTextChange,
    this.onSubmit,
    this.onFocus,
    this.onBlur,
  }) {
    if (viewStyle != null) {
      style.addAll(viewStyle!.toMap());
    }
    if (inputStyle != null) {
      style['inputStyle'] = inputStyle!.toMap();
    }
    if (yogaLayout != null) {
      layout.addAll(yogaLayout!.toMap());
    }
    
    properties['events'] = {
      if (onTextChange != null) 'onTextChange': true,
      if (onSubmit != null) 'onSubmit': true,
      if (onFocus != null) 'onFocus': true,
      if (onBlur != null) 'onBlur': true,
    };
  }

  @override
  Future<String?> _createComponent() async {
    final textInput = native.TextInput(
      inputStyle: inputStyle ?? const native.TextInputStyle(),
      style: viewStyle ?? const ViewStyle(),
      layout: yogaLayout ?? const YogaLayout(),
      onTextChange: onTextChange,
      onSubmit: onSubmit,
      onFocus: onFocus,
      onBlur: onBlur,
    );
    
    final id = await textInput.create();
    return id;
  }
}
