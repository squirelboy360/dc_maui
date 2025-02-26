
import 'package:dc_test/tests/scroll_view_test/scroll_view_composer.dart';

import '../../framework/bridge/core.dart';

class ScrollViewBinder extends ScrollViewComposer {
  @override
  Future<void> bind() async {
    await Core.attachView('root', mainContainer ?? '');

    // Attach the components to the main container
    await Core.attachView(mainContainer ?? '', appbar ?? '');
    await Core.attachView(mainContainer ?? '', gridContainerColumn ?? '');

    // Attach both ScrollViews to the grid container
    // await Core.attachView(
    //     gridContainerColumn ?? '', horizontalScrollView ?? '');
    await Core.attachView(gridContainerColumn ?? '', verticalScrollView ?? '');
    await Core.attachView(gridContainerColumn ?? '', bottomButton ?? '');
  }
}
