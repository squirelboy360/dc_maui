import 'package:dc_test/framework/bridge/controls/text.dart';
import 'package:dc_test/framework/bridge/types/view_types/view_styles.dart';
import 'package:flutter/material.dart' hide View, Text; // Hide Flutter's View
import 'package:logging/logging.dart';
import 'framework/bridge/core.dart';
import 'framework/bridge/controls/view.dart';
import 'framework/bridge/types/layout_layouts/yoga_types.dart';

final _logger = Logger('GridExample');

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Move this up
  // runApp(SizedBox());
  startApp();
}

Future<void> startApp() async {
  try {
    await Core.initialize();
    final rootInfo = await Core.getRootView();
    if (rootInfo == null) {
      debugPrint('Failed to get root view');
      return;
    }

    final mainContainer = await View(
      style: ViewStyle(
        backgroundColor: Colors.white.toARGB32(),
      ),
      layout: YogaLayout(
        flex: 1,
        flexDirection: YogaFlexDirection.column, // Try changing to row
      ),
    ).create();

    final appbar = await View(
            style: ViewStyle(backgroundColor: Colors.amber.toARGB32()),
            layout: YogaLayout(
                width: YogaValue(100, YogaUnit.percent),
                height: YogaValue(100, YogaUnit.point)))
        .create();

    final gridContainerColumn = await View(
      style: ViewStyle(
        backgroundColor: Colors.black.toARGB32(),
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        alignContent: YogaAlign.center,
        height: YogaValue(100, YogaUnit.percent),
        width: YogaValue(100, YogaUnit.percent),
        justifyContent: YogaJustify.center,
        alignItems: YogaAlign.spaceBetween,
        flexDirection: YogaFlexDirection.column,
      ),
    ).create();

    final gridContainer = await View(
      style: ViewStyle(
        backgroundColor: Colors.red.toARGB32(),
      ),
      layout: YogaLayout(
        display: YogaDisplay.flex,
        width: YogaValue(100, YogaUnit.percent),
        height: YogaValue(100, YogaUnit.percent),
        flexDirection: YogaFlexDirection.row,
        flex: 10,
        padding: EdgeValues(all: YogaValue.point(16)),
        flexWrap: YogaWrap.wrapReverse,
        alignContent: YogaAlign.center,
        justifyContent: YogaJustify.center,
      ),
    ).create();

    final colors = [
      0xFFE57373,
      0xFF81C784,
      0xFF64B5F6,
      0xFFFFB74D,
      0xFFBA68C8,
      0xFF4DB6AC,
      0xFFFFD54F,
      0xFFFFD54F,
      0xFF7986CB,
    ];

    Future<void> gridView() async {
      for (var color in colors) {
        final gridItem = await View(
          style: ViewStyle(
            backgroundColor: color,
            cornerRadius: 8,
            shadow: ViewShadow(
              color: Color.fromARGB(255, 28, 213, 65),
              opacity: 0.2,
              offset: Offset(0, 4),
              radius: 8,
            ),
          ),
          layout: YogaLayout(
            padding: EdgeValues(all: YogaValue(8, YogaUnit.point)),
            width: YogaValue(100, YogaUnit.point),
            height: YogaValue(100, YogaUnit.point),
            margin: EdgeValues(all: YogaValue(8, YogaUnit.point)),
          ),
        ).create(
          onEvent: (type, data) {
            _logger.info('Grid item event: $type, data: $data');
          },
        );
        await Core.attachView(gridContainer ?? '', gridItem ?? '');
      }
    }

    final bottomButton = await View(
            style: ViewStyle(
                backgroundColor: Colors.blueAccent.toARGB32(),
                cornerRadius: 20),
            layout: YogaLayout(
                display: YogaDisplay.flex,
                flex: 2.5,
                margin: EdgeValues(all: YogaValue(5, YogaUnit.point)),
                alignSelf: YogaAlign.center,
                height: YogaValue(60, YogaUnit.point),
                width: YogaValue(200, YogaUnit.point),
                alignContent: YogaAlign.center,
                justifyContent: YogaJustify.center,
                alignItems: YogaAlign.center))
        .create();

    // final buttonText = await Text(text: "Sample Text").create();

    // attach
    await Core.attachView('root', mainContainer ?? '');
    await Core.attachView(mainContainer ?? '', appbar ?? 'appbar is null');
    await Core.attachView(mainContainer ?? '',
        gridContainerColumn ?? 'gridContainerColumn is null');

    await Core.attachView(gridContainerColumn ?? '', gridContainer ?? '');
    gridView();
    await Core.attachView(gridContainerColumn ?? '', bottomButton ?? '');

    //
  } catch (e) {
    debugPrint('Error in startApp: $e');
  }
}
