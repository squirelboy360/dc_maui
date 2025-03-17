import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

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

/// Style properties for DCImage
class DCImageStyle implements StyleProps {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final double? opacity;
  final BoxFit? objectFit; // In React Native this is resizeMode
  final Color? backgroundColor;

  const DCImageStyle({
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

  DCImageStyle copyWith({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    double? opacity,
    BoxFit? objectFit,
    Color? backgroundColor,
  }) {
    return DCImageStyle(
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

/// Props for DCImage component
class DCImageProps implements ControlProps {
  final DCImageSource? source;
  final DCImageSource? defaultSource;
  final String? resizeMode;
  final bool? loadingIndicatorEnabled;
  final Function(Map<String, dynamic>)? onLoad;
  final Function(Map<String, dynamic>)? onError;
  final Function()? onLoadStart;
  final Function()? onLoadEnd;
  final ViewStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCImageProps({
    this.source,
    this.defaultSource,
    this.resizeMode,
    this.loadingIndicatorEnabled,
    this.onLoad,
    this.onError,
    this.onLoadStart,
    this.onLoadEnd,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (source != null) map['source'] = source!.toMap();
    if (defaultSource != null) map['defaultSource'] = defaultSource!.toMap();
    if (resizeMode != null) map['resizeMode'] = resizeMode;
    if (loadingIndicatorEnabled != null)
      map['loadingIndicatorEnabled'] = loadingIndicatorEnabled;
    if (onLoad != null) map['onLoad'] = onLoad;
    if (onError != null) map['onError'] = onError;
    if (onLoadStart != null) map['onLoadStart'] = onLoadStart;
    if (onLoadEnd != null) map['onLoadEnd'] = onLoadEnd;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// Image source properties
class DCImageSource {
  final String uri;
  final Map<String, String>? headers;
  final double? width;
  final double? height;
  final double? scale;

  const DCImageSource({
    required this.uri,
    this.headers,
    this.width,
    this.height,
    this.scale,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uri': uri,
    };

    if (headers != null) map['headers'] = headers;
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (scale != null) map['scale'] = scale;

    return map;
  }
}

/// DCImage component
class DCImage extends Control {
  final DCImageProps props;

  DCImage({
    DCImageSource? source,
    DCImageSource? defaultSource,
    String? resizeMode,
    bool? loadingIndicatorEnabled,
    Function(Map<String, dynamic>)? onLoad,
    Function(Map<String, dynamic>)? onError,
    Function()? onLoadStart,
    Function()? onLoadEnd,
    ViewStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCImageProps(
          source: source,
          defaultSource: defaultSource,
          resizeMode: resizeMode,
          loadingIndicatorEnabled: loadingIndicatorEnabled,
          onLoad: onLoad,
          onError: onError,
          onLoadStart: onLoadStart,
          onLoadEnd: onLoadEnd,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCImage',
      props.toMap(),
      [],
    );
  }

  /// Convenience constructor for a network image
  static DCImage network(
    String url, {
    Map<String, String>? headers,
    String? resizeMode,
    ViewStyle? style,
    bool? showLoadingIndicator,
    Function(Map<String, dynamic>)? onLoad,
    Function(Map<String, dynamic>)? onError,
  }) {
    return DCImage(
      source: DCImageSource(
        uri: url,
        headers: headers,
      ),
      resizeMode: resizeMode ?? 'contain',
      style: style,
      loadingIndicatorEnabled: showLoadingIndicator,
      onLoad: onLoad,
      onError: onError,
    );
  }

  /// Convenience constructor for a local image
  static DCImage asset(
    String name, {
    String? resizeMode,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onLoad,
  }) {
    return DCImage(
      source: DCImageSource(
        uri: 'resource:$name',
      ),
      resizeMode: resizeMode ?? 'contain',
      style: style,
      onLoad: onLoad,
    );
  }

  /// Convenience constructor for a base64 image
  static DCImage base64(
    String base64String, {
    String? mimeType = 'image/png',
    String? resizeMode,
    ViewStyle? style,
  }) {
    return DCImage(
      source: DCImageSource(
        uri: 'data:$mimeType;base64,$base64String',
      ),
      resizeMode: resizeMode ?? 'contain',
      style: style,
    );
  }
}
