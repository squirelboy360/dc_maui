import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class Stack extends UIComponent {
  Stack._create(super.id);

  static Future<Stack?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('StackView');
    return id != null ? Stack._create(id) : null;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }

  Future<Stack> addAll(List<UIComponent> children) async {
    for (final child in children) {
      await add(child);
    }
    return this;
  }
}
