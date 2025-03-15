import 'package:dc_test/templating/framework/controls/low_level/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';

/// Modal presentation styles
enum ModalPresentationStyle {
  /// Full-screen presentation
  fullScreen,

  /// Content appears as a card (partial screen)
  pageSheet,

  /// Content appears bottom-anchored
  formSheet,

  /// Semi-transparent background
  overFullScreen,
}

/// Animation types for modal transitions
enum ModalAnimationType {
  /// No animation
  none,

  /// Slide up from bottom
  slide,

  /// Fade in
  fade,
}

/// Style properties for Modal
class ModalStyle implements StyleProps {
  final Color? backgroundColor;
  final double? backdropOpacity;
  final double? borderRadius;
  final EdgeInsets? margin;
  final double? elevation;
  final Duration? animationDuration;

  const ModalStyle({
    this.backgroundColor,
    this.backdropOpacity,
    this.borderRadius,
    this.margin,
    this.elevation,
    this.animationDuration,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (backdropOpacity != null) map['backdropOpacity'] = backdropOpacity;
    if (borderRadius != null) map['borderRadius'] = borderRadius;

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

    if (elevation != null) map['elevation'] = elevation;
    if (animationDuration != null)
      map['animationDuration'] = animationDuration!.inMilliseconds;

    return map;
  }

  /// Factory to convert a Map to a ModalStyle
  factory ModalStyle.fromMap(Map<String, dynamic> map) {
    // Helper function to convert hex string to Color
    Color? hexToColor(String? hexString) {
      if (hexString == null || !hexString.startsWith('#')) return null;
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      }
      return Color(int.parse(hexString, radix: 16));
    }

    return ModalStyle(
      backgroundColor: map['backgroundColor'] is Color
          ? map['backgroundColor']
          : hexToColor(map['backgroundColor']),
      backdropOpacity:
          map['backdropOpacity'] is double ? map['backdropOpacity'] : null,
      borderRadius: map['borderRadius'] is double ? map['borderRadius'] : null,
      margin: map['margin'] is EdgeInsets
          ? map['margin']
          : map['margin'] is double
              ? EdgeInsets.all(map['margin'])
              : null,
      elevation: map['elevation'] is double ? map['elevation'] : null,
      animationDuration: map['animationDuration'] != null
          ? Duration(milliseconds: map['animationDuration'])
          : null,
    );
  }

