import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

import 'package:dc_test/templating/framework/index.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  @override
  void componentDidMount() {
    super.componentDidMount();
    debugPrint("MainApp: Component mounted!");
  }

  @override
  VNode buildRender() {
    final counter = useState<int>('counter', 5);
    final info = useState<Map<String, dynamic>>('showInfo', {});
    return DCSafeAreaView(
        style: ViewStyle(backgroundColor: Colors.indigoAccent),
        onInsetsChange: (v) {
          info.value = v;
        },
        children: [
          DCModal(visible: info.value.isNotEmpty, children: [
            DCView(
                style: ViewStyle(
                    height: 50,
                    backgroundColor: Colors.green.withValues(alpha: 0.1)),
                children: [
                  DCText(
                      text: "Insets: ${info.value}",
                      style: DCTextStyle(fontSize: 20))
                ])
          ]),
          
          DCTouchableOpacity(
              onLongPress: () => debugPrint("long pressed wow"),
              children: [
                DCView(
                    style: ViewStyle(
                        height: 50,
                        backgroundColor: Colors.green.withValues(alpha: 0.1)),
                    children: [
                      DCText(
                          text: "Counter: ${counter.value}",
                          style: DCTextStyle(fontSize: 20))
                    ])
              ])
        ]).build();
  }
}
