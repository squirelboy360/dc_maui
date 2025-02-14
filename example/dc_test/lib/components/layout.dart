import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class HStack extends UIComponent {
  HStack._create(super.id);

  static Future<HStack?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('StackView', properties: {
      'axis': 'horizontal',
      'distribution': 'fill'
    });
    return id != null ? HStack._create(id) : null;
  }

  Future<HStack> spacing(double value) async {
    await NativeUIBridge().updateView(id, {'spacing': value});
    return this;
  }

  Future<T> alignment<T extends UIComponent>(Alignment alignment) async {
    await NativeUIBridge().setAlignment(id, alignment.toString());
    return this as T;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }
}

class VStack extends UIComponent {
  VStack._create(super.id);

  static Future<VStack?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('StackView', properties: {
      'axis': 'vertical',
      'distribution': 'fill'
    });
    return id != null ? VStack._create(id) : null;
  }

  Future<VStack> spacing(double value) async {
    await NativeUIBridge().updateView(id, {'spacing': value});
    return this;
  }

  Future<T> alignment<T extends UIComponent>(Alignment alignment) async {
    await NativeUIBridge().setAlignment(id, alignment.toString());
    return this as T;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }
}
