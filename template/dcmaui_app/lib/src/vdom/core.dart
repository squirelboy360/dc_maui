import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class VDOMCore {
  static const MethodChannel _channel = MethodChannel('vdom_core');

  /// Update only props on a view without recreating it
  Future<bool> updateViewProps(
      String viewId, Map<String, dynamic> props) async {
    print('Core: Updating view props for $viewId');

    try {
      final result = await _channel.invokeMethod<bool>(
        'updateView',
        {
          'viewId': viewId,
          'props': preparePropsForNative(props),
        },
      );

      print('Core: View props update result: $result');
      return result ?? false;
    } catch (e) {
      print('Core: Error updating view props: $e');
      return false;
    }
  }

  /// Helper method to clean up props for native side
  Map<String, dynamic> preparePropsForNative(Map<String, dynamic> props) {
    // Deep copy the props to avoid modifying the original
    final Map<String, dynamic> cleanProps = Map.from(props);

    // Process style if present
    if (cleanProps.containsKey('style') && cleanProps['style'] is Map) {
      final Map<String, dynamic> style = Map.from(cleanProps['style'] as Map);

      // Convert colors to string format if they're Color objects
      style.forEach((key, value) {
        if (value is Color) {
          // Convert Color to hex string with alpha
          style[key] = '#${value.value.toRadixString(16).padLeft(8, '0')}';
        }
      });

      cleanProps['style'] = style;
    }

    // Handle event listeners
    final eventListeners = <String>[];
    cleanProps.forEach((key, value) {
      if (key.startsWith('on') && value != null) {
        final eventName = key.substring(2).toLowerCase();
        eventListeners.add(eventName);
      }
    });

    if (eventListeners.isNotEmpty) {
      cleanProps['_eventListeners'] = eventListeners;
    }

    return cleanProps;
  }
}
