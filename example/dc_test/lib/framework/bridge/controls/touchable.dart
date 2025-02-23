import '../core.dart';
import '../types/touchable_types/touchable_styles.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

typedef TouchableCallback = void Function(Map<String, dynamic> event);

class Touchable {
  String? id;
  final TouchableStyle touchableStyle;
  final ViewStyle style;
  final YogaLayout layout;

  Touchable({
    TouchableStyle? touchableStyle,
    this.style = const ViewStyle(),
    this.layout = const YogaLayout(),
  }) : this.touchableStyle = touchableStyle ?? const TouchableStyle();

  Future<String?> create({
    TouchableCallback? onPress,
    TouchableCallback? onPressIn,
    TouchableCallback? onPressOut,
    TouchableCallback? onLongPress,
  }) async {
    id = await Core.createView(
      viewType: 'TouchableOpacity',
      properties: {
        'touchableStyle': touchableStyle.toMap(),
        'style': style.toMap(),
        'layout': layout.toMap(),
        if (onPress != null ||
            onPressIn != null ||
            onPressOut != null ||
            onLongPress != null)
          'events': {
            if (onPress != null) 'onPress': true,
            if (onPressIn != null) 'onPressIn': true,
            if (onPressOut != null) 'onPressOut': true,
            if (onLongPress != null) 'onLongPress': true,
          },
      },
      onEvent: (event) {
        final type = event['type'] as String;
        switch (type) {
          case 'onPress':
            onPress?.call(event['data'] as Map<String, dynamic>);
            break;
          case 'onPressIn':
            onPressIn?.call(event['data'] as Map<String, dynamic>);
            break;
          case 'onPressOut':
            onPressOut?.call(event['data'] as Map<String, dynamic>);
            break;
          case 'onLongPress':
            onLongPress?.call(event['data'] as Map<String, dynamic>);
            break;
        }
      },
    );
    return id;
  }
}
