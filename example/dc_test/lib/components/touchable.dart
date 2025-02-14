import 'component_interface.dart';
import '../ui_apis.dart';

class TouchableOpacity extends UIComponent {
  TouchableOpacity._create(super.id);
  
  static Future<TouchableOpacity?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('TouchableOpacity');
    return id != null ? TouchableOpacity._create(id) : null;
  }

  Future<TouchableOpacity> setActiveOpacity(double value) async {
    await NativeUIBridge().updateView(id, {'activeOpacity': value});
    return this;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }
}
