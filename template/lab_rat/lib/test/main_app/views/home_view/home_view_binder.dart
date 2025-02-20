part of '../../imports.dart';

class HomeViewBinder extends HomeViewComponents {
  Future<void> mountHome() async {
    final getAppRoot = await Core().getRootView();
    final appRoot = getAppRoot?['viewId'] as String;

    // Attach root view to app root
    await bridge.attachView(appRoot, await rootView);

    // Build header section
    await bridge.attachView(await rootView, await header);
    await bridge.attachView(await header, await profileImage);
    await bridge.attachView(await header, await userName);

    // Build scrollable content
    // await bridge.attachView(await rootView, await scrollContent);
    await bridge.attachView(await rootView, await itemsList);

    // Add floating action button
    await bridge.attachView(await rootView, await actionButton);
  }
}
