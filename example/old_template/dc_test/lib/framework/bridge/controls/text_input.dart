import '../core.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

// Add these enums to match iOS native side
enum KeyboardType {
  default_,
  number,
  email,
  phone,
  url;

  String toValue() {
    return name == 'default_' ? 'default' : name;
  }
}

enum ReturnKeyType {
  default_,
  done,
  go,
  next,
  search,
  send;

  String toValue() {
    return name == 'default_' ? 'default' : name;
  }
}

enum ContentType {
  none,
  username,
  password,
  email,
  name,
  phone,
  address,
  url,
  creditCard;

  // Fix: Return the enum name as a String
  String toValue() {
    return name.toString(); // Explicitly convert enum name to String
  }
}

class TextInputStyle {
  final String? text;
  final String? placeholder;
  final int? textColor;
  final double? fontSize;
  final String? textAlign;
  final KeyboardType? keyboardType; // Updated to use enum
  final ReturnKeyType? returnKeyType; // Updated to use enum
  final ContentType? contentType; // Added content type
  final bool? isSecure;
  final bool? multiline;
  final int? maxLines;
  final bool? editable;

  const TextInputStyle({
    this.text,
    this.placeholder,
    this.textColor,
    this.fontSize,
    this.textAlign,
    this.keyboardType,
    this.returnKeyType,
    this.contentType,
    this.isSecure,
    this.multiline,
    this.maxLines,
    this.editable,
  });

  Map<String, dynamic> toMap() => {
        if (text != null) 'text': text,
        if (placeholder != null) 'placeholder': placeholder,
        if (textColor != null) 'textColor': textColor,
        if (fontSize != null) 'fontSize': fontSize,
        if (textAlign != null) 'textAlign': textAlign,
        if (keyboardType != null) 'keyboardType': keyboardType!.toValue(),
        if (returnKeyType != null) 'returnKeyType': returnKeyType!.toValue(),
        if (contentType != null) 'contentType': contentType!.toValue(),
        if (isSecure != null) 'isSecure': isSecure,
        if (multiline != null) 'multiline': multiline,
        if (maxLines != null) 'maxLines': maxLines,
        if (editable != null) 'editable': editable,
      };
}

class TextInput {
  String? id;
  final TextInputStyle inputStyle;
  final ViewStyle style;
  final YogaLayout layout;
  final void Function(String)? onTextChange;
  final void Function(String)? onSubmit;
  final void Function()? onFocus;
  final void Function()? onBlur;

  TextInput({
    this.inputStyle = const TextInputStyle(),
    this.style = const ViewStyle(),
    this.layout = const YogaLayout(),
    this.onTextChange,
    this.onSubmit,
    this.onFocus,
    this.onBlur,
  });

  Future<String?> create() async {
    id = await Core.createView(
      viewType: 'TextInput',
      properties: {
        'style': {...style.toMap(), 'inputStyle': inputStyle.toMap()},
        'layout': layout.toMap(),
        'events': {
          if (onTextChange != null) 'onTextChange': true,
          if (onSubmit != null) 'onSubmit': true,
          if (onFocus != null) 'onFocus': true,
          if (onBlur != null) 'onBlur': true,
        },
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
    }
  }
}
