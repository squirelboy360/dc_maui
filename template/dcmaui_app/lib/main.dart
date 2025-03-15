import 'package:dc_test/templating/framework/controls/activity_indicator.dart';
import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/checkbox.dart';
import 'package:dc_test/templating/framework/controls/gesture_detector.dart';
import 'package:dc_test/templating/framework/controls/image.dart';
import 'package:dc_test/templating/framework/controls/list_view.dart';
import 'package:dc_test/templating/framework/controls/low_level/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/controls/modal.dart';
import 'package:dc_test/templating/framework/controls/switch.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/text_input.dart';
import 'package:dc_test/templating/framework/controls/touchable.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/context.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/extensions/native_method_channels+vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/hooks/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, View, Text, Checkbox, Switch, Image, TextInputType;
import 'dart:math' as math;
import 'dart:async';

/// This class demonstrates all our controls and ensures they work with the native implementation
class MauiDemoApp extends Component {
  late final UseState<String> _themeState;
  late final UseState<int> _counterState;
  late final UseState<bool> _switchState;
  late final UseState<bool> _checkboxState;
  late final UseState<String> _inputTextState;
  late final UseState<bool> _modalVisible;
  late final UseState<bool> _isLoading;
  late final UseEffect _timerEffect;

  @override
  void componentWillMount() {
    super.componentWillMount();

    // Initialize hooks with proper types
    _themeState = hooks.useState('theme', 'light');
    _counterState = hooks.useState('counter', 0);
    _switchState = hooks.useState('switchValue', false);
    _checkboxState = hooks.useState('checkboxValue', false);
    _inputTextState = hooks.useState('inputText', '');
    _modalVisible = hooks.useState('modalVisible', false);
    _isLoading = hooks.useState('isLoading', false);
    _timerEffect = hooks.useEffect('timer');
  }

  @override
  void componentDidMount() {
    super.componentDidMount();

    if (kDebugMode) {
      print('MauiDemoApp mounted - This will test all controls with native implementations');
    }

    // Test the native side implementation by logging view tree
    MainViewCoordinatorInterface.logNativeViewTree();

    // Verify all native components are properly registered
    _verifyNativeComponentsRegistration();

    // Set up timer effect as an example
    _timerEffect.run(() {
      if (kDebugMode) {
        print('Setting up background timer for native control tests...');
      }

      // Create a timer that runs every 5 seconds
      final timer = Timer.periodic(Duration(seconds: 5), (_) {
        if (kDebugMode) {
          print('Timer tick - testing native control updates');
        }
        // Toggle loading state to test ActivityIndicator
        _isLoading.value = !_isLoading.value;
        setState({'isLoading': _isLoading.value});
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

  void _verifyNativeComponentsRegistration() {
    // This is a diagnostic method to ensure all our components have native implementations
    final requiredControls = [
      'View', 'Text', 'Button', 'Switch', 'Checkbox', 'Image', 
      'ListView', 'TextInput', 'GestureDetector', 'Modal', 'ActivityIndicator'
    ];
    
    if (kDebugMode) {
      print('NATIVE COMPONENT VERIFICATION:');
      print('The following components must be implemented on native side:');
      for (final control in requiredControls) {
        print('• $control');
      }
      print('Please check iOS ViewFactory.swift and Android ViewFactory.java to ensure all components are registered');
      print('END VERIFICATION');
    }
  }

  void _toggleTheme() {
    final newTheme = _themeState.value == 'light' ? 'dark' : 'light';
    if (kDebugMode) {
      print('Switching theme from ${_themeState.value} to $newTheme');
    }

    _themeState.value = newTheme;
    setState({'theme': newTheme});
  }

  void _incrementCounter() {
    final newValue = _counterState.value + 1;
    _counterState.value = newValue;
    setState({'counter': newValue});
  }

  void _decrementCounter() {
    if (_counterState.value <= 0) return;
    final newValue = _counterState.value - 1;
    _counterState.value = newValue;
    setState({'counter': newValue});
  }

  void _resetCounter() {
    _counterState.value = 0;
    setState({'counter': 0});
  }

  void _handleSwitchChange(bool value) {
    _switchState.value = value;
    setState({'switchValue': value});
  }

  void _handleCheckboxChange(bool value) {
    _checkboxState.value = value;
    setState({'checkboxValue': value});
  }

  void _handleTextInputChange(String value) {
    _inputTextState.value = value;
    setState({'inputText': value});
  }

  void _toggleModal() {
    _modalVisible.value = !_modalVisible.value;
    setState({'modalVisible': _modalVisible.value});
  }

  @override
  VNode render() {
    final isDarkTheme = _themeState.value == 'dark';

    // Define colors based on theme
    final backgroundColor = isDarkTheme ? Color(0xFF242424) : Color(0xFFFFFFFF);
    final cardColor = isDarkTheme ? Color(0xFF3A3A3A) : Color(0xFFF8F9FA);
    final textColor = isDarkTheme ? Color(0xFFF8F9FA) : Color(0xFF212529);
    final accentColor = Color(0xFF007BFF);
    final dangerColor = Color(0xFFDC3545);
    final successColor = Color(0xFF28A745);

    return ListView(
      style: ListViewStyle(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.all(16),
      ),
      children: <Control>[
        // Header
        Text(
          'DC MAUI Controls Demo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            lineHeight: 1.2,
          ),
        ),

        Text(
          'This screen demonstrates all available native controls',
          style: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.7),
            marginTop: EdgeInsets.only(top: 8),
            marginBottom: EdgeInsets.only(bottom: 16),
          ),
        ),

        // Counter Card - Tests Button and Text
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
              'Counter Example (Button)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                marginBottom: EdgeInsets.only(bottom: 12),
              ),
            ),

            Text(
              'Counter: ${_counterState.value}',
              style: TextStyle(
                fontSize: 18,
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
                  style: ButtonStyle(
                    backgroundColor: accentColor,
                    padding: EdgeInsets.all(12),
                    marginTop: EdgeInsets.only(top: 8),
                  ),
                ),
                Button(
                  title: 'Decrement (-1)',
                  onPress: (_) => _decrementCounter(),
                  style: ButtonStyle(
                    backgroundColor: dangerColor,
                    padding: EdgeInsets.all(12),
                    marginTop: EdgeInsets.only(top: 8),
                  ),
                ),
                Button(
                  title: 'Reset Counter',
                  onPress: (_) => _resetCounter(),
                  style: ButtonStyle(
                    backgroundColor: successColor,
                    padding: EdgeInsets.all(12),
                    marginTop: EdgeInsets.only(top: 8),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Text Input Card
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
              'Text Input Example',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                marginBottom: EdgeInsets.only(bottom: 12),
              ),
            ),

            TextInput(
              value: _inputTextState.value,
              placeholder: 'Enter some text',
              onChangeText: _handleTextInputChange,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
              placeholderStyle: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 16,
              ),
              inputStyle: TextInputStyle(
                backgroundColor: isDarkTheme ? Color(0xFF1E1E1E) : Color(0xFFFFFFFF),
                borderColor: Color(0xFFCED4DA),
                borderWidth: 1,
                borderRadius: 6,
                padding: EdgeInsets.all(12),
                marginTop: EdgeInsets.only(top: 8),
                marginBottom: EdgeInsets.only(bottom: 8),
              ),
            ),

            Text(
              _inputTextState.value.isEmpty 
                ? 'Enter text above to see it here'
                : 'You typed: ${_inputTextState.value}',
              style: TextStyle(
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
