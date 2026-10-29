// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';

/// Real-time normalized autocorrelation oscilloscope plot.
class AutocorrelationPlot extends StatelessWidget {
  const AutocorrelationPlot({
    super.key,
    required this.correlation,
    this.zeroPositionNormalized = 0.5,
    this.sampleRate = 44100,
    this.maxLagMs = 25.0,
    this.currentFrequency,
    this.targetFrequency,
    this.title = 'Autocorrelation R_xx(τ)',
  });

  final Float32List? correlation;
  final double zeroPositionNormalized;
  final int sampleRate;
  final double maxLagMs;
  final double? currentFrequency;
  final double? targetFrequency;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = context.tunerColors;

    final currentLagMs = (currentFrequency != null && currentFrequency! > 0)
        ? 1000.0 / currentFrequency!
        : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (currentLagMs != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'τ = ${currentLagMs.toStringAsFixed(2)} ms',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tunerColors.inTune,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _AutocorrelationPainter(
                correlation: correlation,
                zeroPositionNormalized: zeroPositionNormalized,
                sampleRate: sampleRate,
                maxLagMs: maxLagMs,
                currentFrequency: currentFrequency,
                targetFrequency: targetFrequency,
                lineColor: theme.colorScheme.secondary,
                gridColor: theme.colorScheme.outlineVariant.withValues(
                  alpha: 0.5,
                ),
                zeroLineColor: theme.colorScheme.outline.withValues(alpha: 0.4),
                textColor: theme.colorScheme.onSurfaceVariant,
                currentLagColor: tunerColors.inTune,
                targetLagColor: theme.colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutocorrelationPainter extends CustomPainter {
  _AutocorrelationPainter({
    required this.correlation,
    required this.zeroPositionNormalized,
    required this.sampleRate,
    required this.maxLagMs,
    required this.currentFrequency,
    required this.targetFrequency,
    required this.lineColor,
    required this.gridColor,
    required this.zeroLineColor,
    required this.textColor,
    required this.currentLagColor,
    required this.targetLagColor,
  });

  final Float32List? correlation;
  final double zeroPositionNormalized;
  final int sampleRate;
  final double maxLagMs;
  final double? currentFrequency;
  final double? targetFrequency;
  final Color lineColor;
  final Color gridColor;
  final Color zeroLineColor;
  final Color textColor;
  final Color currentLagColor;
  final Color targetLagColor;

  static const double bottomPadding = 20.0;
  static const double leftPadding = 8.0;
  static const double rightPadding = 8.0;
  static const double topPadding = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= bottomPadding) return;

    final plotWidth = size.width - leftPadding - rightPadding;
    final plotHeight = size.height - topPadding - bottomPadding;

    double lagToX(double lagMs) =>
        leftPadding + (lagMs / maxLagMs).clamp(0.0, 1.0) * plotWidth;
    double valToY(double val) =>
        topPadding + (1.0 - val.clamp(0.0, 1.0)) * plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final baselineY = topPadding + plotHeight;

    // Draw horizontal zero line where R_xx = 0
    final zeroY = valToY(zeroPositionNormalized);
    final zeroPaint = Paint()
      ..color = zeroLineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(leftPadding, zeroY),
      Offset(leftPadding + plotWidth, zeroY),
      zeroPaint,
    );

    // Draw time lag ticks at 0, 5, 10, 15, 20, 25 ms
    final ticks = [0.0, 5.0, 10.0, 15.0, 20.0, 25.0];
    for (final tick in ticks) {
      if (tick > maxLagMs) continue;
      final x = lagToX(tick);
      canvas.drawLine(Offset(x, topPadding), Offset(x, baselineY), gridPaint);

      final label = '${tick.toInt()}ms';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: textColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width * 0.5, baselineY + 3),
      );
    }

    // Draw target period lag line
    if (targetFrequency != null && targetFrequency! > 0) {
      final targetLagMs = 1000.0 / targetFrequency!;
      if (targetLagMs <= maxLagMs) {
        final targetX = lagToX(targetLagMs);
        final targetPaint = Paint()
          ..color = targetLagColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        _drawDashedLine(
          canvas,
          Offset(targetX, topPadding),
          Offset(targetX, baselineY),
          targetPaint,
        );
      }
    }

    // Draw detected pitch period lag line
    if (currentFrequency != null && currentFrequency! > 0) {
      final lagMs = 1000.0 / currentFrequency!;
      if (lagMs <= maxLagMs) {
        final x = lagToX(lagMs);
        final lagPaint = Paint()
          ..color = currentLagColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x, topPadding), Offset(x, baselineY), lagPaint);
      }
    }

    // Draw correlation waveform
    if (correlation != null && correlation!.isNotEmpty) {
      final path = Path();
      final n = correlation!.length;
      final dtMs = 1000.0 / sampleRate;
      final maxSamples = math.min(n, (maxLagMs / dtMs).ceil() + 1);

      var started = false;
      for (var i = 0; i < maxSamples; i++) {
        final lag = i * dtMs;
        if (lag > maxLagMs) break;
        final x = lagToX(lag);
        final y = valToY(correlation![i].toDouble());

        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }

      final curvePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, curvePaint);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashLength = 4.0,
    double dashSpace = 4.0,
  }) {
    final dy = p2.dy - p1.dy;
    final count = (dy / (dashLength + dashSpace)).abs().ceil();
    for (var i = 0; i < count; i++) {
      final startY = p1.dy + i * (dashLength + dashSpace);
      final endY = math.min(p2.dy, startY + dashLength);
      canvas.drawLine(Offset(p1.dx, startY), Offset(p1.dx, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AutocorrelationPainter oldDelegate) {
    return oldDelegate.correlation != correlation ||
        oldDelegate.zeroPositionNormalized != zeroPositionNormalized ||
        oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.targetFrequency != targetFrequency ||
        oldDelegate.maxLagMs != maxLagMs;
  }
}
