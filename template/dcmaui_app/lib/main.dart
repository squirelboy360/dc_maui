import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/checkbox.dart';
import 'package:dc_test/templating/framework/controls/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/controls/switch.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/touchable.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/context.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/extensions/native_method_channels+vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/hooks/index.dart';
import 'package:dc_test/templating/framework/utility/flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide TextStyle, View, Text, Checkbox, Switch;
import 'dart:math' as math;
import 'dart:async';

class MainApp extends Component {
  @override
  VNode render() {
    return View().build();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MainViewCoordinatorInterface.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to initialize MainViewCoordinatorInterface: $e');
    }
  }

  // Create a VDOM instance with native capabilities
  final vdom = NativeVDOM();

  // Create root app component
  final app =
      ElementFactory.createComponent(() => MainApp(), {'key': 'root-app'});

  try {
    vdom.render(app);
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to render app: $e');
    }
  }

  MainViewCoordinatorInterface.logNativeViewTree();
}
