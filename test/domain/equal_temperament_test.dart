import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/temperaments/equal_temperament.dart';
import 'package:tuner_flutter/domain/temperaments/fifth_modification.dart';
import 'package:tuner_flutter/domain/temperaments/rational_number.dart';
import 'package:tuner_flutter/domain/temperaments/temperament_circle_of_fifths.dart';

void main() {
  group('RationalNumber Exact Arithmetic Tests', () {
    test('Constructs, reduces to lowest terms, and handles negative signs', () {
      final r1 = RationalNumber(4, 8);
      expect(r1.numerator, equals(1));
      expect(r1.denominator, equals(2));
      expect(r1.toDouble(), equals(0.5));

      final r2 = RationalNumber(-6, -9);
      expect(r2.numerator, equals(2));
      expect(r2.denominator, equals(3));

      final r3 = RationalNumber(5, -10);
      expect(r3.numerator, equals(-1));
      expect(r3.denominator, equals(2));

      expect(() => RationalNumber(1, 0), throwsArgumentError);
    });

    test('Arithmetic operations (+, -, *, /, pow)', () {
      final half = RationalNumber(1, 2);
      final third = RationalNumber(1, 3);

      expect(half + third, equals(RationalNumber(5, 6)));
      expect(half - third, equals(RationalNumber(1, 6)));
      expect(half * third, equals(RationalNumber(1, 6)));
      expect(half / third, equals(RationalNumber(3, 2)));
      expect(-half, equals(RationalNumber(-1, 2)));

      expect(() => half / RationalNumber.zero, throwsArgumentError);

      final threeHalf = RationalNumber(3, 2);
      expect(threeHalf.pow(0), equals(RationalNumber.one));
      expect(threeHalf.pow(2), equals(RationalNumber(9, 4)));
      expect(threeHalf.pow(-1), equals(RationalNumber(2, 3)));
    });

    test('Comparisons, equality and gcd', () {
      expect(RationalNumber(2, 4) == RationalNumber(1, 2), isTrue);
      expect(RationalNumber(1, 3) < RationalNumber(1, 2), isTrue);
      expect(RationalNumber(3, 4) > RationalNumber(2, 3), isTrue);
      expect(RationalNumber.gcd(54, 24), equals(6));
      expect(RationalNumber.gcd(-54, 24), equals(6));
    });
  });

  group('FifthModification and Comma Identity Tests', () {
    test('Historical comma ratios', () {
      expect(
        FifthModification.pythagoreanCommaRatio.toDouble(),
        closeTo(531441 / 524288, 1e-9),
      );
      expect(
        FifthModification.syntonicCommaRatio.toDouble(),
        closeTo(81 / 80, 1e-9),
      );
      expect(
        FifthModification.schismaRatio.toDouble(),
        closeTo(32805 / 32768, 1e-9),
      );

      // Check acoustic identity: 1 Pythagorean comma = 1 Syntonic comma * 1 Schisma
      final product =
          FifthModification.syntonicCommaRatio.toDouble() *
          FifthModification.schismaRatio.toDouble();
      expect(
        product,
        closeTo(FifthModification.pythagoreanCommaRatio.toDouble(), 1e-9),
      );
    });

    test('Comma simplification rule: SC + S reduces to PC', () {
      final mod = FifthModification(
        syntonicComma: RationalNumber(1, 4),
        schisma: RationalNumber(1, 4),
      );
      expect(mod.pythagoreanComma, equals(RationalNumber(1, 4)));
      expect(mod.syntonicComma.isZero, isTrue);
      expect(mod.schisma.isZero, isTrue);
    });

    test('Multiplicative ratio evaluation', () {
      final empty = FifthModification();
      expect(empty.toDouble(), closeTo(1.0, 1e-9));

      final onePC = FifthModification(pythagoreanComma: RationalNumber.one);
      expect(onePC.toDouble(), closeTo(531441 / 524288, 1e-7));

      final negTwelvePC = FifthModification(
        pythagoreanComma: RationalNumber(-1, 12),
      );
      final expectedRatio = math.pow(524288 / 531441, 1.0 / 12.0);
      expect(negTwelvePC.toDouble(), closeTo(expectedRatio, 1e-7));
    });
  });

  group('TemperamentCircleOfFifths 12-EDO Tests', () {
    test(
      'circleOfFifthsEDO12 generates equal temperament chromatic ratios',
      () {
        final ratios = TemperamentCircleOfFifths.edo12.getRatios();
        expect(ratios.length, equals(13));
        expect(ratios[0], closeTo(1.0, 1e-9)); // C
        expect(ratios[12], closeTo(2.0, 1e-6)); // C octave

        for (int i = 0; i < 13; i++) {
          final expectedRatio = math.pow(2.0, i / 12.0);
          expect(
            ratios[i],
            closeTo(expectedRatio, 1e-5),
            reason: 'Chromatic step $i',
          );
        }
      },
    );
  });

  group('EqualTemperament (12-EDO) Domain Model Tests', () {
    final temperament = EqualTemperament.edo12();

    test('Metadata and structural parameters', () {
      expect(temperament.name, equals('12-Tone Equal Temperament'));
      expect(temperament.abbreviation, equals('12-EDO'));
      expect(temperament.stableId, equals(1));
      expect(temperament.size, equals(12));
      expect(temperament.equalOctaveDivision, equals(12));
      expect(temperament.rationalNumbers, isNull);
      expect(temperament.circleOfFifths, isNotNull);
    });

    test('Cents scale distribution is strictly 100 cents per semitone', () {
      expect(temperament.cents.length, equals(13));
      expect(temperament.cents.first, equals(0.0));
      expect(temperament.cents.last, equals(1200.0));

      for (int i = 0; i <= 12; i++) {
        expect(temperament.cents[i], equals(i * 100.0));
      }
    });

    test(
      'Frequency ratios match powers of 2^(1/12) and octave ratio is 2.0',
      () {
        expect(temperament.ratios.length, equals(13));
        expect(temperament.ratios[0], closeTo(1.0, 1e-9));
        expect(temperament.ratios[12], closeTo(2.0, 1e-9));

        for (int i = 0; i <= 12; i++) {
          expect(temperament.ratios[i], closeTo(math.pow(2.0, i / 12.0), 1e-9));
        }
      },
    );

    test(
      'Default scale notes start from C4 and form correct chromatic scale',
      () {
        expect(temperament.notes.length, equals(12));
        expect(temperament.notes[0].name, equals('C4'));
        expect(temperament.notes[1].name, equals('C♯4'));
        expect(temperament.notes[2].name, equals('D4'));
        expect(temperament.notes[3].name, equals('D♯4'));
        expect(temperament.notes[4].name, equals('E4'));
        expect(temperament.notes[5].name, equals('F4'));
        expect(temperament.notes[6].name, equals('F♯4'));
        expect(temperament.notes[7].name, equals('G4'));
        expect(temperament.notes[8].name, equals('G♯4'));
        expect(temperament.notes[9].name, equals('A4'));
        expect(temperament.notes[10].name, equals('A♯4'));
        expect(temperament.notes[11].name, equals('B4'));
      },
    );

    test('Root note custom starting offset', () {
      const a4 = MusicalNote(base: BaseNote.a, octave: 4);
      final aScale = EqualTemperament.edo12(rootNote: a4);
      expect(aScale.notes.first.name, equals('A4'));
      expect(aScale.notes[1].name, equals('A♯4'));
      expect(aScale.notes[2].name, equals('B4'));
      expect(aScale.notes[3].name, equals('C5'));
    });

    test(
      'toScaleFrequencies creates seamless MusicalScaleFrequencies with A440',
      () {
        final scaleFreqs = temperament.toScaleFrequencies(
          referenceFrequency: 440.0,
        );

        // A4 is at index 9 in default C-based scale, so relative offset 0 is 440Hz
        expect(scaleFreqs[0], closeTo(440.0, 1e-5));
        expect(scaleFreqs[12], closeTo(880.0, 1e-4));
        expect(scaleFreqs[-12], closeTo(220.0, 1e-4));
      },
    );
  });

  group('Microtonal Equal Division (EDO 19, 24, 31) Tests', () {
    test('19-EDO step distribution', () {
      final edo19 = EqualTemperament(
        name: '19-Tone Equal Temperament',
        abbreviation: '19-EDO',
        description: '19 equal divisions of the octave',
        stableId: 19,
        rootNote: const MusicalNote(base: BaseNote.c, octave: 4),
        notesPerOctave: 19,
      );

      expect(edo19.size, equals(19));
      expect(edo19.cents.length, equals(20));
      expect(edo19.cents.last, equals(1200.0));
      expect(edo19.cents[1], closeTo(1200.0 / 19.0, 1e-6));
      expect(edo19.circleOfFifths, isNull);
    });

    test('24-EDO quarter-tone step distribution', () {
      final edo24 = EqualTemperament(
        name: '24-Tone Equal Temperament',
        abbreviation: '24-EDO',
        description: 'Quarter tone scale',
        stableId: 24,
        rootNote: const MusicalNote(base: BaseNote.c, octave: 4),
        notesPerOctave: 24,
      );

      expect(edo24.size, equals(24));
      expect(edo24.cents[1], closeTo(50.0, 1e-6)); // 50 cents per quarter tone
    });
  });
}
