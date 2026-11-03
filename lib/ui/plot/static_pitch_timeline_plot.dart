import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../dsp/analysis/offline_audio_analyzer.dart';
import 'plot_window_outline.dart';

/// Static interactive timeline pitch plot for offline audio file inspection.
/// Displays the complete pitch trajectory over time with an interactive time scrubber cursor.
class StaticPitchTimelinePlot extends StatefulWidget {
  const StaticPitchTimelinePlot({
    super.key,
    required this.frames,
    required this.durationSeconds,
    required this.currentTime,
    required this.onSeekTime,
    this.targetNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.targetFrequency = 440.0,
    this.tuningState = TuningState.inTune,
    this.toleranceInCents = 10,
    this.outline = const PlotWindowOutline(),
  });

  final List<AnalysisFrame> frames;
  final double durationSeconds;
  final double currentTime;
  final ValueChanged<double> onSeekTime;
  final MusicalNote targetNote;
  final double targetFrequency;
  final TuningState tuningState;
  final int toleranceInCents;
  final PlotWindowOutline outline;

  @override
  State<StaticPitchTimelinePlot> createState() =>
      _StaticPitchTimelinePlotState();
}

class _StaticPitchTimelinePlotState extends State<StaticPitchTimelinePlot> {
  void _handleTouch(Offset localPos, Size size) {
    const leftPad = 48.0;
    const rightPad = 16.0;
    final plotWidth = size.width - leftPad - rightPad;
    if (plotWidth <= 0 || widget.durationSeconds <= 0) return;

    final frac = ((localPos.dx - leftPad) / plotWidth).clamp(0.0, 1.0);
    final targetTime = frac * widget.durationSeconds;
    widget.onSeekTime(targetTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = TunerColors.of(context);

    return GestureDetector(
      onTapDown: (details) =>
          _handleTouch(details.localPosition, context.size ?? Size.zero),
      onHorizontalDragUpdate: (details) =>
          _handleTouch(details.localPosition, context.size ?? Size.zero),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(widget.outline.cornerRadius),
          border: Border.all(
            color: widget.outline.color ?? theme.colorScheme.outlineVariant,
            width: widget.outline.lineWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          size: Size.infinite,
          painter: _StaticPitchPainter(
            frames: widget.frames,
            durationSeconds: widget.durationSeconds,
            currentTime: widget.currentTime,
            targetNote: widget.targetNote,
            targetFrequency: widget.targetFrequency,
            tuningState: widget.tuningState,
            toleranceInCents: widget.toleranceInCents,
            lineColor: theme.colorScheme.primary,
            scrubberColor: theme.colorScheme.tertiary,
            gridColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            textColor: theme.colorScheme.onSurfaceVariant,
            inTuneColor: tunerColors.inTune,
            outOfTuneColor: tunerColors.outOfTune,
          ),
        ),
      ),
    );
  }
}

class _StaticPitchPainter extends CustomPainter {
  _StaticPitchPainter({
    required this.frames,
    required this.durationSeconds,
    required this.currentTime,
    required this.targetNote,
    required this.targetFrequency,
    required this.tuningState,
    required this.toleranceInCents,
    required this.lineColor,
    required this.scrubberColor,
    required this.gridColor,
    required this.textColor,
    required this.inTuneColor,
    required this.outOfTuneColor,
  });

  final List<AnalysisFrame> frames;
  final double durationSeconds;
  final double currentTime;
  final MusicalNote targetNote;
  final double targetFrequency;
  final TuningState tuningState;
  final int toleranceInCents;

  final Color lineColor;
  final Color scrubberColor;
  final Color gridColor;
  final Color textColor;
  final Color inTuneColor;
  final Color outOfTuneColor;

