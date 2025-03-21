import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:jni/jni.dart';
import 'native_bridge.dart';

/// JNI-based implementation of NativeBridge for Android
class JNINativeBridge implements NativeBridge {
  static const String _javaClassName = 'com/dcmaui/framework/DcMauiViewManager';
  late final JClass _viewManagerClass;

  JNINativeBridge() {
    // Initialize JNI if not running on Android
    if (!Platform.isAndroid) {
      try {
        Jni.spawn();
      } catch (e) {
        developer.log('Failed to spawn JNI VM: $e', name: 'JNI');
      }
    }

    _viewManagerClass = JClass.forName(_javaClassName);
  }

  @override
  Future<bool> initialize() async {
    try {
      final result = _viewManagerClass
          .staticMethodId('initialize', '()Z')
          .call(_viewManagerClass, jboolean.type, []);
      // Convert JNI boolean (which is actually an int in Dart) to Dart bool
      return result != 0;
    } catch (e) {
      developer.log('JNI initialize error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> createView(
      String viewId, String type, Map<String, dynamic> props) async {
    try {
      final viewIdJString = JString.fromString(viewId);
      final typeJString = JString.fromString(type);
      final propsJString = JString.fromString(props.toString());

      final result = _viewManagerClass
          .staticMethodId('createView',
              '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z')
          .call(_viewManagerClass, jboolean.type,
              [viewIdJString, typeJString, propsJString]);

      return result != 0;
    } catch (e) {
      developer.log('JNI createView error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> updateView(
      String viewId, Map<String, dynamic> propPatches) async {
    try {
      final viewIdJString = JString.fromString(viewId);
      final propsJString = JString.fromString(propPatches.toString());

      final result = _viewManagerClass
          .staticMethodId(
              'updateView', '(Ljava/lang/String;Ljava/lang/String;)Z')
          .call(
              _viewManagerClass, jboolean.type, [viewIdJString, propsJString]);

      return result != 0;
    } catch (e) {
      developer.log('JNI updateView error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> deleteView(String viewId) async {
    try {
      final viewIdJString = JString.fromString(viewId);

      final result = _viewManagerClass
          .staticMethodId('deleteView', '(Ljava/lang/String;)Z')
          .call(_viewManagerClass, jboolean.type, [viewIdJString]);

      return result != 0;
    } catch (e) {
      developer.log('JNI deleteView error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> attachView(String childId, String parentId, int index) async {
    try {
      final childIdJString = JString.fromString(childId);
      final parentIdJString = JString.fromString(parentId);

      final result = _viewManagerClass
          .staticMethodId(
              'attachView', '(Ljava/lang/String;Ljava/lang/String;I)Z')
          .call(_viewManagerClass, jboolean.type,
              [childIdJString, parentIdJString, index]);

      return result != 0;
    } catch (e) {
      developer.log('JNI attachView error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> setChildren(String viewId, List<String> childrenIds) async {
    try {
      final viewIdJString = JString.fromString(viewId);
      final childrenJString = JString.fromString(childrenIds.toString());

      final result = _viewManagerClass
          .staticMethodId(
              'setChildren', '(Ljava/lang/String;Ljava/lang/String;)Z')
          .call(_viewManagerClass, jboolean.type,
              [viewIdJString, childrenJString]);

      return result != 0;
    } catch (e) {
      developer.log('JNI setChildren error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> addEventListeners(String viewId, List<String> eventTypes) async {
    try {
      final viewIdJString = JString.fromString(viewId);
      final eventsJString = JString.fromString(eventTypes.toString());

      final result = _viewManagerClass
          .staticMethodId(
              'addEventListeners', '(Ljava/lang/String;Ljava/lang/String;)Z')
          .call(
              _viewManagerClass, jboolean.type, [viewIdJString, eventsJString]);

      return result != 0;
    } catch (e) {
      developer.log('JNI addEventListeners error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  Future<bool> removeEventListeners(
      String viewId, List<String> eventTypes) async {
    try {
      final viewIdJString = JString.fromString(viewId);
      final eventsJString = JString.fromString(eventTypes.toString());

      final result = _viewManagerClass
          .staticMethodId(
              'removeEventListeners', '(Ljava/lang/String;Ljava/lang/String;)Z')
          .call(
              _viewManagerClass, jboolean.type, [viewIdJString, eventsJString]);

      return result != 0;
    } catch (e) {
      developer.log('JNI removeEventListeners error: $e', name: 'JNI');
      return false;
    }
  }

  @override
  void setEventHandler(
      Function(String viewId, String eventType, Map<String, dynamic> eventData)
          handler) {
    // This would require a native implementation to register a callback
    // Below is a simplified approach using a static callback
    developer.log('Setting JNI event handler - implementation required',
        name: 'JNI');

    // The actual implementation would involve setting up a Java listener
    // that calls back to Dart through JNI
  }
}
