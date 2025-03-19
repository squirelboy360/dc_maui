import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/main/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/painting.dart' hide TextStyle;

/// A diagnostic component that shows issues and status
class DiagnosticComponent extends Component {
  @override
  Map<String, dynamic> getInitialState() {
    return {
      'messages': <String>[],
      'nativeUIReady': false,
    };
  }

  @override
  void componentDidMount() {
    super.componentDidMount();

    // Listen for events from the native side
    MainViewCoordinatorInterface.eventStream.listen((event) {
      final messages = List<String>.from(state['messages']);

      // Special handling for native UI ready event
      if (event['viewId'] == 'system' &&
          event['eventName'] == 'nativeUIReady') {
        setState({'nativeUIReady': true});
      }

      // Add the event to our messages
      messages.add('Event: ${event['eventName']} from ${event['viewId']}');

      // Keep only the latest 10 messages
      if (messages.length > 10) {
        messages.removeAt(0);
      }

      setState({'messages': messages});
    });

    // Log diagnostic information periodically
    Future.delayed(Duration(seconds: 2), () {
      _logStatus();
    });
  }

  void _logStatus() {
    final messages = List<String>.from(state['messages']);
    messages.add('Status check: Native UI ready: ${state['nativeUIReady']}');
    setState({'messages': messages});
  }

  // Implementation of the abstract buildRender method
  @override
  VNode buildRender() {
    // Create a list of text controls (not VNodes) for all messages
    final List<Control> messageViews = (state['messages'] as List<String>)
        .map<Control>((message) => DCText(
              text: message,
              style: DCTextStyle(
                fontSize: 12,
                color: Color(0xFFFFFFFF),
              ),
            ))
        .toList();

    // Create a container for the diagnostic info
    return DCView(
      style: ViewStyle(
        backgroundColor: Color(0x88000000),
        padding: EdgeInsets.all(8),
      ),
      additionalProps: {
        'style': {
          'position': 'absolute',
          'left': 0,
          'right': 0,
          'bottom': 0,
        }
      },
      children: messageViews,
    ).build();
  }
}
