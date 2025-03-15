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
import 'package:dc_test/templating/framework/hooks/index.dart'; // Import our hooks
import 'package:dc_test/templating/framework/utility/flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, View, Text;
import 'dart:math' as math;
import 'dart:async';

// A theme context for app-wide styling
final themeContext = Context<Map<String, dynamic>>({
  'primaryColor': '#007bff',
  'textColor': '#212529',
  'backgroundColor': '#ffffff',
});

// New component for rebuild visualization using the hooks pattern
class RebuildIndicator extends Component {
  // Create hooks
  final _indicatorState = UseState<bool>('active', false);
  final _colorState = UseState<String>('color', '#ffffff');
  final _animationEffect = UseEffect('animation');
  Timer? _resetTimer;

  @override
  void componentDidMount() {
    super.componentDidMount();

    // Register a notification listener
    ComponentEventBus.instance.onRebuild = () {
      flash();
    };
  }

  void flash() {
    // Cancel existing timer if there is one
    _resetTimer?.cancel();

    // Generate a random color
    final random = math.Random();
    final color =
        '#${(random.nextDouble() * 0xFFFFFF).toInt().toRadixString(16).padLeft(6, '0')}';

    // Set state using our hooks
    _colorState.value = color;
    _indicatorState.value = true;

    // Schedule reset back to inactive after animation
    _resetTimer = Timer(Duration(milliseconds: 800), () {
      _indicatorState.value = false;
    });
  }

  @override
  void componentWillUnmount() {
    _resetTimer?.cancel();
    ComponentEventBus.instance.onRebuild = null;

    // Clean up hooks
    _indicatorState.dispose();
    _colorState.dispose();
    _animationEffect.dispose();
  }

  @override
  VNode render() {
    // Create an animated indicator without using transition property
    return View(
      props: ViewProps(
        style: ViewStyle(
          height: 120,
          width: double.infinity,
          backgroundColor: FlutterUtility.hexToColor(_colorState.value),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _indicatorState.value
              ? [
                  BoxShadow(
                    color: FlutterUtility.hexToColor(_colorState.value)
                        .withOpacity(0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
      ),
      children: [],
    ).build();
  }
}

// Event bus for component rebuild notifications
class ComponentEventBus {
  static final ComponentEventBus _instance = ComponentEventBus._internal();
  static ComponentEventBus get instance => _instance;

  ComponentEventBus._internal();

  Function? onRebuild;

  void notifyRebuild() {
    onRebuild?.call();
  }
}

// A counter component that demonstrates state management using hooks
class Counter extends Component {
  // Create hooks for state
  final _counterState = UseState<int>('count', 0);
  final _timerEffect = UseEffect('autoIncrement');

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
  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {
    if (kDebugMode) {
      final oldCount = prevState['count'] ?? 0;
      print('Counter updated from $oldCount to ${_counterState.value}');
    }

    // Notify the rebuild indicator
    ComponentEventBus.instance.notifyRebuild();
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
  Map<String, dynamic> getInitialState() {
    // We still need to provide initial state for Component class compatibility
    return {'count': _counterState.value};
  }

  @override
  VNode render() {
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
  // Create hooks for app state
  final _showCounterState = UseState<bool>('showCounter', true);
  final _themeState = UseState<String>('theme', 'light');

  // Use separate handler methods with distinct identifiers for each button
  void _handleToggleCounter(Map<String, dynamic> _) {
    final bool currentValue = _showCounterState.value;
    debugPrint(
        'App: Toggle counter button pressed, current=${currentValue}, new=${!currentValue}');
    _showCounterState.value = !currentValue;

    // Notify the rebuild indicator
    ComponentEventBus.instance.notifyRebuild();
  }

  void _handleToggleTheme(Map<String, dynamic> _) {
    final String currentTheme = _themeState.value;
    final String newTheme = currentTheme == 'light' ? 'dark' : 'light';
    debugPrint(
        'App: Toggle theme button pressed, current=${currentTheme}, new=${newTheme}');
    _themeState.value = newTheme;

    // Notify the rebuild indicator
    ComponentEventBus.instance.notifyRebuild();
  }

  @override
  void componentWillUnmount() {
    // Clean up hooks
    _showCounterState.dispose();
    _themeState.dispose();
  }

  @override
  Map<String, dynamic> getInitialState() {
    // We still need to provide initial state for Component class compatibility
    return {'showCounter': _showCounterState.value, 'theme': _themeState.value};
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

    // Add our rebuild indicator at the bottom
    final rebuildIndicator = ElementFactory.createComponent(
        () => RebuildIndicator(), {'key': 'rebuild-indicator'});

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

    // Add rebuild indicator at the bottom
    viewControls.add(ComponentAdapter(rebuildIndicator));

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
