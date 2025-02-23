import '../../framework/bridge/core.dart';
import 'touchable_view_composer.dart';

class TouchableViewBinder extends TouchableViewComposer {
  @override
  Future<void> bind() async {
    await Core.attachView('root', mainContainer ?? '');
    await Core.attachView(mainContainer ?? '', appbar ?? '');
    await Core.attachView(mainContainer ?? '', gridContainerColumn ?? '');
    await Core.attachView(gridContainerColumn ?? '', gridContainer ?? '');
  }
}
