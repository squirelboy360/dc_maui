import 'package:flutter/material.dart';

import '../ui_apis.dart';


abstract class UIComponent {
  final String id;
  @protected
  final NativeUIBridge _bridge;

  UIComponent(this.id) : _bridge = NativeUIBridge();

  // Style configuration builder
  Future<T> style<T extends UIComponent>({
    UIEdgeInsets? margin,
    UIEdgeInsets? padding,
    double? width,
    double? height,
    String? backgroundColor,
    Border? border,
    double? cornerRadius,
    Shadow? shadow,
    Transform? transform,
    double? opacity,
    String? fontFamily,
    double? fontSize,
    String? textColor,
    TextAlign? textAlign,
    bool? visible,
    String? clipBehavior,
  }) async {
    final properties = <String, dynamic>{};

    if (margin != null) properties['margin'] = margin.toMap();
    if (padding != null) properties['padding'] = padding.toMap();
    if (width != null) properties['width'] = width;
    if (height != null) properties['height'] = height;
    if (backgroundColor != null) properties['backgroundColor'] = backgroundColor;
    if (border != null) properties['border'] = border.toMap();
    if (cornerRadius != null) properties['cornerRadius'] = cornerRadius;
    if (shadow != null) properties['shadow'] = shadow.toMap();
    if (transform != null) properties['transform'] = transform.toMap();
    if (opacity != null) properties['opacity'] = opacity;
    if (fontFamily != null) properties['fontFamily'] = fontFamily;
    if (fontSize != null) properties['fontSize'] = fontSize;
    if (textColor != null) properties['textColor'] = textColor;
    if (textAlign != null) properties['textAlign'] = textAlign.toString();
    if (visible != null) properties['visible'] = visible;
    if (clipBehavior != null) properties['clipBehavior'] = clipBehavior;

    await _bridge.updateView(id, properties);
    return this as T;
  }

  // Individual style methods for convenience
  Future<T> margin<T extends UIComponent>(UIEdgeInsets margin) async {
    await _bridge.setViewMargin(id, EdgeInsets.only(
      left: margin.left,
      top: margin.top,
      right: margin.right,
      bottom: margin.bottom
    ));
    return this as T;
  }

  Future<T> padding<T extends UIComponent>(UIEdgeInsets padding) async {
    await _bridge.setViewPadding(id, EdgeInsets.only(
      left: padding.left,
      top: padding.top,
      right: padding.right,
      bottom: padding.bottom
    ));
    return this as T;
  }

  Future<T> size<T extends UIComponent>(double width, double height) async {
    await _bridge.setViewSize(id, width: width, height: height);
    return this as T;
  }

  Future<T> background<T extends UIComponent>(String color) async {
    await _bridge.setViewBackgroundColor(id, color);
    return this as T;
  }

  Future<T> border<T extends UIComponent>({
    double width = 1.0,
    String color = '#000000',
    double radius = 0.0,
  }) async {
    await _bridge.setViewBorder(id, width: width, color: color);
    if (radius > 0) await _bridge.setViewCornerRadius(id, radius);
    return this as T;
  }

  Future<T> shadow<T extends UIComponent>(Shadow shadow) async {
    await _bridge.updateView(id, {'shadow': shadow.toMap()});
    return this as T;
  }

  Future<T> transform<T extends UIComponent>(Transform transform) async {
    await _bridge.updateView(id, {'transform': transform.toMap()});
    return this as T;
  }

  Future<T> opacity<T extends UIComponent>(double opacity) async {
    await _bridge.updateView(id, {'opacity': opacity});
    return this as T;
  }

  // Layout methods
  Future<T> flex<T extends UIComponent>(int flex) async {
    await _bridge.setFlex(id, flex);
    return this as T;
  }

  Future<T> alignment<T extends UIComponent>(Alignment alignment) async {
    await _bridge.setAlignment(id, alignment.toString());
    return this as T;
  }

