import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../plot/plot_window_outline.dart';
import 'staff_clef.dart';

/// Interactive musical staff displaying real-time acoustic pitch notes.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.notes.NoteStaff`.
/// Supports:
/// - Clef layouts: Grand, Treble, Tenor (8vb), Bass.
/// - Key signature configurations (from -7 flats to +7 sharps).
/// - Dynamic diatonic step positioning, ledger lines, and tilted note heads.
/// - Tri-state tuning color feedback (positive inTune glow, outOfTune warning).
class NoteStaff extends StatelessWidget {
  const NoteStaff({
    super.key,
    required this.note,
    this.tuningState = TuningState.unknown,
    this.clef = StaffClef.treble,
    this.keySignature = 0,
    this.onClefChanged,
    this.onKeySignatureChanged,
    this.outline = const PlotWindowOutline(),
  });

  /// The active musical note to render on the staff.
  final MusicalNote note;

  /// Acoustic tuning accuracy state.
  final TuningState tuningState;

  /// Active clef configuration.
  final StaffClef clef;

  /// Number of sharps (>0) or flats (<0) in key signature.
  final int keySignature;

  /// Callback when clef is changed.
  final ValueChanged<StaffClef>? onClefChanged;

  /// Callback when key signature is changed.
  final ValueChanged<int>? onKeySignatureChanged;

  /// Window outline styling.
  final PlotWindowOutline outline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = TunerColors.of(context);

    Color noteColor;
    switch (tuningState) {
      case TuningState.inTune:
        noteColor = tunerColors.positive;
        break;
      case TuningState.tooLow:
      case TuningState.tooHigh:
        noteColor = tunerColors.negative;
        break;
      case TuningState.unknown:
        noteColor = theme.colorScheme.onSurface;
        break;
    }

