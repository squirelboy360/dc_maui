import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class TabItem {
  final String screenId;
  final String title;
  final String? icon;
  final Map<String, dynamic>? properties;

  TabItem({
    required this.screenId,
    required this.title,
    this.icon,
    this.properties,
  });

  Map<String, dynamic> toJson() => {
    'screenId': screenId,
    'title': title,
    if (icon != null) 'icon': icon,
    if (properties != null) ...properties!,
  };
}

class TabBar extends UIComponent {
  TabBar._create(super.id);

  static Future<TabBar?> create(List<TabItem> tabs) async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('TabBar', properties: {
      'tabs': tabs.map((t) => t.toJson()).toList(),
    });
    return id != null ? TabBar._create(id) : null;
  }

  Future<TabBar> selectTab(int index) async {
    await NativeUIBridge().updateView(id, {'selectedIndex': index});
    return this;
  }

  Future<TabBar> onTabChanged(Function(int) callback) async {
    await NativeUIBridge().registerEvent(id, 'onTabChanged', (dynamic args) {
      final index = args['index'] as int;
      callback(index);
    });
    return this;
  }
}
