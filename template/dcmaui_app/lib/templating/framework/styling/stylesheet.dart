import 'dart:collection';

/// StyleSheet utility similar to React Native's StyleSheet
class StyleSheet {
  /// Create a stylesheet from a map of style definitions
  static Map<String, Map<String, dynamic>> create(
      Map<String, Map<String, dynamic>> styles) {
    // In a full implementation, we would do validation, optimization, etc. here
    return Map.unmodifiable(styles);
  }

  /// Flatten styles (resolve any nested style references or arrays)
  static Map<String, dynamic> flatten(dynamic style) {
    if (style == null) return {};

    if (style is Map<String, dynamic>) {
      return style;
    }

    if (style is List) {
      final result = <String, dynamic>{};

      // Apply styles in order, with later styles overriding earlier ones
      for (var s in style) {
        final flatStyle = flatten(s);
        result.addAll(flatStyle);
      }

      return result;
    }

    return {};
  }

  /// Compose multiple styles together
  static List<Map<String, dynamic>> compose(
      List<Map<String, dynamic>?> styles) {
    return styles.where((s) => s != null).cast<Map<String, dynamic>>().toList();
  }

  /// Absolute positioning shorthand
  static Map<String, dynamic> absoluteFill = {
    'position': 'absolute',
    'left': 0,
    'right': 0,
    'top': 0,
    'bottom': 0,
  };

  /// Absolutile positioning helper
  static Map<String, dynamic> absolutePosition(
      double top, double left, double bottom, double right) {
    return {
      'position': 'absolute',
      'top': top,
      'left': left,
      'bottom': bottom,
      'right': right,
    };
  }

  /// Create a hairline border width (platform adaptive)
  static double hairlineWidth = 0.5;
}

/// Example of how to use the StyleSheet:
///
/// ```
/// final styles = StyleSheet.create({
///   'container': {
///     'flex': 1,
///     'backgroundColor': '#fff',
///     'alignItems': 'center',
///     'justifyContent': 'center',
///   },
///   'text': {
///     'color': '#000',
///     'fontSize': 20,
///   },
/// });
///
/// // Usage in a component:
/// View(
///   props: ViewProps(
///     style: styles['container'],
///   ),
///   children: [
///     Text(
///       'Hello, world!',
///       style: TextStyle.fromMap(styles['text']),
///     ),
///   ],
/// )
/// ```
