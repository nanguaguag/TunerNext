// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import '../../domain/models/musical_note.dart';

// Positions on the staff are counted in diatonic steps:
// C0 = 0, D0 = 1, ..., C4 = 28, E4 = 30, G2 = 18.
// One diatonic step is half a staff space.
const int trebleBottomLine = 30; // E4
const int bassBottomLine = 18; // G2
const int staffHeight =
    8; // diatonic positions from bottom to top line (5 lines)
const int middleC = 28; // C4

/// Maximum number of ledger lines drawn above/below the staff;
/// notes beyond are drawn shifted by octaves and the clef gets an octave mark (8, 15, ...).
const int maxLedgerLines = 3;

/// Clef setup of the note staff.
enum StaffClef {
  /// Treble and bass staff bracketed together, as for piano.
  grand,
  treble,

  /// Treble clef with an 8 below; notes are written one octave above sounding pitch.
  tenor,
  bass,
}

enum ClefGlyph { treble, bass }

/// Single five-line staff with a clef.
class SingleStaff {
  const SingleStaff({required this.glyph, required this.bottomLine});

  final ClefGlyph glyph;
  final int bottomLine;

  int get topLine => bottomLine + staffHeight;

  /// Line to which the clef refers: G line for treble (bottom + 2), F line for bass (bottom + 6).
  int get clefLine =>
      glyph == ClefGlyph.treble ? bottomLine + 2 : bottomLine + 6;

  /// Offset of key signature positions relative to treble staff positions:
  /// bass staff uses the same pattern two octaves (14 diatonic steps) lower.
  int get keySignatureOffset => glyph == ClefGlyph.treble ? 0 : -14;
}

/// Layout of one or more staves in a clef setup.
class StaffLayout {
  StaffLayout({required this.staves, required this.writtenOctaves})
    : highestPosition = staves.first.topLine + 2 * maxLedgerLines,
      lowestPosition = staves.last.bottomLine - 2 * maxLedgerLines,
      centerPosition =
          ((staves.first.topLine + 2 * maxLedgerLines) +
              (staves.last.bottomLine - 2 * maxLedgerLines)) ~/
          2,
      staffSpacesVisible =
          ((staves.first.topLine + 2 * maxLedgerLines) -
                  (staves.last.bottomLine - 2 * maxLedgerLines)) /
              2 +
          2;

  final List<SingleStaff> staves;
  final int writtenOctaves;
  final int highestPosition;
  final int lowestPosition;
  final int centerPosition;
  final double staffSpacesVisible;
}

const SingleStaff trebleStaff = SingleStaff(
  glyph: ClefGlyph.treble,
  bottomLine: trebleBottomLine,
);
const SingleStaff bassStaff = SingleStaff(
  glyph: ClefGlyph.bass,
  bottomLine: bassBottomLine,
);

extension StaffClefLayout on StaffClef {
  StaffLayout layout() {
    switch (this) {
      case StaffClef.grand:
        return StaffLayout(
          staves: const [trebleStaff, bassStaff],
          writtenOctaves: 0,
        );
      case StaffClef.treble:
        return StaffLayout(staves: const [trebleStaff], writtenOctaves: 0);
      case StaffClef.tenor:
        return StaffLayout(staves: const [trebleStaff], writtenOctaves: 1);
      case StaffClef.bass:
        return StaffLayout(staves: const [bassStaff], writtenOctaves: 0);
    }
  }

  String get displayName {
    switch (this) {
      case StaffClef.grand:
        return 'Grand Staff';
      case StaffClef.treble:
        return 'Treble Clef';
      case StaffClef.tenor:
        return 'Tenor Clef';
      case StaffClef.bass:
        return 'Bass Clef';
    }
  }
}

/// Largest number of sharps or flats in a standard key signature.
const int maxKeySignature = 7;

const List<BaseNote> sharpOrder = [
  BaseNote.f,
  BaseNote.c,
  BaseNote.g,
  BaseNote.d,
  BaseNote.a,
  BaseNote.e,
  BaseNote.b,
];

final List<BaseNote> flatOrder = sharpOrder.reversed.toList();

// Staff positions of key signature accidentals on treble staff, in sharpOrder/flatOrder.
const List<int> trebleSharpPositions = [38, 35, 39, 36, 33, 37, 34];
const List<int> trebleFlatPositions = [34, 37, 33, 36, 32, 35, 31];
const double keySignatureSpacing = 1.1; // staff spaces per accidental

