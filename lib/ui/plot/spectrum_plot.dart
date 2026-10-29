// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';

/// Real-time FFT power spectrum magnitude oscilloscope plot.
class SpectrumPlot extends StatelessWidget {
  const SpectrumPlot({
    super.key,
    required this.spectrum,
    this.sampleRate = 44100,
    this.maxFrequency = 4000.0,
    this.currentFrequency,
    this.targetFrequency,
    this.title = 'Frequency Spectrum (FFT)',
  });

  final Float32List? spectrum;
  final int sampleRate;
  final double maxFrequency;
  final double? currentFrequency;
  final double? targetFrequency;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = context.tunerColors;

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
                if (currentFrequency != null && currentFrequency! > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${currentFrequency!.toStringAsFixed(1)} Hz',
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
              painter: _SpectrumPainter(
                spectrum: spectrum,
                sampleRate: sampleRate,
                maxFrequency: maxFrequency,
                currentFrequency: currentFrequency,
                targetFrequency: targetFrequency,
                lineColor: theme.colorScheme.primary,
                gridColor: theme.colorScheme.outlineVariant.withValues(
                  alpha: 0.5,
                ),
                textColor: theme.colorScheme.onSurfaceVariant,
                currentFreqColor: tunerColors.inTune,
                targetFreqColor: theme.colorScheme.tertiary,
                harmonicColor: theme.colorScheme.outline.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.spectrum,
    required this.sampleRate,
    required this.maxFrequency,
    required this.currentFrequency,
    required this.targetFrequency,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.currentFreqColor,
    required this.targetFreqColor,
    required this.harmonicColor,
  });

  final Float32List? spectrum;
  final int sampleRate;
  final double maxFrequency;
  final double? currentFrequency;
  final double? targetFrequency;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final Color currentFreqColor;
  final Color targetFreqColor;
  final Color harmonicColor;

  static const double bottomPadding = 20.0;
  static const double leftPadding = 8.0;
  static const double rightPadding = 8.0;
  static const double topPadding = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= bottomPadding) return;

    final plotWidth = size.width - leftPadding - rightPadding;
    final plotHeight = size.height - topPadding - bottomPadding;

    double freqToX(double f) =>
        leftPadding + (f / maxFrequency).clamp(0.0, 1.0) * plotWidth;
    double valToY(double val) =>
        topPadding + (1.0 - val.clamp(0.0, 1.0)) * plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw baseline
    final baselineY = topPadding + plotHeight;
    canvas.drawLine(
      Offset(leftPadding, baselineY),
      Offset(leftPadding + plotWidth, baselineY),
      gridPaint,
    );

    // Draw frequency grid ticks at 0, 500, 1000, 2000, 3000, 4000
    final ticks = [0.0, 500.0, 1000.0, 2000.0, 3000.0, 4000.0];
    for (final tick in ticks) {
      if (tick > maxFrequency) continue;
      final x = freqToX(tick);
      canvas.drawLine(Offset(x, topPadding), Offset(x, baselineY), gridPaint);

      final label = tick >= 1000
          ? '${(tick / 1000).toInt()}k'
          : '${tick.toInt()}';
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

    // Draw harmonics for detected base frequency
    if (currentFrequency != null && currentFrequency! > 0) {
      final f0 = currentFrequency!;
      final harmonicPaint = Paint()
        ..color = harmonicColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (var h = 2; h <= 8; h++) {
        final fh = f0 * h;
        if (fh > maxFrequency) break;
        final hX = freqToX(fh);
        _drawDashedLine(
          canvas,
          Offset(hX, topPadding),
          Offset(hX, baselineY),
          harmonicPaint,
        );
      }

      // Draw current frequency vertical line
      final f0X = freqToX(f0);
      final f0Paint = Paint()
        ..color = currentFreqColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(f0X, topPadding), Offset(f0X, baselineY), f0Paint);
    }

    // Draw target frequency vertical line
    if (targetFrequency != null && targetFrequency! > 0) {
      final targetX = freqToX(targetFrequency!);
      final targetPaint = Paint()
        ..color = targetFreqColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      _drawDashedLine(
        canvas,
        Offset(targetX, topPadding),
        Offset(targetX, baselineY),
        targetPaint,
      );
    }

    // Draw spectrum waveform
    if (spectrum != null && spectrum!.isNotEmpty) {
      final path = Path();
      final n = spectrum!.length;
      final df = (sampleRate / 2.0) / (n - 1);
      final maxIndex = math.min(n, (maxFrequency / df).ceil() + 1);

      var started = false;
      for (var i = 0; i < maxIndex; i++) {
        final f = i * df;
        if (f > maxFrequency) break;
        final x = freqToX(f);
        final y = valToY(spectrum![i].toDouble());

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

      // Area gradient under curve
      final fillPath = Path.from(path)
        ..lineTo(
          freqToX(math.min(maxFrequency, (maxIndex - 1) * df)),
          baselineY,
        )
        ..lineTo(freqToX(0.0), baselineY)
        ..close();

      final fillPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withValues(alpha: 0.25),
                lineColor.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight),
            )
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
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
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) {
    return oldDelegate.spectrum != spectrum ||
        oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.targetFrequency != targetFrequency ||
        oldDelegate.maxFrequency != maxFrequency;
  }
}
