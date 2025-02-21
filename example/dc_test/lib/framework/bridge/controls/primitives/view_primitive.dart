import 'package:flutter/foundation.dart';
import 'package:yoga_layout/yoga_layout.dart';

/// Core primitive for View styling and layout
class ViewPrimitive {
  // Base style properties
  double? opacity;
  int? backgroundColor;
  double? cornerRadius;
  BorderStyle? borderStyle;
  int? borderColor;
  double? borderWidth;
  bool? clipsToBounds;
  ShadowStyle? shadow;
  
  // Transform properties
  TransformStyle? transform;
  
  // Yoga layout properties
  YogaLayout? layout;
  
  ViewPrimitive({
    this.opacity,
    this.backgroundColor,
    this.cornerRadius,
    this.borderStyle,
    this.borderColor, 
    this.borderWidth,
    this.clipsToBounds,
    this.shadow,
    this.transform,
    this.layout,
  });

  Map<String, dynamic> toMap() {
    return {
      'style': {
        if (opacity != null) 'opacity': opacity,
        if (backgroundColor != null) 'backgroundColor': backgroundColor,
        if (cornerRadius != null) 'cornerRadius': cornerRadius,
        if (borderStyle != null) 'borderStyle': borderStyle?.value,
        if (borderColor != null) 'borderColor': borderColor,
        if (borderWidth != null) 'borderWidth': borderWidth,
        if (clipsToBounds != null) 'clipsToBounds': clipsToBounds,
        if (shadow != null) ...shadow!.toMap(),
        if (transform != null) ...transform!.toMap(),
      },
      if (layout != null) 'layout': layout!.toMap(),
    };
  }
}

/// Border style options
enum BorderStyle {
  none('none'),
  solid('solid'),
  dashed('dashed'),
  dotted('dotted');

  final String value;
  const BorderStyle(this.value);
}

/// Shadow configuration
class ShadowStyle {
  final double? opacity;
  final double? radius;
  final double? offsetX;
  final double? offsetY;
  final int? color;

  ShadowStyle({
    this.opacity,
    this.radius,
    this.offsetX,
    this.offsetY,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'shadowOpacity': opacity,
      'shadowRadius': radius,
      'shadowOffset': {
        'width': offsetX,
        'height': offsetY,
      },
      'shadowColor': color,
    };
  }
}

/// Transform configuration  
class TransformStyle {
  final double? scale;
  final double? rotation; // in radians
  final Offset? translation;

  TransformStyle({
    this.scale,
    this.rotation,
    this.translation,
  });

  Map<String, dynamic> toMap() {
    return {
      'transform': {
        if (scale != null) 'scale': scale,
        if (rotation != null) 'rotation': rotation,
        if (translation != null) 'translation': {
          'x': translation!.dx,
          'y': translation!.dy,
        },
      }
    };
  }
}

/// Yoga layout configuration
class YogaLayout {
  // Position
  final YogaEdge? position;
  final Edges? margin;
  final Edges? padding;
  
  // Size
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? minHeight;
  final YogaValue? maxWidth;
  final YogaValue? maxHeight;

  // Flex
  final double? flex;
  final double? flexGrow;
  final double? flexShrink;
  final YogaValue? flexBasis;
  
  // Alignment
  final YogaAlign? alignSelf;
  final YogaAlign? alignItems;
  final YogaAlign? alignContent;
  final YogaJustify? justifyContent;
  
  // Direction
  final YogaFlexDirection? flexDirection;
  final YogaWrap? flexWrap;

  YogaLayout({
    this.position,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth, 
    this.maxHeight,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.alignSelf,
    this.alignItems,
    this.alignContent,
    this.justifyContent,
    this.flexDirection,
    this.flexWrap,
  });

  Map<String, dynamic> toMap() {
    return {
      if (position != null) 'position': position!.value,
      if (margin != null) ...margin!.toMap('margin'),
      if (padding != null) ...padding!.toMap('padding'),
      if (width != null) 'width': width!.toMap(),
      if (height != null) 'height': height!.toMap(),
      if (minWidth != null) 'minWidth': minWidth!.toMap(),
      if (minHeight != null) 'minHeight': minHeight!.toMap(),
      if (maxWidth != null) 'maxWidth': maxWidth!.toMap(),
      if (maxHeight != null) 'maxHeight': maxHeight!.toMap(),
      if (flex != null) 'flex': flex,
      if (flexGrow != null) 'flexGrow': flexGrow,
      if (flexShrink != null) 'flexShrink': flexShrink,
      if (flexBasis != null) 'flexBasis': flexBasis!.toMap(),
      if (alignSelf != null) 'alignSelf': alignSelf!.value,
      if (alignItems != null) 'alignItems': alignItems!.value,
      if (alignContent != null) 'alignContent': alignContent!.value,
      if (justifyContent != null) 'justifyContent': justifyContent!.value,
      if (flexDirection != null) 'flexDirection': flexDirection!.value,
      if (flexWrap != null) 'flexWrap': flexWrap!.value,
    };
  }
}

/// Edge values configuration
class Edges {
  final YogaValue? left;
  final YogaValue? top;
  final YogaValue? right;
  final YogaValue? bottom;
  final YogaValue? start;
  final YogaValue? end;
  final YogaValue? horizontal;
  final YogaValue? vertical;
  final YogaValue? all;

  Edges({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.start,
    this.end,
    this.horizontal,
    this.vertical,
    this.all,
  });

  Map<String, dynamic> toMap(String prefix) {
    return {
      if (left != null) '${prefix}Left': left!.toMap(),
      if (top != null) '${prefix}Top': top!.toMap(),
      if (right != null) '${prefix}Right': right!.toMap(),
      if (bottom != null) '${prefix}Bottom': bottom!.toMap(),
      if (start != null) '${prefix}Start': start!.toMap(),
      if (end != null) '${prefix}End': end!.toMap(),
      if (horizontal != null) '${prefix}Horizontal': horizontal!.toMap(),
      if (vertical != null) '${prefix}Vertical': vertical!.toMap(),
      if (all != null) prefix: all!.toMap(),
    };
  }
}
