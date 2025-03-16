import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';

/// Interface for error reporting services
abstract class ErrorReporter {
  Future<void> reportError(dynamic error, StackTrace? stackTrace);
}

/// Props for ErrorBoundary component
class ErrorBoundaryProps {
  /// Component to render when an error occurs
  final Control Function(dynamic error, void Function() reset)? fallback;

  /// Called when an error is caught
  final void Function(dynamic error, StackTrace? stackTrace)? onError;

  /// Error reporting service
  final ErrorReporter? errorReporter;

  /// Unique identifier for this boundary (helpful for logging)
  final String? id;

  ErrorBoundaryProps({
    this.fallback,
    this.onError,
    this.errorReporter,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 'errorBoundary',
    };
  }
}

/// Component that catches JavaScript errors in its child tree
/// and displays a fallback UI instead of crashing the whole app
class ErrorBoundary extends Component {
  final ErrorBoundaryProps _props;
  final List<Control> _children;

  bool _hasError = false;
  dynamic _error;
  StackTrace? _stackTrace;

  ErrorBoundary(this._props, this._children);

  @override
  Map<String, dynamic> getInitialState() {
    return {
      'hasError': false,
      'error': null,
    };
  }

  @override
  VNode render() {
    if (state['hasError'] == true) {
      // Render fallback UI
      if (_props.fallback != null) {
        return _props.fallback!(_error, _resetError).build();
      }

      // Default error UI
      return ElementFactory.createElement(
        'DCView',
        {
          'style': {
            'padding': 16.0,
            'backgroundColor': '#FFEBEE',
            'borderRadius': 4.0,
            'borderWidth': 1.0,
            'borderColor': '#FFCDD2',
          },
        },
        [
          ElementFactory.createElement(
            'DCText',
            {
              'style': {
                'color': '#D32F2F',
                'fontSize': 16.0,
                'fontWeight': 'bold',
              },
            },
            [], // No children for text
          ),
          ElementFactory.createElement(
            'DCText',
            {
              'content': 'Something went wrong.',
              'style': {
                'color': '#D32F2F',
                'marginTop': 8.0,
              },
            },
            [], // No children for text
          ),
          ElementFactory.createElement(
            'DCButton',
            {
              'title': 'Try again',
              'onPress': (_) => _resetError(),
              'style': {
                'marginTop': 16.0,
                'backgroundColor': '#EF5350',
                'borderRadius': 4.0,
                'paddingVertical': 8.0,
                'paddingHorizontal': 16.0,
              },
              'textStyle': {
                'color': '#FFFFFF',
                'fontWeight': 'bold',
              },
            },
            [], // No children for button
          ),
        ],
      );
    }

    // If no error, render children normally
    if (_children.length == 1) {
      return _children[0].build();
    }

    // Wrap multiple children in a fragment
    return ElementFactory.createElement(
      'DCFragment',
      {},
      _children.map((child) => child.build()).toList(),
    );
  }

  void _resetError() {
    setState({
      'hasError': false,
      'error': null,
    });
    _hasError = false;
    _error = null;
    _stackTrace = null;
  }

  // This lifecycle method is called when an error is thrown in a descendant
  @override
  void componentDidCatch(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('ErrorBoundary: Caught error: $error');
      if (stackTrace != null) print(stackTrace);
    }

    // Update state to render fallback UI
    _hasError = true;
    _error = error;
    _stackTrace = stackTrace;

    setState({
      'hasError': true,
      'error': error.toString(),
    });

    // Call optional error handler
    if (_props.onError != null) {
      _props.onError!(error, stackTrace);
    }

    // Report error to service if provided
    if (_props.errorReporter != null) {
      _props.errorReporter!.reportError(error, stackTrace);
    }
  }
}
