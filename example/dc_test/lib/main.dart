import 'package:dc_test/framework/bridge/types/view_styles.dart';
import 'package:flutter/material.dart' hide View; // Hide Flutter's View
import 'package:logging/logging.dart';
import 'framework/bridge/core.dart';
import 'framework/bridge/controls/view.dart';
import 'framework/bridge/types/yoga_types.dart';
import 'framework/bridge/types/view_types.dart';

final _logger = Logger('GridExample');

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Move this up
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(
      (record) => debugPrint('${record.level.name}: ${record.message}'));

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

    final rootId = rootInfo['viewId'] as String;
    print(rootId);

    final mainContainer = await View(
      style: ViewStyle(
        backgroundColor: 0xFFFAFAFA,
      ),
      layout: YogaLayout(
        flexDirection: YogaFlexDirection.column,
        padding:
            EdgeValues(all: YogaValue.point(16)), // Use static constructors
        flexWrap: YogaWrap.wrap,
        justifyContent: YogaJustify.spaceEvenly,
        alignItems: YogaAlign.center,
        width: YogaValue.percent(100), // Use static constructors
        height: YogaValue.percent(100),
      ),
    ).create();
    // attach
    Core.attachView(rootId, mainContainer ?? '');
    print("mainContainer: $mainContainer");

    final colors = [
      0xFFE57373,
      0xFF81C784,
      0xFF64B5F6,
      0xFFFFB74D,
      0xFFBA68C8,
      0xFF4DB6AC,
      0xFFFFD54F,
      0xFF7986CB
    ];

    for (var color in colors) {
      final gridItem = await  View(
        style: ViewStyle(
          backgroundColor: color,
          cornerRadius: 8,
          shadow: ViewShadow(
            color: Color.fromARGB(255, 250, 80, 80),
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
      print("itemId: $gridItem");
      await Core.attachView(mainContainer ?? '', gridItem ?? '');
    }
  } catch (e) {
    debugPrint('Error in startApp: $e');
  }
}