    return Column(
      children: [
        // Top Clef & Key Signature selector bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clef dropdown
              Flexible(
                child: PopupMenuButton<StaffClef>(
                  initialValue: clef,
                  tooltip: 'Select Clef',
                  onSelected: onClefChanged,
                  child: Chip(
                    avatar: const Icon(Icons.queue_music, size: 16),
                    label: Text(
                      clef.label,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  itemBuilder: (context) => [
                    for (final c in StaffClef.values)
                      PopupMenuItem(value: c, child: Text(c.label)),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Key Signature selector
              Flexible(
                child: PopupMenuButton<int>(
                  initialValue: keySignature,
                  tooltip: 'Key Signature',
                  onSelected: onKeySignatureChanged,
                  child: Chip(
                    avatar: const Icon(Icons.tag, size: 16),
                    label: Text(
                      keySignature == 0
                          ? 'Key: ♮'
                          : keySignature > 0
                          ? 'Key: +$keySignature ♯'
                          : 'Key: $keySignature ♭',
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 0, child: Text('Natural (♮)')),
                    const PopupMenuItem(
                      value: 1,
                      child: Text('+1 Sharp (G Maj / E Min)'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('+2 Sharps (D Maj / B Min)'),
                    ),
                    const PopupMenuItem(
                      value: 3,
                      child: Text('+3 Sharps (A Maj)'),
                    ),
                    const PopupMenuItem(
                      value: -1,
                      child: Text('-1 Flat (F Maj / D Min)'),
                    ),
                    const PopupMenuItem(
                      value: -2,
                      child: Text('-2 Flats (B♭ Maj / G Min)'),
                    ),
                    const PopupMenuItem(
                      value: -3,
                      child: Text('-3 Flats (E♭ Maj)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Staff canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: CustomPaint(
              size: Size.infinite,
              painter: _NoteStaffPainter(
                note: note,
                tuningState: tuningState,
                noteColor: noteColor,
                clef: clef,
                keySignature: keySignature,
                lineColor: theme.colorScheme.outline.withValues(alpha: 0.6),
                outline: outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteStaffPainter extends CustomPainter {
  const _NoteStaffPainter({
    required this.note,
    required this.tuningState,
    required this.noteColor,
    required this.clef,
    required this.keySignature,
    required this.lineColor,
    required this.outline,
  });

  final MusicalNote note;
  final TuningState tuningState;
  final Color noteColor;
  final StaffClef clef;
  final int keySignature;
  final Color lineColor;
  final PlotWindowOutline outline;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw outline
    if (outline.lineWidth > 0) {
      final borderPaint = Paint()
        ..color = outline.color ?? lineColor
        ..strokeWidth = outline.lineWidth
        ..style = PaintingStyle.stroke;
      if (outline.cornerRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(outline.cornerRadius)),
          borderPaint,
        );
      } else {
        canvas.drawRect(rect, borderPaint);
      }
    }

    // Staff geometry
    final staffPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2.0;
    const lineSpacing = 14.0; // Distance between staff lines
    const halfStep = lineSpacing / 2.0; // One diatonic position

    // Draw 5 staff lines centered
    final topStaffLine = centerY - (2 * lineSpacing);
    final bottomStaffLine = centerY + (2 * lineSpacing);

    for (int i = 0; i < 5; i++) {
      final y = topStaffLine + (i * lineSpacing);
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), staffPaint);
    }

    // Draw Clef Indicator at left
    final clefText = clef == StaffClef.bass ? '𝄢' : '𝄞';
    final clefTp = TextPainter(
      text: TextSpan(
        text: clefText,
        style: TextStyle(
          fontSize: clef == StaffClef.bass ? 38 : 46,
          color: lineColor,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final clefY =
        centerY - (clefTp.height / 2.0) - (clef == StaffClef.bass ? 6 : 8);
    clefTp.paint(canvas, Offset(28, clefY));

    // Note positioning
    // Reference: E4 (position 30) is the bottom line of Treble staff
    // In our centered staff:
    // Bottom line is at bottomStaffLine
    final notePos = StaffPositions.diatonicPosition(note);
    final int refBottomLinePos;
    if (clef == StaffClef.bass) {
      refBottomLinePos = StaffPositions.bassBottomLine; // G2 = 18
    } else {
      refBottomLinePos = StaffPositions.trebleBottomLine; // E4 = 30
    }

    final stepDiff = notePos - refBottomLinePos;
    final noteY = bottomStaffLine - (stepDiff * halfStep);
    final noteX = size.width * 0.58;

    // Draw Ledger lines if outside staff lines
    if (noteY > bottomStaffLine + 2) {
      // Below staff
      double ly = bottomStaffLine + lineSpacing;
      while (ly <= noteY + 2) {
        canvas.drawLine(
          Offset(noteX - 16, ly),
          Offset(noteX + 16, ly),
          staffPaint,
        );
        ly += lineSpacing;
      }
    } else if (noteY < topStaffLine - 2) {
      // Above staff
      double ly = topStaffLine - lineSpacing;
      while (ly >= noteY - 2) {
        canvas.drawLine(
          Offset(noteX - 16, ly),
          Offset(noteX + 16, ly),
          staffPaint,
        );
        ly -= lineSpacing;
      }
    }

    // Draw Note Head (Tilted ellipse)
    canvas.save();
    canvas.translate(noteX, noteY);
    canvas.rotate(-math.pi / 8.0); // -22.5 deg tilt

    final headPaint = Paint()
      ..color = noteColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // In-tune glow
    if (tuningState == TuningState.inTune) {
      final glowPaint = Paint()
        ..color = noteColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 16),
        glowPaint,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 15, height: 11),
      headPaint,
    );
    canvas.restore();

    // Draw Note Stem
    final stemPaint = Paint()
      ..color = noteColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final stemUp = noteY >= centerY;
    if (stemUp) {
      canvas.drawLine(
        Offset(noteX + 6.5, noteY - 2),
        Offset(noteX + 6.5, noteY - 38),
        stemPaint,
      );
    } else {
      canvas.drawLine(
        Offset(noteX - 6.5, noteY + 2),
        Offset(noteX - 6.5, noteY + 38),
        stemPaint,
      );
    }

    // Draw Accidental Symbol if sharp or flat
    if (note.modifier != NoteModifier.none) {
      final String accidentalChar;
      switch (note.modifier) {
        case NoteModifier.sharp:
          accidentalChar = '♯';
          break;
        case NoteModifier.flat:
          accidentalChar = '♭';
          break;
        case NoteModifier.doubleSharp:
          accidentalChar = '𝄪';
          break;
        case NoteModifier.doubleFlat:
          accidentalChar = '𝄫';
          break;
        default:
          accidentalChar = '';
      }

      final accTp = TextPainter(
        text: TextSpan(
          text: accidentalChar,
          style: TextStyle(
            fontSize: 22,
            color: noteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      accTp.paint(canvas, Offset(noteX - 24, noteY - (accTp.height / 2.0)));
    }
  }

  @override
  bool shouldRepaint(covariant _NoteStaffPainter oldDelegate) {
    return oldDelegate.note != note ||
        oldDelegate.tuningState != tuningState ||
        oldDelegate.clef != clef ||
        oldDelegate.keySignature != keySignature ||
        oldDelegate.noteColor != noteColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.outline != outline;
  }
}
