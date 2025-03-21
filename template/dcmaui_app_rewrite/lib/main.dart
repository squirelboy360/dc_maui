import 'package:flutter/material.dart';
import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/renderer/vdom_renderer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startNativeApp();
}

void startNativeApp() async {
  // Create VDOM instance
  final vdom = VDom();

  // Create renderer
  final renderer = VDomRenderer();

  // Create root and store reference
  final root = vdom.createRoot();

  // Initial UI
  final initialTree = VDom.createElement('View', props: {
    'backgroundColor': '#FFFFFF',
    'padding': 16,
  }, children: [
    VDom.createElement('Text', props: {
      'fontSize': 24,
      'color': '#000000',
      'textAlign': 'center',
    }, children: [
      VDom.createText('Welcome to DCMAUI')
    ]),
    VDom.createElement('Button', props: {
      'title': 'Click Me',
      'onPress': () {
        // Using a logger instead of print
        debugPrint('Button pressed!');
      },
      'backgroundColor': '#0066CC',
      'color': '#FFFFFF',
      'marginTop': 16,
    })
  ]);

  // Render initial tree to VDOM
  vdom.render(initialTree);

  // Log the root for debugging
  debugPrint('VDOM Root: ${root.toString()}');

  // Render to native UI
  await renderer.renderNode(initialTree);
}
