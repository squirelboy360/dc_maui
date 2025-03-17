import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/core.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
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

  @override
  VNode render() {
    // Create a list of text components for all messages
    final messageViews = state['messages']
        .map<DCText>((message) => DCText(
              message,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFFFFFFF),
              ),
            ))
        .toList();

    // Create a container for the diagnostic info
    return DCView(
      props: DCViewProps(
        style: ViewStyle(
          backgroundColor: Color(0x88000000),
          padding: EdgeInsets.all(8),
          // Remove position-related properties that aren't supported
        ),
        additionalProps: {
          'style': {
            'position': 'absolute',
            'left': 0,
            'right': 0,
            'bottom': 0,
          }
        },
      ),
      children: messageViews,
    ).build();
  }
}
