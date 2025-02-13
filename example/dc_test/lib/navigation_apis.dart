import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('NavigationAPI');

enum NavigationType { stack, tab, modal }

class NavigationAPI {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');

  static final NavigationAPI _instance = NavigationAPI._internal();
  factory NavigationAPI() => _instance;
  NavigationAPI._internal();

  final _navigationStack = <String>[];
  final Map<String, Function()> _popCallbacks = {};

  Future<bool> setupNavigation(NavigationType type, {List<TabInfo>? tabs}) async {
  try {
    _logger.info('Setting up navigation: $type');
    
    final Map<String, dynamic> args = {
      'type': type.toString(),
      if (tabs != null) 'tabs': tabs.map((t) => t.toJson()).toList(),
    };
    
    final result = await _channel.invokeMethod('setupNavigation', args);
    return result ?? false;
  } on PlatformException catch (e) {
    _logger.severe('Navigation setup failed: ${e.message}');
    return false;
  } catch (e) {
    _logger.severe('Unexpected error during navigation setup: $e');
    return false;
  }
}

  Future<bool> push(String screenId, {bool animated = true}) async {
    try {
      _navigationStack.add(screenId);
      return await _channel.invokeMethod<bool>('pushScreen', {
            'screenId': screenId,
            'animated': animated,
          }) ??
          false;
    } catch (e) {
      _logger.severe('Failed to push screen: $e');
      return false;
    }
  }

  Future<bool> pop({bool animated = true}) async {
    if (_navigationStack.isEmpty) return false;

    try {
      final screenId = _navigationStack.removeLast();
      final success = await _channel.invokeMethod<bool>('popScreen', {
            'animated': animated,
          }) ??
          false;

      if (success) {
        _popCallbacks[screenId]?.call();
      }
      return success;
    } catch (e) {
      _logger.severe('Failed to pop screen: $e');
      return false;
    }
  }

  Future<bool> presentModal(String screenId, {bool animated = true}) async {
    try {
      return await _channel.invokeMethod<bool>('presentModal', {
            'screenId': screenId,
            'animated': animated,
          }) ??
          false;
    } catch (e) {
      _logger.severe('Failed to present modal: $e');
      return false;
    }
  }

  Future<bool> dismissModal({bool animated = true}) async {
    try {
      return await _channel.invokeMethod<bool>('dismissModal', {
            'animated': animated,
          }) ??
          false;
    } catch (e) {
      _logger.severe('Failed to dismiss modal: $e');
      return false;
    }
  }

  Future<bool> switchTab(int index) async {
    try {
      return await _channel.invokeMethod<bool>('switchTab', {
            'index': index,
          }) ??
          false;
    } catch (e) {
      _logger.severe('Failed to switch tab: $e');
      return false;
    }
  }

  void registerPopCallback(String screenId, Function() callback) {
    _popCallbacks[screenId] = callback;
  }

  void unregisterPopCallback(String screenId) {
    _popCallbacks.remove(screenId);
  }
}

// Helper classes
class TabInfo {
  final String screenId;
  final String title;
  final Map<String, dynamic>? additionalConfig;

  TabInfo({
    required this.screenId,
    required this.title,
    this.additionalConfig,
  });

  Map<String, dynamic> toJson() => {
        'screenId': screenId,
        'title': title,
        if (additionalConfig != null) ...additionalConfig!,
      };
}
