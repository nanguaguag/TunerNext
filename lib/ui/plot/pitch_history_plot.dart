// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../domain/musical_scale/musical_scale.dart';
import 'pitch_history_data.dart';

/// High-performance Canvas widget for rendering real-time logarithmic
/// pitch history curves, cent tolerance bands, and dynamic tuning indicators.
class PitchHistoryPlot extends StatelessWidget {
  const PitchHistoryPlot({
    super.key,
    required this.historyData,
    required this.scale,
    required this.targetFrequency,
    required this.targetNote,
    required this.tuningState,
    this.toleranceInCents = 5.0,
    this.visibleSemitoneRange = 1.5,
  });

  final PitchHistoryData historyData;
  final MusicalScale scale;
  final double targetFrequency;
  final MusicalNote targetNote;
  final TuningState tuningState;
  final double toleranceInCents;
  final double visibleSemitoneRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomPaint(
      painter: _PitchHistoryPainter(
        historyData: historyData,
        scale: scale,
        targetFrequency: targetFrequency,
        targetNote: targetNote,
        tuningState: tuningState,
        toleranceInCents: toleranceInCents,
        visibleSemitoneRange: visibleSemitoneRange,
        theme: theme,
        tunerColors: context.tunerColors,
        isDark: isDark,
      ),
      size: Size.infinite,
    );
  }
}

class _PitchHistoryPainter extends CustomPainter {
  _PitchHistoryPainter({
    required this.historyData,
    required this.scale,
    required this.targetFrequency,
    required this.targetNote,
    required this.tuningState,
    required this.toleranceInCents,
    required this.visibleSemitoneRange,
    required this.theme,
    required this.tunerColors,
    required this.isDark,
  });

  final PitchHistoryData historyData;
  final MusicalScale scale;
  final double targetFrequency;
  final MusicalNote targetNote;
  final TuningState tuningState;
  final double toleranceInCents;
  final double visibleSemitoneRange;
  final ThemeData theme;
  final TunerColors tunerColors;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final targetNoteIndex = scale.getNoteIndex(targetFrequency);
    final yMin = targetNoteIndex - visibleSemitoneRange;
    final yMax = targetNoteIndex + visibleSemitoneRange;
    final ySpan = yMax - yMin;

    double noteIndexToY(double index) {
      final norm = (index - yMin) / ySpan;
      return size.height * (1.0 - norm);
    }

    // 1. Draw tolerance zone background band
    final toleranceSemitones = toleranceInCents / 100.0;
    final yTolTop = noteIndexToY(targetNoteIndex + toleranceSemitones);
    final yTolBottom = noteIndexToY(targetNoteIndex - toleranceSemitones);
    final targetY = noteIndexToY(targetNoteIndex);

    final toleranceColor = tunerColors.inTune.withValues(alpha: 0.12);

