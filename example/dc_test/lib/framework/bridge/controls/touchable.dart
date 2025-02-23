import '../core.dart';
import '../types/layout_layouts/yoga_types.dart';
import '../types/view_types/view_styles.dart';

typedef TouchCallback = void Function();

class TouchableStyle extends ViewStyle {
  final double? activeOpacity;
  final bool? enabled;
  final bool? delaysContentTouches;
  final bool? cancelsTouchesInView;

  const TouchableStyle({
    this.activeOpacity = 0.2,
    this.enabled,
    this.delaysContentTouches,
    this.cancelsTouchesInView,
    super.alpha,
    super.backgroundColor,
    super.cornerRadius,
    super.border,
    super.shadow,
    // ... other ViewStyle properties
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      if (activeOpacity != null) 'activeOpacity': activeOpacity,
      if (enabled != null) 'enabled': enabled,
      if (delaysContentTouches != null) 'delaysContentTouches': delaysContentTouches,
      if (cancelsTouchesInView != null) 'cancelsTouchesInView': cancelsTouchesInView,
    };
  }
}

class Touchable {
  String? id;
  final TouchableStyle style;
  final YogaLayout layout;
  final TouchCallback? onPress;
  final TouchCallback? onLongPress;
  final TouchCallback? onPressIn;
  final TouchCallback? onPressOut;

  Touchable({
    this.style = const TouchableStyle(),
    this.layout = const YogaLayout(),
    this.onPress,
    this.onLongPress,
    this.onPressIn,
    this.onPressOut,
  });

  Future<String?> create() async {
    final events = <String, bool>{
      if (onPress != null) 'onPress': true,
      if (onLongPress != null) 'onLongPress': true,
      if (onPressIn != null) 'onPressIn': true,
      if (onPressOut != null) 'onPressOut': true,
    };

    id = await Core.createView(
      viewType: 'TouchableOpacity',
      properties: {
        'style': style.toMap(),
        'touchableStyle': {
          'activeOpacity': style.activeOpacity,
          'enabled': style.enabled,
          'delaysContentTouches': style.delaysContentTouches,
          'cancelsTouchesInView': style.cancelsTouchesInView,
        },
        'layout': layout.toMap(),
        if (events.isNotEmpty) 'events': events,
      },
      onEvent: _handleEvent,
    );
    
    return id;
  }

  void _handleEvent(String type, dynamic data) {
    switch (type) {
      case 'onPress':
        onPress?.call();
        break;
      case 'onLongPress':
        onLongPress?.call();
        break;
      case 'onPressIn':
        onPressIn?.call();
        break;
      case 'onPressOut':
        onPressOut?.call();
        break;
    }
  }
}
