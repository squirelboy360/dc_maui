enum TouchEventType {
  onPress,
  onLongPress,
  onPressIn,
  onPressOut,
  onDoublePress
}

enum ButtonEventType {
  onClick,
  onLongPress,
  onPressIn,
  onPressOut
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
  onScaleEnd
}

class TouchEvent {
  final String viewId;
  final TouchEventType type;
  final double? x;
  final double? y;
  final double pressure;
  final double timestamp;

  TouchEvent({
    required this.viewId,
    required this.type,
    this.x,
    this.y,
    this.pressure = 1.0,
    required this.timestamp,
  });
}
