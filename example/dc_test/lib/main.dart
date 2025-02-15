import 'dart:math';
import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart'
    show Colors, runApp, SizedBox, WidgetsFlutterBinding, EdgeInsets;

final _bridge = NativeUIBridge();
final _random = Random();
final _colors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.amber,
  Colors.indigo
];

void main() {
  runApp(const SizedBox());
  mainApp();
}

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final counter = ValueNotifier(0);

  final rootInfo = await _bridge.getRootView();
  if (rootInfo == null || rootInfo['viewId'] == null) return;

  final mainStack = await _bridge.createView('StackView',
      layout: Layout(
        mainAxisAlignment: MainAxisAlignment.start,
        width: ViewSizeUtils.fillWidth,
        height: ViewSizeUtils.fillHeight,
      ));
  await _bridge.attachView(rootInfo['viewId'] as String, mainStack!);

  final topBar = await _bridge.createView('StackView',
      layout: Layout(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        width: ViewSizeUtils.fillWidth,
        height: ViewSizeUtils.height(100),
        padding: EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.grey[200],
      ));
  await _bridge.attachView(mainStack, topBar!);

  final leadingButton = await _bridge.createView(
    'Button',
    layout: Layout(height: ViewSizeUtils.height(44)),
  );
  await _bridge.attachView(topBar, leadingButton!);
  await _bridge.updateView(leadingButton, {'title': 'Menu'});

  final titleLabel = await _bridge.createView('Label');
  await _bridge.attachView(topBar, titleLabel!);
  await _bridge.updateView(titleLabel, {'text': 'Count: 0'});

  final listView = await _bridge.createListView(
    direction: ScrollDirection.vertical,
    spacing: 12,
    padding: EdgeInsets.all(16),
  );
  await _bridge.attachView(mainStack, listView!.viewId);

  final actionButton = await _bridge.createView(
    'Button',
    layout: Layout(height: ViewSizeUtils.height(44)),
  );
  await _bridge.attachView(topBar, actionButton!);
  await _bridge.updateView(actionButton, {'title': 'Add'});
  await _bridge.setViewBackgroundColor(actionButton, Colors.blue);

  await _bridge.registerEvent(actionButton, 'onClick', () async {
    counter.value++;
    await _bridge.updateView(titleLabel, {'text': 'Count: ${counter.value}'});

    await listView.addItem(() async {
      final itemStack = await _bridge.createView('StackView',
          layout: Layout(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            padding: EdgeInsets.all(16),
            backgroundColor: _colors[_random.nextInt(_colors.length)],
            height: ViewSizeUtils.height(60),
            width: ViewSizeUtils.fillWidth,
          ));

      if (itemStack == null) return null;

      final itemLabel = await _bridge.createView('Label');
      await _bridge.attachView(itemStack, itemLabel!);
      await _bridge.updateView(itemLabel, {
        'text': 'Item #${counter.value}',
        'textColor': Colors.white,
      });

      return itemStack;
    });
  });
}

class ValueNotifier<T> {
  T _value;
  T get value => _value;
  set value(T newValue) => _value = newValue;
  ValueNotifier(this._value);
}
