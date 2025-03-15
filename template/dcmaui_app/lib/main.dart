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

// New component for rebuild visualization
class RebuildIndicator extends Component {
  // Timer for animation
  Timer? _resetTimer;

  @override
  Map<String, dynamic> getInitialState() {
    return {
      'active': false,
      'color': '#ffffff',
    };
  }

  @override
  void componentDidMount() {
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

    // Set state to show the flash
    setState({
      'active': true,
      'color': color,
    });

    // Schedule reset back to inactive after animation
    _resetTimer = Timer(Duration(milliseconds: 800), () {
      setState({
        'active': false,
      });
    });
  }

  @override
  void componentWillUnmount() {
    _resetTimer?.cancel();
    ComponentEventBus.instance.onRebuild = null;
  }

  @override
  VNode render() {
    return View(
      props: ViewProps(
        style: ViewStyle(
          height: 8,
          width: double.infinity,
          backgroundColor: Color.fromHexString(state['color']),
          borderRadius: BorderRadius.circular(4),
          boxShadow: state['active']
              ? [
                  BoxShadow(
                    color: Color.fromHexString(state['color']).withOpacity(0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : [],
          transition: 'all 0.3s ease',
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

// A counter component that demonstrates state management
class Counter extends Component {
  @override
  Map<String, dynamic> getInitialState() {
    return {'count': 0};
  }

  void _increment() {
    setState({'count': state['count'] + 1});
  }

  @override
  void componentDidMount() {
    if (kDebugMode) {
      print('Counter mounted');
    }
  }

  @override
  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {
    if (kDebugMode) {
      print('Counter updated from ${prevState['count']} to ${state['count']}');
    }

    // Notify the rebuild indicator
    ComponentEventBus.instance.notifyRebuild();
  }

  @override
  void componentWillUnmount() {
    if (kDebugMode) {
      print('Counter unmounting');
    }
  }

  @override
  VNode render() {
    if (kDebugMode) {
      print('Counter rendering with count: ${state['count']}');
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
          'Counter: ${state['count']}',
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

// App component that uses context and manages child components
class App extends Component {
  @override
  Map<String, dynamic> getInitialState() {
    return {'showCounter': true, 'theme': 'light'};
  }

  // Use separate handler methods with distinct identifiers for each button
  void _handleToggleCounter(Map<String, dynamic> _) {
    final bool currentValue = state['showCounter'];
    debugPrint(
        'App: Toggle counter button pressed, current=${currentValue}, new=${!currentValue}');
    setState({'showCounter': !currentValue});

    // Notify the rebuild indicator
    ComponentEventBus.instance.notifyRebuild();
  }

  void _handleToggleTheme(Map<String, dynamic> _) {
    final String currentTheme = state['theme'];
    final String newTheme = currentTheme == 'light' ? 'dark' : 'light';
    debugPrint(
        'App: Toggle theme button pressed, current=${currentTheme}, new=${newTheme}');
    setState({'theme': newTheme});

    // Notify the rebuild indicator
    ComponentEventBus.instance.notifyRebuild();
  }

  @override
  VNode render() {
    if (kDebugMode) {
      debugPrint(
          'App rendering with theme: ${state["theme"]}, showCounter: ${state["showCounter"]}');
    }

    final Color backgroundColor =
        state['theme'] == 'light' ? Color(0xFFFFFFFF) : Color(0xFF343A40);
    final Color textColor =
        state['theme'] == 'light' ? Color(0xFF212529) : Color(0xFFF8F9FA);

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
        title: state['theme'] == 'light'
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
        title: state['showCounter']
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
    if (state['showCounter']) {
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

// Extension method for Color to support hex string creation
extension ColorExtension on Color {
  static Color fromHexString(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The VM service messages are normal and helpful for debugging
  // They indicate that:
  // 1. Your app is running correctly on the device
  // 2. DevTools is available for debugging
  // 3. You have VM service connectivity to the device
  // This is especially important for our framework which uses method channels
  // to communicate between Flutter and native code

  // Initialize the coordinator
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
