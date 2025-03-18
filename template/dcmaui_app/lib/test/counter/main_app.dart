import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/index.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  @override
  VNode render() {
    // Using hooks for state management
    final counter = UseState<int>('counter', 0);

    // CRITICAL FIX: Add debug output
    debugPrint('MainApp: Rendering with counter=${counter.value}');

    // CRITICAL FIX: Don't call .build() here - the Component base class will do it
    return DCView(
      style: ViewStyle(
        padding: EdgeInsets.all(10),
        backgroundColor: Colors.amber,
      ),
      children: [
        DCView(
          style: ViewStyle(
            height: 500,
            width: 20,
            backgroundColor: Colors.green,
            padding: EdgeInsets.all(20),
          ),
          children: [
            DCButton(
              title: "Increment Counter",
              onPress: () {
                // Simpler state update with hooks
                counter.value += 1;
              },
            ),
            DCText(
              text: 'Counter: ${counter.value}',
              style: DCTextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: "bold",
              ),
            ),
            DCText(
              text: 'Using DC framework with hooks',
              style: DCTextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    ).build();
  }
}
