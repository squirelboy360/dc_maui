import '../ui_composer.dart';
import '../bridge/controls/touchable.dart' as native;
import '../bridge/types/layout_layouts/yoga_types.dart';

typedef OnPressCallback = void Function();

class DCTouchable extends UIComponent<native.Touchable> {
  final native.TouchableStyle? touchableStyle;
  final YogaLayout? yogaLayout;
  final OnPressCallback? onPress;
  final OnPressCallback? onLongPress;
  final OnPressCallback? onPressIn;
  final OnPressCallback? onPressOut;

  DCTouchable({
    this.touchableStyle,
    this.yogaLayout,
    this.onPress,
    this.onLongPress,
    this.onPressIn,
    this.onPressOut,
    List<UIComponent> children = const [],
  }) {
    if (touchableStyle != null) {
      style.addAll(touchableStyle!.toMap());
    }
    if (yogaLayout != null) {
      layout.addAll(yogaLayout!.toMap());
    }
    
    properties['events'] = {
      if (onPress != null) 'onPress': true,
      if (onLongPress != null) 'onLongPress': true,
      if (onPressIn != null) 'onPressIn': true,
      if (onPressOut != null) 'onPressOut': true,
    };
    
    this.children.addAll(children);
  }

  @override
  Future<String?> _createComponent() async {
    final touchable = native.Touchable(
      style: touchableStyle ?? const native.TouchableStyle(),
      layout: yogaLayout ?? const YogaLayout(),
      onPress: onPress,
      onLongPress: onLongPress,
      onPressIn: onPressIn,
      onPressOut: onPressOut,
    );
    
    final id = await touchable.create();
    return id;
  }
}
