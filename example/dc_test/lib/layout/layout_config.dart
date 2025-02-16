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
  final dynamic width;
  final dynamic height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? flex;

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
    this.margin,
    this.padding,
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
    if (flex != null) 'flex': flex,
  };
}