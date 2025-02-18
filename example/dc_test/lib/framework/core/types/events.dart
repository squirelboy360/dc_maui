import 'package:flutter/material.dart';

enum TouchEventType {
  onPress,
  onLongPress,
  onPressIn,
  onPressOut,
  onDoublePress,
  onDragStart,
  onDragUpdate,
  onDragEnd,
  onScaleStart,
  onScaleUpdate,
  onScaleEnd;

  @override
  String toString() => name;
}

enum ButtonEventType {
  onClick,
  onLongPress,
  onPressIn,
  onPressOut,
  onDoublePress // Add this
}

enum GestureEventType {
  onTap,
  onDoubleTap,
  onLongPress,
  onPanStart,
  onPanUpdate,
  onPanEnd,
  onScaleStart,
  onScaleUpdate,
  onScaleEnd,
  onRotateStart,
  onRotateUpdate,
  onRotateEnd,
  onDragStart, // Add these new gesture events
  onDragUpdate,
  onDragEnd,
  onPointerDown,
  onPointerMove,
  onPointerUp,
  onPointerCancel
}

// Keep TouchEventData but make it match native side
class TouchEventData {
  final String viewId;
  final TouchEventType type;
  final Offset position;
  final double? pressure;
  final double timestamp;

  TouchEventData({
    required this.viewId,
    required this.type,
    required this.position,
    this.pressure,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'viewId': viewId,
        'type': type.index,
        'x': position.dx,
        'y': position.dy,
        if (pressure != null) 'pressure': pressure,
        'timestamp': timestamp,
      };

  factory TouchEventData.fromJson(Map<String, dynamic> json) {
    return TouchEventData(
      viewId: json['viewId'] as String,
      type: TouchEventType.values[json['type'] as int],
      position: Offset(
        json['x'] as double,
        json['y'] as double,
      ),
      pressure: json['pressure'] as double?,
      timestamp: json['timestamp'] as double,
    );
  }
}

// Add support for rich gesture data
class GestureEventData {
  final String viewId;
  final GestureEventType type;
  final Offset? position;
  final Offset? delta;
  final double? scale;
  final double? rotation;
  final double? velocity;
  final int? pointerCount;
  final double timestamp;

  GestureEventData({
    required this.viewId,
    required this.type,
    this.position,
    this.delta,
    this.scale,
    this.rotation,
    this.velocity,
    this.pointerCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'viewId': viewId,
        'type': type.index,
        if (position != null) ...{
          'x': position!.dx,
          'y': position!.dy,
        },
        if (delta != null) ...{
          'deltaX': delta!.dx,
          'deltaY': delta!.dy,
        },
        if (scale != null) 'scale': scale,
        if (rotation != null) 'rotation': rotation,
        if (velocity != null) 'velocity': velocity,
        if (pointerCount != null) 'pointerCount': pointerCount,
        'timestamp': timestamp,
      };

  factory GestureEventData.fromJson(Map<String, dynamic> json) {
    return GestureEventData(
      viewId: json['viewId'] as String,
      type: GestureEventType.values[json['type'] as int],
      position: json['x'] != null
          ? Offset(
              json['x'] as double,
              json['y'] as double,
            )
          : null,
      delta: json['deltaX'] != null
          ? Offset(
              json['deltaX'] as double,
              json['deltaY'] as double,
            )
          : null,
      scale: json['scale'] as double?,
      rotation: json['rotation'] as double?,
      velocity: json['velocity'] as double?,
      pointerCount: json['pointerCount'] as int?,
      timestamp: json['timestamp'] as double,
    );
  }
}

enum TouchableEvent {
  onTouchDown,
  onTouchMove,
  onTouchUp,
  onTouchCancel;

  @override
  String toString() => name;
}
