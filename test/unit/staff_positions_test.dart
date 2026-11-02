import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/staff/staff_clef.dart';

void main() {
  group('StaffPositions', () {
    test('calculates correct diatonic step positions', () {
      // Middle C = C4 = position 28
      const c4 = MusicalNote(base: BaseNote.c, octave: 4);
      expect(StaffPositions.diatonicPosition(c4), equals(28));

      // E4 = bottom line of treble staff = position 30
      const e4 = MusicalNote(base: BaseNote.e, octave: 4);
      expect(StaffPositions.diatonicPosition(e4), equals(30));

      // A4 = position 33
      const a4 = MusicalNote(base: BaseNote.a, octave: 4);
      expect(StaffPositions.diatonicPosition(a4), equals(33));

      // G2 = bottom line of bass staff = position 18
      const g2 = MusicalNote(base: BaseNote.g, octave: 2);
      expect(StaffPositions.diatonicPosition(g2), equals(18));
    });
  });
}
