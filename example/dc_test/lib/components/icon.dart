import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class Icon extends UIComponent {
  Icon._create(super.id);

  static Future<Icon?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('ImageView');
    return id != null ? Icon._create(id) : null;
  }

  Future<Icon> loadSvg(String svgPath) async {
    await NativeUIBridge().updateView(id, {'svg': svgPath});
    return this;
  }

  Future<Icon> tint(String color) async {
    await NativeUIBridge().updateView(id, {'tintColor': color});
    return this;
  }
}
