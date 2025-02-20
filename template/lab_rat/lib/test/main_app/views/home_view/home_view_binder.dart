part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {
  Future<void> mountHome() async {
    final appRoot = (await Core().getRootView())?['viewId'] as String;

    // Mount root
    await bridge.attachView(appRoot, await rootView);

    // Mount list
    await bridge.attachView(await rootView, await itemsList);

    await bridge.attachView(await rootView, await appBar);

    // Mount FAB
    // await bridge.attachView(await rootView, await fab);
  }
}
