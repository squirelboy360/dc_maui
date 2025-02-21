part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {
  Future<void> mountHome() async {
    final appRoot = (await Core().getRootView())?['viewId'] as String;

    // Mount root
    await bridge.attachView(appRoot, await rootView);
    await bridge.attachView(await rootView, await appBar);
    // await bridge.attachView(await appBar, await appBarTitle);
    await bridge.attachView(await rootView, await bgShit);
    // Mount list
    // await bridge.attachView(await rootView, await itemsList);

    // Mount FAB
    // await bridge.attachView(await rootView, await fab);
  }
}
