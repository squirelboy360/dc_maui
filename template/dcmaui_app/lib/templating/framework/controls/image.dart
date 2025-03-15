import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'dart:io' show Platform;

/// Image resize modes
enum ImageResizeMode {
  cover,
  contain,
  stretch,
  center,
  repeat,
  none,
}

/// Style properties for Image
class ImageStyle implements StyleProps {
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final double? opacity;
  final BoxFit? resizeMode;
  final bool? clipToBounds;
  final List<BoxShadow>? boxShadow;
  final Color? tintColor;

  const ImageStyle({
    this.width,
    this.height,
    this.margin,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.opacity,
    this.resizeMode,
    this.clipToBounds,
    this.boxShadow,
    this.tintColor,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;

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

    if (borderRadius != null) {
      if (borderRadius!.topLeft == borderRadius!.topRight &&
          borderRadius!.topLeft == borderRadius!.bottomLeft &&
          borderRadius!.topLeft == borderRadius!.bottomRight) {
        map['borderRadius'] = borderRadius!.topLeft.x;
      } else {
        map['borderTopLeftRadius'] = borderRadius!.topLeft.x;
        map['borderTopRightRadius'] = borderRadius!.topRight.x;
        map['borderBottomLeftRadius'] = borderRadius!.bottomLeft.x;
        map['borderBottomRightRadius'] = borderRadius!.bottomRight.x;
      }
    }

    if (borderWidth != null) map['borderWidth'] = borderWidth;

    if (borderColor != null) {
      final colorValue = borderColor!.value.toRadixString(16).padLeft(8, '0');
      map['borderColor'] = '#$colorValue';
    }

    if (opacity != null) map['opacity'] = opacity;

    if (resizeMode != null) {
      switch (resizeMode) {
        case BoxFit.cover:
          map['resizeMode'] = 'cover';
          break;
        case BoxFit.contain:
          map['resizeMode'] = 'contain';
          break;
        case BoxFit.fill:
          map['resizeMode'] = 'stretch';
          break;
        case BoxFit.fitWidth:
          map['resizeMode'] = 'fitWidth';
          break;
        case BoxFit.fitHeight:
          map['resizeMode'] = 'fitHeight';
          break;
        case BoxFit.none:
          map['resizeMode'] = 'none';
          break;
        case BoxFit.scaleDown:
          map['resizeMode'] = 'scaleDown';
          break;
        default:
          map['resizeMode'] = 'cover';
      }
    }

    if (clipToBounds != null) map['clipToBounds'] = clipToBounds;

    if (tintColor != null) {
      final colorValue = tintColor!.value.toRadixString(16).padLeft(8, '0');
      map['tintColor'] = '#$colorValue';
    }

    if (boxShadow != null && boxShadow!.isNotEmpty) {
      final shadow = boxShadow!.first;
      map['shadowColor'] =
          '#${shadow.color.value.toRadixString(16).padLeft(8, '0')}';
      map['shadowOffset'] = {
        'width': shadow.offset.dx,
        'height': shadow.offset.dy
      };
      map['shadowOpacity'] = shadow.color.opacity;
      map['shadowRadius'] = shadow.blurRadius;
    }

    return map;
  }

  factory ImageStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }
      return Color(int.parse(hexString, radix: 16));
    }

    // Convert resize mode
    BoxFit? parseResizeMode(String? mode) {
      if (mode == null) return null;
      switch (mode) {
        case 'cover':
          return BoxFit.cover;
        case 'contain':
          return BoxFit.contain;
        case 'stretch':
          return BoxFit.fill;
        case 'center':
          return BoxFit.none;
        case 'fitWidth':
          return BoxFit.fitWidth;
        case 'fitHeight':
          return BoxFit.fitHeight;
        case 'none':
          return BoxFit.none;
        default:
          return BoxFit.cover;
      }
    }

    // Convert margin
    EdgeInsets? convertMargin(dynamic margin) {
      if (margin is EdgeInsets) return margin;
      if (margin is double) return EdgeInsets.all(margin);
      return null;
    }

    // Convert border radius
    BorderRadius? convertBorderRadius(dynamic radius) {
      if (radius is BorderRadius) return radius;
      if (radius is double) return BorderRadius.circular(radius);
      return null;
    }

    return ImageStyle(
      width: map['width'] is double ? map['width'] : null,
      height: map['height'] is double ? map['height'] : null,
      margin: convertMargin(map['margin']),
      borderRadius: convertBorderRadius(map['borderRadius']),
      borderWidth: map['borderWidth'] is double ? map['borderWidth'] : null,
      borderColor: map['borderColor'] is Color
          ? map['borderColor']
          : hexToColor(map['borderColor']),
      opacity: map['opacity'] is double ? map['opacity'] : null,
      resizeMode: map['resizeMode'] is String
          ? parseResizeMode(map['resizeMode'])
          : null,
      clipToBounds: map['clipToBounds'] is bool ? map['clipToBounds'] : null,
      tintColor: map['tintColor'] is Color
          ? map['tintColor']
          : hexToColor(map['tintColor']),
    );
  }

  ImageStyle copyWith({
    double? width,
    double? height,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    double? borderWidth,
    Color? borderColor,
    double? opacity,
    BoxFit? resizeMode,
    bool? clipToBounds,
    List<BoxShadow>? boxShadow,
    Color? tintColor,
  }) {
    return ImageStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      opacity: opacity ?? this.opacity,
      resizeMode: resizeMode ?? this.resizeMode,
      clipToBounds: clipToBounds ?? this.clipToBounds,
      boxShadow: boxShadow ?? this.boxShadow,
      tintColor: tintColor ?? this.tintColor,
    );
  }
}

