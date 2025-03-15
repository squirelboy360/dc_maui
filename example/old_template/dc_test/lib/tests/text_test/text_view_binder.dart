import '../../framework/bridge/core.dart';
import 'text_view_composer.dart';

class TextViewBinder extends TextViewComposer {
  @override
  Future<void> bind() async {
    await Core.attachView('root', mainContainer ?? '');
    await Core.attachView(mainContainer ?? '', appbar ?? '');
    await Core.attachView(mainContainer ?? '', gridContainerColumn ?? '');
    
    // Attach text container first
    await Core.attachView(gridContainerColumn ?? '', textContainer ?? '');
    await Core.attachView(textContainer ?? '', centeredText ?? '');
    
    // Then attach grid
    await Core.attachView(gridContainerColumn ?? '', gridContainer ?? '');
    
    // Finally the bottom button
    await Core.attachView(mainContainer ?? '', bottomButton ?? '');
    await Core.attachView(bottomButton ?? '', bottomButtonText ?? ''); 
  }
}
