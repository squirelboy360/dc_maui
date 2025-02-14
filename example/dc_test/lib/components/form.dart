import 'component_interface.dart';
import '../ui_apis.dart';

class Form extends UIComponent {
  Form._create(super.id);

  static Future<Form?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('Form');
    return id != null ? Form._create(id) : null;
  }

  Future<bool> submit() async {
    return await NativeUIBridge().updateView(id, {'action': 'submit'});
  }

  Future<bool> reset() async {
    return await NativeUIBridge().updateView(id, {'action': 'reset'});
  }
}
