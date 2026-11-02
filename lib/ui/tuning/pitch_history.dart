import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../plot/plot_window_outline.dart';
import '../plot/point_shape.dart';
import 'pitch_history_state.dart';

/// Interactive acoustic pitch history graph.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.tuning.PitchHistory`.
/// Renders:
/// - Equal temperament / musical scale semitone horizontal grid lines and note labels.
/// - Active target note horizontal indicator with pill badge.
/// - In-tune tolerance bounds (e.g. ±5 cents) with boundary lines and cent labels.
/// - Historical pitch polyline, breaking cleanly on silence/null frames without flying lines.
/// - Tri-state current pitch indicator point (green glowing circle, upward triangle, downward triangle).
/// - Dynamic cent deviation text badge when out of tune.
/// - Stylized plot window outline border.
class PitchHistory extends StatelessWidget {
  const PitchHistory({
    super.key,
    required this.state,
    required this.targetNote,
    this.targetFrequency,
    this.tuningState = TuningState.unknown,
    this.toleranceInCents = 5,
    this.plotWindowPadding = const EdgeInsets.only(
      left: 4,
      top: 0,
      right: 40,
      bottom: 0,
    ),
    this.plotWindowOutline = const PlotWindowOutline(),
    this.lineWidth = 2.0,
    this.lineWidthInactive = 1.0,
    this.lineColor,
    this.lineColorInactive,
    this.pointSize = 10.0,
    this.pointSizeInactive = 7.0,
    this.colorInTune,
    this.colorOutOfTune,
    this.colorInactive,
    this.colorOnInTune,
    this.colorOnOutOfTune,
    this.colorOnInactive,
    this.targetNoteLineWidth = 2.0,
    this.toleranceLineColor,
    this.toleranceLabelStyle,
    this.toleranceLabelColor,
    this.tickLineWidth = 1.0,
    this.tickLineColor,
    this.tickLabelStyle,
    this.tickLabelColor,
    this.centDeviationStyle,
    this.centDeviationColor,
    this.preferSharp = true,
  });

  final PitchHistoryState state;
  final MusicalNote targetNote;
  final double? targetFrequency;
  final TuningState tuningState;
  final int toleranceInCents;
  final EdgeInsets plotWindowPadding;
  final PlotWindowOutline plotWindowOutline;

  final double lineWidth;
  final double lineWidthInactive;
  final Color? lineColor;
  final Color? lineColorInactive;

  final double pointSize;
  final double pointSizeInactive;
  final Color? colorInTune;
  final Color? colorOutOfTune;
  final Color? colorInactive;
  final Color? colorOnInTune;
  final Color? colorOnOutOfTune;
  final Color? colorOnInactive;

  final double targetNoteLineWidth;
  final Color? toleranceLineColor;
  final TextStyle? toleranceLabelStyle;
  final Color? toleranceLabelColor;

  final double tickLineWidth;
  final Color? tickLineColor;
  final TextStyle? tickLabelStyle;
  final Color? tickLabelColor;

  final TextStyle? centDeviationStyle;
  final Color? centDeviationColor;
  final bool preferSharp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = TunerColors.of(context);

    final resolvedTargetFreq =
        targetFrequency ??
        (440.0 * math.pow(2.0, (targetNote.midiNumber - 69) / 12.0));

    final resolvedInTuneColor = colorInTune ?? tunerColors.positive;
    final resolvedOutOfTuneColor = colorOutOfTune ?? tunerColors.negative;
    final resolvedInactiveColor = colorInactive ?? theme.colorScheme.outline;

    final resolvedOnInTuneColor = colorOnInTune ?? tunerColors.onPositive;
    final resolvedOnOutOfTuneColor = colorOnOutOfTune ?? tunerColors.onNegative;
    final resolvedOnInactiveColor =
        colorOnInactive ?? theme.colorScheme.onInverseSurface;

    final resolvedLineColor = lineColor ?? theme.colorScheme.onSurface;
    final resolvedLineColorInactive =
        lineColorInactive ?? theme.colorScheme.outline;

    final resolvedTickLineColor =
        tickLineColor ?? theme.colorScheme.outline.withValues(alpha: 0.4);
    final resolvedTickLabelStyle =
        tickLabelStyle ??
        theme.textTheme.labelMedium ??
        const TextStyle(fontSize: 12);
    final resolvedTickLabelColor =
        tickLabelColor ?? theme.colorScheme.onSurface;

