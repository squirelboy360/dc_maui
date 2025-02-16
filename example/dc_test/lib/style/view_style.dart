import 'package:flutter/material.dart';

// Base interface for all style types
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}

// Border styles
class BorderStyle implements JsonSerializable {
  final double width;
  final Color color;
  final BorderType style;

  const BorderStyle({
    this.width = 1.0,
    required this.color,
    this.style = BorderType.solid,
  });

  @override
  Map<String, dynamic> toJson() => {
    'width': width,
    'color': color.value,
    'style': style.name,
  };
}

enum BorderType {
  none,
  solid,
  dashed,
  dotted
}

// Shadow style
class ShadowStyle implements JsonSerializable {
  final Color color;
  final Offset offset;
  final double radius;
  final double opacity;

  const ShadowStyle({
    required this.color,
    this.offset = const Offset(0, 2),
    this.radius = 4,
    this.opacity = 0.25,
  });

  @override
  Map<String, dynamic> toJson() => {
    'color': color.value,
    'offset': {'x': offset.dx, 'y': offset.dy},
    'radius': radius,
    'opacity': opacity,
  };
}

// Gradient style
class GradientStyle implements JsonSerializable {
  final List<Color> colors;
  final List<double> stops;
  final GradientType type;
  final Alignment begin;
  final Alignment end;
  final double? angle; // For linear gradients

  const GradientStyle({
    required this.colors,
    this.stops = const [],
    this.type = GradientType.linear,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.angle,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'colors': colors.map((c) => c.value).toList(),
    'stops': stops,
    'begin': {'x': begin.x, 'y': begin.y},
    'end': {'x': end.x, 'y': end.y},
    if (angle != null) 'angle': angle,
  };
}

enum GradientType {
  linear,
  radial,
  sweep
}

// Text style properties
class TextStyle implements JsonSerializable {
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? lineHeight;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final bool? italic;
  final int? maxLines;
  final TextOverflow? overflow;

  const TextStyle({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.decoration,
    this.textAlign,
    this.italic,
    this.maxLines,
    this.overflow,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (fontFamily != null) 'fontFamily': fontFamily,
    if (fontSize != null) 'fontSize': fontSize,
    if (fontWeight != null) 'fontWeight': fontWeight!.value,
    if (color != null) 'color': color!.value,
    if (letterSpacing != null) 'letterSpacing': letterSpacing,
    if (wordSpacing != null) 'wordSpacing': wordSpacing,
    if (lineHeight != null) 'lineHeight': lineHeight,
    if (decoration != null) 'decoration': decoration!.toString(),
    if (textAlign != null) 'textAlign': textAlign!.name,
    if (italic != null) 'italic': italic,
    if (maxLines != null) 'maxLines': maxLines,
    if (overflow != null) 'overflow': overflow!.name,
  };
}

// Transform style
class TransformStyle implements JsonSerializable {
  final double? rotation; // in degrees
  final Offset? scale;
  final Offset? translation;
  final Offset? anchor;
  final Matrix4? transform;

  const TransformStyle({
    this.rotation,
    this.scale,
    this.translation,
    this.anchor,
    this.transform,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (rotation != null) 'rotation': rotation,
    if (scale != null) 'scale': {'x': scale!.dx, 'y': scale!.dy},
    if (translation != null) 'translation': {'x': translation!.dx, 'y': translation!.dy},
    if (anchor != null) 'anchor': {'x': anchor!.dx, 'y': anchor!.dy},
    if (transform != null) 'matrix': transform!.storage,
  };
}

// Image style
class ImageStyle implements JsonSerializable {
  final BoxFit? fit;
  final FilterQuality? filterQuality;
  final BlendMode? blendMode;
  final Color? tintColor;
  final double? opacity;

  const ImageStyle({
    this.fit,
    this.filterQuality,
    this.blendMode,
    this.tintColor,
    this.opacity,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (fit != null) 'fit': fit!.name,
    if (filterQuality != null) 'filterQuality': filterQuality!.name,
    if (blendMode != null) 'blendMode': blendMode!.name,
    if (tintColor != null) 'tintColor': tintColor!.value,
    if (opacity != null) 'opacity': opacity,
  };
}

// Unified view style that combines all style properties
class ViewStyle implements JsonSerializable {
  final Color? backgroundColor;
  final double? opacity;
  final BorderStyle? border;
  final double? cornerRadius;
  final List<ShadowStyle>? shadows;
  final GradientStyle? gradient;
  final BlendMode? blendMode;
  final TransformStyle? transform;
  final bool? clipToBounds;
  final TextStyle? textStyle;
  final ImageStyle? imageStyle;
  final Map<String, dynamic>? extraStyles; // For platform-specific styles

  const ViewStyle({
    this.backgroundColor,
    this.opacity,
    this.border,
    this.cornerRadius,
    this.shadows,
    this.gradient,
    this.blendMode,
    this.transform,
    this.clipToBounds,
    this.textStyle,
    this.imageStyle,
    this.extraStyles,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (opacity != null) 'opacity': opacity,
    if (border != null) 'border': border!.toJson(),
    if (cornerRadius != null) 'cornerRadius': cornerRadius,
    if (shadows != null) 'shadows': shadows!.map((s) => s.toJson()).toList(),
    if (gradient != null) 'gradient': gradient!.toJson(),
    if (blendMode != null) 'blendMode': blendMode!.name,
    if (transform != null) 'transform': transform!.toJson(),
    if (clipToBounds != null) 'clipToBounds': clipToBounds,
    if (textStyle != null) 'textStyle': textStyle!.toJson(),
    if (imageStyle != null) 'imageStyle': imageStyle!.toJson(),
    if (extraStyles != null) ...extraStyles!,
  };
}