import 'package:dc_test/framework/bridge/controls/view.dart';
import 'package:dc_test/framework/bridge/core.dart';
import 'package:dc_test/framework/bridge/types/view_types/view_styles.dart';
import 'package:flutter/material.dart' hide View, Text, TextStyle;
import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/text.dart';
import '../../framework/bridge/controls/touchable.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';

class TouchableViewComposer extends UIComposer {
  String? parent;
  String? touchableButton;
  String? buttonText;

  @override
  Future<void> compose() async {
    parent = await View(
      style: ViewStyle(backgroundColor: Colors.white.value),
      layout: YogaLayout(
        flex: 1,
        alignItems: YogaAlign.center,
        justifyContent: YogaJustify.center,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    touchableButton = await Touchable(
      style: TouchableStyle(
        activeOpacity: 0.4,
        backgroundColor: Colors.blue.value,
        cornerRadius: 8,
        enabled: true,
      ),
      layout: YogaLayout(
        width: YogaValue(200, YogaUnit.point),
        height: YogaValue(50, YogaUnit.point),
        alignItems: YogaAlign.center,
        justifyContent: YogaJustify.center,
      ),
      onPress: () {
        print('Button pressed! Event received on Dart side');
      },
      onPressIn: () {
        print('Button press started on Dart side');
      },
      onPressOut: () {
        print('Button press ended on Dart side');
      },
    ).create();

    buttonText = await Text(
      text: "Press Me!",
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white.value,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
      ),
    ).create();
  }

  @override
  Future<void> bind() async {
    await Core.attachView('root', parent ?? '');
    await Core.attachView(parent ?? '', touchableButton ?? '');
    await Core.attachView(touchableButton ?? '', buttonText ?? '');
  }
}