/// Returns modifier applied by key signature to a base note.
/// [keySignature]: Number of sharps (> 0) or flats (< 0).
NoteModifier keySignatureModifier(BaseNote base, int keySignature) {
  if (keySignature > 0 && sharpOrder.take(keySignature).any((n) => n == base)) {
    return NoteModifier.sharp;
  }
  if (keySignature < 0 && flatOrder.take(-keySignature).any((n) => n == base)) {
    return NoteModifier.flat;
  }
  return NoteModifier.none;
}

/// Note spelling representation on the staff.
class SpelledNote {
  const SpelledNote({required this.note, required this.showAccidental});

  final MusicalNote note;
  final bool showAccidental;
}

/// Determines the spelling of a note for staff rendering.
SpelledNote spellNote(
  MusicalNote note, {
  bool useEnharmonic = false,
  int? keySignature,
}) {
  final preferred = useEnharmonic ? _switchEnharmonic(note) : note;
  if (keySignature == null) {
    return SpelledNote(
      note: preferred,
      showAccidental: preferred.modifier != NoteModifier.none,
    );
  }

  final candidates = note.enharmonicBase == null
      ? [note]
      : [preferred, _switchEnharmonic(preferred)];

  MusicalNote? spelled;
  for (final c in candidates) {
    if (c.modifier == keySignatureModifier(c.base, keySignature)) {
      spelled = c;
      break;
    }
  }
  if (spelled == null) {
    for (final c in candidates) {
      if ((keySignature > 0 &&
              (c.modifier == NoteModifier.sharp ||
                  c.modifier == NoteModifier.doubleSharp)) ||
          (keySignature < 0 &&
              (c.modifier == NoteModifier.flat ||
                  c.modifier == NoteModifier.doubleFlat))) {
        spelled = c;
        break;
      }
    }
  }
  spelled ??= candidates.first;

  return SpelledNote(
    note: spelled,
    showAccidental:
        spelled.modifier != keySignatureModifier(spelled.base, keySignature),
  );
}

MusicalNote _switchEnharmonic(MusicalNote note) {
  if (note.enharmonicBase == null || note.enharmonicModifier == null) {
    return note;
  }
  return MusicalNote(
    base: note.enharmonicBase!,
    modifier: note.enharmonicModifier!,
    octave: note.octave,
    enharmonicBase: note.base,
    enharmonicModifier: note.modifier,
  );
}

/// Diatonic position of a note on the staff, with C0 = 0.
int staffPosition(MusicalNote note) {
  return 7 * note.octave + note.base.index;
}

/// Note placement on the staff, shifting octaves when out of visible range.
class StaffPlacement {
  const StaffPlacement({required this.position, required this.octaveMark});

  final int position;
  final int octaveMark;
}

/// Calculates note placement on the staff, shifting by octaves if out of drawn range.
StaffPlacement staffPlacement(int soundingPosition, StaffClef clef) {
  final layout = clef.layout();
  var position = soundingPosition + 7 * layout.writtenOctaves;
  var octaveMark = layout.writtenOctaves;

  while (position > layout.highestPosition) {
    position -= 7;
    octaveMark -= 1;
  }
  while (position < layout.lowestPosition) {
    position += 7;
    octaveMark += 1;
  }
  return StaffPlacement(position: position, octaveMark: octaveMark);
}

/// Positions of ledger lines needed for a note at [position].
List<int> ledgerLinePositions(int position, StaffClef clef) {
  final staves = clef.layout().staves;
  final top = staves.first.topLine;
  final bottom = staves.last.bottomLine;

  if (position >= top + 2) {
    final list = <int>[];
    for (var p = top + 2; p <= position; p += 2) {
      list.add(p);
    }
    return list;
  }

  if (position <= bottom - 2) {
    final list = <int>[];
    for (var p = bottom - 2; p >= position; p -= 2) {
      list.add(p);
    }
    return list;
  }

  // Middle C between treble and bass staves
  if (staves.length > 1 && position == middleC) {
    return [middleC];
  }

  return const [];
}

/// Staff positions of the key signature accidentals for each staff from top to bottom.
List<List<int>> keySignaturePositions(int keySignature, StaffClef clef) {
  final treblePositions = keySignature > 0
      ? trebleSharpPositions
      : trebleFlatPositions;
  final count = math.min(maxKeySignature, keySignature.abs());
  final result = <List<int>>[];

  for (final staff in clef.layout().staves) {
    final staffPositions = <int>[];
    for (var i = 0; i < count; i++) {
      staffPositions.add(treblePositions[i] + staff.keySignatureOffset);
    }
    result.add(staffPositions);
  }
  return result;
}
