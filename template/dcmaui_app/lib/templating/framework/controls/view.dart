import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for View component
class ViewStyle implements StyleProps {
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Alignment? align;
  final double? aspectRatio;
  final double? borderRadius;
  final double? borderTopLeftRadius;
  final double? borderTopRightRadius;
  final double? borderBottomLeftRadius;
  final double? borderBottomRightRadius;
  final double? borderWidth;
  final Color? borderColor;
  final double? opacity;
  final List<Map<String, dynamic>>? transform;
  final String? overflow;
  final double? shadowOpacity;
  final Color? shadowColor;
  final double? shadowRadius;
  final Map<String, double>? shadowOffset;
  final BoxConstraints? constraints;
  final FlexFit? flex;
  final int? flexGrow;
  final int? flexShrink;
  final double? flexBasis;
  final Alignment? alignSelf;
  final String? position;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final String? display;

  const ViewStyle({
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.align,
    this.aspectRatio,
    this.borderRadius,
    this.borderTopLeftRadius,
    this.borderTopRightRadius,
    this.borderBottomLeftRadius,
    this.borderBottomRightRadius,
    this.borderWidth,
    this.borderColor,
    this.opacity,
    this.transform,
    this.overflow,
    this.shadowOpacity,
    this.shadowColor,
    this.shadowRadius,
    this.shadowOffset,
    this.constraints,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.alignSelf,
    this.position,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.display,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (backgroundColor != null) {
      final colorValue = backgroundColor!.toHexString();
      map['backgroundColor'] = colorValue;
    }

    // Handle padding
    if (padding != null) {
      if (padding!.left == padding!.right &&
          padding!.top == padding!.bottom &&
          padding!.left == padding!.top) {
        map['padding'] = padding!.top;
      } else {
        map['paddingLeft'] = padding!.left;
        map['paddingRight'] = padding!.right;
        map['paddingTop'] = padding!.top;
        map['paddingBottom'] = padding!.bottom;
      }
    }

    // Handle margin
    if (margin != null) {
      if (margin!.left == margin!.right &&
          margin!.top == margin!.bottom &&
          margin!.left == margin!.top) {
        map['margin'] = margin!.top;
      } else {
        map['marginLeft'] = margin!.left;
        map['marginRight'] = margin!.right;
        map['marginTop'] = margin!.top;
        map['marginBottom'] = margin!.bottom;
      }
    }

    // Dimensions
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (minWidth != null) map['minWidth'] = minWidth;
    if (minHeight != null) map['minHeight'] = minHeight;
    if (maxWidth != null) map['maxWidth'] = maxWidth;
    if (maxHeight != null) map['maxHeight'] = maxHeight;

    // Alignment
    if (align != null) {
      // Convert Flutter Alignment to string representation
      final alignment = _getAlignmentString(align!);
      if (alignment != null) map['alignItems'] = alignment;
    }

    // Aspect ratio
    if (aspectRatio != null) map['aspectRatio'] = aspectRatio;

    // Border properties
    if (borderRadius != null) map['borderRadius'] = borderRadius;
    if (borderTopLeftRadius != null)
      map['borderTopLeftRadius'] = borderTopLeftRadius;
    if (borderTopRightRadius != null)
      map['borderTopRightRadius'] = borderTopRightRadius;
    if (borderBottomLeftRadius != null)
      map['borderBottomLeftRadius'] = borderBottomLeftRadius;
    if (borderBottomRightRadius != null)
      map['borderBottomRightRadius'] = borderBottomRightRadius;
    if (borderWidth != null) map['borderWidth'] = borderWidth;

    if (borderColor != null) {
      final colorValue = borderColor!.toHexString();
      map['borderColor'] = colorValue;
    }

    // Opacity
    if (opacity != null) map['opacity'] = opacity;

    // Transform
    if (transform != null && transform!.isNotEmpty) {
      map['transform'] = transform;
    }

    // Overflow
    if (overflow != null) map['overflow'] = overflow;

    // Shadow properties
    if (shadowOpacity != null) map['shadowOpacity'] = shadowOpacity;

    if (shadowColor != null) {
      final colorValue = shadowColor!.toHexString();
      map['shadowColor'] = colorValue;
    }

    if (shadowRadius != null) map['shadowRadius'] = shadowRadius;
    if (shadowOffset != null) map['shadowOffset'] = shadowOffset;

    // Constraints
    if (constraints != null) {
      if (constraints!.minWidth != 0 && constraints!.minWidth.isFinite) {
        map['minWidth'] = constraints!.minWidth;
      }
      if (constraints!.maxWidth != double.infinity) {
        map['maxWidth'] = constraints!.maxWidth;
      }
      if (constraints!.minHeight != 0 && constraints!.minHeight.isFinite) {
        map['minHeight'] = constraints!.minHeight;
      }
      if (constraints!.maxHeight != double.infinity) {
        map['maxHeight'] = constraints!.maxHeight;
      }
    }

    // Flex properties
    if (flex != null) {
      if (flex == FlexFit.tight) {
        map['flex'] = 1;
      } else if (flex == FlexFit.loose) {
        map['flex'] = 0;
      }
    }
    if (flexGrow != null) map['flexGrow'] = flexGrow;
    if (flexShrink != null) map['flexShrink'] = flexShrink;
    if (flexBasis != null) map['flexBasis'] = flexBasis;

    // Alignment self
    if (alignSelf != null) {
      final alignment = _getAlignmentString(alignSelf!);
      if (alignment != null) map['alignSelf'] = alignment;
    }

    // Position
    if (position != null) map['position'] = position;
    if (top != null) map['top'] = top;
    if (right != null) map['right'] = right;
    if (bottom != null) map['bottom'] = bottom;
    if (left != null) map['left'] = left;

    // Display
    if (display != null) map['display'] = display;

    return map;
  }

  // Helper to convert Flutter Alignment to string
  String? _getAlignmentString(dynamic alignment) {
    if (alignment is Alignment) {
      if (alignment == Alignment.center) return 'center';
      if (alignment == Alignment.centerLeft) return 'flex-start';
      if (alignment == Alignment.centerRight) return 'flex-end';
      if (alignment == Alignment.topCenter) return 'flex-start';
      if (alignment == Alignment.bottomCenter) return 'flex-end';
      if (alignment == Alignment.topLeft) return 'flex-start';
      if (alignment == Alignment.topRight) return 'flex-end';
      if (alignment == Alignment.bottomLeft) return 'flex-end';
      if (alignment == Alignment.bottomRight) return 'flex-end';
    }
    return null;
  }
}

/// Props for View component
class DCViewProps implements ControlProps {
  final bool? pointerEvents;
  final bool? accessible;
  final String? accessibilityLabel;
  final bool? accessibilityLiveRegion;
  final String? importantForAccessibility;
  final String? testID;
  final Function()? onClick;
  final Function()? onLayout;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCViewProps({
    this.pointerEvents,
    this.accessible,
    this.accessibilityLabel,
    this.accessibilityLiveRegion,
    this.importantForAccessibility,
    this.testID,
    this.onClick,
    this.onLayout,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (pointerEvents != null) map['pointerEvents'] = pointerEvents;
    if (accessible != null) map['accessible'] = accessible;
    if (accessibilityLabel != null) {
      map['accessibilityLabel'] = accessibilityLabel;
    }
    if (accessibilityLiveRegion != null) {
      map['accessibilityLiveRegion'] = accessibilityLiveRegion;
    }
    if (importantForAccessibility != null) {
      map['importantForAccessibility'] = importantForAccessibility;
    }
    if (testID != null) map['testID'] = testID;
    if (onClick != null) map['onClick'] = onClick;
    if (onLayout != null) map['onLayout'] = onLayout;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// View component that matches React Native's View
class DCView extends Control {
  final DCViewProps props;
  final List<Control> children;

  DCView({
    bool? pointerEvents,
    bool? accessible,
    String? accessibilityLabel,
    bool? accessibilityLiveRegion,
    String? importantForAccessibility,
    String? testID,
    Function()? onClick,
    Function()? onLayout,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCViewProps(
          pointerEvents: pointerEvents,
          accessible: accessible,
          accessibilityLabel: accessibilityLabel,
          accessibilityLiveRegion: accessibilityLiveRegion,
          importantForAccessibility: importantForAccessibility,
          testID: testID,
          onClick: onClick,
          onLayout: onLayout,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCView',
      props.toMap(),
      buildChildren(children),
    );
  }
}

// Add this extension method to handle color conversion consistently
extension ColorExtension on Color {
  String toHexString() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
