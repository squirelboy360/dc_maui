import 'package:dc_test/framework/layout/layout_config.dart';
import 'package:dc_test/framework/style/view_style.dart';

enum ViewType {
  view,
  label,
  button,
  touchableOpacity,
  scrollable,
  listView;

  String get value {
    switch (this) {
      case ViewType.view:
        return 'View';
      case ViewType.label:
        return 'Label';
      case ViewType.button:
        return 'Button';
      case ViewType.touchableOpacity:
        return 'TouchableOpacity';
      case ViewType.scrollable:
        return 'Scrollable';
      case ViewType.listView:
        return 'ListView';
    }
  }
}


// Example usage:
/*
final listView = bridge.createView(
  ViewType.listView,
  layout: LayoutConfig(
    flex: 1,
    width: LayoutConfig.percent(100),
    height: LayoutConfig.percent(100),
    padding: EdgeInsets.all(16),
  ),
  style: ViewStyle(
    backgroundColor: Colors.white,
  ),
  scrollEvents: {
    ScrollEventType.onScroll: (data) {
      print('Scrolling: ${data.y}');
    },
  },
);

final scrollView = bridge.createView(
  ViewType.scrollable,
  layout: LayoutConfig(
    flex: 1,
    alignItems: YGAlign.center,
    justifyContent: YGJustify.flexStart,
    display: YGDisplay.flex,
  ),
  style: ViewStyle(
    backgroundColor: Colors.white,
  ),
);
*/

// Add ListView data type
class ListViewItem {
  final ViewType viewType;
  final ViewStyle style;
  final LayoutConfig layout;

  const ListViewItem({
    required this.viewType,
    required this.style,
    required this.layout,
  });

  Map<String, dynamic> toJson() => {
        'type': viewType.value,
        'properties': style.toJson(),
        'layout': layout.toJson(),
      };
}

// Usage example:
/*
listViewData: List.generate(
  20,
  (index) => ListViewItem(
    viewType: ViewType.view,
    style: ViewStyle(
      backgroundColor: Colors.white,
      cornerRadius: 8.0,
      shadows: [
        ShadowStyle(
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 2),
          radius: 4.0,
        )
      ],
    ),
    layout: LayoutConfig(
      height: LayoutConfig.points(80),
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
    ),
  ),
)
*/
