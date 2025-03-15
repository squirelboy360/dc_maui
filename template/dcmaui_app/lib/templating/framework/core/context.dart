import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';

/// Context provider and consumer implementation similar to React Context API
class Context<T> {
  final T defaultValue;

  Context(this.defaultValue);

  /// Provider component for this context
  Provider<T> createProvider() {
    return Provider<T>(this);
  }

  /// Consumer component for this context
  Consumer<T> createConsumer() {
    return Consumer<T>(this);
  }
}

/// Provider component that makes a value available to all descendants
class Provider<T> extends Component {
  final Context<T> contextObj;

  Provider(this.contextObj);

  T get value => props['value'] as T;

  @override
  VNode render() {
    final children = props['children'] as List<VNode>? ?? [];
    return ElementFactory.createElement('provider', {}, children);
  }
}

/// Consumer component that reads a value from context
class Consumer<T> extends Component {
  final Context<T> contextObj;

  Consumer(this.contextObj);

  @override
  VNode render() {
    final builder = props['builder'] as VNode Function(T value);
    return builder(contextObj.defaultValue);
  }
}
