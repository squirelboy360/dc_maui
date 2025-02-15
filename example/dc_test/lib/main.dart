import 'dart:math';
import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MainApp');
final NativeUIBridge bridge = NativeUIBridge();

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(
      (record) => debugPrint('${record.level.name}: ${record.message}'));
  runApp(const SizedBox());
  mainApp();
}

class AppState {
  int _counter = 0;
  int get counter => _counter;
  void increment() => _counter++;

  // Add listView property
  ListViewController? listView;
}

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();

  final rootInfo = await bridge.getRootView();
  if (rootInfo == null) return;
  final rootId = rootInfo['viewId'] as String;

  // Create main stack and ensure it fills the root view
  final mainStack = await bridge.createVStack(spacing: 0);
  if (mainStack == null) return;
  await bridge.attachView(rootId, mainStack);
  await bridge.setViewToFillParent(mainStack); // Add this line

  // Create banner and ensure it fills width
  final banner = await _createBanner(state);
  if (banner == null) return;
  await bridge.attachView(mainStack, banner);
  await bridge.setViewToFillWidth(
      banner); // Already in _createBanner but ensure it's here

  // Create and configure list view
  final listView =
      await bridge.createListView(spacing: 8, padding: EdgeInsets.all(16));
  if (listView == null) return;
  await bridge.attachView(mainStack, listView.viewId);
  await bridge.setViewToFillWidth(listView.viewId); // Add this line
  await bridge.setViewLayout(listView.viewId,
      flex: 1); // Add this line to make it fill remaining space

  state.listView = listView;
  _logger.info('UI Setup Complete');
}

Future<String?> _createBanner(AppState state) async {
  final banner = await bridge.createView('View');
  if (banner == null) return null;

  // Set banner background
  await bridge.setViewBackgroundColor(banner, Colors.blue[800]);

  // Create and configure content stack
  final content = await bridge.createHStack(
      spacing: 16,
      alignment: FlexAlignment.spaceBetween,
      padding: EdgeInsets.symmetric(horizontal: 16));
  if (content == null) return null;

  // First attach the content to banner
  await bridge.attachView(banner, content);

  // Then set the content layout
  await bridge.setViewToFillParent(content);

  final leadingBtn = await bridge.createView('Button');
  if (leadingBtn == null) return null;
  await bridge.attachView(content, leadingBtn);
  await bridge.updateView(leadingBtn, {'title': 'Menu'});
  await bridge.setViewBackgroundColor(leadingBtn, Colors.pink);

  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return null;
  await bridge.attachView(content, titleLabel);
  await bridge.updateView(titleLabel,
      {'text': 'App Count: ${state.counter}', 'textColor': Colors.yellow});

  final trailingBtn = await bridge.createView('Button');
  if (trailingBtn == null) return null;
  await bridge.attachView(content, trailingBtn);
  await bridge.updateView(trailingBtn, {'title': 'Add'});
  await bridge.setViewBackgroundColor(trailingBtn, Colors.blue);

  await bridge.registerEvent(trailingBtn, 'onClick', () async {
    state.increment();
    await bridge
        .updateView(titleLabel, {'text': 'App Count: ${state.counter}'});

    final itemBg = await bridge.createView('View');
    if (itemBg == null) return;

    // First set the background color
    final random = Random();
    final color = Color.fromRGBO(
        random.nextInt(255), random.nextInt(255), random.nextInt(255), 1);
    await bridge.setViewBackgroundColor(itemBg, color);

    // Create and configure the label
    final itemLabel = await bridge.createView('Label');
    if (itemLabel == null) return;
    await bridge.attachView(itemBg, itemLabel);
    await bridge.updateView(itemLabel,
        {'text': 'Item ${state.counter}', 'textColor': Colors.blueGrey});
    await bridge.setViewLayout(itemLabel,
        width: -1, height: -1); // Make label fill parent

    // Use the listView's addItem method with proper setup
    await state.listView?.addItem(() async {
      // Set layout properties before returning the view
      await bridge.setViewLayout(itemBg, height: 60);
      await bridge.setViewToFillWidth(itemBg);
      return itemBg;
    });
  });

  // Set banner layout last, after all children are attached
  await bridge.setViewLayout(banner, height: 100);
  await bridge.setViewToFillWidth(banner);

  return banner;
}
