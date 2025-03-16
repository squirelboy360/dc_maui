import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  @override
  VNode render() {
    return DCView(
      props: DCViewProps(
        style: DCViewStyle(
          padding: EdgeInsets.all(100),
          backgroundColor: Colors.amber,
        ),
      ),
      children: [
        DCView(
          props: DCViewProps(
            style: DCViewStyle(
              backgroundColor: Colors.indigo,
            ),
          ),
          children: [
            DCButton(
              title: "DCButton 1",
              onPress: (p0) {
                print('DCButton 1 pressed');
              },
            ),

            
            DCText(
              style: TextStyle(
                color: Colors.red,
              ),
              'Hello, World!',
            ),
            DCText(
              'Hello, World!',
            ),
            DCText(
              style: TextStyle(
                color: Colors.red,
              ),
              'Hello, World!',
            ),
            DCText(
              'Hello, World!',
            ),
            DCText(
              style: TextStyle(
                color: Colors.red,
              ),
              'Hello, World!',
            ),
            DCText(
              'Hello, World!',
            ),
          ],
        ),
      ],
    ).build();
  }
}