    final resolvedToleranceLineColor =
        toleranceLineColor ?? theme.colorScheme.outline;
    final resolvedToleranceLabelStyle =
        toleranceLabelStyle ??
        theme.textTheme.labelSmall ??
        const TextStyle(fontSize: 10);
    final resolvedToleranceLabelColor =
        toleranceLabelColor ?? theme.colorScheme.inverseSurface;

    final resolvedCentDeviationStyle =
        centDeviationStyle ??
        theme.textTheme.labelSmall ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
    final resolvedCentDeviationColor =
        centDeviationColor ?? theme.colorScheme.onSurface;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _PitchHistoryPainter(
            state: state,
            targetNote: targetNote,
            targetFrequency: resolvedTargetFreq,
            tuningState: tuningState,
            toleranceInCents: toleranceInCents,
            padding: plotWindowPadding,
            outline: plotWindowOutline,
            lineWidth: lineWidth,
            lineWidthInactive: lineWidthInactive,
            lineColor: resolvedLineColor,
            lineColorInactive: resolvedLineColorInactive,
            pointSize: pointSize,
            pointSizeInactive: pointSizeInactive,
            colorInTune: resolvedInTuneColor,
            colorOutOfTune: resolvedOutOfTuneColor,
            colorInactive: resolvedInactiveColor,
            colorOnInTune: resolvedOnInTuneColor,
            colorOnOutOfTune: resolvedOnOutOfTuneColor,
            colorOnInactive: resolvedOnInactiveColor,
            targetNoteLineWidth: targetNoteLineWidth,
            toleranceLineColor: resolvedToleranceLineColor,
            toleranceLabelStyle: resolvedToleranceLabelStyle,
            toleranceLabelColor: resolvedToleranceLabelColor,
            tickLineWidth: tickLineWidth,
            tickLineColor: resolvedTickLineColor,
            tickLabelStyle: resolvedTickLabelStyle,
            tickLabelColor: resolvedTickLabelColor,
            centDeviationStyle: resolvedCentDeviationStyle,
            centDeviationColor: resolvedCentDeviationColor,
            preferSharp: preferSharp,
          ),
        );
      },
    );
  }
}

class _PitchHistoryPainter extends CustomPainter {
  const _PitchHistoryPainter({
    required this.state,
    required this.targetNote,
    required this.targetFrequency,
    required this.tuningState,
    required this.toleranceInCents,
    required this.padding,
    required this.outline,
    required this.lineWidth,
    required this.lineWidthInactive,
    required this.lineColor,
    required this.lineColorInactive,
    required this.pointSize,
    required this.pointSizeInactive,
    required this.colorInTune,
    required this.colorOutOfTune,
    required this.colorInactive,
    required this.colorOnInTune,
    required this.colorOnOutOfTune,
    required this.colorOnInactive,
    required this.targetNoteLineWidth,
    required this.toleranceLineColor,
    required this.toleranceLabelStyle,
    required this.toleranceLabelColor,
    required this.tickLineWidth,
    required this.tickLineColor,
    required this.tickLabelStyle,
    required this.tickLabelColor,
    required this.centDeviationStyle,
    required this.centDeviationColor,
    required this.preferSharp,
  });

  final PitchHistoryState state;
  final MusicalNote targetNote;
  final double targetFrequency;
  final TuningState tuningState;
  final int toleranceInCents;
  final EdgeInsets padding;
  final PlotWindowOutline outline;

  final double lineWidth;
  final double lineWidthInactive;
  final Color lineColor;
  final Color lineColorInactive;

  final double pointSize;
  final double pointSizeInactive;
  final Color colorInTune;
  final Color colorOutOfTune;
  final Color colorInactive;
  final Color colorOnInTune;
  final Color colorOnOutOfTune;
  final Color colorOnInactive;

  final double targetNoteLineWidth;
  final Color toleranceLineColor;
  final TextStyle toleranceLabelStyle;
  final Color toleranceLabelColor;

  final double tickLineWidth;
  final Color tickLineColor;
  final TextStyle tickLabelStyle;
  final Color tickLabelColor;

  final TextStyle centDeviationStyle;
  final Color centDeviationColor;
  final bool preferSharp;

  Color get tuningColor {
    switch (tuningState) {
      case TuningState.inTune:
        return colorInTune;
      case TuningState.tooLow:
      case TuningState.tooHigh:
        return colorOutOfTune;
      case TuningState.unknown:
        return colorInactive;
    }
  }

