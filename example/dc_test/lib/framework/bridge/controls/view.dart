import 'package:dc_test/framework/bridge/types/view_types/view_styles.dart';

import '../types/layout_layouts/yoga_types.dart';
import '../core.dart';

class View {
  String? id;
  final ViewStyle style;
  final YogaLayout layout; // Changed from Map to YogaLayout

  View({
    this.style = const ViewStyle(),
    this.layout = const YogaLayout(),
  });

  Future<String?> create({EventCallback? onEvent}) async {
    id = await Core.createView(
      viewType: 'View',
      properties: {
        'style': style.toMap(),
        'layout': layout.toMap(), // Using YogaLayout's toMap directly
        if (onEvent != null) 'events': {'onEvent': true},
      },
      onEvent: onEvent,
    );
    return id;
  }
}
