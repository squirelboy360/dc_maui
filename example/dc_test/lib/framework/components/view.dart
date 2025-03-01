import '../ui_composer.dart';
import '../bridge/controls/view.dart';
import '../bridge/types/layout_layouts/yoga_types.dart';
import '../bridge/types/view_types/view_styles.dart';

class DCView extends UIComponent<String> {
  final ViewStyle viewStyle;
  final YogaLayout yogaLayout;

  DCView({
    this.viewStyle = const ViewStyle(),
    this.yogaLayout = const YogaLayout(),
    List<UIComponent> children = const [],
  }) {
    style = viewStyle.toMap();
    layout = yogaLayout.toMap();
    this.children = List.from(children);
  }

  @override
  Future<String?> createComponent() async {
    final view = View(
      style: viewStyle,
      layout: yogaLayout,
    );
    
    return await view.create();
  }
}