  Color get onTuningColor {
    switch (tuningState) {
      case TuningState.inTune:
        return colorOnInTune;
      case TuningState.tooLow:
      case TuningState.tooHigh:
        return colorOnOutOfTune;
      case TuningState.unknown:
        return colorOnInactive;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plotLeft = padding.left;
    final plotTop = padding.top;
    final plotRight = math.max(plotLeft + 10.0, size.width - padding.right);
    final plotBottom = math.max(plotTop + 10.0, size.height - padding.bottom);
    final plotRect = Rect.fromLTRB(plotLeft, plotTop, plotRight, plotBottom);

    // 1. Draw outline border if configured
    if (outline.lineWidth > 0) {
      final borderPaint = Paint()
        ..color = outline.color ?? lineColorInactive.withValues(alpha: 0.5)
        ..strokeWidth = outline.lineWidth
        ..style = PaintingStyle.stroke;
      if (outline.cornerRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            plotRect,
            Radius.circular(outline.cornerRadius),
          ),
          borderPaint,
        );
      } else {
        canvas.drawRect(plotRect, borderPaint);
      }
    }

    // 2. Compute ViewPort in musical MIDI numbers
    final targetMidi = targetNote.midiNumber.toDouble();
    final latestFreq = state.latestFrequency;
    final currentMidi = (latestFreq != null && latestFreq > 0.0)
        ? 69.0 + (12.0 * math.log(latestFreq / 440.0) / math.ln2)
        : null;

    const visibleRangeInIndices = 1.5;
    const visibleRangeInIndices2 = 0.38;

    final double midiMin;
    final double midiMax;

    if (currentMidi == null) {
      midiMin = targetMidi - visibleRangeInIndices;
      midiMax = targetMidi + visibleRangeInIndices;
    } else {
      midiMin = math.min(
        targetMidi - visibleRangeInIndices,
        currentMidi.floorToDouble() - visibleRangeInIndices2,
      );
      midiMax = math.max(
        targetMidi + visibleRangeInIndices,
        currentMidi.ceilToDouble() + visibleRangeInIndices2,
      );
    }

    final midiDelta = math.max(0.1, midiMax - midiMin);

    double midiToY(double midi) {
      final fraction = (midi - midiMin) / midiDelta;
      return plotBottom - (fraction * plotRect.height);
    }

    // 3. Draw horizontal semitone tick lines & note labels (YTicks)
    final firstTick = midiMin.ceil();
    final lastTick = midiMax.floor();

    final tickPaint = Paint()
      ..color = tickLineColor
      ..strokeWidth = tickLineWidth
      ..style = PaintingStyle.stroke;

    for (int m = firstTick; m <= lastTick; m++) {
      final y = midiToY(m.toDouble());
      if (y >= plotTop && y <= plotBottom) {
        canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), tickPaint);

