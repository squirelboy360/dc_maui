import 'component_interface.dart';
import '../low_apis/ui_apis.dart';

class ListView extends UIComponent {
  ListView._create(super.id);

  static Future<ListView?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('ListView');
    return id != null ? ListView._create(id) : null;
  }

  Future<ListView> setData<T>({
    required List<T> items,
    required ItemBuilder<T> itemBuilder,
    bool horizontal = false,
    double spacing = 8.0,
    bool separators = false,
  }) async {
    await NativeUIBridge().updateView(id, {
      'horizontal': horizontal,
      'spacing': spacing,
      'separators': separators,
    });

    for (var item in items) {
      final child = await itemBuilder(item);
      await child.attachTo(id);
    }
    return this;
  }

  Future<ListView> onRefresh(Function() callback) async {
    await NativeUIBridge().registerEvent(id, 'onRefresh', callback);
    return this;
  }

  Future<ListView> onLoadMore(Function() callback) async {
    await NativeUIBridge().registerEvent(id, 'onLoadMore', callback);
    return this;
  }
}

typedef ItemBuilder<T> = Future<UIComponent> Function(T item);
