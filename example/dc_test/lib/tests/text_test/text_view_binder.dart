import '../../framework/bridge/core.dart';
import 'text_view_composer.dart';

class TextViewBinder extends TextViewComposer {
  @override
  Future<void> bind() async {
    await Core.attachView('root', mainContainer ?? '');
    await Core.attachView(mainContainer ?? '', appbar ?? '');
    await Core.attachView(mainContainer ?? '', gridContainerColumn ?? '');
    await Core.attachView(gridContainerColumn ?? '', gridContainer ?? '');
    await Core.attachView(gridContainer ?? '', centeredText ?? '');
    await Core.attachView(mainContainer ?? '', bottomButton ?? '');
  }
}
