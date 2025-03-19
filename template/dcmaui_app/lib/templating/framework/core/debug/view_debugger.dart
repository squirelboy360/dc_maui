import 'package:flutter/foundation.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Helper class for debugging view hierarchy issues in DC MAUI Framework
class ViewDebugger {
  /// Enable detailed rendering logs
  static bool enableRenderLogs = true;

  /// Enable view hierarchy dump
  static bool enableHierarchyDump = false;

  /// Log rendering of a node
  static void logRender(String nodeType, String? nodeId,
      {Map<String, dynamic>? props}) {
    if (!enableRenderLogs) return;

    String propsString = props != null
        ? props.entries
            .map((e) => '${e.key}: ${_formatValue(e.value)}')
            .join(', ')
        : 'null';

    debugPrint(
        'DC RENDER: $nodeType${nodeId != null ? " ($nodeId)" : ""} - props: {$propsString}');
  }

  /// Print a view hierarchy for debugging
  static void dumpHierarchy(VNode node, [int depth = 0]) {
    if (!enableHierarchyDump) return;

    String indent = '  ' * depth;
    String nodeType = node.runtimeType.toString();
    String props = node.props?.toString() ?? 'null';

    debugPrint('$indent$nodeType - $props');

    for (var child in node.children) {
      dumpHierarchy(child, depth + 1);
    }
  }

  /// Format values for logging
  static String _formatValue(dynamic value) {
    if (value is Function) {
      return 'Function';
    } else if (value is Map) {
      return '{...}';
    } else if (value is List) {
      return '[...]';
    } else {
      return value.toString();
    }
  }
}
