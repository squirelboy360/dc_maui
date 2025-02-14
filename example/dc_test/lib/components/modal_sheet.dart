import 'component_interface.dart';
import '../ui_apis.dart';

class ModalSheet extends UIComponent {
  ModalSheet._create(super.id);

  static Future<ModalSheet?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('ModalSheet');
    return id != null ? ModalSheet._create(id) : null;
  }

  Future<ModalSheet> setConfig({
    double height = 300,
    bool isDraggable = true,
    double cornerRadius = 16,
    String backgroundColor = '#FFFFFF',
    bool enableDragToDismiss = true,
    double dragDismissThreshold = 0.3,
  }) async {
    await NativeUIBridge().updateView(id, {
      'height': height,
      'isDraggable': isDraggable,
      'cornerRadius': cornerRadius,
      'backgroundColor': backgroundColor,
      'enableDragToDismiss': enableDragToDismiss,
      'dragDismissThreshold': dragDismissThreshold,
    });
    return this;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }

  Future<bool> present({bool animated = true}) async {
    return await NativeUIBridge().updateView(id, {
      'action': 'present',
      'animated': animated
    });
  }

  Future<bool> dismiss({bool animated = true}) async {
    return await NativeUIBridge().updateView(id, {
      'action': 'dismiss',
      'animated': animated
    });
  }

  Future<ModalSheet> onDismiss(Function() callback) async {
    await NativeUIBridge().registerEvent(id, 'onDismiss', callback);
    return this;
  }
}