  static const double leftPad = 48.0;
  static const double rightPad = 16.0;
  static const double topPad = 12.0;
  static const double bottomPad = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= leftPad + rightPad || size.height <= topPad + bottomPad) {
      return;
    }

    final plotWidth = size.width - leftPad - rightPad;
    final plotHeight = size.height - topPad - bottomPad;
    final plotRect = Rect.fromLTWH(leftPad, topPad, plotWidth, plotHeight);

    // Compute robust MIDI range across valid frames or fallback around target note
    final validMidis = <double>[];
    for (final frame in frames) {
      if (!frame.isSilence &&
          frame.frequency >= 40.0 &&
          frame.frequency <= 4200.0) {
        final m = 69.0 + (12.0 * math.log(frame.frequency / 440.0) / math.ln2);
        validMidis.add(m);
      }
    }

    final targetMidi = targetNote.midiNumber.toDouble();
    var midiMin = targetMidi - 4.0;
    var midiMax = targetMidi + 4.0;

    if (validMidis.isNotEmpty) {
      validMidis.sort();
      // Use 2% and 98% quantiles to reject transient cymbal/drum noise spikes
      final p02 = validMidis[(validMidis.length * 0.02).floor()];
      final p98 =
          validMidis[(validMidis.length * 0.98).floor().clamp(
            0,
            validMidis.length - 1,
          )];

      midiMin = math.min(p02 - 1.5, targetMidi - 2.0);
      midiMax = math.max(p98 + 1.5, targetMidi + 2.0);

      // Ensure at least 8 semitones span for pleasing aesthetics
      if (midiMax - midiMin < 8.0) {
        final mid = (midiMin + midiMax) / 2.0;
        midiMin = mid - 4.0;
        midiMax = mid + 4.0;
      }
    }

    final midiSpan = math.max(1.0, midiMax - midiMin);
    final dur = math.max(0.1, durationSeconds);

    double timeToX(double t) => leftPad + (t / dur).clamp(0.0, 1.0) * plotWidth;
    double midiToY(double m) =>
        topPad + (1.0 - (m - midiMin) / midiSpan).clamp(0.0, 1.0) * plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Draw horizontal semitone ticks & labels with adaptive thinning
    final firstTick = midiMin.ceil();
    final lastTick = midiMax.floor();
    for (var m = firstTick; m <= lastTick; m++) {
      final y = midiToY(m.toDouble());
      final note = MusicalNote.fromMidiNumber(m);

      // Adaptive thinning: avoid overlapping labels when midiSpan is large
      final bool shouldDrawLabel;
      final bool isNatural = note.modifier == NoteModifier.none;
      final bool isC = isNatural && note.base == BaseNote.c;

      if (midiSpan <= 24) {
        shouldDrawLabel = true;
      } else if (midiSpan <= 48) {
        shouldDrawLabel = isNatural;
      } else {
        shouldDrawLabel = isC;
      }

      if (midiSpan <= 36 || isNatural || isC) {
        canvas.drawLine(
          Offset(leftPad, y),
          Offset(leftPad + plotWidth, y),
          gridPaint,
        );
      }

      if (shouldDrawLabel) {
        final tp = TextPainter(
          text: TextSpan(
            text: note.name,
            style: TextStyle(
              color: isC ? textColor : textColor.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: isC ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(leftPad - tp.width - 6.0, y - tp.height / 2.0));
      }
    }

    // 2. Target Note horizontal line
    final targetY = midiToY(targetMidi);
    final targetPaint = Paint()
      ..color = inTuneColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(leftPad, targetY),
      Offset(leftPad + plotWidth, targetY),
      targetPaint,
    );

    // 3. Time axis labels at bottom
    final numTimeSteps = 5;
    for (var i = 0; i <= numTimeSteps; i++) {
      final t = (dur / numTimeSteps) * i;
      final x = timeToX(t);
      canvas.drawLine(
        Offset(x, topPad + plotHeight),
        Offset(x, topPad + plotHeight + 4.0),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${t.toStringAsFixed(1)}s',
          style: TextStyle(color: textColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2.0, topPad + plotHeight + 6.0));
    }

    // 4. Draw pitch history polyline with jump break discontinuity handling
    canvas.save();
    canvas.clipRect(plotRect);

    final path = Path();
    var hasActivePoint = false;
    double lastTime = 0.0;
    double lastMidi = 0.0;

    for (var i = 0; i < frames.length; i++) {
      final f = frames[i];
      if (f.isSilence || f.frequency <= 0) {
        hasActivePoint = false;
        continue;
      }

      final m = 69.0 + (12.0 * math.log(f.frequency / 440.0) / math.ln2);
      final x = timeToX(f.timeSeconds);
      final y = midiToY(m);

      // Acoustic continuity check:
      // Break line on octave jumps or transient noise spikes (> 4.0 semitones)
      // or temporal gaps (> 0.08 seconds).
      final isDiscontinuous =
          hasActivePoint &&
          ((m - lastMidi).abs() > 4.0 || (f.timeSeconds - lastTime) > 0.08);

      if (!hasActivePoint || isDiscontinuous) {
        path.moveTo(x, y);
        // Add a micro dot at the start of a segment or isolated frame
        path.addOval(Rect.fromCircle(center: Offset(x, y), radius: 1.0));
        path.moveTo(x, y);
        hasActivePoint = true;
      } else {
        path.lineTo(x, y);
      }

      lastTime = f.timeSeconds;
      lastMidi = m;
    }

    final curvePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, curvePaint);

    canvas.restore();

    // 5. Draw interactive time scrubber cursor
    final scrubberX = timeToX(currentTime);
    final scrubberPaint = Paint()
      ..color = scrubberColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(scrubberX, topPad),
      Offset(scrubberX, topPad + plotHeight),
      scrubberPaint,
    );

    // Draw scrubber triangle head at top
    final headPath = Path()
      ..moveTo(scrubberX - 6.0, topPad)
      ..lineTo(scrubberX + 6.0, topPad)
      ..lineTo(scrubberX, topPad + 8.0)
      ..close();
    final headPaint = Paint()
      ..color = scrubberColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(headPath, headPaint);
  }

  @override
  bool shouldRepaint(covariant _StaticPitchPainter old) {
    return old.frames != frames ||
        old.currentTime != currentTime ||
        old.targetNote != targetNote ||
        old.targetFrequency != targetFrequency ||
        old.tuningState != tuningState;
  }
}
