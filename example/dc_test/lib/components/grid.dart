import 'component_interface.dart';
import '../ui_apis.dart';

class GridView extends UIComponent {
  GridView._create(super.id);

  static Future<GridView?> create() async {
    final bridge = NativeUIBridge();
    final id = await bridge.createView('GridView');
    return id != null ? GridView._create(id) : null;
  }

  Future<GridView> setLayout({
    required int columns,
    double spacing = 8,
    double lineSpacing = 8,
  }) async {
    await NativeUIBridge().updateView(id, {
      'columns': columns,
      'spacing': spacing,
      'lineSpacing': lineSpacing,
    });
    return this;
  }
}
