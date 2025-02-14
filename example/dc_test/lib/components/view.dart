import 'component_interface.dart';
import '../ui_apis.dart';

class View extends UIComponent {
  View._create(super.id);

  static Future<View?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('View');
    return id != null ? View._create(id) : null;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }
}