        // Note label in right margin
        final note = MusicalNote.fromMidiNumber(m, preferSharp: preferSharp);
        final tp = TextPainter(
          text: TextSpan(
            text: note.name,
            style: tickLabelStyle.copyWith(color: tickLabelColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelX = plotRight + 6.0;
        final labelY = y - (tp.height / 2.0);
        tp.paint(canvas, Offset(labelX, labelY));
      }
    }

    // 4. Draw tolerance lines (±toleranceInCents) and cent labels
    final tolSemitones = toleranceInCents / 100.0;
    final yLowTol = midiToY(targetMidi - tolSemitones);
    final yHighTol = midiToY(targetMidi + tolSemitones);

    final tolPaint = Paint()
      ..color = toleranceLineColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedHorizontalLine(
      canvas,
      Offset(plotLeft, yLowTol),
      plotRight,
      tolPaint,
    );
    _drawDashedHorizontalLine(
      canvas,
      Offset(plotLeft, yHighTol),
      plotRight,
      tolPaint,
    );

    // Tolerance boundary labels on left side
    final tolLowTp = TextPainter(
      text: TextSpan(
        text: '-$toleranceInCents ¢',
        style: toleranceLabelStyle.copyWith(color: toleranceLabelColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tolLowTp.paint(canvas, Offset(plotLeft + 4.0, yLowTol + 2.0));

    final tolHighTp = TextPainter(
      text: TextSpan(
        text: '+$toleranceInCents ¢',
        style: toleranceLabelStyle.copyWith(color: toleranceLabelColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tolHighTp.paint(
      canvas,
      Offset(plotLeft + 4.0, yHighTol - tolHighTp.height - 2.0),
    );

    // 5. Draw Target Note horizontal line and target pill badge
    final yTarget = midiToY(targetMidi);
    final targetLinePaint = Paint()
      ..color = tuningColor
      ..strokeWidth = targetNoteLineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(plotLeft, yTarget),
      Offset(plotRight, yTarget),
      targetLinePaint,
    );

    // Pill badge for target note at right margin
    final targetBadgeTp = TextPainter(
      text: TextSpan(
        text: targetNote.name,
        style: tickLabelStyle.copyWith(
          color: onTuningColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const pillPaddingH = 6.0;
    const pillPaddingV = 2.0;
    final pillWidth = targetBadgeTp.width + (pillPaddingH * 2.0);
    final pillHeight = targetBadgeTp.height + (pillPaddingV * 2.0);
    final pillLeft = plotRight + 4.0;
    final pillTop = yTarget - (pillHeight / 2.0);
    final pillRect = Rect.fromLTWH(pillLeft, pillTop, pillWidth, pillHeight);

    final pillBgPaint = Paint()
      ..color = tuningColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(8.0)),
      pillBgPaint,
    );
    targetBadgeTp.paint(
      canvas,
      Offset(pillLeft + pillPaddingH, pillTop + pillPaddingV),
    );

    // 6. Draw pitch history polyline (clipping to plot window)
    final cap = math.max(2, state.capacity);
    final xStep = plotRect.width / ((cap - 1) * 1.1);

    canvas.save();
    canvas.clipRect(plotRect);

    final historyPath = Path();
    bool inSegment = false;

    for (int i = 0; i < state.size; i++) {
      final f = state.frequencies[i];
      final x = plotLeft + (i * xStep);
      if (f != null && f > 0.0) {
        final m = 69.0 + (12.0 * math.log(f / 440.0) / math.ln2);
        final y = midiToY(m);
        if (!inSegment) {
          historyPath.moveTo(x, y);
          inSegment = true;
        } else {
          historyPath.lineTo(x, y);
        }
      } else {
        inSegment = false;
      }
    }

    final isInactive = tuningState == TuningState.unknown;
    final polylinePaint = Paint()
      ..color = isInactive ? lineColorInactive : lineColor
      ..strokeWidth = isInactive ? lineWidthInactive : lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(historyPath, polylinePaint);
    canvas.restore();

    // 7. Draw latest pitch point mark & cent deviation badge
    if (state.size > 0 &&
        latestFreq != null &&
        latestFreq > 0.0 &&
        currentMidi != null) {
      final xLast = plotLeft + ((state.size - 1) * xStep);
      final yLast = midiToY(currentMidi);
      final pointOffset = Offset(xLast, yLast);

      final pSize = isInactive ? pointSizeInactive : pointSize;
      PointShapePainter.drawTuningPoint(
        canvas,
        pointOffset,
        tuningState: tuningState,
        size: pSize,
        inTuneColor: colorInTune,
        outOfTuneColor: colorOutOfTune,
        inactiveColor: colorInactive,
      );

      // Cent deviation badge if out of tune
      if (tuningState == TuningState.tooHigh ||
          tuningState == TuningState.tooLow) {
        final devCents =
            (1200.0 * math.log(latestFreq / targetFrequency) / math.ln2)
                .round();
        final devSign = devCents > 0 ? '+' : '';
        final devText = '$devSign$devCents ¢';

        final devTp = TextPainter(
          text: TextSpan(
            text: devText,
            style: centDeviationStyle.copyWith(color: centDeviationColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        // Kotlin: if TooHigh, south (above); if TooLow, north (below)
        final double devY;
        if (tuningState == TuningState.tooHigh) {
          devY = yLast - (pSize / 2.0) - devTp.height - 4.0;
        } else {
          devY = yLast + (pSize / 2.0) + 4.0;
        }

        final devX = (xLast - (devTp.width / 2.0)).clamp(
          plotLeft,
          plotRight - devTp.width,
        );

        devTp.paint(canvas, Offset(devX, devY));
      }
    }
  }

  void _drawDashedHorizontalLine(
    Canvas canvas,
    Offset start,
    double endX,
    Paint paint, {
    double dashWidth = 4.0,
    double dashSpace = 4.0,
  }) {
    double currentX = start.dx;
    final y = start.dy;
    while (currentX < endX) {
      final nextX = math.min(currentX + dashWidth, endX);
      canvas.drawLine(Offset(currentX, y), Offset(nextX, y), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _PitchHistoryPainter oldDelegate) {
    return oldDelegate.tuningState != tuningState ||
        oldDelegate.targetFrequency != targetFrequency ||
        oldDelegate.targetNote != targetNote ||
        oldDelegate.toleranceInCents != toleranceInCents ||
        oldDelegate.preferSharp != preferSharp ||
        oldDelegate.outline != outline ||
        oldDelegate.padding != padding ||
        oldDelegate.state != state;
  }
}
