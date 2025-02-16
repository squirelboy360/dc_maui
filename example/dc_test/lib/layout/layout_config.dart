import 'package:dc_test/core/types/layout/yoga_types.dart';
import 'package:flutter/material.dart';


class LayoutConfig {
  final YogaPositionType? position;
  final YogaDisplay? display;
  final YogaFlexDirection? flexDirection;
  final YogaJustify? justifyContent;
  final YogaAlign? alignItems;
  final YogaAlign? alignSelf;
  final double? flexGrow;
  final double? flexShrink;
  final dynamic width;  // Can be double or String for percentages
  final dynamic height; // Can be double or String for percentages
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Offset? absolutePosition;
  final double? aspectRatio;
  final bool? expanded;
  final int? flex;
  
  const LayoutConfig({
    this.position,
    this.display,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.alignSelf,
    this.flexGrow,
    this.flexShrink,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.margin,
    this.padding,
    this.absolutePosition,
    this.aspectRatio,
    this.expanded,
    this.flex,
  });

  Map<String, dynamic> toJson() => {
    if (position != null) 'position': position!.name,
    if (display != null) 'display': display!.name,
    if (flexDirection != null) 'flexDirection': flexDirection!.name,
    if (justifyContent != null) 'justifyContent': justifyContent!.name,
    if (alignItems != null) 'alignItems': alignItems!.name,
    if (alignSelf != null) 'alignSelf': alignSelf!.name,
    if (flexGrow != null) 'flexGrow': flexGrow,
    if (flexShrink != null) 'flexShrink': flexShrink,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (minWidth != null) 'minWidth': minWidth,
    if (minHeight != null) 'minHeight': minHeight,
    if (maxWidth != null) 'maxWidth': maxWidth,
    if (maxHeight != null) 'maxHeight': maxHeight,
    if (margin != null) 'margin': {
      'top': margin!.top,
      'right': margin!.right,
      'bottom': margin!.bottom,
      'left': margin!.left,
    },
    if (padding != null) 'padding': {
      'top': padding!.top,
      'right': padding!.right,
      'bottom': padding!.bottom,
      'left': padding!.left,
    },
    if (absolutePosition != null) 'absolutePosition': {
      'x': absolutePosition!.dx,
      'y': absolutePosition!.dy,
    },
    if (aspectRatio != null) 'aspectRatio': aspectRatio,
    if (expanded != null) 'expanded': expanded,
    if (flex != null) 'flex': flex,
  };
}