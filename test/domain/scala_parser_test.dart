import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/scala/keyboard_mapping.dart';
import 'package:tuner_flutter/domain/scala/scala_note_helper.dart';
import 'package:tuner_flutter/domain/scala/scala_parser.dart';
import 'package:tuner_flutter/domain/scala/scala_scale.dart';
import 'package:tuner_flutter/domain/scala/scala_serializer.dart';
import 'package:tuner_flutter/domain/temperaments/custom_temperament.dart';
import 'package:tuner_flutter/domain/temperaments/rational_number.dart';

void main() {
  const parser = ScalaParser();
  const serializer = ScalaSerializer();

  group('ScalaParser .scl Parsing Tests', () {
    test('Standard 12-EDO cents scale parses correctly', () {
      const scl = '''
! 12edo.scl
!
12-tone Equal Temperament
12
!
100.0
200.0
300.0
400.0
500.0
600.0
700.0
800.0
900.0
1000.0
1100.0
1200.0
''';

      final result = parser.parseScl(scl);
      expect(result.isOk, isTrue);
      expect(result.scales.length, 1);

      final scale = result.scales.first;
      expect(scale.name, '12-tone Equal Temperament');
      expect(scale.count, 12);
      expect(scale.periodCents, 1200.0);
      expect(scale.fullCents.length, 13);
      expect(scale.fullCents[0], 0.0);
      expect(scale.fullCents[1], 100.0);
      expect(scale.fullCents[12], 1200.0);
    });

    test(
      'Just intonation pentatonic with ratios and note annotations matches Kotlin parity',
      () {
        const scl = '''
! pentatonic.scl
!
Pentatonic
5
!
 9/8    note=D
 5/4    note=E
 3/2    note=G
 5/3    note=A
 2/1    note=C
''';

        final result = parser.parseScl(scl);
        expect(result.isOk, isTrue);
        final scale = result.scales.single;

        expect(scale.count, 5);
        expect(scale.intervals.map((i) => i.isRatio).every((r) => r), isTrue);

        final expectedRationals = [
          RationalNumber(9, 8),
          RationalNumber(5, 4),
          RationalNumber(3, 2),
          RationalNumber(5, 3),
          RationalNumber(2, 1),
        ];
        expect(
          scale.intervals.map((i) => i.rational).toList(),
          expectedRationals,
        );

        final noteNames = scale.noteNames;
        expect(noteNames, isNotNull);
        expect(noteNames!.map((n) => n.base).toList(), [
          BaseNote.d,
          BaseNote.e,
          BaseNote.g,
          BaseNote.a,
          BaseNote.c,
        ]);

        final fullRationals = scale.fullRationalNumbers;
        expect(fullRationals, isNotNull);
        expect(fullRationals!.length, 6);
        expect(fullRationals[0], RationalNumber(1, 1));
        expect(fullRationals.last, RationalNumber(2, 1));
      },
    );

    test(
      'Pure integer ratio without slash is parsed with denominator 1 (e.g. "2" as 2/1)',
      () {
        const scl = '''
Harmonics test
3
!
3/2
5/3
2
''';

        final result = parser.parseScl(scl);
        expect(result.isOk, isTrue);
        final scale = result.scales.single;

        expect(scale.intervals[2].rational, RationalNumber(2, 1));
        expect(scale.intervals[2].ratio, 2.0);
        expect(scale.intervals[2].cents, closeTo(1200.0, 1e-4));
      },
    );

    test('Mixed cents and ratios parsed correctly', () {
      const scl = '''
Mixed Tuning
3
!
 100.0
 5/4
 1200.0
''';

      final result = parser.parseScl(scl);
      expect(result.isOk, isTrue);
      final scale = result.scales.single;

      expect(scale.intervals[0].isRatio, isFalse);
      expect(scale.intervals[0].cents, 100.0);
      expect(scale.intervals[1].isRatio, isTrue);
      expect(scale.intervals[1].rational, RationalNumber(5, 4));
      expect(scale.intervals[2].isRatio, isFalse);

      // Since interval 0 is cents, fullRationalNumbers must be null
      expect(scale.fullRationalNumbers, isNull);
      expect(scale.fullCents.length, 4);
    });

    test(
      'Metadata comments (! version, abbreviation, description) are properly extracted',
      () {
        const scl = '''
! version=2.4.0
! abbreviation=19-EDO
! description=19-tone equal temperament for Renaissance music
19-tone EDO
19
!
 63.158
 126.316
 189.474
 252.632
 315.789
 378.947
 442.105
 505.263
 568.421
 631.579
 694.737
 757.895
 821.053
 884.211
 947.368
 1010.526
 1073.684
 1136.842
 1200.000
''';

        final result = parser.parseScl(scl);
        expect(result.isOk, isTrue);
        final scale = result.scales.single;

        expect(scale.version, '2.4.0');
        expect(scale.abbreviation, '19-EDO');
        expect(
          scale.description,
          '19-tone equal temperament for Renaissance music',
        );
        expect(scale.name, '19-tone EDO');
        expect(scale.count, 19);
      },
    );

    test('Multiple scales in a single stream are parsed independently', () {
      const stream = '''
! First scale
Scale One
2
!
600.0
1200.0
!
! Second scale
Scale Two
3
!
400.0
800.0
1200.0
''';

      final result = parser.parseScl(stream);
      expect(result.isOk, isTrue);
      expect(result.scales.length, 2);

      expect(result.scales[0].name, 'Scale One');
      expect(result.scales[0].count, 2);
      expect(result.scales[1].name, 'Scale Two');
      expect(result.scales[1].count, 3);
    });

    test(
      'UTF-8 BOM and Windows CRLF line endings are stripped transparently',
      () {
        const bomScl = '\uFEFF! bom.scl\r\nBOM Scale\r\n1\r\n!\r\n1200.0\r\n';

        final result = parser.parseScl(bomScl);
        expect(result.isOk, isTrue);
        expect(result.scales.single.name, 'BOM Scale');
        expect(result.scales.single.count, 1);
      },
    );

    test(
      'Enharmonic notes and octave offset strings are parsed accurately',
      () {
        expect(ScalaNoteHelper.parseNoteAssignment('note=C#'), isNotNull);
        final cSharp = ScalaNoteHelper.parseNoteAssignment('note=C#')!;
        expect(cSharp.base, BaseNote.c);
        expect(cSharp.modifier, NoteModifier.sharp);

        final enharmonic = ScalaNoteHelper.parseNoteAssignment('note=F#/Gb')!;
        expect(enharmonic.base, BaseNote.f);
        expect(enharmonic.modifier, NoteModifier.sharp);
        expect(enharmonic.enharmonicBase, BaseNote.g);
        expect(enharmonic.enharmonicModifier, NoteModifier.flat);

        final octaveOffset = ScalaNoteHelper.parseNoteAssignment('note=D+1')!;
        expect(octaveOffset.base, BaseNote.d);
        expect(octaveOffset.octave, 1);

        final formatted = ScalaNoteHelper.formatNoteForScala(enharmonic);
        expect(formatted, 'F#/Gb');
      },
    );
  });

  group('ScalaParser Error Handling and Validation', () {
    test('Empty file or comments-only file returns Empty status', () {
      expect(parser.parseScl('').isEmpty, isTrue);
      expect(parser.parseScl('   \n\n\t  ').isEmpty, isTrue);
      expect(
        parser.parseScl('! Just a comment line\n! Another comment').isEmpty,
        isTrue,
      );
    });

    test(
      'Invalid scale size string flags error and returns Invalid status',
      () {
        const badSize = '''
Bad Scale
not_a_number
!
100.0
''';
        final result = parser.parseScl(badSize);
        expect(result.isInvalid, isTrue);
        expect(result.errors.first, contains('Invalid scale size'));
      },
    );

    test('Truncated file with fewer lines than declared count flags error', () {
      const truncated = '''
Truncated
5
!
100.0
200.0
''';
      final result = parser.parseScl(truncated);
      expect(result.isInvalid, isTrue);
      expect(result.errors.first, contains('Truncated file'));
    });

    test('Division by zero in ratio flags error', () {
      const zeroDenom = '''
Zero Denom
1
!
3/0
''';
      final result = parser.parseScl(zeroDenom);
      expect(result.isInvalid, isTrue);
      expect(result.errors.first, contains('zero denominator'));
    });
  });

  group('ScalaSerializer Round-trip Tests', () {
    test(
      'SCL serialization and re-parsing preserves all interval and note data',
      () {
        final original = ScalaScale(
          name: 'Werckmeister Test',
          abbreviation: 'Werck',
          description: 'Andreas Werckmeister 1691 tuning',
          version: '1.0',
          intervals: [
            ScalaPitchInterval.fromCents(
              90.225,
              note: const MusicalNote(
                base: BaseNote.c,
                modifier: NoteModifier.sharp,
                octave: 4,
              ),
            ),
            ScalaPitchInterval.fromRatio(
              9,
              8,
              note: const MusicalNote(base: BaseNote.d, octave: 4),
            ),
            ScalaPitchInterval.fromRatio(
              2,
              1,
              note: const MusicalNote(base: BaseNote.c, octave: 5),
            ),
          ],
        );

        final exportedScl = serializer.serializeScl(original);
        final parseResult = parser.parseScl(exportedScl);

        expect(parseResult.isOk, isTrue);
        final reloaded = parseResult.scales.single;

        expect(reloaded.name, original.name);
        expect(reloaded.abbreviation, original.abbreviation);
        expect(reloaded.description, original.description);
        expect(reloaded.count, 3);
        expect(reloaded.intervals[0].cents, closeTo(90.225, 1e-3));
        expect(reloaded.intervals[0].note?.base, BaseNote.c);
        expect(reloaded.intervals[1].rational, RationalNumber(9, 8));
        expect(reloaded.intervals[2].rational, RationalNumber(2, 1));
      },
    );
  });

  group('Huygens-Fokker Keyboard Mapping (.kbm) Tests', () {
    test('Standard 12-key mapping parses accurately', () {
      const kbm = '''
! Standard 12-key mapping
! Size of map:
12
! First MIDI note:
0
! Last MIDI note:
127
! Middle note (C4):
60
! Reference note (A4):
69
! Reference frequency:
440.0
! Scale degree for octave:
12
! Mapping keys:
0
1
2
3
4
5
6
7
8
9
10
11
''';

      final mapping = parser.parseKbm(kbm);
      expect(mapping.mapSize, 12);
      expect(mapping.firstMidiNote, 0);
      expect(mapping.lastMidiNote, 127);
      expect(mapping.middleMidiNote, 60);
      expect(mapping.referenceMidiNote, 69);
      expect(mapping.referenceFrequency, 440.0);
      expect(mapping.scaleDegreeForOctave, 12);
      expect(mapping.keyPattern, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
    });

    test('Unmapped key "x" parses as -1', () {
      const kbmWithSkip = '''
! Mapping with unmapped key
3
0
127
60
69
442.0
3
0
x
2
''';
      final mapping = parser.parseKbm(kbmWithSkip);
      expect(mapping.mapSize, 3);
      expect(mapping.referenceFrequency, 442.0);
      expect(mapping.keyPattern, [0, -1, 2]);
    });

    test('KBM serialization round-trips cleanly', () {
      final original = KeyboardMapping.standardForScale(
        7,
        middleMidiNote: 62,
        referenceMidiNote: 69,
        referenceFrequency: 415.0,
      );

      final exported = serializer.serializeKbm(original);
      final reloaded = parser.parseKbm(exported);

      expect(reloaded.mapSize, 7);
      expect(reloaded.middleMidiNote, 62);
      expect(reloaded.referenceMidiNote, 69);
      expect(reloaded.referenceFrequency, 415.0);
      expect(reloaded.keyPattern, original.keyPattern);
    });
  });

  group('CustomTemperament Integration Tests', () {
    test(
      'CustomTemperament built from ScalaScale integrates with MusicalScaleFrequencies',
      () {
        const scl = '''
Ptolemy Just Intonation
7
!
9/8
5/4
4/3
3/2
5/3
15/8
2/1
''';

        final result = parser.parseScl(scl);
        expect(result.isOk, isTrue);

        final customTemperament = CustomTemperament.fromScalaScale(
          result.scales.single,
        );
        expect(customTemperament.size, 7);
        expect(customTemperament.name, 'Ptolemy Just Intonation');
        expect(customTemperament.rationalNumbers, isNotNull);
        expect(customTemperament.cents.length, 8);
        expect(customTemperament.cents[0], 0.0);
        expect(customTemperament.cents[7], closeTo(1200.0, 1e-4));

        // Build musical scale frequencies
        final scaleFrequencies = customTemperament.toScaleFrequencies(
          referenceFrequency: 440.0,
        );
        expect(scaleFrequencies.length, greaterThan(0));

        // In a 7-tone octave scale, degree offset +7 is exactly one octave above degree 0
        final f0 = scaleFrequencies[0];
        final f7 = scaleFrequencies[7];
        expect(f0, closeTo(440.0, 1e-4));
        expect(f7 / f0, closeTo(2.0, 1e-4));
      },
    );
  });
}
