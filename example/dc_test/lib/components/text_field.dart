import 'component_interface.dart';
import '../ui_apis.dart';

class TextField extends UIComponent {
  TextField._create(super.id);

  static Future<TextField?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('TextField');
    return id != null ? TextField._create(id) : null;
  }

  Future<TextField> setText(String text) async {
    await NativeUIBridge().updateView(id, {'text': text});
    return this;
  }

  Future<TextField> setPlaceholder(String placeholder) async {
    await NativeUIBridge().updateView(id, {'placeholder': placeholder});
    return this;
  }

  Future<TextField> onTextChanged(Function(String) callback) async {
    await NativeUIBridge().registerEvent(id, 'textChanged', callback);
    return this;
  }

  Future<TextField> setKeyboardType(KeyboardType type) async {
    await NativeUIBridge().updateView(id, {'keyboardType': type.value});
    return this;
  }

  Future<TextField> setSecureTextEntry(bool secure) async {
    await NativeUIBridge().updateView(id, {'secureTextEntry': secure});
    return this;
  }
}

enum KeyboardType {
  text('text'),
  number('number'),
  email('email'),
  phone('phone'),
  url('url');

  final String value;
  const KeyboardType(this.value);
}
