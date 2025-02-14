import 'component_interface.dart';
import '../ui_apis.dart';

class Card extends UIComponent {
  Card._create(super.id);

  static Future<Card?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('Card');
    return id != null ? Card._create(id) : null;
  }

  Future<Card> elevation(double value) async {
    await NativeUIBridge().updateView(id, {'elevation': value});
    return this;
  }
}
