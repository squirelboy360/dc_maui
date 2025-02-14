import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class NavigationBar extends UIComponent {
  NavigationBar._create(super.id);

  static Future<NavigationBar?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('NavigationBar');
    return id != null ? NavigationBar._create(id) : null;
  }

  Future<NavigationBar> setTitle(String title) async {
    await NativeUIBridge().updateView(id, {'title': title});
    return this;
  }

  Future<NavigationBar> setLeftItems(List<BarButtonItem> items) async {
    await NativeUIBridge().updateView(id, {
      'leftItems': items.map((i) => i.toJson()).toList(),
    });
    return this;
  }

  Future<NavigationBar> setRightItems(List<BarButtonItem> items) async {
    await NativeUIBridge().updateView(id, {
      'rightItems': items.map((i) => i.toJson()).toList(),
    });
    return this;
  }

  Future<NavigationBar> setStyle({
    String? backgroundColor,
    String? tintColor,
    bool? translucent,
    double? height,
  }) async {
    await NativeUIBridge().updateView(id, {
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (tintColor != null) 'tintColor': tintColor,
      if (translucent != null) 'translucent': translucent,
      if (height != null) 'height': height,
    });
    return this;
  }
}

class BarButtonItem {
  final String? title;
  final String? icon;
  final Function()? onTap;

  BarButtonItem({this.title, this.icon, this.onTap});

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (icon != null) 'icon': icon,
  };
}
