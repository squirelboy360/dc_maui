part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {


  Future<void> mountHome() async {
    final appRoot = (await Core().getRootView())?['viewId'] as String;

    // Mount root
    await bridge.attachView(appRoot, await rootView);

    // Mount header section
    await bridge.attachView(await rootView, await header);
    await bridge.attachView(await header, await counterDisplay);
    await bridge.attachView(await counterDisplay, await counterText);

    // Mount list
    await bridge.attachView(await rootView, await itemsList);

    // Mount FAB
    await bridge.attachView(await rootView, await fab);
  }
}