  // Position methods for Stack children
  Future<T> position<T extends UIComponent>({
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) async {
    await _bridge.setStackPosition(id,
      top: top,
      left: left,
      right: right,
      bottom: bottom
    );
    return this as T;
  }

  Future<T> zIndex<T extends UIComponent>(int index) async {
    await _bridge.setZIndex(id, index);
    return this as T;
  }

  // Animation support
  Future<T> animate<T extends UIComponent>(
    Map<String, dynamic> properties, {
    int duration = 300,
    Curve curve = Curves.easeInOut,
  }) async {
    await _bridge.animate(id, properties,
      duration: duration,
      curve: curve.toString(),
    );
    return this as T;
  }

  // Advanced styling
  Future<T> gradient<T extends UIComponent>({
    required List<String> colors,
    List<double>? stops,
    GradientType type = GradientType.linear,
    double angle = 0,
  }) async {
    await _bridge.setGradient(id,
      colors: colors,
      stops: stops,
      type: type.toString(),
      angle: angle,
    );
    return this as T;
  }

  Future<T> blur<T extends UIComponent>(double radius) async {
    await _bridge.setBlur(id, radius);
    return this as T;
  }

  Future<T> mask<T extends UIComponent>(MaskType type) async {
    await _bridge.setMask(id, type.toString());
    return this as T;
  }

  // Gesture support
  Future<T> enableGesture<T extends UIComponent>(GestureType type) async {
    await _bridge.enableGesture(id, type.toString());
    return this as T;
  }

  Future<T> disableGesture<T extends UIComponent>(GestureType type) async {
    await _bridge.disableGesture(id, type.toString());
    return this as T;
  }

  // Common UI operations
  Future<bool> attachTo(String parentId) => _bridge.attachView(parentId, id);
  Future<bool> setVisible(bool visible) => _bridge.setViewVisibility(id, visible);
  Future<bool> remove() => _bridge.deleteView(id);

  // Event handling
  Future<bool> on(String event, Function callback) => 
      _bridge.registerEvent(id, event, callback);
  Future<bool> off(String event) => 
      _bridge.unregisterEvent(id, event);

  // Add onClick method to base class
  Future<T> onClick<T extends UIComponent>(Function callback) async {
    await _bridge.registerEvent(id, 'onClick', callback);
    return this as T;
  }

  // Chainable API
  Future<T> then<T extends UIComponent>(ComponentBuilder<T> builder) async {
    return await builder(this as T);
  }
}

typedef ComponentBuilder<T> = Future<T> Function(T component);

// Styling helper classes
class UIEdgeInsets {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const UIEdgeInsets.all(double value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const UIEdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  Map<String, dynamic> toMap() => {
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };
}

class Border {
  final double width;
  final String color;
  final double radius;

  const Border({
    this.width = 1.0,
    this.color = '#000000',
    this.radius = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'width': width,
        'color': color,
        'radius': radius,
      };
}

class Shadow {
  final String color;
  final double offsetX;
  final double offsetY;
  final double blur;
  final double spread;

  const Shadow({
    this.color = '#000000',
    this.offsetX = 0,
    this.offsetY = 2,
    this.blur = 4,
    this.spread = 0,
  });

  Map<String, dynamic> toMap() => {
        'color': color,
        'offsetX': offsetX,
        'offsetY': offsetY,
        'blur': blur,
        'spread': spread,
      };
}

class Transform {
  final double? scaleX;
  final double? scaleY;
  final double? rotation;
  final double? translateX;
  final double? translateY;

  const Transform({
    this.scaleX,
    this.scaleY,
    this.rotation,
    this.translateX,
    this.translateY,
  });

  Map<String, dynamic> toMap() => {
        if (scaleX != null) 'scaleX': scaleX,
        if (scaleY != null) 'scaleY': scaleY,
        if (rotation != null) 'rotation': rotation,
        if (translateX != null) 'translateX': translateX,
        if (translateY != null) 'translateY': translateY,
      };
}

enum GradientType { linear, radial, sweep }
enum MaskType { circle, roundRect, custom }
enum GestureType { tap, doubleTap, longPress, pan, pinch, rotate }

class Alignment {
  final String value;
  const Alignment._(this.value);

  static const topLeft = Alignment._('topLeft');
  static const topCenter = Alignment._('topCenter');
  static const topRight = Alignment._('topRight');
  static const centerLeft = Alignment._('centerLeft');
  static const center = Alignment._('center');
  static const centerRight = Alignment._('centerRight');
  static const bottomLeft = Alignment._('bottomLeft');
  static const bottomCenter = Alignment._('bottomCenter');
  static const bottomRight = Alignment._('bottomRight');

  @override
  String toString() => value;
}
