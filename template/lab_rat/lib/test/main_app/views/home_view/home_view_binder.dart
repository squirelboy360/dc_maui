part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {
  Future<void> mountHome() async {
    final getAppRoot = await Core().getRootView();
    final appRoot = getAppRoot?['viewId'] as String;

   
    bridge.attachView(await rootView, await appbar).then((_) async {
      // appbar attaches
      bridge.attachView(await appbar, await decrementButton);
      bridge.attachView(await appbar, await title);
      bridge.attachView(await appbar, await incrementButton);
    });

     bridge.attachView(appRoot, await rootView);
   
  }
}
