import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class Button extends UIComponent {
  Button._create(super.id);

  static Future<Button?> create() async {
    final id = await NativeUIBridge().createView('Button');
    return id != null ? Button._create(id) : null;
  }

  Future<Button> setTitle(String title) async {
    await NativeUIBridge().updateView(id, {'title': title});
    return this;
  }

  @override
  Future<T> onClick<T extends UIComponent>(Function callback) async {
    await NativeUIBridge().registerEvent(id, 'onClick', callback);
    return this as T;
  }

  Future<Button> enable(bool enabled) async {
    await NativeUIBridge().updateView(id, {'isEnabled': enabled});
    return this;
  }
}
