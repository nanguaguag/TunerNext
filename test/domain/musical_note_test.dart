import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';

void main() {
  group('MusicalNote Domain Model Tests', () {
    test('A4 frequency representation and name formatting', () {
      const note = MusicalNote(base: BaseNote.a, octave: 4);
      expect(note.name, equals('A4'));
      expect(note.pitchClassName, equals('A'));
    });

    test('Accidentals formatting with Unicode symbols', () {
      const sharpNote = MusicalNote(
        base: BaseNote.c,
        modifier: NoteModifier.sharp,
        octave: 4,
        enharmonicBase: BaseNote.d,
        enharmonicModifier: NoteModifier.flat,
      );
      expect(sharpNote.name, equals('C♯4'));
      expect(sharpNote.pitchClassName, equals('C♯'));

      const flatNote = MusicalNote(
        base: BaseNote.d,
        modifier: NoteModifier.flat,
        octave: 4,
      );
      expect(sharpNote.matches(flatNote), isTrue);
    });

    test('Equality and Octave distinction', () {
      const a4 = MusicalNote(base: BaseNote.a, octave: 4);
      const a5 = MusicalNote(base: BaseNote.a, octave: 5);
      expect(a4 == a5, isFalse);
      expect(a4.matches(a5, ignoreOctave: true), isTrue);
    });
  });
}
