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
class PitchHistory extends StatefulWidget {
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
  State<PitchHistory> createState() => _PitchHistoryState();
}

class _PitchHistoryState extends State<PitchHistory>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _midiMinAnimation;
  late Animation<double> _midiMaxAnimation;

  double _currentMidiMin = 0.0;
  double _currentMidiMax = 0.0;

  // Gesture state tracking
  double _panDeltaMidi = 0.0;
  double _zoomFactor = 1.0;
  bool _isUserInteracting = false;
  double _prevScale = 1.0;
  Offset _prevFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    final (initMin, initMax) = _computeTargetMidiRange(
      widget.targetNote,
      widget.state.latestFrequency,
    );
    _currentMidiMin = initMin;
    _currentMidiMax = initMax;

    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addListener(() {
          setState(() {
            _currentMidiMin = _midiMinAnimation.value;
            _currentMidiMax = _midiMaxAnimation.value;
          });
        });

    _midiMinAnimation = AlwaysStoppedAnimation(_currentMidiMin);
    _midiMaxAnimation = AlwaysStoppedAnimation(_currentMidiMax);

    widget.state.addListener(_onStateUpdated);
  }

  @override
  void didUpdateWidget(PitchHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      oldWidget.state.removeListener(_onStateUpdated);
      widget.state.addListener(_onStateUpdated);
    }
    _checkAnimateRange();
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateUpdated);
    _animController.dispose();
    super.dispose();
  }

  void _onStateUpdated() {
    _checkAnimateRange();
  }

  void _checkAnimateRange() {
    if (_isUserInteracting) return;
    final (targetMin, targetMax) = _computeTargetMidiRange(
      widget.targetNote,
      widget.state.latestFrequency,
    );

    if ((targetMin - _currentMidiMin).abs() > 0.05 ||
        (targetMax - _currentMidiMax).abs() > 0.05) {
      _midiMinAnimation = Tween<double>(begin: _currentMidiMin, end: targetMin)
          .animate(
            CurvedAnimation(
              parent: _animController,
              curve: Curves.easeOutCubic,
            ),
          );
      _midiMaxAnimation = Tween<double>(begin: _currentMidiMax, end: targetMax)
          .animate(
            CurvedAnimation(
              parent: _animController,
              curve: Curves.easeOutCubic,
            ),
          );
      _animController.forward(from: 0.0);
    }
  }

  static (double, double) _computeTargetMidiRange(
    MusicalNote targetNote,
    double? latestFreq,
  ) {
    final targetMidi = targetNote.midiNumber.toDouble();
    final currentMidi = (latestFreq != null && latestFreq > 0.0)
        ? 69.0 + (12.0 * math.log(latestFreq / 440.0) / math.ln2)
        : null;

    const visibleRangeInIndices = 1.5;
    const visibleRangeInIndices2 = 0.38;

    if (currentMidi == null) {
      return (
        targetMidi - visibleRangeInIndices,
        targetMidi + visibleRangeInIndices,
      );
    } else {
      final clampedCurrentMidi = currentMidi.clamp(
        targetMidi - 4.0,
        targetMidi + 4.0,
      );
      final lower = math.min(
        targetMidi - visibleRangeInIndices,
        clampedCurrentMidi.floorToDouble() - visibleRangeInIndices2,
      );
      final upper = math.max(
        targetMidi + visibleRangeInIndices,
        clampedCurrentMidi.ceilToDouble() + visibleRangeInIndices2,
      );
      return (lower, upper);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = TunerColors.of(context);

    final resolvedTargetFreq =
        widget.targetFrequency ??
        (440.0 * math.pow(2.0, (widget.targetNote.midiNumber - 69) / 12.0));

    final resolvedInTuneColor = widget.colorInTune ?? tunerColors.positive;
    final resolvedOutOfTuneColor =
        widget.colorOutOfTune ?? tunerColors.negative;
    final resolvedInactiveColor =
        widget.colorInactive ?? theme.colorScheme.outline;

    final resolvedOnInTuneColor =
        widget.colorOnInTune ?? tunerColors.onPositive;
    final resolvedOnOutOfTuneColor =
        widget.colorOnOutOfTune ?? tunerColors.onNegative;
    final resolvedOnInactiveColor =
        widget.colorOnInactive ?? theme.colorScheme.onInverseSurface;

    final resolvedLineColor = widget.lineColor ?? theme.colorScheme.onSurface;
    final resolvedLineColorInactive =
        widget.lineColorInactive ?? theme.colorScheme.outline;

    final resolvedTickLineColor =
        widget.tickLineColor ??
        theme.colorScheme.outline.withValues(alpha: 0.4);
    final resolvedTickLabelStyle =
        widget.tickLabelStyle ??
        theme.textTheme.labelMedium ??
        const TextStyle(fontSize: 12);
    final resolvedTickLabelColor =
        widget.tickLabelColor ?? theme.colorScheme.onSurface;

    final resolvedToleranceLineColor =
        widget.toleranceLineColor ?? theme.colorScheme.outline;
    final resolvedToleranceLabelStyle =
        widget.toleranceLabelStyle ??
        theme.textTheme.labelSmall ??
        const TextStyle(fontSize: 10);
    final resolvedToleranceLabelColor =
        widget.toleranceLabelColor ?? theme.colorScheme.inverseSurface;

    final resolvedCentDeviationStyle =
        widget.centDeviationStyle ??
        theme.textTheme.labelSmall ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
    final resolvedCentDeviationColor =
        widget.centDeviationColor ?? theme.colorScheme.onSurface;

    final centerMidi =
        (_currentMidiMin + _currentMidiMax) / 2.0 + _panDeltaMidi;
    final halfSpan = ((_currentMidiMax - _currentMidiMin) / 2.0) * _zoomFactor;
    final effectiveMidiMin = centerMidi - halfSpan;
    final effectiveMidiMax = centerMidi + halfSpan;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _isUserInteracting = false;
          _panDeltaMidi = 0.0;
          _zoomFactor = 1.0;
        });
        _checkAnimateRange();
      },
      onScaleStart: (details) {
        _prevScale = 1.0;
        _prevFocal = details.localFocalPoint;
      },
      onScaleUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final height = renderBox.size.height;
        if (height <= 0) return;

        final dy = details.localFocalPoint.dy - _prevFocal.dy;
        final span = math.max(0.1, _currentMidiMax - _currentMidiMin);
        // Drag down reveals higher notes above; drag up reveals lower notes
        final deltaMidi = (dy / height) * span;

        final scaleDelta = details.scale / _prevScale;
        _prevScale = details.scale;
        _prevFocal = details.localFocalPoint;

        setState(() {
          _isUserInteracting = true;
          _panDeltaMidi += deltaMidi;
          if ((scaleDelta - 1.0).abs() > 0.01) {
            _zoomFactor = (_zoomFactor / scaleDelta).clamp(0.2, 5.0);
          }
        });
      },
      child: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _PitchHistoryPainter(
              state: widget.state,
              targetNote: widget.targetNote,
              targetFrequency: resolvedTargetFreq,
              tuningState: widget.tuningState,
              toleranceInCents: widget.toleranceInCents,
              padding: widget.plotWindowPadding,
              outline: widget.plotWindowOutline,
              lineWidth: widget.lineWidth,
              lineWidthInactive: widget.lineWidthInactive,
              lineColor: resolvedLineColor,
              lineColorInactive: resolvedLineColorInactive,
              pointSize: widget.pointSize,
              pointSizeInactive: widget.pointSizeInactive,
              colorInTune: resolvedInTuneColor,
              colorOutOfTune: resolvedOutOfTuneColor,
              colorInactive: resolvedInactiveColor,
              colorOnInTune: resolvedOnInTuneColor,
              colorOnOutOfTune: resolvedOnOutOfTuneColor,
              colorOnInactive: resolvedOnInactiveColor,
              targetNoteLineWidth: widget.targetNoteLineWidth,
              toleranceLineColor: resolvedToleranceLineColor,
              toleranceLabelStyle: resolvedToleranceLabelStyle,
              toleranceLabelColor: resolvedToleranceLabelColor,
              tickLineWidth: widget.tickLineWidth,
              tickLineColor: resolvedTickLineColor,
              tickLabelStyle: resolvedTickLabelStyle,
              tickLabelColor: resolvedTickLabelColor,
              centDeviationStyle: resolvedCentDeviationStyle,
              centDeviationColor: resolvedCentDeviationColor,
              preferSharp: widget.preferSharp,
              midiMin: effectiveMidiMin,
              midiMax: effectiveMidiMax,
              isUserInteracting: _isUserInteracting,
            ),
          );
        },
      ),
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
    required this.midiMin,
    required this.midiMax,
    required this.isUserInteracting,
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

  final double midiMin;
  final double midiMax;
  final bool isUserInteracting;

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
        ..color = isUserInteracting
            ? tuningColor
            : (outline.color ?? lineColorInactive.withValues(alpha: 0.5))
        ..strokeWidth = isUserInteracting
            ? outline.lineWidth * 1.5
            : outline.lineWidth
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

    // 2. ViewPort coordinates (animated smoothly or gesture-controlled)
    final targetMidi = targetNote.midiNumber.toDouble();
    final latestFreq = state.latestFrequency;
    final currentMidi = (latestFreq != null && latestFreq > 0.0)
        ? 69.0 + (12.0 * math.log(latestFreq / 440.0) / math.ln2)
        : null;

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

    // 6. Draw pitch history polyline (clipped to plot window via Liang-Barsky)
    final cap = math.max(2, state.capacity);
    final xStep = plotRect.width / ((cap - 1) * 1.1);

    canvas.save();
    canvas.clipRect(plotRect);

    final historyPath = Path();
    Offset? lastPoint;

    for (int i = 0; i < state.size - 1; i++) {
      final f0 = state.frequencies[i];
      final f1 = state.frequencies[i + 1];
      if (f0 != null && f0 > 0.0 && f1 != null && f1 > 0.0) {
        final x0 = plotLeft + (i * xStep);
        final x1 = plotLeft + ((i + 1) * xStep);
        final m0 = 69.0 + (12.0 * math.log(f0 / 440.0) / math.ln2);
        final m1 = 69.0 + (12.0 * math.log(f1 / 440.0) / math.ln2);
        final y0 = midiToY(m0);
        final y1 = midiToY(m1);

        _clipSegmentLiangBarsky(x0, y0, x1, y1, plotRect, (cx0, cy0, cx1, cy1) {
          if (lastPoint == null ||
              (lastPoint!.dx - cx0).abs() > 0.5 ||
              (lastPoint!.dy - cy0).abs() > 0.5) {
            historyPath.moveTo(cx0, cy0);
          }
          historyPath.lineTo(cx1, cy1);
          lastPoint = Offset(cx1, cy1);
        });
      } else {
        lastPoint = null;
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
      if (yLast >= plotTop && yLast <= plotBottom) {
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

  /// Parametric Liang-Barsky line clipping against [bounds] to eliminate flying line spikes.
  static bool _clipSegmentLiangBarsky(
    double x0,
    double y0,
    double x1,
    double y1,
    Rect bounds,
    void Function(double cx0, double cy0, double cx1, double cy1) onSegment,
  ) {
    final dx = x1 - x0;
    final dy = y1 - y0;

    var u1 = 0.0;
    var u2 = 1.0;

    bool clipTest(double p, double q) {
      if (p < 0.0) {
        final r = q / p;
        if (r > u2) return false;
        if (r > u1) u1 = r;
      } else if (p > 0.0) {
        final r = q / p;
        if (r < u1) return false;
        if (r < u2) u2 = r;
      } else if (q < 0.0) {
        return false;
      }
      return true;
    }

    if (clipTest(-dx, x0 - bounds.left) &&
        clipTest(dx, bounds.right - x0) &&
        clipTest(-dy, y0 - bounds.top) &&
        clipTest(dy, bounds.bottom - y0)) {
      final cx0 = x0 + u1 * dx;
      final cy0 = y0 + u1 * dy;
      final cx1 = x0 + u2 * dx;
      final cy1 = y0 + u2 * dy;
      onSegment(cx0, cy0, cx1, cy1);
      return true;
    }
    return false;
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
