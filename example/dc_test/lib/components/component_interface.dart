import 'package:flutter/material.dart';
import '../low_apis/ui_apis.dart';

abstract class UIComponent {
  final String id;
  @protected
  final NativeUIBridge _bridge;

  UIComponent(this.id) : _bridge = NativeUIBridge();

  // Enhanced style configuration
  Future<T> style<T extends UIComponent>({
    // Layout
    UIEdgeInsets? margin,
    UIEdgeInsets? padding,
    double? width,
    double? height,
    AspectRatio? aspectRatio,

    // Visual
    String? backgroundColor,
    List<String>? gradientColors,
    GradientConfig? gradient,
    Border? border,
    double? cornerRadius,
    Shadow? shadow,
    double? blur,

    // Transform
    Transform? transform,
    double? opacity,
    double? scale,
    double? rotation,
    Offset? translation,

    // Typography
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    String? textColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,

    // Behavior
    bool? visible,
    String? clipBehavior,
    bool? userInteractionEnabled,
    ContentMode? contentMode,

    // Advanced
    MaskType? mask,
    List<Filter>? filters,
  }) async {
    final properties = <String, dynamic>{};

    // Layout properties
    if (margin != null) properties['margin'] = margin.toMap();
    if (padding != null) properties['padding'] = padding.toMap();
    if (width != null) properties['width'] = width;
    if (height != null) properties['height'] = height;
    if (aspectRatio != null) properties['aspectRatio'] = aspectRatio.value;

    // Visual properties
    if (backgroundColor != null)
      properties['backgroundColor'] = backgroundColor;
    if (gradientColors != null) {
      properties['gradient'] = {
        'colors': gradientColors,
        'type': 'linear',
        'angle': 0.0,
      };
    }
    if (gradient != null) properties['gradient'] = gradient.toMap();
    if (border != null) properties['border'] = border.toMap();
    if (cornerRadius != null) properties['cornerRadius'] = cornerRadius;
    if (shadow != null) properties['shadow'] = shadow.toMap();
    if (blur != null) properties['blur'] = blur;

    // Transform properties
    if (transform != null) properties['transform'] = transform.toMap();
    if (opacity != null) properties['opacity'] = opacity;
    if (scale != null) properties['scale'] = scale;
    if (rotation != null) properties['rotation'] = rotation;
    if (translation != null) {
      properties['translation'] = {
        'x': translation.dx,
        'y': translation.dy,
      };
    }

    // Typography properties
    if (fontFamily != null) properties['fontFamily'] = fontFamily;
    if (fontSize != null) properties['fontSize'] = fontSize;
    if (fontWeight != null) properties['fontWeight'] = fontWeight.value;
    if (textColor != null) properties['textColor'] = textColor;
    if (textAlign != null) properties['textAlign'] = textAlign.toString();
    if (maxLines != null) properties['maxLines'] = maxLines;
    if (overflow != null) properties['textOverflow'] = overflow.toString();

    // Behavior properties
    if (visible != null) properties['visible'] = visible;
    if (clipBehavior != null) properties['clipBehavior'] = clipBehavior;
    if (userInteractionEnabled != null) {
      properties['userInteractionEnabled'] = userInteractionEnabled;
    }
    if (contentMode != null) properties['contentMode'] = contentMode.toString();

    // Advanced properties
    if (mask != null) properties['mask'] = mask.toString();
    if (filters != null)
      properties['filters'] = filters.map((f) => f.toMap()).toList();

    await _bridge.updateView(id, properties);
    return this as T;
  }

