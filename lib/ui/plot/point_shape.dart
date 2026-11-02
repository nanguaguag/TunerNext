import 'package:flutter/material.dart';
import '../../domain/models/tuning_state.dart';

/// Renders the three-state pitch indicator on a canvas.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.plot.PointShape`.
class PointShapePainter {
  PointShapePainter._();

  /// Draws a circle centered at [offset].
  static void drawCircle(
    Canvas canvas,
    Offset offset, {
    required double size,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(offset, size / 2.0, paint);
  }

  /// Draws a circle with an upward-pointing triangle above it (indicating pitch is Too Low -> tune up).
  static void drawCircleWithUpwardTriangle(
    Canvas canvas,
    Offset offset, {
    required double size,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final r = size / 2.0;
    canvas.drawCircle(offset, r, paint);

    final rTri = 1.3 * r;
    final dy = -1.5 * r;

    final path = Path()
      ..moveTo(offset.dx - rTri, offset.dy + dy)
      ..lineTo(offset.dx + rTri, offset.dy + dy)
      ..lineTo(offset.dx, offset.dy + dy - rTri * 1.2)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Draws a circle with a downward-pointing triangle below it (indicating pitch is Too High -> tune down).
  static void drawCircleWithDownwardTriangle(
    Canvas canvas,
    Offset offset, {
    required double size,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final r = size / 2.0;
    canvas.drawCircle(offset, r, paint);

    final rTri = 1.3 * r;
    final dy = 1.5 * r;

    final path = Path()
      ..moveTo(offset.dx - rTri, offset.dy + dy)
      ..lineTo(offset.dx + rTri, offset.dy + dy)
      ..lineTo(offset.dx, offset.dy + dy + rTri * 1.2)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Draws the indicator point corresponding to the current [TuningState].
  static void drawTuningPoint(
    Canvas canvas,
    Offset offset, {
    required TuningState tuningState,
    required double size,
    required Color inTuneColor,
    required Color outOfTuneColor,
    required Color inactiveColor,
  }) {
    switch (tuningState) {
      case TuningState.inTune:
        // Draw green in-tune glow + circle
        final glowPaint = Paint()
          ..color = inTuneColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        canvas.drawCircle(offset, size * 0.8, glowPaint);
        drawCircle(canvas, offset, size: size, color: inTuneColor);
        break;
      case TuningState.tooLow:
        drawCircleWithUpwardTriangle(
          canvas,
          offset,
          size: size,
          color: outOfTuneColor,
        );
        break;
      case TuningState.tooHigh:
        drawCircleWithDownwardTriangle(
          canvas,
          offset,
          size: size,
          color: outOfTuneColor,
        );
        break;
      case TuningState.unknown:
        drawCircle(canvas, offset, size: size * 0.7, color: inactiveColor);
        break;
    }
  }
}
