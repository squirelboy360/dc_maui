import 'package:dc_test/templating/framework/controls/low_levels/component.dart';
import 'package:flutter/foundation.dart';

/// PureComponent implements shouldComponentUpdate with shallow comparison
/// to avoid unnecessary re-renders when props or state haven't changed
abstract class PureComponent extends Component {
  PureComponent() : super();

  @override
  bool shouldComponentUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState) {
    // Compare props (shallow comparison)
    if (nextProps.length != props.length) return true;

    for (final key in props.keys) {
      // Skip function comparisons as they're not reliably comparable
      if (props[key] is Function && nextProps[key] is Function) {
        continue;
      }

      if (!nextProps.containsKey(key) || props[key] != nextProps[key]) {
        if (kDebugMode) {
          print(
              'PureComponent: Prop "$key" changed from ${props[key]} to ${nextProps[key]}');
        }
        return true;
      }
    }

    // Check for new props
    for (final key in nextProps.keys) {
      if (!props.containsKey(key)) {
        if (kDebugMode) {
          print('PureComponent: New prop added: $key');
        }
        return true;
      }
    }

    // Compare state (shallow comparison)
    if (nextState.length != state.length) return true;

    for (final key in state.keys) {
      if (!nextState.containsKey(key) || state[key] != nextState[key]) {
        if (kDebugMode) {
          print(
              'PureComponent: State "$key" changed from ${state[key]} to ${nextState[key]}');
        }
        return true;
      }
    }

    // Check for new state keys
    for (final key in nextState.keys) {
      if (!state.containsKey(key)) {
        if (kDebugMode) {
          print('PureComponent: New state added: $key');
        }
        return true;
      }
    }

    // No changes detected
    return false;
  }
}
