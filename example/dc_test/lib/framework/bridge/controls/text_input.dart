import '../core.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

// Text input specific types
enum KeyboardType {
  default_('default'),
  number('number'),
  email('email'),
  phone('phone'),
  url('url');

  final String value;
  const KeyboardType(this.value);
}

enum ReturnKeyType {
  done('done'),
  go('go'),
  next('next'),
  search('search'),
  send('send');

  final String value;
  const ReturnKeyType(this.value);
}

enum ContentType {
  username('username'),
  password('password'),
  email('email'),
  name('name'),
  phone('phone'),
  address('address'),
  none('none');

  final String value;
  const ContentType(this.value);
}

class TextInputStyle {
  final String? placeholder;
  final int? textColor;
  final double? fontSize;
  final String? textAlign;
  final KeyboardType? keyboardType;
  final ReturnKeyType? returnKeyType;
  final bool? isSecure;
  final bool? autocorrection;
  final ContentType? contentType;
  final String? toolbarStyle;

  const TextInputStyle({
    this.placeholder,
    this.textColor,
    this.fontSize,
    this.textAlign,
    this.keyboardType,
    this.returnKeyType, 
    this.isSecure,
    this.autocorrection,
    this.contentType,
    this.toolbarStyle,
  });

  Map<String, dynamic> toMap() => {
    if (placeholder != null) 'placeholder': placeholder,
    if (textColor != null) 'textColor': textColor,
    if (fontSize != null) 'fontSize': fontSize,
    if (textAlign != null) 'textAlign': textAlign,
    if (keyboardType != null) 'keyboardType': keyboardType!.value,
    if (returnKeyType != null) 'returnKeyType': returnKeyType!.value,
    if (isSecure != null) 'isSecure': isSecure,
    if (autocorrection != null) 'autocorrection': autocorrection,
    if (contentType != null) 'contentType': contentType!.value,
    if (toolbarStyle != null) 'toolbarStyle': toolbarStyle,
  };
}

typedef TextInputCallback = void Function(String text);
typedef TextInputFocusCallback = void Function();
typedef KeyboardChangeCallback = void Function(double height);

class TextInput {
  String? id;
  final TextInputStyle inputStyle;
  final ViewStyle style;
  final YogaLayout layout;
  final TextInputCallback? onTextChange;
  final TextInputCallback? onSubmit;
  final TextInputFocusCallback? onFocus;
  final TextInputFocusCallback? onBlur;
  final KeyboardChangeCallback? onKeyboardChange;

  TextInput({
    this.inputStyle = const TextInputStyle(),
    this.style = const ViewStyle(),
    this.layout = const YogaLayout(),
    this.onTextChange,
    this.onSubmit,
    this.onFocus,
    this.onBlur, 
    this.onKeyboardChange,
  });

  Future<String?> create() async {
    final events = <String, bool>{
      if (onTextChange != null) 'onTextChange': true,
      if (onSubmit != null) 'onSubmit': true,
      if (onFocus != null) 'onFocus': true,
      if (onBlur != null) 'onBlur': true,
      if (onKeyboardChange != null) 'onKeyboardChange': true,
    };

    id = await Core.createView(
      viewType: 'TextInput',
      properties: {
        'style': style.toMap(),
        'inputStyle': inputStyle.toMap(),
        'layout': layout.toMap(),
        'events': events,
      },
      onEvent: _handleEvent,
    );

    return id;
  }

  void _handleEvent(String type, dynamic data) {
    switch (type) {
      case 'onTextChange':
        onTextChange?.call(data['text'] as String);
        break;
      case 'onSubmit':
        onSubmit?.call(data['text'] as String);
        break;
      case 'onFocus':
        onFocus?.call();
        break;
      case 'onBlur':
        onBlur?.call();
        break;
      case 'onKeyboardChange':
        onKeyboardChange?.call(data['height'] as double);
        break;
    }
  }
}
