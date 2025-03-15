import 'package:dc_test/templating/framework/controls/button.dart';
import 'package:dc_test/templating/framework/controls/component_adapter.dart';
import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/context.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/component_vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/extensions/native_method_channels+vdom.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle, View, Text;

// A theme context for app-wide styling
final themeContext = Context<Map<String, dynamic>>({
  'primaryColor': '#007bff',
  'textColor': '#212529',
  'backgroundColor': '#ffffff',
});

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
          title: 'Increment',
          onPress: (_) => _increment(),
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

  void _toggleCounter() {
    setState({'showCounter': !state['showCounter']});
  }

  void _toggleTheme() {
    setState({'theme': state['theme'] == 'light' ? 'dark' : 'light'});
  }

  @override
  VNode render() {
    if (kDebugMode) {
      print(
          'App rendering with theme: ${state['theme']}, showCounter: ${state['showCounter']}');
    }

    final Color backgroundColor =
        state['theme'] == 'light' ? Color(0xFFFFFFFF) : Color(0xFF343A40);

    final Color textColor =
        state['theme'] == 'light' ? Color(0xFF212529) : Color(0xFFF8F9FA);

    // Create a list of controls for our view
    final List<Control> viewControls = <Control>[
      Text(
        'DC MAUI Demo App',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      Button(
        title: 'Toggle Theme',
        onPress: (_) => _toggleTheme(),
        style: {'marginBottom': 16},
      ),
      Button(
        title: state['showCounter'] ? 'Hide Counter' : 'Show Counter',
        onPress: (_) => _toggleCounter(),
        style: {'marginBottom': 24},
      ),
    ];

    // Conditionally add counter component
    if (state['showCounter']) {
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

  if (kDebugMode) {
    print('\n====== Starting DC MAUI App ======\n');
  }

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

  if (kDebugMode) {
    print('\n====== Starting App Render ======\n');
  }

  // Log detailed VDOM tree before rendering
  _logElementTree(app);

  // Render the app
  try {
    vdom.render(app);
  } catch (e) {
    if (kDebugMode) {
      print('ERROR: Failed to render app: $e');
    }
  }

  if (kDebugMode) {
    print('\n====== VDOM Rendering Complete ======\n');
    print('The app is now running. You should see the UI tree logged above.');
  }

  // Request log of the native view tree after a short delay
  Future.delayed(Duration(seconds: 2), () {
    MainViewCoordinatorInterface.logNativeViewTree();
  });

  // Simulate an event from native side after 3 seconds
  Future.delayed(Duration(seconds: 3), () {
    if (kDebugMode) {
      print('\n====== Simulating Native Event ======\n');
    }
    MainViewCoordinatorInterface.simulateNativeEvent(
        'view_0', 'press', {'x': 100, 'y': 200});
  });
}

// Helper function to log the element tree
void _logElementTree(VNode node, [int depth = 0]) {
  final indent = ' ' * (depth * 2);
  final isComponent = node.props['_isComponent'] == true;

  print(
      '$indent- ${node.type} (${isComponent ? "Component" : "Element"}) key: ${node.key}');

  if (isComponent) {
    print('$indent  ComponentID: ${node.props['_componentId']}');
  } else {
    // Print some key props
    final keyProps = <String, dynamic>{};
    if (node.props.containsKey('style'))
      keyProps['style'] = node.props['style'];
    if (node.props.containsKey('text')) keyProps['text'] = node.props['text'];
    if (node.props.containsKey('title'))
      keyProps['title'] = node.props['title'];
    print('$indent  Props: $keyProps');
  }

  for (final child in node.children) {
    _logElementTree(child, depth + 1);
  }
}
