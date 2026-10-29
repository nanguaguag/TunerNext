// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import 'staff_models.dart';
import 'svg_path_parser.dart';

const double trebleClefWidth = 2.642;
const double trebleClefTop = -4.571;
const double trebleClefBottom = 2.673;

const double bassClefWidth = 2.791;
const double bassClefTop = -1.077;
const double bassClefBottom = 2.3;

const double noteHeadRadiusX = 0.64;
const double noteHeadRadiusY = 0.568;
const double noteHeadSkew = 0.3;

const double accidentalStaffSpacePerEm = 0.308;

const String trebleClefPathData =
    'M1.529 -4.567C1.512 -4.564 1.501 -4.557 1.468 -4.528C1.275 -4.363 1.12 -4.14 1.027 -3.896C0.966 -3.735 0.931 -3.574 0.92 -3.392C0.916 -3.34 0.918 -3.198 0.923 -3.149C0.934 -3.035 0.939 -3.004 1.004 -2.703C1.011 -2.673 1.034 -2.563 1.056 -2.459L1.097 -2.27L1.003 -2.176C0.952 -2.124 0.894 -2.064 0.874 -2.043C0.662 -1.818 0.475 -1.592 0.3 -1.348C0.238 -1.262 0.194 -1.189 0.154 -1.106C0.072 -0.935 0.025 -0.769 0.005 -0.574C0 -0.52 0 -0.355 0.005 -0.304C0.019 -0.175 0.038 -0.087 0.075 0.026C0.132 0.202 0.222 0.364 0.342 0.508C0.496 0.692 0.693 0.835 0.915 0.924C1.042 0.975 1.169 1.007 1.317 1.023C1.362 1.028 1.529 1.028 1.572 1.024C1.638 1.017 1.698 1.007 1.756 0.993C1.775 0.988 1.792 0.984 1.792 0.984C1.793 0.985 1.878 1.382 1.889 1.435C1.922 1.601 1.931 1.754 1.914 1.884C1.9 1.997 1.867 2.1 1.82 2.176C1.789 2.225 1.761 2.262 1.72 2.304C1.658 2.367 1.599 2.41 1.523 2.447C1.456 2.48 1.397 2.5 1.325 2.513C1.279 2.521 1.247 2.524 1.193 2.524C1.128 2.524 1.081 2.518 1.019 2.503C0.974 2.492 0.908 2.469 0.874 2.452L0.864 2.447L0.895 2.446C0.931 2.444 0.967 2.438 0.999 2.427C1.031 2.417 1.084 2.391 1.11 2.372C1.134 2.355 1.171 2.321 1.189 2.298C1.243 2.233 1.275 2.152 1.281 2.065C1.285 2.004 1.275 1.94 1.254 1.884C1.195 1.734 1.061 1.633 0.898 1.614C0.869 1.611 0.808 1.613 0.78 1.618C0.709 1.63 0.643 1.659 0.586 1.702C0.543 1.733 0.494 1.789 0.465 1.837C0.382 1.978 0.382 2.153 0.464 2.288C0.512 2.367 0.625 2.473 0.726 2.534C0.842 2.605 0.966 2.647 1.101 2.662C1.2 2.673 1.306 2.666 1.404 2.642C1.616 2.59 1.798 2.464 1.919 2.285C1.98 2.196 2.02 2.097 2.044 1.976C2.06 1.892 2.066 1.824 2.064 1.72C2.062 1.575 2.054 1.525 1.98 1.18C1.952 1.048 1.929 0.939 1.929 0.938C1.929 0.937 1.94 0.932 1.954 0.926C1.985 0.913 2.054 0.877 2.086 0.858C2.326 0.717 2.507 0.492 2.585 0.24C2.605 0.176 2.615 0.134 2.624 0.072C2.642 -0.059 2.634 -0.195 2.601 -0.324C2.582 -0.398 2.557 -0.465 2.528 -0.522C2.47 -0.639 2.419 -0.711 2.331 -0.799C2.248 -0.882 2.167 -0.94 2.064 -0.991C1.96 -1.042 1.858 -1.071 1.732 -1.087C1.697 -1.092 1.555 -1.091 1.522 -1.086C1.508 -1.084 1.497 -1.083 1.496 -1.083C1.496 -1.083 1.461 -1.248 1.418 -1.45L1.339 -1.817L1.379 -1.855C1.4 -1.876 1.447 -1.921 1.483 -1.955C1.554 -2.022 1.582 -2.05 1.629 -2.102C1.75 -2.234 1.852 -2.383 1.928 -2.537C2.031 -2.747 2.09 -2.965 2.104 -3.192C2.108 -3.244 2.106 -3.38 2.101 -3.428C2.086 -3.581 2.058 -3.706 2.004 -3.868C1.928 -4.097 1.824 -4.293 1.699 -4.443C1.673 -4.475 1.618 -4.529 1.595 -4.546C1.569 -4.565 1.551 -4.571 1.529 -4.567ZM1.735 -3.956C1.775 -3.945 1.81 -3.924 1.833 -3.896C1.853 -3.873 1.864 -3.846 1.875 -3.796C1.897 -3.699 1.896 -3.593 1.874 -3.471C1.866 -3.428 1.849 -3.359 1.837 -3.32C1.798 -3.2 1.735 -3.062 1.663 -2.942C1.574 -2.793 1.475 -2.66 1.35 -2.521C1.32 -2.488 1.22 -2.384 1.218 -2.385C1.216 -2.387 1.129 -2.802 1.124 -2.836C1.103 -2.961 1.099 -3.077 1.111 -3.196C1.128 -3.349 1.175 -3.5 1.246 -3.625C1.263 -3.655 1.3 -3.709 1.324 -3.74C1.352 -3.775 1.407 -3.83 1.439 -3.856C1.507 -3.91 1.586 -3.95 1.646 -3.96C1.673 -3.964 1.708 -3.963 1.735 -3.956ZM1.228 -1.656C1.239 -1.604 1.355 -1.06 1.357 -1.055C1.358 -1.051 1.357 -1.049 1.355 -1.049C1.348 -1.049 1.279 -1.023 1.245 -1.007C1.115 -0.946 1.001 -0.853 0.915 -0.736C0.891 -0.704 0.875 -0.678 0.851 -0.634C0.818 -0.574 0.801 -0.531 0.78 -0.458C0.758 -0.381 0.746 -0.281 0.751 -0.2C0.759 -0.067 0.792 0.047 0.857 0.162C0.908 0.252 0.993 0.347 1.08 0.409C1.136 0.449 1.223 0.495 1.258 0.503C1.301 0.512 1.341 0.472 1.331 0.429C1.326 0.406 1.318 0.396 1.285 0.376C1.196 0.321 1.125 0.238 1.086 0.14C1.04 0.024 1.038 -0.111 1.081 -0.226C1.108 -0.3 1.148 -0.363 1.2 -0.417C1.256 -0.475 1.316 -0.518 1.388 -0.549C1.413 -0.56 1.458 -0.576 1.459 -0.574C1.459 -0.574 1.492 -0.422 1.531 -0.237C1.571 -0.053 1.64 0.271 1.685 0.481C1.73 0.692 1.767 0.866 1.767 0.867C1.767 0.873 1.672 0.898 1.614 0.908C1.567 0.916 1.54 0.919 1.493 0.92C1.342 0.926 1.204 0.9 1.066 0.841C0.866 0.756 0.696 0.609 0.576 0.417C0.48 0.265 0.422 0.088 0.403 -0.103C0.399 -0.141 0.399 -0.292 0.403 -0.333C0.422 -0.535 0.487 -0.733 0.593 -0.909C0.658 -1.018 0.832 -1.248 0.987 -1.431C1.066 -1.524 1.215 -1.691 1.22 -1.691C1.22 -1.691 1.224 -1.675 1.228 -1.656ZM1.705 -0.595C1.839 -0.58 1.967 -0.525 2.071 -0.438C2.106 -0.409 2.157 -0.357 2.179 -0.328C2.222 -0.27 2.258 -0.208 2.283 -0.144C2.33 -0.025 2.345 0.114 2.324 0.239C2.291 0.435 2.18 0.613 2.011 0.74C1.985 0.759 1.942 0.787 1.911 0.805L1.901 0.811L1.885 0.736C1.876 0.695 1.866 0.646 1.862 0.627C1.858 0.609 1.798 0.328 1.729 0.003C1.659 -0.321 1.602 -0.589 1.601 -0.593L1.6 -0.599L1.638 -0.599C1.659 -0.599 1.689 -0.597 1.705 -0.595Z';

