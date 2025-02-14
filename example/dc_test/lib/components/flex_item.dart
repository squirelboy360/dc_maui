import 'component_interface.dart';

class FlexItem<T extends UIComponent> {
  final T component;
  final int flex;
  
  FlexItem(this.component, {this.flex = 1});
  
  Future<void> applyFlex() async {
    await component.flex(flex);
  }
}
