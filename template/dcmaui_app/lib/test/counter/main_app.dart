import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

import 'package:dc_test/templating/framework/index.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  final counter = UseState<int>('counter', 0);

  @override
  VNode buildRender() {
    // CRITICAL FIX: Add extensive debug output
    debugPrint('MainApp: Building render with counter=${counter.value}');

    // Return a simple UI to verify rendering is working
    return DCSafeAreaView(
      style: ViewStyle(
        padding: EdgeInsets.all(20),
        height: 100,
        backgroundColor: Colors.blue,
        display: 'flex',
      ),
      children: [
        DCSwitch(value: true, onValueChange: (v) => print(v)),
        DCSwitch(value: true, onValueChange: (v) => print(v)),
        DCSwitch(value: true, onValueChange: (v) => print(v)),
        DCImage(
            style: DCImageStyle(
                backgroundColor: Colors.pink,
                height: 150,
                objectFit: BoxFit.fitHeight,
                borderRadius: BorderRadius.circular(20)),
            source: DCImageSource(
                uri:
                    "data:image/jpeg;base64,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")),
        DCCheckbox(
            value: true,
            onChange: (v) => print(v),
            style: DCCheckboxStyle(
                boxSize: 50,
                checkedColor: Colors.red,
                margin: EdgeInsets.all(20))),
        DCModal(
            visible: true,
            closeByBackdrop: true,
            onDismiss: () => debugPrint("Modal dismissed"),
            onShow: () => debugPrint("Showing Modal"),
            statusBarTranslucent: true,
            shouldCloseOnOverlayTap: true,
            animationType: 'slide',
            children: [
              DCText(text: 'Hello World'),
              DCButton(title: 'Close', onPress: () => print('Close')),
            ]),
        DCActivityIndicator(
            animating: true,
            size: 'large',
            style: ViewStyle(backgroundColor: Colors.red)),

        DCTextInput(
            autoCapitalize: 'none',
            keyboardType: 'number-pad',
            placeholder: "Enter a number",
            style: DCTextInputStyle(backgroundColor: Colors.green)),
        DCScrollView(),
        DCText(
          text: 'Counter: ${(counter.value)}',
          style: DCTextStyle(
            color: Colors.orange,
            fontSize: 24,
            fontWeight: "bold",
          ),
        ),

        DCButton(
          title: "Increment",
          onPress: () {
            debugPrint(
                'Button pressed - incrementing counter from ${counter.value} to ${counter.value + 1}');
            int newValue = counter.value + 1;
            counter.value = newValue;
            debugPrint('Counter should now be: $newValue');
          },
        ),

        // CRITICAL FIX: Add a button with explicit no-param signature for testing
        DCButton(
          title: "Test No Params",
          onPress: () {
            debugPrint('Button pressed with no params function');
          },
        ),

        // CRITICAL FIX: Add a button with explicit param signature for testing
        DCTouchableHighlight(
          style: ViewStyle(backgroundColor: Colors.yellow, height: 50),
          onPress: () {
            debugPrint('Button pressed with param function, param: ');
          },
        ),
      ],
    ).build();
  }
}
