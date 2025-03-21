import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'native_bridge.dart';

/// FFI-based implementation of NativeBridge for iOS/macOS
class FFINativeBridge implements NativeBridge {
  late final DynamicLibrary _nativeLib;

  // Function pointers for native methods
  late final int Function() _initialize;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)
      _createView;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>) _updateView;
  late final int Function(Pointer<Utf8>) _deleteView;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>, int) _attachView;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>) _setChildren;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>) _addEventListeners;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>) _removeEventListeners;

  // Singleton instance for callback handling
  static FFINativeBridge? _instance;

  // Event callback
  Function(String viewId, String eventType, Map<String, dynamic> eventData)?
      _eventHandler;

  FFINativeBridge() {
    _instance = this;

    // Load the native library
    if (Platform.isIOS || Platform.isMacOS) {
      _nativeLib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('FFI bridge only supports iOS and macOS');
    }

    // Get function pointers
    _initialize = _nativeLib
        .lookupFunction<Int8 Function(), int Function()>('dcmaui_initialize');

    _createView = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>),
        int Function(
            Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_create_view');

    _updateView = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_update_view');

    _deleteView = _nativeLib.lookupFunction<Int8 Function(Pointer<Utf8>),
        int Function(Pointer<Utf8>)>('dcmaui_delete_view');

    _attachView = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>, Int32),
        int Function(Pointer<Utf8>, Pointer<Utf8>, int)>('dcmaui_attach_view');

    _setChildren = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_set_children');

    _addEventListeners = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(
            Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_add_event_listeners');

    _removeEventListeners = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(
            Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_remove_event_listeners');

    // Set up callback for native events
    final callbackFunc = Pointer.fromFunction<
        Void Function(
            Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)>(_nativeEventCallback);

    _nativeLib
        .lookupFunction<
            Void Function(
                Pointer<
                    NativeFunction<
                        Void Function(
                            Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)>>),
            void Function(
                Pointer<
                    NativeFunction<
                        Void Function(Pointer<Utf8>, Pointer<Utf8>,
                            Pointer<Utf8>)>>)>('dcmaui_set_event_callback')
        .call(callbackFunc);
  }

  @override
  Future<bool> initialize() async {
    return _initialize() == 1;
  }

  @override
  Future<bool> createView(
      String viewId, String type, Map<String, dynamic> props) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final typePointer = type.toNativeUtf8(allocator: arena);
      final propsJson = jsonEncode(props);
      final propsPointer = propsJson.toNativeUtf8(allocator: arena);

      final result = _createView(viewIdPointer, typePointer, propsPointer);
      return result == 1;
    });
  }

  @override
  Future<bool> updateView(
      String viewId, Map<String, dynamic> propPatches) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final propsJson = jsonEncode(propPatches);
      final propsPointer = propsJson.toNativeUtf8(allocator: arena);

      final result = _updateView(viewIdPointer, propsPointer);
      return result == 1;
    });
  }

  @override
  Future<bool> deleteView(String viewId) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);

      final result = _deleteView(viewIdPointer);
      return result == 1;
    });
  }

  @override
  Future<bool> attachView(String childId, String parentId, int index) async {
    return using((arena) {
      final childIdPointer = childId.toNativeUtf8(allocator: arena);
      final parentIdPointer = parentId.toNativeUtf8(allocator: arena);

      final result = _attachView(childIdPointer, parentIdPointer, index);
      return result == 1;
    });
  }

  @override
  Future<bool> setChildren(String viewId, List<String> childrenIds) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final childrenJson = jsonEncode(childrenIds);
      final childrenPointer = childrenJson.toNativeUtf8(allocator: arena);

      final result = _setChildren(viewIdPointer, childrenPointer);
      return result == 1;
    });
  }

  @override
  Future<bool> addEventListeners(String viewId, List<String> eventTypes) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final eventsJson = jsonEncode(eventTypes);
      final eventsPointer = eventsJson.toNativeUtf8(allocator: arena);

      final result = _addEventListeners(viewIdPointer, eventsPointer);
      return result == 1;
    });
  }

  @override
  Future<bool> removeEventListeners(
      String viewId, List<String> eventTypes) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final eventsJson = jsonEncode(eventTypes);
      final eventsPointer = eventsJson.toNativeUtf8(allocator: arena);

      final result = _removeEventListeners(viewIdPointer, eventsPointer);
      return result == 1;
    });
  }

  @override
  void setEventHandler(
      Function(String viewId, String eventType, Map<String, dynamic> eventData)
          handler) {
    _eventHandler = handler;
  }

  // Native callback handler
  static void _nativeEventCallback(Pointer<Utf8> viewIdPtr,
      Pointer<Utf8> eventTypePtr, Pointer<Utf8> eventDataPtr) {
    final viewId = viewIdPtr.toDartString();
    final eventType = eventTypePtr.toDartString();
    final eventDataJson = eventDataPtr.toDartString();
    final eventData = jsonDecode(eventDataJson) as Map<String, dynamic>;

    // Forward to the registered handler
    _instance?._eventHandler?.call(viewId, eventType, eventData);
  }
}
