import 'package:flutter/material.dart';
import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class Label extends UIComponent {
  Label._create(super.id);  // Use super parameter

  static Future<Label?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('Label');
    return id != null ? Label._create(id) : null;
  }

  Future<Label> setText(String text) async {
    await NativeUIBridge().updateView(id, {'text': text});
    return this;
  }

  Future<Label> setTextStyle({
    String? fontFamily,
    double? fontSize,
    String? textColor,
    TextAlign? textAlign,
  }) async {
    final style = <String, dynamic>{};
    if (fontFamily != null) style['fontFamily'] = fontFamily;
    if (fontSize != null) style['fontSize'] = fontSize;
    if (textColor != null) style['textColor'] = textColor;
    if (textAlign != null) style['textAlign'] = textAlign.toString();
    
    await NativeUIBridge().updateView(id, style);
    return this;
  }
}
