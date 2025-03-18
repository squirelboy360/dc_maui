import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  @override
  Map<String, dynamic> getInitialState() {
    return {'counter': 0};
  }

  void _incrementCounter() {
    // Get the current counter value
    final counter = state['counter'] as int? ?? 0;
    // Update state with new counter value
    setState({'counter': counter + 1});

    // Debug output to verify state update
    debugPrint('MainApp: State updated, counter is now ${counter + 1}');
  }

  @override
  VNode buildRender() {
    // CRITICAL FIX: Add extensive debug output
    debugPrint('MainApp: Building render with counter=${state["counter"]}');

    // Return a simple UI to verify rendering is working
    return DCView(
      style: ViewStyle(
        height: 100,
        backgroundColor: Colors.blue,
        padding: EdgeInsets.all(20),
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
            _incrementCounter();
          },
        ),
      ],
    ).build();
  }
}