    final bandPaint = Paint()
      ..color = toleranceColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(0, yTolTop, size.width, yTolBottom),
      bandPaint,
    );

    // 2. Draw tolerance boundary lines (dashed style)
    final tolLinePaint = Paint()
      ..color = tunerColors.inTune.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedHorizontalLine(canvas, 0, size.width, yTolTop, tolLinePaint);
    _drawDashedHorizontalLine(canvas, 0, size.width, yTolBottom, tolLinePaint);

    // 3. Draw neighboring semitone grid lines & note labels
    final gridLinePaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    final lowerSemiY = noteIndexToY(targetNoteIndex - 1.0);
    final upperSemiY = noteIndexToY(targetNoteIndex + 1.0);

    canvas.drawLine(
      Offset(0, lowerSemiY),
      Offset(size.width, lowerSemiY),
      gridLinePaint,
    );
    canvas.drawLine(
      Offset(0, upperSemiY),
      Offset(size.width, upperSemiY),
      gridLinePaint,
    );

    _drawNoteLabel(canvas, size, targetNoteIndex - 1.0, lowerSemiY);
    _drawNoteLabel(canvas, size, targetNoteIndex + 1.0, upperSemiY);

    // 4. Draw target note center baseline
    final targetLineColor = switch (tuningState) {
      TuningState.inTune => tunerColors.inTune,
      TuningState.tooLow ||
      TuningState.tooHigh => tunerColors.outOfTune.withValues(alpha: 0.7),
      TuningState.unknown => theme.colorScheme.outline.withValues(alpha: 0.5),
    };

    final centerLinePaint = Paint()
      ..color = targetLineColor
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(0, targetY),
      Offset(size.width, targetY),
      centerLinePaint,
    );
    _drawNoteLabel(canvas, size, targetNoteIndex, targetY, isTarget: true);

    // 5. Draw Pitch History Trace
    final points = historyData.toList();
    if (points.isNotEmpty) {
      final tracePaint = Paint()
        ..color = isDark ? Colors.white70 : Colors.black87
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      var pathStarted = false;
      final xStep = size.width / math.max(1, historyData.capacity - 1);
      final startIndex = historyData.capacity - points.length;

      Offset? latestValidOffset;

      for (var i = 0; i < points.length; i++) {
        final pt = points[i];
        if (pt.isSilence || pt.frequency <= 0.0) {
          pathStarted = false;
          continue;
        }

        final x = (startIndex + i) * xStep;
        final noteIdx = scale.getNoteIndex(pt.frequency);
        final y = noteIndexToY(noteIdx).clamp(0.0, size.height);
        final currentOffset = Offset(x, y);
        latestValidOffset = currentOffset;

        if (!pathStarted) {
          path.moveTo(x, y);
          pathStarted = true;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, tracePaint);

      // 6. Draw dynamic tuning indicator dot
      if (latestValidOffset != null && tuningState != TuningState.unknown) {
        final dotColor = switch (tuningState) {
          TuningState.inTune => tunerColors.inTune,
          TuningState.tooLow || TuningState.tooHigh => tunerColors.outOfTune,
          TuningState.unknown => theme.colorScheme.outline,
        };

        // Outer glow
        final glowPaint = Paint()
          ..color = dotColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
        canvas.drawCircle(latestValidOffset, 12.0, glowPaint);

        // Core dot
        final dotPaint = Paint()..color = dotColor;
        canvas.drawCircle(latestValidOffset, 7.0, dotPaint);

        final dotBorderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(latestValidOffset, 7.0, dotBorderPaint);
      }
    }

    // 7. Draw directional indicator arrow (UP / DOWN) on left side
    _drawDirectionArrows(canvas, size, targetY);
  }

  void _drawDashedHorizontalLine(
    Canvas canvas,
    double xStart,
    double xEnd,
    double y,
    Paint paint, {
    double dashWidth = 5.0,
    double dashSpace = 4.0,
  }) {
    var x = xStart;
    while (x < xEnd) {
      final x2 = math.min(x + dashWidth, xEnd);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  void _drawNoteLabel(
    Canvas canvas,
    Size size,
    double noteIndex,
    double y, {
    bool isTarget = false,
  }) {
    final note = scale.getNote(noteIndex.round());
    final text = note.pitchClassName;

    final textStyle = TextStyle(
      color: isTarget
          ? (isDark ? Colors.white : Colors.black)
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: isTarget ? 13.0 : 11.0,
      fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final xPos = size.width - textPainter.width - 8.0;
    final yPos = y - textPainter.height / 2.0;

    if (isTarget) {
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          xPos - 4.0,
          yPos - 2.0,
          textPainter.width + 8.0,
          textPainter.height + 4.0,
        ),
        const Radius.circular(4.0),
      );
      final bgPaint = Paint()
        ..color = theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.85,
        );
      canvas.drawRRect(bgRect, bgPaint);
    }

    textPainter.paint(canvas, Offset(xPos, yPos));
  }

  void _drawDirectionArrows(Canvas canvas, Size size, double centerY) {
    if (tuningState == TuningState.unknown) return;

    final arrowColor = switch (tuningState) {
      TuningState.inTune => tunerColors.inTune,
      TuningState.tooLow || TuningState.tooHigh => tunerColors.outOfTune,
      TuningState.unknown => Colors.transparent,
    };

    final paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    const arrowX = 20.0;
    const arrowSize = 10.0;

    if (tuningState == TuningState.tooLow) {
      // Need to tune UP: arrow pointing upwards
      final path = Path()
        ..moveTo(arrowX, centerY + 24.0)
        ..lineTo(arrowX - arrowSize, centerY + 24.0 + arrowSize * 1.3)
        ..lineTo(arrowX + arrowSize, centerY + 24.0 + arrowSize * 1.3)
        ..close();
      canvas.drawPath(path, paint);
    } else if (tuningState == TuningState.tooHigh) {
      // Need to tune DOWN: arrow pointing downwards
      final path = Path()
        ..moveTo(arrowX, centerY - 24.0)
        ..lineTo(arrowX - arrowSize, centerY - 24.0 - arrowSize * 1.3)
        ..lineTo(arrowX + arrowSize, centerY - 24.0 - arrowSize * 1.3)
        ..close();
      canvas.drawPath(path, paint);
    } else if (tuningState == TuningState.inTune) {
      // In tune diamond indicator
      final path = Path()
        ..moveTo(arrowX, centerY - 8.0)
        ..lineTo(arrowX + 8.0, centerY)
        ..lineTo(arrowX, centerY + 8.0)
        ..lineTo(arrowX - 8.0, centerY)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchHistoryPainter oldDelegate) {
    return oldDelegate.historyData != historyData ||
        oldDelegate.targetFrequency != targetFrequency ||
        oldDelegate.tuningState != tuningState ||
        oldDelegate.toleranceInCents != toleranceInCents ||
        oldDelegate.isDark != isDark;
  }
}
