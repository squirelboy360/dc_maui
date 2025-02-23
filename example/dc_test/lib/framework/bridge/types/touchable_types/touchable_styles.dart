import 'dart:io';
import 'package:flutter/material.dart';

class TouchableStyle {
  final double? activeOpacity;
  final bool? disabled;
  final int? underlayColor;
  final double? pressedScale;
  final Duration? pressAnimationDuration;
  final bool? hasHapticFeedback;

  const TouchableStyle({
    this.activeOpacity,
    this.disabled,
    this.underlayColor,
    this.pressedScale,
    this.pressAnimationDuration,
    this.hasHapticFeedback,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) return {};

    return {
      if (activeOpacity != null) 'activeOpacity': activeOpacity,
      if (disabled != null) 'disabled': disabled,
      if (underlayColor != null) 'underlayColor': underlayColor,
      if (pressedScale != null) 'pressedScale': pressedScale,
      if (pressAnimationDuration != null) 'pressAnimationDuration': pressAnimationDuration?.inMilliseconds,
      if (hasHapticFeedback != null) 'hasHapticFeedback': hasHapticFeedback,
    };
  }
}
