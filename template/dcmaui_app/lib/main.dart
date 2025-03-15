import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/context.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/extensions/native_method_channels+vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/hooks/index.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, View, Text;
import 'dart:async';

// A theme context for app-wide styling
final themeContext = Context<Map<String, dynamic>>({
  'primaryColor': '#007bff',
  'textColor': '#212529',
  'backgroundColor': '#ffffff',
});

class Counter extends Component {
  late final UseState<int> _counterState;
  late final UseEffect _timerEffect;

  Counter() {
    // Initialize hooks with this component
    _counterState = UseState<int>('count', 0, component: this);
    _timerEffect = UseEffect('autoIncrement', component: this);
  }

  @override
  void componentDidMount() {
    if (kDebugMode) {
      print('Counter mounted');
    }

    // Demonstrate useEffect with a timer that increments every 30 seconds
    _timerEffect.run(() {
      if (kDebugMode) {
        print('Setting up auto-increment timer');
      }

      final timer = Timer.periodic(Duration(seconds: 30), (_) {
        _counterState.value += 1;
      });

      // Return cleanup function
      return () {
        if (kDebugMode) {
          print('Cleaning up auto-increment timer');
        }
        timer.cancel();
      };
    }, []); // Empty dependency array means only run on mount
  }

  void _increment() {
    // Use the hook's setter
    _counterState.value += 1;
  }

  @override
  void componentWillUnmount() {
    if (kDebugMode) {
      print('Counter unmounting');
    }

    // Clean up hooks
    _counterState.dispose();
    _timerEffect.dispose();
  }

  @override
  render() {
    if (kDebugMode) {
      print('Counter rendering with count: ${_counterState.value}');
    }

    // Create controls
    final counterView = View(
      props: ViewProps(
        style: ViewStyle(
          padding: EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Color(0xFFF8F9FA),
        ),
      ),
      children: <Control>[
        Text(
          'Counter: ${_counterState.value}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        Button(
          title: 'Increment by 1',
          onPress: (_) => _increment(),
          style: {'backgroundColor': '#6c757d', 'marginTop': 8},
        ),
      ],
    );

    // Convert the View Control into a VNode
    return counterView.build();
  }
}

// App component that uses context and manages child components with hooks
class App extends Component {
  late final UseState<bool> _showCounterState;
  late final UseState<String> _themeState;

  App() {
    // Initialize hooks with this component
    _showCounterState = UseState<bool>('showCounter', true, component: this);
    _themeState = UseState<String>('theme', 'light', component: this);
  }

  // Use separate handler methods with distinct identifiers for each button
  void _handleToggleCounter(Map<String, dynamic> v) {
    if (kDebugMode) {
      print("onpress Event props: $v");
    }
    final bool currentValue = _showCounterState.value;
    debugPrint(
        'App: Toggle counter button pressed, current=${currentValue}, new=${!currentValue}');
    _showCounterState.value = !currentValue;
  }

  void _handleToggleTheme(Map<String, dynamic> _) {
    final String currentTheme = _themeState.value;
    final String newTheme = currentTheme == 'light' ? 'dark' : 'light';
    debugPrint(
        'App: Toggle theme button pressed, current=${currentTheme}, new=${newTheme}');
    _themeState.value = newTheme;
  }

  @override
  void componentWillUnmount() {
    // Clean up hooks
    _showCounterState.dispose();
    _themeState.dispose();
  }

  @override
  VNode render() {
    if (kDebugMode) {
      debugPrint(
          'App rendering with theme: ${_themeState.value}, showCounter: ${_showCounterState.value}');
    }

    final Color backgroundColor =
        _themeState.value == 'light' ? Color(0xFFFFFFFF) : Color(0xFF343A40);
    final Color textColor =
        _themeState.value == 'light' ? Color(0xFF212529) : Color(0xFFF8F9FA);

    final List<Control> viewControls = <Control>[
      Text(
        'DC MAUI Demo App',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),

      // IMPORTANT FIX: Use unique identifiers in button titles to ensure proper event routing
      Button(
        title: _themeState.value == 'light'
            ? '🌙 Switch to Dark Theme'
            : '☀️ Switch to Light Theme',
        onPress: _handleToggleTheme,
        style: {
          'marginBottom': 16,
          'backgroundColor': '#007bff',
          'id': 'theme-button',
          'padding': 12,
        },
      ),

      Button(
        title: _showCounterState.value
            ? '🙈 Hide Counter Component'
            : '👁️ Show Counter Component',
        onPress: _handleToggleCounter,
        style: {
          'marginBottom': 24,
          'backgroundColor': '#28a745',
          'id': 'counter-button',
          'padding': 12,
        },
      ),
    ];

    // Conditionally add counter component
    if (_showCounterState.value) {
      // Create the counter component and wrap it in our adapter
      final counterComponent = ElementFactory.createComponent(
          () => Counter(), {'key': 'main-counter'});
      viewControls.add(ComponentAdapter(counterComponent));
    }
    // Create the root view control
    final rootView = View(
      props: ViewProps(
        style: ViewStyle(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(24),
          height: double.infinity,
        ),
      ),
      children: viewControls,
    );

    // Convert the View Control into a VNode
    return rootView.build();
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

  // Create a VDOM instance with combined component and native capabilities
  final vdom = NativeVDOM();

  // Create root app component
  final app = ElementFactory.createComponent(() => App(), {'key': 'root-app'});
  try {
    vdom.render(app);
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to render app: $e');
    }
  }
  MainViewCoordinatorInterface.logNativeViewTree();
}
