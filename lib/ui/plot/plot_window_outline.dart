import 'package:flutter/material.dart';

/// Defines the border line width, corner radius, and outline color for plot windows and cards.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.plot.PlotWindowOutline`.
class PlotWindowOutline {
  const PlotWindowOutline({
    this.lineWidth = 1.0,
    this.cornerRadius = 8.0,
    this.color,
  });

  /// Border line width in logical pixels (default 1.0 dp).
  final double lineWidth;

  /// Corner radius in logical pixels (default 8.0 dp).
  final double cornerRadius;

  /// Outline border color. If null, fallback to the theme's outline/onSurface color.
  final Color? color;

  PlotWindowOutline copyWith({
    double? lineWidth,
    double? cornerRadius,
    Color? color,
  }) {
    return PlotWindowOutline(
      lineWidth: lineWidth ?? this.lineWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlotWindowOutline &&
          runtimeType == other.runtimeType &&
          lineWidth == other.lineWidth &&
          cornerRadius == other.cornerRadius &&
          color == other.color;

  @override
  int get hashCode => Object.hash(lineWidth, cornerRadius, color);

  @override
  String toString() =>
      'PlotWindowOutline(lineWidth: $lineWidth, cornerRadius: $cornerRadius, color: $color)';
}
