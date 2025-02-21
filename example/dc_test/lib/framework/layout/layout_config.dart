import 'package:flutter/material.dart';
import '../types/layout/yoga_types.dart';

class LayoutConfig {
  // Size properties
  final YGValue? width;
  final YGValue? height;
  final YGValue? minWidth;
  final YGValue? maxWidth;
  final YGValue? minHeight;
  final YGValue? maxHeight;

  // Flex properties
  final double? flex;
  final double? flexGrow;
  final double? flexShrink;
  final YGValue? flexBasis;
  final YGFlexDirection? flexDirection;
  final YGWrap? flexWrap; // Added

  // Spacing
  final double? gap;
  final double? rowGap;
  final double? columnGap;

  // Alignment & Positioning
  final YGJustify? justifyContent;
  final YGAlign? alignItems;
  final YGAlign? alignSelf;
  final YGAlign? alignContent;
  final YGPositionType? position;

  // Spacing
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final EdgeInsets? border;

  // Position coordinates
  final YGValue? left;
  final YGValue? top;
  final YGValue? right;
  final YGValue? bottom;

  // Additional properties
  final double? aspectRatio;
  final YGDisplay? display;
  final YGOverflow? overflow; // Added

  const LayoutConfig({
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.flexDirection,
    this.flexWrap,
    this.gap,
    this.rowGap,
    this.columnGap,
    this.justifyContent,
    this.alignItems,
    this.alignSelf,
    this.alignContent,
    this.position,
    this.margin,
    this.padding,
    this.border,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.aspectRatio,
    this.display,
    this.overflow,
  });

  Map<String, dynamic> toJson() => {
        if (width != null) 'width': width!.toJson(),
        if (height != null) 'height': height!.toJson(),
        if (minWidth != null) 'minWidth': minWidth!.toJson(),
        if (maxWidth != null) 'maxWidth': maxWidth!.toJson(),
        if (minHeight != null) 'minHeight': minHeight!.toJson(),
        if (maxHeight != null) 'maxHeight': maxHeight!.toJson(),
        if (flex != null) 'flex': flex,
        if (flexGrow != null) 'flexGrow': flexGrow,
        if (flexShrink != null) 'flexShrink': flexShrink,
        if (flexBasis != null) 'flexBasis': flexBasis!.toJson(),
        if (flexDirection != null) 'flexDirection': flexDirection!.name,
        if (flexWrap != null) 'flexWrap': flexWrap!.name,
        if (gap != null) 'gap': gap,
        if (rowGap != null) 'rowGap': rowGap,
        if (columnGap != null) 'columnGap': columnGap,
        if (justifyContent != null) 'justifyContent': justifyContent!.name,
        if (alignItems != null) 'alignItems': alignItems!.name,
        if (alignSelf != null) 'alignSelf': alignSelf!.name,
        if (alignContent != null) 'alignContent': alignContent!.name,
        if (position != null) 'position': position!.name,
        if (margin != null) 'margin': margin!.toEdgeMap(),
        if (padding != null) 'padding': padding!.toEdgeMap(),
        if (border != null) 'border': border!.toEdgeMap(),
        if (left != null) 'left': left!.toJson(),
        if (top != null) 'top': top!.toJson(),
        if (right != null) 'right': right!.toJson(),
        if (bottom != null) 'bottom': bottom!.toJson(),
        if (aspectRatio != null) 'aspectRatio': aspectRatio,
        if (display != null) 'display': display!.name,
        if (overflow != null) 'overflow': overflow!.name,
      };
}