  // Enhanced layout methods
  Future<T> layout<T extends UIComponent>({
    FlexFit? fit,
    int? flex,
    Alignment? alignment,
    bool? expandHorizontally,
    bool? expandVertically,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) async {
    final properties = <String, dynamic>{};

    if (fit != null) properties['flexFit'] = fit.toString();
    if (flex != null) properties['flex'] = flex;
    if (alignment != null) properties['alignment'] = alignment.toString();
    if (expandHorizontally != null)
      properties['expandHorizontally'] = expandHorizontally;
    if (expandVertically != null)
      properties['expandVertically'] = expandVertically;
    if (minWidth != null) properties['minWidth'] = minWidth;
    if (maxWidth != null) properties['maxWidth'] = maxWidth;
    if (minHeight != null) properties['minHeight'] = minHeight;
    if (maxHeight != null) properties['maxHeight'] = maxHeight;

    await _bridge.updateView(id, properties);
    return this as T;
  }

  // Enhanced animation support
  Future<T> animate<T extends UIComponent>({
    required Map<String, dynamic> properties,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    bool? repeatForever,
    int? repeatCount,
    bool? autoreverse,
    VoidCallback? completion,
  }) async {
    final animationConfig = {
      'properties': properties,
      'duration': duration.inMilliseconds,
      'curve': curve.toString(),
      if (repeatForever != null) 'repeatForever': repeatForever,
      if (repeatCount != null) 'repeatCount': repeatCount,
      if (autoreverse != null) 'autoreverse': autoreverse,
    };

    await _bridge.animate(id, animationConfig);

    if (completion != null) {
      await _bridge.registerEvent(id, 'animationComplete', (_) => completion());
    }

    return this as T;
  }

  // Enhanced gesture support
  Future<T> onGesture<T extends UIComponent>(
    GestureType type,
    Function(GestureInfo) callback, {
    bool cancelsTouches = false,
    required bool requiresFailureOf,
  }) async {
    await _bridge.registerEvent(id, type.toString(), (args) {
      callback(GestureInfo.fromMap(args));
    });
    return this as T;
  }

  // State binding support
  Future<T> bindState<T extends UIComponent>(
      String key, StateChangeCallback callback) async {
    await _bridge.bind(id, key, callback);
    return this as T;
  }

  // Layout constraint helpers
  Future<T> constrain<T extends UIComponent>({
    UIEdgeInsets? insets,
    double? width,
    double? height,
    double? aspectRatio,
    Alignment? alignment,
  }) async {
    final constraints = <String, dynamic>{};

    if (insets != null) constraints['insets'] = insets.toMap();
    if (width != null) constraints['width'] = width;
    if (height != null) constraints['height'] = height;
    if (aspectRatio != null) constraints['aspectRatio'] = aspectRatio;
    if (alignment != null) constraints['alignment'] = alignment.toString();

    await _bridge.updateView(id, {'constraints': constraints});
    return this as T;
  }

  // Add these core methods back
  Future<bool> attachTo(String parentId) => _bridge.attachView(parentId, id);
  Future<bool> setVisible(bool visible) =>
      _bridge.setViewVisibility(id, visible);
  Future<bool> remove() => _bridge.deleteView(id);

  // Add onClick back
  Future<T> onClick<T extends UIComponent>(Function callback) async {
    await _bridge.registerEvent(id, 'onClick', callback);
    return this as T;
  }

  // Add basic style methods back
  Future<T> margin<T extends UIComponent>(UIEdgeInsets margin) async {
    await _bridge.setViewMargin(
        id,
        EdgeInsets.only(
            left: margin.left,
            top: margin.top,
            right: margin.right,
            bottom: margin.bottom));
    return this as T;
  }

  Future<T> padding<T extends UIComponent>(UIEdgeInsets padding) async {
    await _bridge.setViewPadding(
        id,
        EdgeInsets.only(
            left: padding.left,
            top: padding.top,
            right: padding.right,
            bottom: padding.bottom));
    return this as T;
  }

  Future<T> size<T extends UIComponent>(double width, double height) async {
    await _bridge.setViewSize(id, width: width, height: height);
    return this as T;
  }
}

// Additional supporting types
class GradientConfig {
  final List<String> colors;
  final List<double>? stops;
  final GradientType type;
  final double angle;
  final Point? startPoint;
  final Point? endPoint;
  final double? radius;

  GradientConfig({
    required this.colors,
    this.stops,
    this.type = GradientType.linear,
    this.angle = 0,
    this.startPoint,
    this.endPoint,
    this.radius,
  });

  Map<String, dynamic> toMap() => {
        'colors': colors,
        if (stops != null) 'stops': stops,
        'type': type.toString(),
        'angle': angle,
        if (startPoint != null) 'startPoint': startPoint!.toMap(),
        if (endPoint != null) 'endPoint': endPoint!.toMap(),
        if (radius != null) 'radius': radius,
      };
}

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  Map<String, double> toMap() => {'x': x, 'y': y};
}

class Filter {
  final String type;
  final Map<String, dynamic> parameters;

  const Filter(this.type, this.parameters);

  Map<String, dynamic> toMap() => {
        'type': type,
        'parameters': parameters,
      };

  static Filter blur(double radius) => Filter('blur', {'radius': radius});

  static Filter brightness(double amount) =>
      Filter('brightness', {'amount': amount});
}

class AspectRatio {
  final double value;
  const AspectRatio(this.value);
}

enum ContentMode {
  scaleToFill,
  scaleAspectFit,
  scaleAspectFill,
  center,
  top,
  bottom,
  left,
  right,
}

enum FlexFit { tight, loose }

