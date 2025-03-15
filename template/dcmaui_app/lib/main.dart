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
import 'package:dc_test/templating/framework/styling/stylesheet.dart';
import 'package:dc_test/templating/framework/utility/flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, View, Text,Checkbox, Switch, ;
import 'dart:math' as math;
import 'dart:async';

// Main component that demonstrates our hook-based state management
class MainApp extends Component {
  late final UseState<String> _themeState;
  late final UseState<int> _counterState;
  late final UseState<bool> _switchState;
  late final UseState<bool> _checkboxState;
  late final UseEffect _timerEffect;

  @override
  void componentWillMount() {
    super.componentWillMount();

    // Initialize hooks with proper types
    _themeState = hooks.useState('theme', 'light');
    _counterState = hooks.useState('counter', 0);
    _switchState = hooks.useState('switchValue', false);
    _checkboxState = hooks.useState('checkboxValue', false);
    _timerEffect = hooks.useEffect('timer');
  }

  @override
  void componentDidMount() {
    super.componentDidMount();

    if (kDebugMode) {
      print('MainApp mounted');
    }

    // Set up timer effect as an example
    _timerEffect.run(() {
      if (kDebugMode) {
        print('Setting up background timer...');
      }

      // Create a timer that runs every 5 seconds
      final timer = Timer.periodic(Duration(seconds: 5), (_) {
        if (kDebugMode) {
          print('Timer tick - current counter: ${_counterState.value}');
        }
      });

      // Return cleanup function
      return () {
        timer.cancel();
        if (kDebugMode) {
          print('Timer cleaned up');
        }
      };
    }, []); // Empty deps array = run only on mount
  }

  void _toggleTheme() {
    final newTheme = _themeState.value == 'light' ? 'dark' : 'light';
    if (kDebugMode) {
      print('Switching theme from ${_themeState.value} to $newTheme');
    }

    // Update theme state
    _themeState.value = newTheme;
    setState({'theme': newTheme});
  }

  void _incrementCounter() {
    final newValue = _counterState.value + 1;
    if (kDebugMode) {
      print('Incrementing counter from ${_counterState.value} to $newValue');
    }

    // Update counter state
    _counterState.value = newValue;
    setState({'counter': newValue});
  }

  void _decrementCounter() {
    if (_counterState.value <= 0) return;

    final newValue = _counterState.value - 1;
    if (kDebugMode) {
      print('Decrementing counter from ${_counterState.value} to $newValue');
    }

    // Update counter state
    _counterState.value = newValue;
    setState({'counter': newValue});
  }

  void _resetCounter() {
    if (kDebugMode) {
      print('Resetting counter from ${_counterState.value} to 0');
    }

    // Reset counter state
    _counterState.value = 0;
    setState({'counter': 0});
  }

  void _handleSwitchChange(bool value) {
    if (kDebugMode) {
      print('Switch toggled from ${_switchState.value} to $value');
    }

    // Update switch state
    _switchState.value = value;
    setState({'switchValue': value});
  }

  void _handleCheckboxChange(bool value) {
    if (kDebugMode) {
      print('Checkbox toggled from ${_checkboxState.value} to $value');
    }

    // Update checkbox state
    _checkboxState.value = value;
    setState({'checkboxValue': value});
  }

  @override
  VNode render() {
    final isDarkTheme = _themeState.value == 'dark';

    if (kDebugMode) {
      print(
          'MainApp rendering - theme: ${_themeState.value}, counter: ${_counterState.value}');
    }

    // Define colors based on theme
    final backgroundColor = isDarkTheme ? Color(0xFF242424) : Color(0xFFFFFFFF);
    final cardColor = isDarkTheme ? Color(0xFF3A3A3A) : Color(0xFFF8F9FA);
    final textColor = isDarkTheme ? Color(0xFFF8F9FA) : Color(0xFF212529);
    final accentColor = Color(0xFF007BFF);
    final dangerColor = Color(0xFFDC3545);
    final successColor = Color(0xFF28A745);

    return View(
      props: ViewProps(
        style: ViewStyle(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(16),
          height: double.infinity,
        ),
      ),
      children: <Control>[
        // Header
        Text(
          'DC MAUI Demo App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
            lineHeight: 1.2,
          ),
        ),

        // Counter Card
        View(
          props: ViewProps(
            style: ViewStyle(
              backgroundColor: cardColor,
              padding: EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(8),
              marginTop: EdgeInsets.only(top: 16),
              marginBottom: EdgeInsets.only(bottom: 16),
            ),
          ),
          children: <Control>[
            Text(
              'Counter: ${_counterState.value}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            View(
              props: ViewProps(
                style: ViewStyle(
                  marginTop: EdgeInsets.only(top: 16),
                ),
              ),
              children: <Control>[
                Button(
                  title: 'Increment (+1)',
                  onPress: (_) => _incrementCounter(),
                  style: {
                    'backgroundColor': '#007bff',
                    'padding': 12.0,
                    'marginTop': 8.0,
                  },
                ),
                Button(
                  title: 'Decrement (-1)',
                  onPress: (_) => _decrementCounter(),
                  style: {
                    'backgroundColor': '#dc3545',
                    'padding': 12.0,
                    'marginTop': 8.0,
                  },
                ),
                Button(
                  title: 'Reset Counter',
                  onPress: (_) => _resetCounter(),
                  style: {
                    'backgroundColor': '#28a745',
                    'padding': 12.0,
                    'marginTop': 8.0,
                  },
                ),
              ],
            ),
          ],
        ),

        // Control Showcase Card
        View(
          props: ViewProps(
            style: ViewStyle(
              backgroundColor: cardColor,
              padding: EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(8),
              marginBottom: EdgeInsets.only(bottom: 16),
            ),
          ),
          children: <Control>[
            Text(
              'Control Showcase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            // Switch Row
            View(
              props: ViewProps(
                style: ViewStyle(
                  marginTop: EdgeInsets.only(top: 16),
                  marginBottom: EdgeInsets.only(bottom: 8),
                ),
              ),
              children: <Control>[
                Text(
                  'Switch Control:',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Switch(
                  value: _switchState.value,
                  onValueChange: _handleSwitchChange,
                  activeTrackColor: successColor,
                ),
              ],
            ),

            // Checkbox Row
            View(
              props: ViewProps(
                style: ViewStyle(
                  marginTop: EdgeInsets.only(top: 16),
                  marginBottom: EdgeInsets.only(bottom: 8),
                ),
              ),
              children: <Control>[
                Text(
                  'Checkbox Control:',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Checkbox(
                  value: _checkboxState.value,
                  onValueChange: _handleCheckboxChange,
                  checkedColor: accentColor,
                ),
              ],
            ),

            // Touchable Demo
            Touchable(
              onPress: () {
                if (kDebugMode) {
                  print('Touchable area pressed!');
                }
              },
              child: View(
                props: ViewProps(
                  style: ViewStyle(
                    backgroundColor:
                        isDarkTheme ? Color(0xFF343A40) : Color(0xFFE9ECEF),
                    padding: EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(6),
                    marginTop: EdgeInsets.only(top: 8),
                  ),
                ),
                children: <Control>[
                  Text(
                    'This is a touchable area - tap me!',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Theme Toggle Button
        Button(
          title: _themeState.value == 'light'
              ? 'Switch to Dark Theme'
              : 'Switch to Light Theme',
          onPress: (_) => _toggleTheme(),
          style: {
            'backgroundColor': '#6c757d',
            'padding': 12,
            'marginTop': 16,
          },
        ),
      ],
    ).build();
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
