part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {
  Future<void> bindComponents() async {
    final getAppRoot = await Core().getRootView();
    final appRoot = getAppRoot?['viewId'] as String;

    bridge.attachView(appRoot, await rootView);
    bridge.attachView(await rootView, await appbar);
    // appbar attaches
    bridge.attachView(await appbar, await decrementButton);
    bridge.attachView(await appbar, await title);
    bridge.attachView(await appbar, await incrementButton);
  }
}