class GestureInfo {
  final Offset location;
  final Offset? translation;
  final double? scale;
  final double? rotation;
  final double? velocity;
  final GestureState state;

  GestureInfo({
    required this.location,
    this.translation,
    this.scale,
    this.rotation,
    this.velocity,
    required this.state,
  });

  factory GestureInfo.fromMap(Map<String, dynamic> map) => GestureInfo(
        location: Offset(map['x'] ?? 0.0, map['y'] ?? 0.0),
        translation: map['translation'] != null
            ? Offset(map['translation']['x'], map['translation']['y'])
            : null,
        scale: map['scale']?.toDouble(),
        rotation: map['rotation']?.toDouble(),
        velocity: map['velocity']?.toDouble(),
        state: GestureState.values[map['state'] ?? 0],
      );
}

enum GestureState { began, changed, ended, cancelled }

typedef StateChangeCallback = void Function(dynamic value);

enum GradientType { linear, radial, sweep }

enum MaskType { circle, roundRect, custom }

enum GestureType { tap, doubleTap, longPress, pan, pinch, rotate }

enum TextOverflow { clip, ellipsis, fade }

enum FontWeight {
  thin(100),
  extraLight(200),
  light(300),
  regular(400),
  medium(500),
  semiBold(600),
  bold(700),
  extraBold(800),
  black(900);

  final int value;
  const FontWeight(this.value);
}

class FontStyle {
  final String family;
  final double size;
  final FontWeight weight;
  final bool italic;

  const FontStyle({
    required this.family,
    required this.size,
    this.weight = FontWeight.regular,
    this.italic = false,
  });

  Map<String, dynamic> toMap() => {
        'family': family,
        'size': size,
        'weight': weight.toString(),
        'italic': italic,
      };
}

class Dimension {
  final double value;
  final bool isPercent;

  const Dimension(this.value, {this.isPercent = false});

  Map<String, dynamic> toMap() => {
        'value': value,
        'isPercent': isPercent,
      };
}

class Size {
  final Dimension width;
  final Dimension height;

  const Size({
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toMap() => {
        'width': width.toMap(),
        'height': height.toMap(),
      };
}

class Position {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const Position({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  Map<String, dynamic> toMap() => {
        if (top != null) 'top': top,
        if (right != null) 'right': right,
        if (bottom != null) 'bottom': bottom,
        if (left != null) 'left': left,
      };
}

class AnimationConfig {
  final Map<String, dynamic> properties;
  final Duration duration;
  final Curve curve;
  final bool? repeatForever;
  final int? repeatCount;
  final bool? autoreverse;

  const AnimationConfig({
    required this.properties,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.repeatForever,
    this.repeatCount,
    this.autoreverse,
  });

  Map<String, dynamic> toMap() => {
        'properties': properties,
        'duration': duration.inMilliseconds,
        'curve': curve.toString(),
        if (repeatForever != null) 'repeatForever': repeatForever,
        if (repeatCount != null) 'repeatCount': repeatCount,
        if (autoreverse != null) 'autoreverse': autoreverse,
      };
}

class LayoutConstraints {
  final UIEdgeInsets? insets;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final Alignment? alignment;

  const LayoutConstraints({
    this.insets,
    this.width,
    this.height,
    this.aspectRatio,
    this.alignment,
  });

  Map<String, dynamic> toMap() => {
        if (insets != null) 'insets': insets!.toMap(),
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (aspectRatio != null) 'aspectRatio': aspectRatio,
        if (alignment != null) 'alignment': alignment.toString(),
      };
}

class FlexConfig {
  final FlexFit? fit;
  final int? flex;
  final Alignment? alignment;
  final bool? expandHorizontally;
  final bool? expandVertically;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  const FlexConfig({
    this.fit,
    this.flex,
    this.alignment,
    this.expandHorizontally,
    this.expandVertically,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  Map<String, dynamic> toMap() => {
        if (fit != null) 'flexFit': fit.toString(),
        if (flex != null) 'flex': flex,
        if (alignment != null) 'alignment': alignment.toString(),
        if (expandHorizontally != null)
          'expandHorizontally': expandHorizontally,
        if (expandVertically != null) 'expandVertically': expandVertically,
        if (minWidth != null) 'minWidth': minWidth,
        if (maxWidth != null) 'maxWidth': maxWidth,
        if (minHeight != null) 'minHeight': minHeight,
        if (maxHeight != null) 'maxHeight': maxHeight,
      };
}

// Add UIEdgeInsets back (it was removed)
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

// Fix Border class to include toMap
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

// Add proper Alignment implementation
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

// Add toMap to Shadow class
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

// Add toMap to Transform class
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
