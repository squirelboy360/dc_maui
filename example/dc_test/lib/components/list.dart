import 'component_interface.dart';
import '../ui_apis.dart';

class ListView extends UIComponent {
  ListView._create(super.id);

  static Future<ListView?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('ListView');
    return id != null ? ListView._create(id) : null;
  }

  Future<ListView> setData<T>(
    List<T> items,
    ItemBuilder<T> builder, {
    bool horizontal = false,
    double spacing = 8,
    double lineSpacing = 8,
  }) async {
    await NativeUIBridge().updateView(id, {
      'horizontal': horizontal,
      'spacing': spacing,
      'lineSpacing': lineSpacing,
    });

    for (var item in items) {
      final child = await builder(item);
      await add(child);
    }
    return this;
  }

  Future<T> add<T extends UIComponent>(T child) async {
    await child.attachTo(id);
    return child;
  }
}

typedef ItemBuilder<T> = Future<UIComponent> Function(T item);
