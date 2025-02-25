import 'dart:ui';

import 'package:dc_test/framework/bridge/controls/view.dart';
import 'package:dc_test/framework/bridge/types/layout_layouts/yoga_types.dart';
import 'package:dc_test/framework/bridge/types/view_types/view_styles.dart';
import 'package:dc_test/tests/scroll_view_test/scroll_view_composer.dart';

import '../../framework/bridge/core.dart';

class ScrollViewBinder extends ScrollViewComposer {
  @override
  Future<void> bind() async {
    await Core.attachView('root', mainContainer ?? '');
    await Core.attachView(mainContainer ?? '', appbar ?? 'appbar is null');
    await Core.attachView(mainContainer ?? '',
        gridContainerColumn ?? 'gridContainerColumn is null');
    // grid column

    await Core.attachView(gridContainerColumn ?? '', scrollView ?? '');

    await createGridItems();

    await Core.attachView(gridContainerColumn ?? '', bottomButton ?? '');
  }

  // grid items

  Future<void> createGridItems() async {
    for (var color in colors) {
      final gridItem = await View(
        style: ViewStyle(
          backgroundColor: color,
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
          width: YogaValue(90, YogaUnit.percent),
          alignSelf: YogaAlign.center,
          height: YogaValue(100, YogaUnit.point),
          margin: EdgeValues(all: YogaValue(8, YogaUnit.point)),
        ),
      ).create(
        onEvent: (type, data) {
          print('Grid item event: $type, data: $data');
        },
      );
      await Core.attachView(scrollView ?? '', gridItem ?? '');
    }
  }
}
