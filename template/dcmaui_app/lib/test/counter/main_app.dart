import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/controls/low_levels/state_controller.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

import 'package:dc_test/templating/framework/index.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  // CRITICAL FIX: Make counter nullable instead of late to avoid initialization error
  StateValue<int>? counter;

  @override
  void componentDidMount() {
    super.componentDidMount();
    debugPrint("MainApp: Component mounted!");

    // CRITICAL FIX: Initialize counter in componentDidMount and trigger render
    counter = useState<int>('counter', 0);
    debugPrint('MainApp: Initialized counter with value ${counter!.value}');
  }

  // CRITICAL FIX: Explicit method for incrementing to be more React-like
  void incrementCounter() {
    if (counter != null) {
      counter!.value = counter!.value + 1;
      debugPrint(
          'MainApp: Called incrementCounter - should be updating to ${counter!.value}');
    }
  }

  @override
  VNode buildRender() {
    // CRITICAL FIX: Always initialize counter if needed
    counter ??= useState<int>('counter', 0);

    // Get counter value
    final currentCount = counter!.value;
    debugPrint('MainApp: Rendering with counter=$currentCount');

    // CRITICAL FIX: Use simplest possible DOM for testing
    return DCSafeAreaView(
      style: ViewStyle(
        padding: EdgeInsets.all(20),
        backgroundColor: Colors.blue,
        display: 'flex',
      ),
      children: [
        DCText(text: 'Counter: $currentCount'),
        DCButton(
          title: "Increment",
          onPress: () => counter!.value = counter!.value + 1,
        ),
        DCView(
            style: ViewStyle(
              height: 150,
              borderRadius: 20,
              shadowRadius: 20,
              padding: EdgeInsets.all(20),
              position: 'none',
              backgroundColor: Colors.red,
              display: 'flex',
            ),
            children: [
              DCText(text: 'This is a child view'),
              DCButton(
                title: "Decrement",
                onPress: () => counter!.value = counter!.value - 1,
              ),
            ]),
        DCModal(visible: counter!.value > 5, animationType: 'slide', children: [
          DCText(text: 'This is a modal'),
          DCButton(
            title: "Close",
            onPress: () => counter!.value = 0,
          ),
        ]),
      ],
    ).build();
  }
}
