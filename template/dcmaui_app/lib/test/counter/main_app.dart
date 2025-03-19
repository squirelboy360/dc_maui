import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

import 'package:dc_test/templating/framework/index.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  final counter = UseState<int>('counter', 0);

  @override
  VNode buildRender() {
    // CRITICAL FIX: Add extensive debug output
    debugPrint('MainApp: Building render with counter=${state["counter"]}');

    // Return a simple UI to verify rendering is working
    return DCSafeAreaView(
      style: ViewStyle(
        height: 100,
        backgroundColor: Colors.blue,
      ),
      children: [
   
                  DCText(
                    text: 'Counter: ${state["counter"]}',
                    style: DCTextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: "bold",
                    ),
                  ),
                
            
        DCButton(
          title: "Increment",
          onPress: () {
            debugPrint('Button pressed - incrementing counter');
            counter.value++;
          },
        ),
      ],
    ).build();
  }
}
