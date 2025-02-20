import 'package:flutter/material.dart';

enum NativeEventType {
  // Touch events
  onPress,
  onLongPress,
  onPressIn,
  onPressOut,
  onDoubleTap,

  // Scroll events
  onScroll,
  onScrollEnd,

  // Gesture events
  onPanStart,
  onPanUpdate,
  onPanEnd,
  onScaleStart,
  onScaleUpdate,
  onScaleEnd,

  // Focus events
  onFocus,
  onBlur
}

// Base event data class
class NativeEventData {
  final String viewId;
  final NativeEventType type;
  final double timestamp;
  final double? x;
  final double? y;
  final double? scale;
  final Offset? translation;
  final Offset? velocity;

  const NativeEventData({
    required this.viewId,
    required this.type,
    required this.timestamp,
    this.x,
    this.y,
    this.scale,
    this.translation,
    this.velocity,
  });

  // Add factory constructor for native map
  factory NativeEventData.fromNative(Map<String, dynamic> map) {
    return NativeEventData(
      viewId: map['viewId'] as String,
      type: NativeEventType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      timestamp: map['timestamp'] as double,
      x: map['x'] as double?,
      y: map['y'] as double?,
      scale: map['scale'] as double?,
      translation: map['translation'] != null
          ? Offset(
              (map['translation']['x'] as num).toDouble(),
              (map['translation']['y'] as num).toDouble(),
            )
          : null,
      velocity: map['velocity'] != null
          ? Offset(
              (map['velocity']['x'] as num).toDouble(),
              (map['velocity']['y'] as num).toDouble(),
            )
          : null,
    );
  }
}

// Specialized event data classes
class TouchEventData extends NativeEventData {
  final double? x;
  final double? y;
  final double pressure;
  final bool isPressed;

  const TouchEventData({
    required super.viewId,
    required super.type,
    required super.timestamp,
    this.x,
    this.y,
    this.pressure = 1.0,
    this.isPressed = false,
  });
}

class ScrollEventData extends NativeEventData {
  @override
  final double? x;
  @override
  final double? y;
  final Offset? velocity; // Change to match parent class

  const ScrollEventData({
    required super.viewId,
    required super.type,
    required super.timestamp,
    this.x,
    this.y,
    this.velocity,
  });
}

class GestureEventData extends NativeEventData {
  final double? scale;
  final Offset? translation;
  final Offset? velocity;

  const GestureEventData({
    required super.viewId,
    required super.type,
    required super.timestamp,
    this.scale,
    this.translation,
    this.velocity,
  });
}
