import 'dart:io';
import 'package:flutter/material.dart';

enum ViewContentMode {
  scaleToFill('scaleToFill'),
  scaleAspectFit('scaleAspectFit'),
  scaleAspectFill('scaleAspectFill'),
  redraw('redraw'),
  center('center'),
  top('top'),
  bottom('bottom'),
  left('left'),
  right('right'),
  topLeft('topLeft'),
  topRight('topRight'),
  bottomLeft('bottomLeft'),
  bottomRight('bottomRight');

  final String value;
  const ViewContentMode(this.value);
}

// iOS View Tint Adjustment Mode
enum ViewTintAdjustment {
  normal('normal'),
  automatic('automatic'),
  dimmed('dimmed');

  final String value;
  const ViewTintAdjustment(this.value);
}

class ViewTransform {
  final double? scale;
  final double? rotation; // in radians
  final Offset? translation;
  final Matrix4? transform;

  const ViewTransform({
    this.scale,
    this.rotation,
    this.translation,
    this.transform,
  });

  Map<String, dynamic> toMap() => {
        if (scale != null) 'scale': scale,
        if (rotation != null) 'rotation': rotation,
        if (translation != null)
          'translation': {
            'x': translation!.dx,
            'y': translation!.dy,
          },
        if (transform != null) 'transform': transform!.storage,
      };
}

class ViewShadow {
  final double opacity;
  final Color color;
  final Offset offset;
  final double radius;
  final bool shouldRasterize;

  const ViewShadow({
    this.opacity = 1.0,
    required this.color,
    this.offset = Offset.zero,
    this.radius = 0,
    this.shouldRasterize = false,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) return {};

    return {
      'shadowOpacity': opacity,
      'shadowColor': color.value,
      'shadowOffset': {
        'width': offset.dx,
        'height': offset.dy,
      },
      'shadowRadius': radius,
      'shouldRasterize': shouldRasterize,
    };
  }
}

/// Border style for views
class ViewBorder {
  final int color; // This should be an int (ARGB32 format), not a Color object
  final double width;
  final List<double>? dashPattern;

  const ViewBorder({
    required this.color,
    this.width = 1.0,
    this.dashPattern,
  });

  Map<String, dynamic> toMap() => {
        'color': color,
        'width': width,
        if (dashPattern != null) 'dashPattern': dashPattern,
      };
}

// iOS View Semantics
class ViewSemantics {
  final String? label;
  final String? hint;
  final String? value;
  final String? traits;
  final bool? enabled;

  const ViewSemantics({
    this.label,
    this.hint,
    this.value,
    this.traits,
    this.enabled,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) return {};

    return {
      if (label != null) 'accessibilityLabel': label,
      if (hint != null) 'accessibilityHint': hint,
      if (value != null) 'accessibilityValue': value,
      if (traits != null) 'accessibilityTraits': traits,
      if (enabled != null) 'isAccessibilityElement': enabled,
    };
  }
}

class ViewStyle {
  // UIView Core Properties
  final double? alpha;
  final int? backgroundColor;
  final bool? hidden;
  final Offset? center;
  final Size? bounds;
  final ViewTransform? transform;

  // Layer Properties
  final double? cornerRadius;
  final List<UIRectCorner>? maskedCorners;
  final ViewBorder? border;
  final ViewShadow? shadow;
  final bool? masksToBounds;
  final double? opacity;

  // Content
  final ViewContentMode? contentMode;
  final bool? clipsToBounds;

  // Interaction
  final bool? userInteractionEnabled;
  final bool? multipleTouchEnabled;
  final double? contentScaleFactor;

  // Layout
  final bool? preservesSuperviewLayoutMargins;
  final EdgeInsets? layoutMargins;
  final bool? insetsLayoutMarginsFromSafeArea;

  // iOS Specific
  final bool? clearsContextBeforeDrawing;
  final int? tintColor;
  final ViewTintAdjustment? tintAdjustmentMode;
  final ViewSemantics? semantics;
  final bool? isOpaque;
  final int? tag;

  const ViewStyle({
    this.alpha,
    this.backgroundColor,
    this.hidden,
    this.center,
    this.bounds,
    this.transform,
    this.cornerRadius,
    this.maskedCorners,
    this.border,
    this.shadow,
    this.masksToBounds,
    this.opacity,
    this.contentMode,
    this.clipsToBounds,
    this.userInteractionEnabled,
    this.multipleTouchEnabled,
    this.contentScaleFactor,
    this.preservesSuperviewLayoutMargins,
    this.layoutMargins,
    this.insetsLayoutMarginsFromSafeArea,
    this.clearsContextBeforeDrawing,
    this.tintColor,
    this.tintAdjustmentMode,
    this.semantics,
    this.isOpaque,
    this.tag,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) {
      return {
        // for other platforms
      };
    }

    return {
      if (alpha != null) 'alpha': alpha,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (hidden != null) 'hidden': hidden,
      if (center != null) 'center': {'x': center!.dx, 'y': center!.dy},
      if (bounds != null)
        'bounds': {'width': bounds!.width, 'height': bounds!.height},
      if (transform != null) ...transform!.toMap(),
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
      if (maskedCorners != null)
        'maskedCorners': maskedCorners!.map((c) => c.value).toList(),
      if (border != null) ...border!.toMap(),
      if (shadow != null) ...shadow!.toMap(),
      if (masksToBounds != null) 'masksToBounds': masksToBounds,
      if (opacity != null) 'opacity': opacity,
      if (contentMode != null) 'contentMode': contentMode!.value,
      if (clipsToBounds != null) 'clipsToBounds': clipsToBounds,
      if (userInteractionEnabled != null)
        'userInteractionEnabled': userInteractionEnabled,
      if (multipleTouchEnabled != null)
        'multipleTouchEnabled': multipleTouchEnabled,
      if (contentScaleFactor != null) 'contentScaleFactor': contentScaleFactor,
      if (preservesSuperviewLayoutMargins != null)
        'preservesSuperviewLayoutMargins': preservesSuperviewLayoutMargins,
      if (layoutMargins != null)
        'layoutMargins': {
          'top': layoutMargins!.top,
          'left': layoutMargins!.left,
          'bottom': layoutMargins!.bottom,
          'right': layoutMargins!.right,
        },
      if (insetsLayoutMarginsFromSafeArea != null)
        'insetsLayoutMarginsFromSafeArea': insetsLayoutMarginsFromSafeArea,
      if (clearsContextBeforeDrawing != null)
        'clearsContextBeforeDrawing': clearsContextBeforeDrawing,
      if (tintColor != null) 'tintColor': tintColor,
      if (tintAdjustmentMode != null)
        'tintAdjustmentMode': tintAdjustmentMode!.value,
      if (semantics != null) ...semantics!.toMap(),
      if (isOpaque != null) 'isOpaque': isOpaque,
      if (tag != null) 'tag': tag,
    };
  }
}

enum UIRectCorner {
  topLeft('topLeft'),
  topRight('topRight'),
  bottomLeft('bottomLeft'),
  bottomRight('bottomRight'),
  allCorners('all');

  final String value;
  const UIRectCorner(this.value);
}
