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

    // Attach the ScrollView to its parent - but not the children to the ScrollView
    // The children are already included in the ScrollView creation
    await Core.attachView(gridContainerColumn ?? '', scrollView ?? '');

    await Core.attachView(gridContainerColumn ?? '', bottomButton ?? '');
  }
}
