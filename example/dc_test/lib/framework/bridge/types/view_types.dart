import 'dart:io';
import 'package:dc_test/framework/bridge/types/view_styles.dart';
import 'package:flutter/material.dart';

class ViewStyle {
  // UIView properties
  final double? opacity;
  final int? backgroundColor;
  final bool? clipsToBounds;
  final bool? userInteractionEnabled;
  final bool? multipleTouchEnabled;
  final ViewContentMode? contentMode;
  final ViewSemantics? semantics;
  
  // Layer properties
  final ViewTransform? transform;
  final ViewShadow? shadow;
  final ViewBorder? border;
  final double? cornerRadius;
  final List<double>? maskedCorners;
  
  // iOS specific
  final bool? clearsContextBeforeDrawing;
  final bool? preservesSuperviewLayoutMargins;
  final EdgeInsets? layoutMargins;
  final bool? insetsLayoutMarginsFromSafeArea;
  final ViewTintAdjustment? tintAdjustmentMode;
  final int? tintColor;
  
  const ViewStyle({
    this.opacity,
    this.backgroundColor,
    this.clipsToBounds,
    this.userInteractionEnabled,
    this.multipleTouchEnabled,
    this.contentMode,
    this.semantics,
    this.transform,
    this.shadow,
    this.border,
    this.cornerRadius,
    this.maskedCorners,
    this.clearsContextBeforeDrawing,
    this.preservesSuperviewLayoutMargins,
    this.layoutMargins,
    this.insetsLayoutMarginsFromSafeArea,
    this.tintAdjustmentMode,
    this.tintColor,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) return {};
    
    return {
      if (opacity != null) 'opacity': opacity,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (clipsToBounds != null) 'clipsToBounds': clipsToBounds,
      if (userInteractionEnabled != null) 'userInteractionEnabled': userInteractionEnabled,
      if (multipleTouchEnabled != null) 'multipleTouchEnabled': multipleTouchEnabled,
      if (contentMode != null) 'contentMode': contentMode!.value,
      if (semantics != null) ...semantics!.toMap(),
      if (transform != null) ...transform!.toMap(),
      if (shadow != null) ...shadow!.toMap(),
      if (border != null) ...border!.toMap(),
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
      if (maskedCorners != null) 'maskedCorners': maskedCorners,
      if (clearsContextBeforeDrawing != null) 'clearsContextBeforeDrawing': clearsContextBeforeDrawing,
      if (preservesSuperviewLayoutMargins != null) 'preservesSuperviewLayoutMargins': preservesSuperviewLayoutMargins,
      if (layoutMargins != null) 'layoutMargins': {
        'top': layoutMargins!.top,
        'left': layoutMargins!.left,
        'bottom': layoutMargins!.bottom,
        'right': layoutMargins!.right,
      },
      if (insetsLayoutMarginsFromSafeArea != null) 'insetsLayoutMarginsFromSafeArea': insetsLayoutMarginsFromSafeArea,
      if (tintAdjustmentMode != null) 'tintAdjustmentMode': tintAdjustmentMode!.value,
      if (tintColor != null) 'tintColor': tintColor,
    };
  }
}

class ViewTransform {
  final double? scale;
  final double? rotation;
  final Offset? translation;

  const ViewTransform({
    this.scale,
    this.rotation,
    this.translation,
  });

  Map<String, dynamic> toMap() => {
    if (scale != null) 'scale': scale,
    if (rotation != null) 'rotation': rotation,
    if (translation != null) 'translation': {
      'x': translation!.dx,
      'y': translation!.dy
    },
  };
}
