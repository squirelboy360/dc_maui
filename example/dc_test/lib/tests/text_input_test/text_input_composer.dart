import 'package:flutter/material.dart' hide Text, TextStyle, View;
import '../../framework/bridge/controls/text_input.dart';
import '../../framework/bridge/controls/view.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/ui_composer.dart';
import '../../framework/bridge/core.dart';

class TextInputTestComposer extends UIComposer {
  String? container;
  String? emailInput;
  String? passwordInput;
  String? addressInput;

  @override
  Future<void> compose() async {
    // Root container
    container = await View(
      style: ViewStyle(
        backgroundColor: Colors.greenAccent.toARGB32(),
      ),
      layout: YogaLayout(
        flex: 1,
        alignItems: YogaAlign.center,
        justifyContent: YogaJustify.spaceAround,
        // padding: EdgeValues(horizontal: YogaValue(50, YogaUnit.point)),
      ),
    ).create();

    // Email input
    emailInput = await TextInput(
      inputStyle: TextInputStyle(
        placeholder: "Enter email",
        textColor: Colors.pink.value,
        fontSize: 16,
        keyboardType: KeyboardType.email,
        contentType: ContentType.email,
        returnKeyType: ReturnKeyType.next,
      ),
      style: ViewStyle(
        backgroundColor: Colors.blue[200]!.value,
        cornerRadius: 8,
      ),
      layout: YogaLayout(
        width: YogaValue(300, YogaUnit.point),
        height: YogaValue(50, YogaUnit.point),
        margin: EdgeValues(bottom: YogaValue(16, YogaUnit.point)),
      ),
      onTextChange: (text) {
        print('Email changed: $text');
      },
      onFocus: () {
        print('Email field focused');
      },
      onBlur: () {
        print('Email field blurred');
      },
    ).create();

    // Password input
    passwordInput = await TextInput(
      inputStyle: TextInputStyle(
        placeholder: "Enter password",
        textColor: Colors.black.value,
        fontSize: 16,
        isSecure: true,
        contentType: ContentType.password,
        returnKeyType: ReturnKeyType.next,
      ),
      style: ViewStyle(
        backgroundColor: Colors.grey[200]!.value,
        cornerRadius: 8,
      ),
      layout: YogaLayout(
        width: YogaValue(300, YogaUnit.point),
        height: YogaValue(50, YogaUnit.point),
        margin: EdgeValues(bottom: YogaValue(16, YogaUnit.point)),
      ),
      onTextChange: (text) {
        print('Password changed: $text');
      },
    ).create();

    // Address input
    addressInput = await TextInput(
      inputStyle: TextInputStyle(
        placeholder: "Enter address",
        textColor: Colors.black.value,
        fontSize: 16,
        contentType: ContentType.address,
        returnKeyType: ReturnKeyType.done,
      ),
      style: ViewStyle(
        backgroundColor: Colors.grey[200]!.value,
        cornerRadius: 8,
      ),
      layout: YogaLayout(
        width: YogaValue(300, YogaUnit.point),
        height: YogaValue(50, YogaUnit.point),
      ),
      onTextChange: (text) {
        print('Address changed: $text');
      },
      onSubmit: (text) {
        print('Form submitted with address: $text');
      },
    ).create();
  }

  @override
  Future<void> bind() async {
    await Core.attachView('root', container!);
    await Core.attachView(container!, emailInput!);
    await Core.attachView(container!, passwordInput!);
    await Core.attachView(container!, addressInput!);
  }
}
