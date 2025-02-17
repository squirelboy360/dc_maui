import 'package:flutter/material.dart';
import '../core/types/layout/yoga_types.dart';

class LayoutConfig {
  final YGValue? width;
  final YGValue? height;
  final YGValue? minWidth;
  final YGValue? minHeight;
  final YGValue? maxWidth;
  final YGValue? maxHeight;
  final YGPositionType? position;
  final YGDisplay? display;
  final YGFlexDirection? flexDirection;
  final YGJustify? justifyContent;
  final YGAlign? alignItems;
  final YGAlign? alignSelf;
  final double? flex;
  final double? flexGrow;
  final double? flexShrink;
  final YGValue? flexBasis;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Map<YGEdge, double>? border;

  const LayoutConfig({
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.position,
    this.display,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.alignSelf,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.margin,
    this.padding,
    this.border,
  });

  // Helper constructors
  static YGValue percent(double value) => YGValue(value, YGUnit.percent);
  static YGValue points(double value) => YGValue(value, YGUnit.point);
  static YGValue auto() => YGValue(double.nan, YGUnit.auto);

  Map<String, dynamic> toJson() => {
        if (width != null) 'width': width!.toJson(),
        if (height != null) 'height': height!.toJson(),
        if (minWidth != null) 'minWidth': minWidth!.toJson(),
        if (minHeight != null) 'minHeight': minHeight!.toJson(),
        if (maxWidth != null) 'maxWidth': maxWidth!.toJson(),
        if (maxHeight != null) 'maxHeight': maxHeight!.toJson(),
        if (position != null) 'position': position!.name,
        if (display != null) 'display': display!.name,
        if (flexDirection != null) 'flexDirection': flexDirection!.name,
        if (justifyContent != null) 'justifyContent': justifyContent!.name,
        if (alignItems != null) 'alignItems': alignItems!.name,
        if (alignSelf != null) 'alignSelf': alignSelf!.name,
        if (flex != null) 'flex': flex,
        if (flexGrow != null) 'flexGrow': flexGrow,
        if (flexShrink != null) 'flexShrink': flexShrink,
        if (flexBasis != null) 'flexBasis': flexBasis!.toJson(),
        if (margin != null)
          'margin': {
            'top': margin!.top,
            'right': margin!.right,
            'bottom': margin!.bottom,
            'left': margin!.left,
          },
        if (padding != null)
          'padding': {
            'top': padding!.top,
            'right': padding!.right,
            'bottom': padding!.bottom,
            'left': padding!.left,
          },
        if (border != null)
          'border': border!.map((edge, value) => MapEntry(edge.name, value)),
      };
}
