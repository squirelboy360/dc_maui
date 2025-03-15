import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';

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

    return map;
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
