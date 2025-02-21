import 'dart:ui';

import '../types/view_types.dart';
import '../types/yoga_types.dart';
import '../core.dart';

class View {
  String? id;
  final ViewStyle style;
  final Map<String, YogaValue> layout;

  View({
    this.style = const ViewStyle(),  // Now using const constructor
    this.layout = const {},          // Map is already const-compatible
  });

  Future<String?> create({EventCallback? onEvent}) async {
    id = await Core.createView(
      viewType: 'View',
      properties: {
        'style': style.toMap(),
        'layout': layout.map((key, value) => MapEntry(key, value.toMap())),
        if (onEvent != null) 'events': {'onEvent': true},
      },
      onEvent: onEvent,
    );
    return id;
  }

  Future<bool> update() async {
    if (id == null) return false;
    return await Core.updateView(
      id!,
      properties: {
        'style': style.toMap(),
        'layout': layout.map((key, value) => MapEntry(key, value.toMap())),
      },
    );
  }
}
