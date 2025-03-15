import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';

/// Easing functions for animations
enum Easing {
  /// Linear easing
  linear,

  /// Ease-in (slow start, fast end)
  easeIn,

  /// Ease-out (fast start, slow end)
  easeOut,

  /// Ease-in-out (slow start, fast middle, slow end)
  easeInOut,

  /// Elastic easing
  elastic,

  /// Bounce easing
  bounce,

  /// Back easing (slight overshoot)
  back,
}

/// Animation value that can be passed to a component
class AnimatedValue {
  final double _value;
  final String _animationId;

  AnimatedValue(this._value, this._animationId);

  Map<String, dynamic> toJSON() {
    return {
      'animatedValue': _value,
      'animationId': _animationId,
    };
  }

  double get value => _value;
}

/// Animation configuration
class AnimationConfig {
  final double? duration;
  final double? delay;
  final Easing? easing;

  AnimationConfig({
    this.duration = 500, // 500ms default
    this.delay = 0,
    this.easing = Easing.easeInOut,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (duration != null) map['duration'] = duration;
    if (delay != null) map['delay'] = delay;

    if (easing != null) {
      switch (easing) {
        case Easing.linear:
          map['easing'] = 'linear';
          break;
        case Easing.easeIn:
          map['easing'] = 'easeIn';
          break;
        case Easing.easeOut:
          map['easing'] = 'easeOut';
          break;
        case Easing.easeInOut:
          map['easing'] = 'easeInOut';
          break;
        case Easing.elastic:
          map['easing'] = 'elastic';
          break;
        case Easing.bounce:
          map['easing'] = 'bounce';
          break;
        case Easing.back:
          map['easing'] = 'back';
          break;
        default:
          map['easing'] = 'easeInOut';
      }
    }

    return map;
  }
}

/// Main Animated API class
class Animated {
  // Counter for generating unique animation IDs
  static int _nextAnimationId = 0;

  /// Create a timing animation
  static AnimatedValue timing(AnimatedValue value, AnimationConfig config) {
    final animationId = 'anim_${_nextAnimationId++}';

    // In a real implementation, we'd register the animation with the native side
    // For now, this is just a placeholder
    return AnimatedValue(value.value, animationId);
  }

  /// Create a spring animation
  static AnimatedValue spring(
    AnimatedValue value, {
    double damping = 10.0,
    double stiffness = 100.0,
    double mass = 1.0,
    bool overshootClamping = false,
  }) {
    final animationId = 'anim_${_nextAnimationId++}';

    // In a real implementation, we'd register the animation with the native side
    return AnimatedValue(value.value, animationId);
  }

  /// Decay animation (gradually slows down)
  static AnimatedValue decay(
    AnimatedValue value, {
    double velocity = 0.0,
    double deceleration = 0.997,
  }) {
    final animationId = 'anim_${_nextAnimationId++}';

    // In a real implementation, we'd register the animation with the native side
    return AnimatedValue(value.value, animationId);
  }

  /// Create an animated view component
  static Control createAnimatedView(
    Control child,
    Map<String, dynamic> animatedStyles,
  ) {
    // This is a placeholder for the actual implementation
    // In a real implementation, we'd pass the animated properties to the native side
    return _AnimatedControl(child, animatedStyles);
  }
}

/// Internal animated control wrapper
class _AnimatedControl extends Control {
  final Control child;
  final Map<String, dynamic> animatedStyles;

  _AnimatedControl(this.child, this.animatedStyles);

  @override
  VNode build() {
    return ElementFactory.createElement(
      'AnimatedView',
      {
        'animatedStyles': animatedStyles,
      },
      [child.build()],
    );
  }
}
