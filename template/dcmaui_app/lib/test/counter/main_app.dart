import 'package:dc_test/templating/framework/controls/section_list.dart';
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
    final showInfo = useState<bool>('showInfo', false);
    return DCSafeAreaView(
        style: ViewStyle(backgroundColor: Colors.indigoAccent),
        children: [
          DCView(style: ViewStyle(backgroundColor: Colors.amber,height: 300), children: [
            DCTouchableOpacity(
              style: ViewStyle(alignSelf: 'center'),
                onPress: () {
                  counter.value++;
                  showInfo.value = true;
                },
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
                ]),
            DCModal(visible: showInfo.value, children: [
              DCView(
                  style: ViewStyle(height: 50, backgroundColor: Colors.green),
                  children: [
                    DCText(
                        text: "Insets: ${showInfo.value}",
                        style: DCTextStyle(fontSize: 20))
                  ])
            ]),
          ])
        ]).build();
  }
}
