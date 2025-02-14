import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final _logger = Logger('NavigationAPI');

enum NavigationType { stack, tab, modal }

class NavigationAPI {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');

  static final NavigationAPI _instance = NavigationAPI._internal();
  factory NavigationAPI() => _instance;
  NavigationAPI._internal();

  final _navigationStack = <String>[];
  final Map<String, Function()> _popCallbacks = {};
  final Map<String, Function(dynamic)> _navigationEventCallbacks = {};

  // Navigation State
  static const String _navStateKey = 'nav_state_key';
  NavigationState _state = NavigationState();

  // Lifecycle Handlers
  final Map<String, NavigationLifecycle> _lifecycles = {};
  final List<NavigationGuard> _guards = [];

  Future<bool> setupNavigation(NavigationType type,
      {List<TabInfo>? tabs}) async {
    try {
      _logger.info('Setting up navigation: $type');

      // Setup event handler for navigation callbacks
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onNavigationEvent':
            return _handleNavigationEvent(call.arguments);
          case 'onScreenPop':
            return _handleScreenPop(call.arguments);
          default:
            return null;
        }
      });

      final Map<String, dynamic> args = {
        'type': type.toString(),
        if (tabs != null) 'tabs': tabs.map((t) => t.toJson()).toList(),
      };

      final result = await _channel.invokeMethod('setupNavigation', args);
      return result ?? false;
    } catch (e) {
      _logger.severe('Navigation setup failed: $e');
      return false;
    }
  }

  // Enhanced push with result callback
  Future<bool> push(
    String screenId, {
    bool animated = true,
    TransitionStyle? transition,
    Duration? duration,
    Map<String, dynamic>? props,
    NavigationGuard? guard,
  }) async {
    // Check navigation guard
    if (guard != null && !await guard(screenId, props)) {
      return false;
    }

    final options = {
      'screenId': screenId,
      'animated': animated,
      if (transition != null) 'transition': transition.toString(),
      if (duration != null) 'duration': duration.inMilliseconds,
      if (props != null) 'props': props,
    };

    try {
      final success = await _channel.invokeMethod('pushScreen', options);
      if (success == true) {
        _state.addScreen(screenId, props);
        await _persistNavigationState();
        _notifyLifecycle(screenId, ScreenEvent.willAppear);
      }
      return success ?? false;
    } catch (e) {
      _logger.severe('Push failed: $e');
      return false;
    }
  }

  Future<bool> pop<T>({T? result, bool animated = true}) async {
    if (_navigationStack.isEmpty) return false;

    try {
      final screenId = _navigationStack.last;
      final success = await _channel.invokeMethod<bool>('popScreen', {
        'animated': animated,
        if (result != null) 'result': result,
      });

      if (success ?? false) {
        _navigationStack.removeLast();
        _popCallbacks[screenId]?.call();
        _navigationEventCallbacks.remove(screenId);
      }
      return success ?? false;
    } catch (e) {
      _logger.severe('Failed to pop screen: $e');
      return false;
    }
  }

  Future<bool> presentModal(String screenId,
      {bool animated = true,
      Map<String, dynamic>? properties,
      Function(dynamic)? onResult}) async {
    try {
      if (onResult != null) {
        _navigationEventCallbacks[screenId] = onResult;
      }

      return await _channel.invokeMethod<bool>('presentModal', {
            'screenId': screenId,
            'animated': animated,
            if (properties != null) 'properties': properties,
          }) ??
          false;
    } catch (e) {
      _logger.severe('Failed to present modal: $e');
      return false;
    }
  }

  Future<bool> dismissModal<T>({T? result, bool animated = true}) async {
    try {
      return await _channel.invokeMethod<bool>('dismissModal', {
            'animated': animated,
            if (result != null) 'result': result,
          }) ??
          false;
    } catch (e) {
      _logger.severe('Failed to dismiss modal: $e');
      return false;
    }
  }

  Future<bool> switchTab(int index, {Map<String, dynamic>? properties}) async {
    try {
      return await _channel.invokeMethod<bool>('switchTab', {
            'index': index,
            if (properties != null) 'properties': properties,
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

  // Handle navigation events from native
  Future<dynamic> _handleNavigationEvent(dynamic arguments) async {
    if (arguments is Map) {
      final String? screenId = arguments['screenId'];
      final dynamic result = arguments['result'];

      if (screenId != null && _navigationEventCallbacks.containsKey(screenId)) {
        _navigationEventCallbacks[screenId]?.call(result);
      }
    }
    return null;
  }

  Future<dynamic> _handleScreenPop(dynamic arguments) async {
    if (arguments is Map) {
      final String? screenId = arguments['screenId'];
      if (screenId != null) {
        _popCallbacks[screenId]?.call();
      }
    }
    return null;
  }

  // Screen Lifecycle
  void registerLifecycle(String screenId, NavigationLifecycle lifecycle) {
    _lifecycles[screenId] = lifecycle;
  }

  void unregisterLifecycle(String screenId) {
    _lifecycles.remove(screenId);
  }

  // Navigation Guards
  void addNavigationGuard(NavigationGuard guard) {
    _guards.add(guard);
  }

  // State Persistence
  Future<void> _persistNavigationState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_navStateKey, jsonEncode(_state.toJson()));
  }

  Future<void> restoreNavigationState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_navStateKey);
    if (stateJson != null) {
      _state = NavigationState.fromJson(jsonDecode(stateJson));
      // Restore stack
      for (final screen in _state.screenStack) {
        await push(screen.id, props: screen.props, animated: false);
      }
    }
  }

  void _notifyLifecycle(String screenId, ScreenEvent event) {
    _lifecycles[screenId]?.call(event);
  }
}

// Helper classes
class TabInfo {
  final String screenId;
  final String title;
  final String? icon; // SVG path
  final Map<String, dynamic>? additionalConfig;

  TabInfo({
    required this.screenId,
    required this.title,
    this.icon,
    this.additionalConfig,
  });

  Map<String, dynamic> toJson() => {
        'screenId': screenId,
        'title': title,
        if (icon != null) 'icon': icon,
        if (additionalConfig != null) ...additionalConfig!,
      };
}

// Supporting Types
enum TransitionStyle { slide, fade, scale, custom }

enum ScreenEvent { willAppear, didAppear, willDisappear, didDisappear }

typedef NavigationGuard = Future<bool> Function(
    String screenId, Map<String, dynamic>? props);
typedef NavigationLifecycle = void Function(ScreenEvent event);

class NavigationState {
  final List<ScreenInfo> screenStack = [];

  void addScreen(String id, Map<String, dynamic>? props) {
    screenStack.add(ScreenInfo(id, props));
  }

  Map<String, dynamic> toJson() => {
        'screenStack': screenStack.map((s) => s.toJson()).toList(),
      };

  static NavigationState fromJson(Map<String, dynamic> json) {
    final state = NavigationState();
    final List screens = json['screenStack'] ?? [];
    state.screenStack.addAll(screens.map((s) => ScreenInfo.fromJson(s)));
    return state;
  }
}

class ScreenInfo {
  final String id;
  final Map<String, dynamic>? props;

  ScreenInfo(this.id, this.props);

  Map<String, dynamic> toJson() => {
        'id': id,
        if (props != null) 'props': props,
      };

  static ScreenInfo fromJson(Map<String, dynamic> json) {
    return ScreenInfo(
      json['id'],
      json['props'],
    );
  }
}