const String bassClefPathData =
    'M0.954 -1.068C0.78 -1.057 0.609 -1.007 0.464 -0.924C0.26 -0.807 0.114 -0.631 0.053 -0.428C0.043 -0.394 0.034 -0.353 0.029 -0.314C0.024 -0.278 0.024 -0.187 0.029 -0.151C0.044 -0.043 0.082 0.05 0.143 0.125C0.207 0.205 0.294 0.262 0.387 0.284C0.439 0.296 0.514 0.299 0.562 0.29C0.679 0.27 0.778 0.206 0.843 0.108C0.874 0.06 0.895 0.008 0.906 -0.051C0.912 -0.079 0.914 -0.147 0.91 -0.175C0.887 -0.364 0.745 -0.511 0.557 -0.539C0.527 -0.544 0.471 -0.544 0.439 -0.539C0.382 -0.531 0.326 -0.511 0.28 -0.481C0.27 -0.475 0.262 -0.471 0.262 -0.471C0.262 -0.472 0.267 -0.483 0.272 -0.497C0.299 -0.559 0.333 -0.616 0.377 -0.672C0.399 -0.7 0.445 -0.748 0.474 -0.772C0.572 -0.858 0.699 -0.921 0.83 -0.95C0.89 -0.963 0.941 -0.969 1.006 -0.971C1.16 -0.976 1.302 -0.93 1.427 -0.836C1.578 -0.722 1.684 -0.542 1.734 -0.315C1.755 -0.218 1.763 -0.15 1.766 -0.031C1.773 0.224 1.744 0.429 1.667 0.659C1.59 0.89 1.468 1.112 1.302 1.323C1.195 1.459 1.038 1.616 0.895 1.731C0.651 1.925 0.383 2.075 0.071 2.191C0.032 2.206 0.02 2.211 0.014 2.216C0.004 2.226 0 2.237 0 2.252C0 2.281 0.019 2.3 0.048 2.3C0.062 2.3 0.141 2.284 0.216 2.265C0.538 2.185 0.827 2.065 1.101 1.897C1.308 1.771 1.519 1.599 1.677 1.43C1.751 1.35 1.8 1.292 1.861 1.211C1.921 1.131 1.955 1.08 2.005 0.997C2.066 0.896 2.124 0.78 2.167 0.674C2.26 0.445 2.312 0.199 2.312 -0.005C2.312 -0.063 2.31 -0.095 2.303 -0.144C2.276 -0.327 2.202 -0.494 2.083 -0.639C2.012 -0.726 1.907 -0.815 1.807 -0.874C1.694 -0.941 1.588 -0.984 1.453 -1.019C1.303 -1.058 1.106 -1.077 0.954 -1.068ZM2.604 -0.659C2.591 -0.656 2.566 -0.647 2.554 -0.641C2.518 -0.621 2.492 -0.588 2.479 -0.548C2.473 -0.532 2.473 -0.529 2.473 -0.5C2.473 -0.471 2.473 -0.468 2.479 -0.452C2.496 -0.401 2.533 -0.364 2.584 -0.347C2.6 -0.341 2.603 -0.341 2.632 -0.341C2.661 -0.341 2.664 -0.341 2.68 -0.347C2.731 -0.364 2.768 -0.401 2.785 -0.452C2.791 -0.468 2.791 -0.471 2.791 -0.5C2.791 -0.529 2.791 -0.532 2.785 -0.548C2.769 -0.599 2.731 -0.636 2.681 -0.653C2.667 -0.658 2.661 -0.658 2.637 -0.659C2.622 -0.659 2.607 -0.659 2.604 -0.659ZM2.604 0.341C2.591 0.344 2.566 0.353 2.554 0.359C2.518 0.379 2.492 0.412 2.479 0.452C2.473 0.468 2.473 0.471 2.473 0.5C2.473 0.529 2.473 0.532 2.479 0.548C2.496 0.599 2.533 0.636 2.584 0.653C2.6 0.659 2.603 0.659 2.632 0.659C2.661 0.659 2.664 0.659 2.68 0.653C2.731 0.636 2.768 0.599 2.785 0.548C2.791 0.532 2.791 0.529 2.791 0.5C2.791 0.471 2.791 0.468 2.785 0.452C2.769 0.401 2.731 0.364 2.681 0.347C2.667 0.342 2.661 0.342 2.637 0.341C2.622 0.341 2.607 0.341 2.604 0.341Z';

