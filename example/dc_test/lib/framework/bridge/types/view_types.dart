import 'package:flutter/material.dart';

class ViewTransform {
  final double? scale;
  final double? rotation;
  final Offset? translation;

  const ViewTransform({
    this.scale,
    this.rotation,
    this.translation,
  });

  Map<String, dynamic> toMap() => {
        if (scale != null) 'scale': scale,
        if (rotation != null) 'rotation': rotation,
        if (translation != null)
          'translation': {'x': translation!.dx, 'y': translation!.dy},
      };
}
