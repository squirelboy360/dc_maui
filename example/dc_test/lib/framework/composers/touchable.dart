import '../bridge/controls/touchable.dart' as bridge;
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../ui_composer.dart';

class DCTouchable extends UIComponent<String> {
  final bridge.TouchableStyle touchableStyle;
  final YogaLayout yogaLayout;
  final bridge.TouchCallback? onPress;
  final bridge.TouchCallback? onLongPress;
  final bridge.TouchCallback? onPressIn;
  final bridge.TouchCallback? onPressOut;

  DCTouchable({
    this.touchableStyle = const bridge.TouchableStyle(),
    this.yogaLayout = const YogaLayout(),
    this.onPress,
    this.onLongPress,
    this.onPressIn,
    this.onPressOut,
    List<UIComponent> children = const [],
  }) {
    style = touchableStyle.toMap();
    layout = yogaLayout.toMap();
    this.children = List.from(children);
  }

  @override
  Future<String?> createComponent() async {
    final touchable = bridge.Touchable(
      style: touchableStyle,
      layout: yogaLayout,
      onPress: onPress,
      onLongPress: onLongPress,
      onPressIn: onPressIn,
      onPressOut: onPressOut,
    );
    
    return await touchable.create();
  }
}
