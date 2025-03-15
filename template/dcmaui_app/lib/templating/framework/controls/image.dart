import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/painting.dart';

/// Enum defining how the image should resize to fit its container
enum ResizeMode {
  /// Scale the image uniformly to fit within the bounds
  contain,

  /// Scale the image uniformly to fill the bounds
  cover,

  /// Stretch the image to fill the bounds
  stretch,

  /// Center the image in the bounds
  center,

  /// Repeat the image to fill the bounds
  repeat
}

/// Style properties for Image
class ImageStyle implements StyleProps {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final double? opacity;
  final BoxFit? objectFit; // In React Native this is resizeMode
  final Color? backgroundColor;

  const ImageStyle({
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.opacity,
    this.objectFit,
    this.backgroundColor,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;

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

    if (opacity != null) map['opacity'] = opacity;

    if (objectFit != null) {
      switch (objectFit) {
        case BoxFit.contain:
          map['resizeMode'] = 'contain';
          break;
        case BoxFit.cover:
          map['resizeMode'] = 'cover';
          break;
        case BoxFit.fill:
          map['resizeMode'] = 'stretch';
          break;
        case BoxFit.none:
          map['resizeMode'] = 'center';
          break;
        case BoxFit.scaleDown:
          map['resizeMode'] = 'contain';
          break;
        default:
          map['resizeMode'] = 'cover';
      }
    }

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    return map;
  }

  ImageStyle copyWith({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    double? opacity,
    BoxFit? objectFit,
    Color? backgroundColor,
  }) {
    return ImageStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      opacity: opacity ?? this.opacity,
      objectFit: objectFit ?? this.objectFit,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

/// Props for Image component
class ImageProps implements ControlProps {
  final ImageSource source;
  final ImageStyle? style;
  final bool? loadingIndicatorEnabled;
  final String? blurHash; // For advanced image loading (optional)
  final Function()? onLoad;
  final Function(String)? onError;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const ImageProps({
    required this.source,
    this.style,
    this.loadingIndicatorEnabled,
    this.blurHash,
    this.onLoad,
    this.onError,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'source': source.toMap(),
      ...additionalProps,
    };

    if (style != null) map['style'] = style!.toMap();
    if (loadingIndicatorEnabled != null) {
      map['loadingIndicatorEnabled'] = loadingIndicatorEnabled;
    }
    if (blurHash != null) map['blurHash'] = blurHash;
    if (onLoad != null) map['onLoad'] = onLoad;
    if (onError != null) map['onError'] = onError;
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// Represents an image source - either a remote URL or local asset
class ImageSource {
  final String? uri;
  final String? assetName;
  final double? scale;
  final Map<String, String>? headers;

  /// Create a source from a URI/URL
  const ImageSource.network(this.uri, {this.headers, this.scale})
      : assetName = null;

  /// Create a source from a local asset
  const ImageSource.asset(this.assetName, {this.scale})
      : uri = null,
        headers = null;

  Map<String, dynamic> toMap() {
    if (uri != null) {
      final map = <String, dynamic>{'uri': uri};
      if (headers != null) map['headers'] = headers;
      if (scale != null) map['scale'] = scale;
      return map;
    } else if (assetName != null) {
      final map = <String, dynamic>{'assetName': assetName};
      if (scale != null) map['scale'] = scale;
      return map;
    } else {
      return {};
    }
  }
}

/// Image component
class Image extends Control {
  final ImageProps props;

  /// Create an image from a URI/URL
  Image.network(
    String uri, {
    Map<String, String>? headers,
    ImageStyle? style,
    bool? loadingIndicatorEnabled,
    String? blurHash,
    Function()? onLoad,
    Function(String)? onError,
    String? testID,
  }) : props = ImageProps(
          source: ImageSource.network(uri, headers: headers),
          style: style,
          loadingIndicatorEnabled: loadingIndicatorEnabled,
          blurHash: blurHash,
          onLoad: onLoad,
          onError: onError,
          testID: testID,
        );

  /// Create an image from a local asset
  Image.asset(
    String assetName, {
    double? scale,
    ImageStyle? style,
    bool? loadingIndicatorEnabled,
    String? blurHash,
    Function()? onLoad,
    Function(String)? onError,
    String? testID,
  }) : props = ImageProps(
          source: ImageSource.asset(assetName, scale: scale),
          style: style,
          loadingIndicatorEnabled: loadingIndicatorEnabled,
          blurHash: blurHash,
          onLoad: onLoad,
          onError: onError,
          testID: testID,
        );

  Image.custom({required this.props});

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Image',
      props.toMap(),
      [], // Image doesn't have children
    );
  }
}
