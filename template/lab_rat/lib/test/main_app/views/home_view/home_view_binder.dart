part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {
  Future<void> mountHome() async {
    // Mount view hierarchy in correct order
    await bridge.attachView(await bridge.appRoot(), await rootView);

    // Mount header
    await bridge.attachView(await rootView, await header);
    await bridge.attachView(await header, await title);

    // Mount main content container
    await bridge.attachView(await rootView, await content);

    // Mount sidebar and main area in content
    await bridge.attachView(await content, await sidebar);
    await bridge.attachView(await content, await title);
    await bridge.attachView(await content, await mainArea);


    // Mount FAB last to ensure it's on top
    await bridge.attachView(await rootView, await fab);
  }
}