/// CustomPainter for rendering classical note staff, Gonville clefs, notes, and accidentals.
class NoteStaffPainter extends CustomPainter {
  NoteStaffPainter({
    required this.note,
    required this.tuningState,
    required this.staffClef,
    this.keySignature,
    required this.staffColor,
    required this.inTuneColor,
    required this.outOfTuneColor,
    required this.unknownTuningColor,
    required this.borderColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
  }) : _trebleClefPath = SvgPathParser.parse(trebleClefPathData),
       _bassClefPath = SvgPathParser.parse(bassClefPathData);

  final MusicalNote? note;
  final TuningState tuningState;
  final StaffClef staffClef;
  final int? keySignature;
  final Color staffColor;
  final Color inTuneColor;
  final Color outOfTuneColor;
  final Color unknownTuningColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;

  final Path _trebleClefPath;
  final Path _bassClefPath;

  Color get noteColor {
    switch (tuningState) {
      case TuningState.inTune:
        return inTuneColor;
      case TuningState.tooLow:
      case TuningState.tooHigh:
        return outOfTuneColor;
      case TuningState.unknown:
        return unknownTuningColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Draw container outline
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, borderPaint);

    canvas.save();
    canvas.clipRRect(rrect);

    final layout = staffClef.layout();
    final numKeyAccidentals = keySignature?.abs() ?? 0;

    final staffSpace = math.min(
      size.height / layout.staffSpacesVisible,
      size.width / (9.0 + numKeyAccidentals * keySignatureSpacing),
    );

    final lineWidth = 0.1 * staffSpace;
    final left = 0.5 * staffSpace;
    final right = size.width - 0.5 * staffSpace;
    final centerY = 0.5 * size.height;

    double y(int position) =>
        centerY - 0.5 * staffSpace * (position - layout.centerPosition);

    final linePaint = Paint()
      ..color = staffColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 1. Draw 5 horizontal staff lines for each staff
    for (final staff in layout.staves) {
      for (var pos = staff.bottomLine; pos <= staff.topLine; pos += 2) {
        final lineY = y(pos);
        canvas.drawLine(Offset(left, lineY), Offset(right, lineY), linePaint);
      }
    }

    // 2. Draw vertical connecting bar on left
    canvas.drawLine(
      Offset(left, y(layout.staves.first.topLine) - 0.5 * lineWidth),
      Offset(left, y(layout.staves.last.bottomLine) + 0.5 * lineWidth),
      linePaint,
    );

    // 3. Draw Clef glyphs
    final clefX = left + 0.5 * staffSpace;
    final clefPaint = Paint()
      ..color = staffColor
      ..style = PaintingStyle.fill;

    for (final staff in layout.staves) {
      final isTreble = staff.glyph == ClefGlyph.treble;
      final clefPath = isTreble ? _trebleClefPath : _bassClefPath;
      final clefLineY = y(staff.clefLine);

      canvas.save();
      canvas.translate(clefX, clefLineY);
      canvas.scale(staffSpace, staffSpace);
      canvas.drawPath(clefPath, clefPaint);
      canvas.restore();
    }

    // 4. Draw Key Signature accidentals
    final keySignatureX = clefX + (bassClefWidth + 0.6) * staffSpace;
    if (keySignature != null && keySignature != 0) {
      final isSharp = keySignature! > 0;
      final symbol = isSharp ? '\uE10C' : '\uE100'; // Gonville sharp / flat
      final fallbackSymbol = isSharp ? '♯' : '♭';
      final positions = keySignaturePositions(keySignature!, staffClef);

      for (var i = 0; i < numKeyAccidentals; i++) {
        final rightX =
            keySignatureX + (i + 1) * keySignatureSpacing * staffSpace;
        for (final staffPositions in positions) {
          _drawAccidental(
            canvas: canvas,
            symbol: symbol,
            fallbackSymbol: fallbackSymbol,
            rightX: rightX,
            noteY: y(staffPositions[i]),
            staffSpace: staffSpace,
            color: staffColor,
          );
        }
      }
    }

    // 5. Calculate note placement & drawing
    final spelled = note != null
        ? spellNote(note!, keySignature: keySignature)
        : null;
    final soundingPos = note != null ? staffPosition(note!) : null;
    final placement = soundingPos != null
        ? staffPlacement(soundingPos, staffClef)
        : null;

    final noteX = math.max(
      keySignatureX +
          (numKeyAccidentals * keySignatureSpacing + 3.5) * staffSpace,
      0.45 * size.width,
    );

    if (placement != null) {
      final noteY = y(placement.position);

      // Ledger lines
      for (final p in ledgerLinePositions(placement.position, staffClef)) {
        final lineY = y(p);
        canvas.drawLine(
          Offset(noteX - 1.1 * staffSpace, lineY),
          Offset(noteX + 1.1 * staffSpace, lineY),
          linePaint,
        );
      }

      // Draw skewed note head
      canvas.save();
      canvas.translate(noteX, noteY);
      canvas.scale(staffSpace, staffSpace);
      final skewMatrix = Matrix4.identity()..setEntry(0, 1, -noteHeadSkew);
      canvas.transform(skewMatrix.storage);
      final headPaint = Paint()
        ..color = noteColor
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 2 * noteHeadRadiusX,
          height: 2 * noteHeadRadiusY,
        ),
        headPaint,
      );
      canvas.restore();

