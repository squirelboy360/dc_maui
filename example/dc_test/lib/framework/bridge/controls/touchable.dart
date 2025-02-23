import '../core.dart';
import '../types/touchable_types/touchable_styles.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

typedef TouchableEventCallback = void Function(Map<String, dynamic> event);

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
    TouchableEventCallback? onPress,
    TouchableEventCallback? onPressIn,
    TouchableEventCallback? onPressOut,
    TouchableEventCallback? onLongPress,
  }) async {
    print("Creating Touchable with properties: ${touchableStyle.toMap()}");
    
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
        if (event is! Map<String, dynamic>) return;
        
        final type = event['type'] as String?;
        final data = event['data'] as Map<String, dynamic>? ?? {};
        
        switch (type) {
          case 'onPress':
            onPress?.call(data);
            break;
          case 'onPressIn':
            onPressIn?.call(data);
            break;
          case 'onPressOut':
            onPressOut?.call(data);
            break;
          case 'onLongPress':
            onLongPress?.call(data);
            break;
        }
      },
    );
    return id;
  }
}
