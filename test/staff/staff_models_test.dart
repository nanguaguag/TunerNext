// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/staff/staff_models.dart';

void main() {
  group('Staff Models & Diatonic Math Tests', () {
    test('Diatonic staff positions align with Kotlin reference', () {
      expect(
        staffPosition(const MusicalNote(base: BaseNote.c, octave: 0)),
        equals(0),
      );
      expect(
        staffPosition(const MusicalNote(base: BaseNote.d, octave: 0)),
        equals(1),
      );
      expect(
        staffPosition(const MusicalNote(base: BaseNote.c, octave: 4)),
        equals(28),
      ); // Middle C
      expect(
        staffPosition(const MusicalNote(base: BaseNote.e, octave: 4)),
        equals(30),
      ); // Treble bottom line
      expect(
        staffPosition(const MusicalNote(base: BaseNote.g, octave: 2)),
        equals(18),
      ); // Bass bottom line
    });

    test('Staff layouts calculate correct clef lines and boundaries', () {
      final grand = StaffClef.grand.layout();
      expect(grand.staves.length, equals(2));
      expect(grand.staves.first.glyph, equals(ClefGlyph.treble));
      expect(grand.staves.last.glyph, equals(ClefGlyph.bass));
      expect(grand.writtenOctaves, equals(0));

      final tenor = StaffClef.tenor.layout();
      expect(tenor.staves.length, equals(1));
      expect(tenor.staves.first.glyph, equals(ClefGlyph.treble));
      expect(tenor.writtenOctaves, equals(1));

      final bass = StaffClef.bass.layout();
      expect(bass.staves.length, equals(1));
      expect(bass.staves.first.glyph, equals(ClefGlyph.bass));
      expect(bass.staves.first.clefLine, equals(24)); // F3
    });

    test('Ledger line generation matches standard musical practice', () {
      // Middle C on grand staff (position 28)
      final middleCLedgers = ledgerLinePositions(28, StaffClef.grand);
      expect(middleCLedgers, equals([28]));

      // Note within treble staff: G4 (pos 32)
      final g4Ledgers = ledgerLinePositions(32, StaffClef.treble);
      expect(g4Ledgers, isEmpty);

      // Note high above treble staff: A5 (pos 40, top line is F5 = 38)
      // Needs ledger line at 40
      final a5Ledgers = ledgerLinePositions(40, StaffClef.treble);
      expect(a5Ledgers, equals([40]));

      // Note very high above: C6 (pos 42) -> ledgers at 40, 42
      final c6Ledgers = ledgerLinePositions(42, StaffClef.treble);
      expect(c6Ledgers, equals([40, 42]));

      // Note below bass staff: E2 (pos 16, bottom line is G2 = 18)
      final e2Ledgers = ledgerLinePositions(16, StaffClef.bass);
      expect(e2Ledgers, equals([16]));
    });

    test('Staff placement transposes out-of-range notes with octave marks', () {
      // Middle C in treble clef: in range, no octave transposition
      final c4Placement = staffPlacement(28, StaffClef.treble);
      expect(c4Placement.position, equals(28));
      expect(c4Placement.octaveMark, equals(0));

      // Tenor clef shifts written pitch 1 octave up
      final tenorC4 = staffPlacement(28, StaffClef.tenor);
      expect(tenorC4.position, equals(35)); // 28 + 7
      expect(tenorC4.octaveMark, equals(1));

      // Extremely high note (e.g. C8 = pos 56) shifts down and marks octave
      final highC = staffPlacement(56, StaffClef.treble);
      expect(
        highC.position,
        lessThanOrEqualTo(StaffClef.treble.layout().highestPosition),
      );
      expect(highC.octaveMark, lessThan(0));
    });

    test('Key signature modifiers follow the cycle of fifths', () {
      // 1 sharp (G major / E minor) -> F#
      expect(keySignatureModifier(BaseNote.f, 1), equals(NoteModifier.sharp));
      expect(keySignatureModifier(BaseNote.c, 1), equals(NoteModifier.none));

      // 3 sharps (A major / F# minor) -> F#, C#, G#
      expect(keySignatureModifier(BaseNote.f, 3), equals(NoteModifier.sharp));
      expect(keySignatureModifier(BaseNote.c, 3), equals(NoteModifier.sharp));
      expect(keySignatureModifier(BaseNote.g, 3), equals(NoteModifier.sharp));
      expect(keySignatureModifier(BaseNote.d, 3), equals(NoteModifier.none));

      // 2 flats (Bb major / G minor) -> Bb, Eb
      expect(keySignatureModifier(BaseNote.b, -2), equals(NoteModifier.flat));
      expect(keySignatureModifier(BaseNote.e, -2), equals(NoteModifier.flat));
      expect(keySignatureModifier(BaseNote.a, -2), equals(NoteModifier.none));
    });

    test(
      'Note spelling respects active key signature and natural cancellation',
      () {
        // Note F# in G major (1 sharp): accidental hidden (in key signature)
        const fSharp = MusicalNote(
          base: BaseNote.f,
          modifier: NoteModifier.sharp,
          octave: 4,
        );
        final spelledInG = spellNote(fSharp, keySignature: 1);
        expect(spelledInG.showAccidental, isFalse);

        // Note F natural in G major: natural accidental required to cancel key signature
        const fNatural = MusicalNote(
          base: BaseNote.f,
          modifier: NoteModifier.none,
          octave: 4,
        );
        final spelledNaturalInG = spellNote(fNatural, keySignature: 1);
        expect(spelledNaturalInG.showAccidental, isTrue);

        // Note F# in C major (0 sharps): sharp accidental required
        final spelledInC = spellNote(fSharp, keySignature: 0);
        expect(spelledInC.showAccidental, isTrue);
      },
    );
  });
}
