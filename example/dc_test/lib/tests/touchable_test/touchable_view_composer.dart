import 'package:dc_test/framework/bridge/core.dart';
import 'package:flutter/material.dart' hide View, Text, TextStyle;
import '../../framework/ui_composer.dart';
import '../../framework/bridge/controls/text.dart';
import '../../framework/bridge/controls/view.dart';
import '../../framework/bridge/controls/touchable.dart';
import '../../framework/bridge/types/layout_layouts/yoga_types.dart';
import '../../framework/bridge/types/text_types/text_styles.dart';
import '../../framework/bridge/types/view_types/view_styles.dart';
import '../../framework/bridge/types/touchable_types/touchable_styles.dart';

abstract class TouchableViewComposer extends UIComposer {
  String? mainContainer;
  String? appbar;
  String? gridContainerColumn;
  String? gridContainer;
  final List<String?> gridItems = [];
  
  final colors = [
    0xFFE57373, 0xFF81C784, 0xFF64B5F6, 0xFFFFB74D,
    0xFFBA68C8, 0xFF4DB6AC, 0xFFFFD54F, 0xFFFFD54F,
    0xFF7986CB,
  ];
  
  int selectedIndex = -1;

  @override
  Future<void> compose() async {
    // ... keep existing container setup code ...

    gridContainer = await View(
      style: ViewStyle(backgroundColor: Colors.black.withOpacity(0.1).value),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
        flexDirection: YogaFlexDirection.row,
        flex: 10,
        padding: EdgeValues(all: YogaValue.point(16)),
        flexWrap: YogaWrap.wrap,
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
      ),
    ).create();

    await createGridItems();
  }

  Future<void> createGridItems() async {
    for (var i = 0; i < colors.length; i++) {
      final touchable = await Touchable(
        touchableStyle: TouchableStyle(
          activeOpacity: 0.7,
          pressedScale: 0.95,
          hasHapticFeedback: true,
        ),
        style: ViewStyle(
          backgroundColor: colors[i],
          cornerRadius: 8,
          shadow: ViewShadow(
            color: Color.fromARGB(255, 28, 213, 65),
            opacity: 0.2,
            offset: Offset(0, 4),
            radius: 8,
          ),
        ),
        layout: YogaLayout(
          padding: EdgeValues(all: YogaValue(8, YogaUnit.point)),
          width: YogaValue(100, YogaUnit.point),
          height: YogaValue(100, YogaUnit.point),
          margin: EdgeValues(all: YogaValue(8, YogaUnit.point)),
          alignItems: YogaAlign.center,
          justifyContent: YogaJustify.center,
        ),
      ).create(
        onPress: (event) => handleItemPress(i),
      );

      final colorText = await Text(
        text: '#${colors[i].toRadixString(16).toUpperCase()}',
        textStyle: TextStyle(
          fontSize: 12,
          color: _isColorDark(colors[i]) ? Colors.white.value : Colors.black.value,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
        ),
      ).create();

      await Core.attachView(touchable ?? '', colorText ?? '');
      await Core.attachView(gridContainer ?? '', touchable ?? '');
      gridItems.add(touchable);
    }
  }

  Future<void> handleItemPress(int index) async {
    selectedIndex = index;
    
    // Update all items' colors
    for (var i = 0; i < gridItems.length; i++) {
      final newColor = i == selectedIndex ? Colors.purple.value : colors[i];
      await Core.updateViewState(gridItems[i] ?? '', {
        'style': {'backgroundColor': newColor}
      });
    }
  }

  bool _isColorDark(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return (r * 0.299 + g * 0.587 + b * 0.114) < 128;
  }
}