  ModalStyle copyWith({
    Color? backgroundColor,
    double? backdropOpacity,
    double? borderRadius,
    EdgeInsets? margin,
    double? elevation,
    Duration? animationDuration,
  }) {
    return ModalStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backdropOpacity: backdropOpacity ?? this.backdropOpacity,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      elevation: elevation ?? this.elevation,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

/// Props for Modal component
class ModalProps implements ControlProps {
  final bool visible;
  final Function()? onRequestClose;
  final bool? transparent;
  final ModalPresentationStyle? presentationStyle;
  final ModalAnimationType? animationType;
  final bool? hardwareAccelerated;
  final Function()? onShow;
  final Function()? onDismiss;
  final String? testID;
  final ModalStyle? style;
  final Map<String, dynamic> additionalProps;

  const ModalProps({
    required this.visible,
    this.onRequestClose,
    this.transparent,
    this.presentationStyle,
    this.animationType,
    this.hardwareAccelerated,
    this.onShow,
    this.onDismiss,
    this.testID,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'visible': visible,
      ...additionalProps,
    };

    if (onRequestClose != null) map['onRequestClose'] = onRequestClose;
    if (transparent != null) map['transparent'] = transparent;

    if (presentationStyle != null) {
      switch (presentationStyle) {
        case ModalPresentationStyle.fullScreen:
          map['presentationStyle'] = 'fullScreen';
          break;
        case ModalPresentationStyle.pageSheet:
          map['presentationStyle'] = 'pageSheet';
          break;
        case ModalPresentationStyle.formSheet:
          map['presentationStyle'] = 'formSheet';
          break;
        case ModalPresentationStyle.overFullScreen:
          map['presentationStyle'] = 'overFullScreen';
          break;
        default:
          map['presentationStyle'] = 'fullScreen';
      }
    }

    if (animationType != null) {
      switch (animationType) {
        case ModalAnimationType.none:
          map['animationType'] = 'none';
          break;
        case ModalAnimationType.slide:
          map['animationType'] = 'slide';
          break;
        case ModalAnimationType.fade:
          map['animationType'] = 'fade';
          break;
        default:
          map['animationType'] = 'none';
      }
    }

    if (hardwareAccelerated != null) {
      map['hardwareAccelerated'] = hardwareAccelerated;
    }
    if (onShow != null) map['onShow'] = onShow;
    if (onDismiss != null) map['onDismiss'] = onDismiss;
    if (testID != null) map['testID'] = testID;
    if (style != null) map['style'] = style!.toMap();

    // Add platform-specific props and defaults
    if (kIsWeb) {
      map['_platform'] = 'web';
      // Web-specific modal properties
      if (!map.containsKey('dismissOnOverlayClick') &&
          !additionalProps.containsKey('dismissOnOverlayClick')) {
        map['dismissOnOverlayClick'] = true; // Standard web behavior
      }

      // Default animation for web
      if (animationType == null && !map.containsKey('animationType')) {
        map['animationType'] = 'fade'; // Fade is more common on web
      }
    } else if (Platform.isIOS) {
      map['_platform'] = 'ios';
      // iOS-specific modal properties
      if (presentationStyle == null && !map.containsKey('presentationStyle')) {
        map['presentationStyle'] = 'pageSheet'; // Default iOS style
      }

      if (!map.containsKey('statusBarTranslucent')) {
        map['statusBarTranslucent'] =
            true; // iOS modals often have translucent status bar
      }
    } else if (Platform.isAndroid) {
      map['_platform'] = 'android';
      // Android-specific modal properties
      if (!map.containsKey('statusBarTranslucent')) {
        map['statusBarTranslucent'] = false; // Default Android behavior
      }

      if (!map.containsKey('hardwareAccelerated') &&
          !additionalProps.containsKey('hardwareAccelerated')) {
        map['hardwareAccelerated'] =
            true; // Hardware acceleration for smoother animation
      }

      // Default elevation for Android Material Design
      if (style?.elevation == null && !map.containsKey('elevation')) {
        map['elevation'] =
            24.0; // Standard Material Design elevation for dialogs
      }
    }

    return map;
  }

  ModalProps copyWith({
    bool? visible,
    Function()? onRequestClose,
    bool? transparent,
    ModalPresentationStyle? presentationStyle,
    ModalAnimationType? animationType,
    bool? hardwareAccelerated,
    Function()? onShow,
    Function()? onDismiss,
    String? testID,
    ModalStyle? style,
    Map<String, dynamic>? additionalProps,
  }) {
    return ModalProps(
      visible: visible ?? this.visible,
      onRequestClose: onRequestClose ?? this.onRequestClose,
      transparent: transparent ?? this.transparent,
      presentationStyle: presentationStyle ?? this.presentationStyle,
      animationType: animationType ?? this.animationType,
      hardwareAccelerated: hardwareAccelerated ?? this.hardwareAccelerated,
      onShow: onShow ?? this.onShow,
      onDismiss: onDismiss ?? this.onDismiss,
      testID: testID ?? this.testID,
      style: style ?? this.style,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// Modal component
class Modal extends Control {
  final ModalProps props;
  final List<Control> children;

  Modal({
    required bool visible,
    Function()? onRequestClose,
    bool? transparent,
    ModalPresentationStyle? presentationStyle,
    ModalAnimationType? animationType = ModalAnimationType.slide,
    bool? hardwareAccelerated,
    Function()? onShow,
    Function()? onDismiss,
    String? testID,
    ModalStyle? style,
    Map<String, dynamic>? styleMap,
    required this.children,
  }) : props = ModalProps(
          visible: visible,
          onRequestClose: onRequestClose,
          transparent: transparent,
          presentationStyle: presentationStyle,
          animationType: animationType,
          hardwareAccelerated: hardwareAccelerated,
          onShow: onShow,
          onDismiss: onDismiss,
          testID: testID,
          style:
              style ?? (styleMap != null ? ModalStyle.fromMap(styleMap) : null),
        );

  Modal.custom({
    required this.props,
    required this.children,
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'Modal',
      props.toMap(),
      buildChildren(children),
    );
  }
}
