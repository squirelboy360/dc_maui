import 'package:dc_test/templating/framework/controls/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';

/// DCModal presentation styles
enum DCModalPresentationStyle {
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
enum DCModalAnimationType {
  /// No animation
  none,

  /// Slide up from bottom
  slide,

  /// Fade in
  fade,
}

/// Props for DCModal component
class DCModalProps implements ControlProps {
  final bool visible;
  final Function()? onRequestClose;
  final bool? transparent;
  final DCModalPresentationStyle? presentationStyle;
  final DCModalAnimationType? animationType;
  final bool? hardwareAccelerated;
  final Function()? onShow;
  final Function()? onDismiss;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCModalProps({
    required this.visible,
    this.onRequestClose,
    this.transparent,
    this.presentationStyle,
    this.animationType,
    this.hardwareAccelerated,
    this.onShow,
    this.onDismiss,
    this.testID,
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
        case DCModalPresentationStyle.fullScreen:
          map['presentationStyle'] = 'fullScreen';
          break;
        case DCModalPresentationStyle.pageSheet:
          map['presentationStyle'] = 'pageSheet';
          break;
        case DCModalPresentationStyle.formSheet:
          map['presentationStyle'] = 'formSheet';
          break;
        case DCModalPresentationStyle.overFullScreen:
          map['presentationStyle'] = 'overFullScreen';
          break;
        default:
          map['presentationStyle'] = 'fullScreen';
      }
    }

    if (animationType != null) {
      switch (animationType) {
        case DCModalAnimationType.none:
          map['animationType'] = 'none';
          break;
        case DCModalAnimationType.slide:
          map['animationType'] = 'slide';
          break;
        case DCModalAnimationType.fade:
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

    return map;
  }
}

/// DCModal component
class DCModal extends Control {
  final DCModalProps props;
  final List<Control> children;

  DCModal({
    required bool visible,
    Function()? onRequestClose,
    bool? transparent,
    DCModalPresentationStyle? presentationStyle,
    DCModalAnimationType? animationType = DCModalAnimationType.slide,
    bool? hardwareAccelerated,
    Function()? onShow,
    Function()? onDismiss,
    String? testID,
    required this.children,
  }) : props = DCModalProps(
          visible: visible,
          onRequestClose: onRequestClose,
          transparent: transparent,
          presentationStyle: presentationStyle,
          animationType: animationType,
          hardwareAccelerated: hardwareAccelerated,
          onShow: onShow,
          onDismiss: onDismiss,
          testID: testID,
        );

  DCModal.custom({
    required this.props,
    required this.children,
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCModal',
      props.toMap(),
      buildChildren(children),
    );
  }
}