/// Props for Image control
class ImageProps implements ControlProps {
  final String source; // URL or asset path
  final bool? isAsset;
  final bool? loadingIndicator;
  final Function(bool)? onLoadStart;
  final Function(bool)? onLoadEnd;
  final Function(dynamic)? onError;
  final Function()? onPress;
  final ImageStyle? style;
  final String? testID;
  final String? accessibilityLabel;
  final Map<String, dynamic> additionalProps;

  const ImageProps({
    required this.source,
    this.isAsset,
    this.loadingIndicator,
    this.onLoadStart,
    this.onLoadEnd,
    this.onError,
    this.onPress,
    this.style,
    this.testID,
    this.accessibilityLabel,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'source': source,
      ...additionalProps,
    };

    if (isAsset != null) map['isAsset'] = isAsset;
    if (loadingIndicator != null) map['loadingIndicator'] = loadingIndicator;
    if (onLoadStart != null) map['onLoadStart'] = onLoadStart;
    if (onLoadEnd != null) map['onLoadEnd'] = onLoadEnd;
    if (onError != null) map['onError'] = onError;
    if (onPress != null) map['onPress'] = onPress;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;
    if (accessibilityLabel != null)
      map['accessibilityLabel'] = accessibilityLabel;

    // Add platform-specific props and behavior
    if (kIsWeb) {
      map['_platform'] = 'web';

      // Apply web-specific image handling
      if (onPress != null && !map.containsKey('cursor')) {
        map['cursor'] = 'pointer';
      }

      // Better loading behavior on web
      if (!map.containsKey('loading') &&
          !additionalProps.containsKey('loading')) {
        map['loading'] = 'lazy';
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';

      // iOS-specific image properties
      if (!map.containsKey('fadeDuration') &&
          !additionalProps.containsKey('fadeDuration')) {
        map['fadeDuration'] = 300; // iOS image fade in duration in milliseconds
      }

      if (style?.resizeMode == null && !map.containsKey('resizeMode')) {
        map['resizeMode'] = 'cover'; // Default for iOS
      }

      // Add default clipping behavior
      if (style?.clipToBounds == null && !map.containsKey('clipToBounds')) {
        map['clipToBounds'] = true;
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';

      // Android-specific image properties
      if (!map.containsKey('fadeDuration') &&
          !additionalProps.containsKey('fadeDuration')) {
        map['fadeDuration'] = 300; // Android fade in duration
      }

      if (onPress != null && !map.containsKey('rippleColor')) {
        map['rippleColor'] = '#20000000'; // Ripple effect for clickable images
      }

      // Add default scaleType
      if (style?.resizeMode == null && !map.containsKey('resizeMode')) {
        map['resizeMode'] = 'centerCrop'; // Android equivalent of 'cover'
      }
    }

    return map;
  }

  ImageProps copyWith({
    String? source,
    bool? isAsset,
    bool? loadingIndicator,
    Function(bool)? onLoadStart,
    Function(bool)? onLoadEnd,
    Function(dynamic)? onError,
    Function()? onPress,
    ImageStyle? style,
    String? testID,
    String? accessibilityLabel,
    Map<String, dynamic>? additionalProps,
  }) {
    return ImageProps(
      source: source ?? this.source,
      isAsset: isAsset ?? this.isAsset,
      loadingIndicator: loadingIndicator ?? this.loadingIndicator,
      onLoadStart: onLoadStart ?? this.onLoadStart,
      onLoadEnd: onLoadEnd ?? this.onLoadEnd,
      onError: onError ?? this.onError,
      onPress: onPress ?? this.onPress,
      style: style ?? this.style,
      testID: testID ?? this.testID,
      accessibilityLabel: accessibilityLabel ?? this.accessibilityLabel,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Image control
class Image extends Control {
  final ImageProps props;

  Image({
    required String source,
    bool? isAsset,
    bool? loadingIndicator,
    Function(bool)? onLoadStart,
    Function(bool)? onLoadEnd,
    Function(dynamic)? onError,
    Function()? onPress,
    ImageStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
    String? accessibilityLabel,
  }) : props = ImageProps(
          source: source,
          isAsset: isAsset,
          loadingIndicator: loadingIndicator,
          onLoadStart: onLoadStart,
          onLoadEnd: onLoadEnd,
          onError: onError,
          onPress: onPress,
          style:
              style ?? (styleMap != null ? ImageStyle.fromMap(styleMap) : null),
          testID: testID,
          accessibilityLabel: accessibilityLabel,
        );

  Image.custom({required this.props});

  /// Create an image from an asset
  static Image asset({
    required String name,
    bool? loadingIndicator,
    Function(bool)? onLoadStart,
    Function(bool)? onLoadEnd,
    Function(dynamic)? onError,
    Function()? onPress,
    ImageStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
    String? accessibilityLabel,
  }) {
    return Image(
      source: name,
      isAsset: true,
      loadingIndicator: loadingIndicator,
      onLoadStart: onLoadStart,
      onLoadEnd: onLoadEnd,
      onError: onError,
      onPress: onPress,
      style: style ?? (styleMap != null ? ImageStyle.fromMap(styleMap) : null),
      testID: testID,
      accessibilityLabel: accessibilityLabel,
    );
  }

  /// Create an image from a network URL
  static Image network({
    required String url,
    bool? loadingIndicator,
    Function(bool)? onLoadStart,
    Function(bool)? onLoadEnd,
    Function(dynamic)? onError,
    Function()? onPress,
    ImageStyle? style,
    Map<String, dynamic>? styleMap,
    String? testID,
    String? accessibilityLabel,
  }) {
    return Image(
      source: url,
      isAsset: false,
      loadingIndicator: loadingIndicator,
      onLoadStart: onLoadStart,
      onLoadEnd: onLoadEnd,
      onError: onError,
      onPress: onPress,
      style: style ?? (styleMap != null ? ImageStyle.fromMap(styleMap) : null),
      testID: testID,
      accessibilityLabel: accessibilityLabel,
    );
  }

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Image',
      props.toMap(),
      [], // Image doesn't have children
    );
  }
}