      // Draw accidental if needed
      if (spelled != null && spelled.showAccidental) {
        final sym = _accidentalSymbol(spelled.note.modifier);
        final fallbackSym = _accidentalFallbackSymbol(spelled.note.modifier);
        _drawAccidental(
          canvas: canvas,
          symbol: sym,
          fallbackSymbol: fallbackSym,
          rightX: noteX - 1.1 * staffSpace,
          noteY: noteY,
          staffSpace: staffSpace,
          color: noteColor,
        );
      }
    }

    // 6. Draw clef octave transposition mark (e.g. 8 for tenor clef or shifted note)
    final octaveMark = placement?.octaveMark ?? layout.writtenOctaves;
    if (octaveMark != 0) {
      final staff = octaveMark > 0 ? layout.staves.last : layout.staves.first;
      final clefEdge = octaveMark > 0
          ? (staff.glyph == ClefGlyph.treble
                ? trebleClefBottom
                : bassClefBottom)
          : (staff.glyph == ClefGlyph.treble ? trebleClefTop : bassClefTop);
      final isClefOwnMark = octaveMark == layout.writtenOctaves;

      _drawOctaveClefMark(
        canvas: canvas,
        octaves: octaveMark.abs(),
        above: octaveMark < 0,
        centerX:
            clefX +
            0.5 *
                (staff.glyph == ClefGlyph.treble
                    ? trebleClefWidth
                    : bassClefWidth) *
                staffSpace,
        clefEdgeY: y(staff.clefLine) + clefEdge * staffSpace,
        staffSpace: staffSpace,
        color: isClefOwnMark ? staffColor : noteColor,
      );
    }

    // 7. Note name label (right of note head)
    if (spelled != null) {
      final labelText = spelled.note.name;
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: noteColor,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelY = placement != null ? y(placement.position) : centerY;
      final top = (labelY - 0.5 * textPainter.height)
          .clamp(0.0, math.max(0.0, size.height - textPainter.height))
          .toDouble();
      textPainter.paint(canvas, Offset(noteX + 1.5 * staffSpace, top));
    }

    canvas.restore();
  }

  void _drawAccidental({
    required Canvas canvas,
    required String symbol,
    required String fallbackSymbol,
    required double rightX,
    required double noteY,
    required double staffSpace,
    required Color color,
  }) {
    final fontSizePx = staffSpace / accidentalStaffSpacePerEm;
    // Try Gonville first with Unicode fallback in fontFamilyFallback
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: color,
          fontFamily: 'Gonville',
          fontSize: fontSizePx,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final baselineY = noteY + staffSpace;
    final top =
        baselineY -
        textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    textPainter.paint(canvas, Offset(rightX - textPainter.width, top));
  }

  void _drawOctaveClefMark({
    required Canvas canvas,
    required int octaves,
    required bool above,
    required double centerX,
    required double clefEdgeY,
    required double staffSpace,
    required Color color,
  }) {
    final markText = (7 * octaves + 1).toString();
    final textPainter = TextPainter(
      text: TextSpan(
        text: markText,
        style: TextStyle(
          color: color,
          fontSize: 1.4 * staffSpace,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final top = above ? clefEdgeY - textPainter.height : clefEdgeY;
    textPainter.paint(canvas, Offset(centerX - 0.5 * textPainter.width, top));
  }

  String _accidentalSymbol(NoteModifier mod) {
    switch (mod) {
      case NoteModifier.none:
        return '\uE107'; // Gonville natural
      case NoteModifier.sharp:
        return '\uE10C'; // Gonville sharp
      case NoteModifier.flat:
        return '\uE100'; // Gonville flat
      case NoteModifier.doubleSharp:
        return '\uE111'; // Gonville double sharp
      case NoteModifier.doubleFlat:
        return '\uE105'; // Gonville double flat
    }
  }

  String _accidentalFallbackSymbol(NoteModifier mod) {
    switch (mod) {
      case NoteModifier.none:
        return '♮';
      case NoteModifier.sharp:
        return '♯';
      case NoteModifier.flat:
        return '♭';
      case NoteModifier.doubleSharp:
        return '𝄪';
      case NoteModifier.doubleFlat:
        return '𝄫';
    }
  }

  @override
  bool shouldRepaint(covariant NoteStaffPainter oldDelegate) {
    return oldDelegate.note != note ||
        oldDelegate.tuningState != tuningState ||
        oldDelegate.staffClef != staffClef ||
        oldDelegate.keySignature != keySignature ||
        oldDelegate.staffColor != staffColor ||
        oldDelegate.inTuneColor != inTuneColor ||
        oldDelegate.outOfTuneColor != outOfTuneColor ||
        oldDelegate.unknownTuningColor != unknownTuningColor ||
        oldDelegate.borderColor != borderColor;
  }
}
