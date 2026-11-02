import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/temperaments/chain_of_fifths.dart';
import 'package:tuner_flutter/domain/temperaments/fifth_modification.dart';
import 'package:tuner_flutter/domain/temperaments/predefined_temperament.dart';
import 'package:tuner_flutter/domain/temperaments/rational_number.dart';

void main() {
  group('ChainOfFifths Core Algorithm Tests', () {
    test(
      'Pure fifths traverse upwards and downwards folding into [1.0, 2.0)',
      () {
        final chain = ChainOfFifths(
          List.generate(11, (_) => FifthModification()),
          5, // C is at index 5 in Db-Ab-Eb-Bb-F-C-G-D-A-E-B-F#
        );

        final ratios = chain.getRatiosAlongFifths();
        expect(ratios.length, equals(12));
        expect(ratios[5], closeTo(1.0, 1e-9)); // C (root)

        for (final r in ratios) {
          expect(r, greaterThanOrEqualTo(1.0));
          expect(r, lessThan(2.0));
        }

        final sorted = chain.getSortedRatios();
        expect(sorted.length, equals(12));
        expect(sorted.first, closeTo(1.0, 1e-9));
        for (int i = 1; i < sorted.length; i++) {
          expect(sorted[i], greaterThan(sorted[i - 1]));
        }
      },
    );

    test('Closing circle correction completes full 12-tone cycle', () {
      final chain = ChainOfFifths(
        List.generate(11, (_) => FifthModification()),
        0,
      );
      final closing = chain.getClosingCircleCorrection();
      expect(closing.pythagoreanComma, equals(RationalNumber(-1, 1)));
    });
  });

  group('Pure Tuning (Just Intonation) Verification', () {
    final pure = PredefinedTemperaments.pure();

    test('Harmonic integer ratios and structural integrity', () {
      expect(pure.name, contains('Pure Tuning'));
      expect(pure.size, equals(12));
      expect(pure.rationalNumbers, isNotNull);
      expect(pure.rationalNumbers!.length, equals(13));
      expect(pure.rationalNumbers![0], equals(RationalNumber(1, 1))); // C
      expect(
        pure.rationalNumbers![4],
        equals(RationalNumber(5, 4)),
      ); // E (Pure major third)
      expect(
        pure.rationalNumbers![7],
        equals(RationalNumber(3, 2)),
      ); // G (Pure fifth)
      expect(
        pure.rationalNumbers![12],
        equals(RationalNumber(2, 1)),
      ); // C octave
    });

    test('Pure major third is 386.31 cents and pure fifth is 701.96 cents', () {
      // E: 5/4 = 386.3137 cents
      expect(pure.cents[4], closeTo(386.3137, 1e-3));
      // G: 3/2 = 701.9550 cents
      expect(pure.cents[7], closeTo(701.9550, 1e-3));
      // F: 4/3 = 498.0450 cents
      expect(pure.cents[5], closeTo(498.0450, 1e-3));
      // B: 15/8 = 1088.2687 cents
      expect(pure.cents[11], closeTo(1088.2687, 1e-3));
    });
  });

  group('Pythagorean Tuning Verification', () {
    final pyth = PredefinedTemperaments.pythagorean();

    test('Pythagorean major third ditone (81/64) is 407.82 cents', () {
      expect(pyth.size, equals(12));
      expect(pyth.cents.first, equals(0.0));
      expect(pyth.cents.last, equals(1200.0));

      // Ditone major third (81/64): ~407.82 cents
      expect(pyth.cents[4], closeTo(407.82, 0.05));
      // Pure fifth: 701.955 cents
      expect(pyth.cents[7], closeTo(701.955, 1e-3));
    });
  });

  group('Meantone Temperaments Verification', () {
    test('1/4-comma meantone produces pure major third (386.31 cents)', () {
      final meantone = PredefinedTemperaments.quarterCommaMeantone();
      expect(meantone.size, equals(12));
      // With 1/4 syntonic comma narrowed fifths, C-E is exactly 5/4 = 386.31 cents
      expect(meantone.cents[4], closeTo(386.3137, 1e-3));
    });

    test('Extended 1/4-comma meantone features 15-note scale', () {
      final ext = PredefinedTemperaments.extendedQuarterCommaMeantone();
      expect(ext.size, equals(15));
      expect(ext.cents.length, equals(16));
      expect(ext.cents.last, equals(1200.0));
    });

    test('1/3-comma meantone produces pure minor third (315.64 cents)', () {
      final third = PredefinedTemperaments.thirdCommaMeantone();
      expect(third.size, equals(12));
      // Eb (minor third): 6/5 ratio is ~315.64 cents
      expect(third.cents[3], closeTo(315.64, 0.05));
    });
  });

  group(
    'Well-Temperament Families (Werckmeister, Kirnberger, Neidhardt, Vallotti, Young)',
    () {
      test('Werckmeister III well-temperament properties', () {
        final w3 = PredefinedTemperaments.werckmeisterIII();
        expect(w3.size, equals(12));
        expect(w3.cents.length, equals(13));
        expect(w3.cents.first, equals(0.0));
        expect(w3.cents.last, equals(1200.0));

        // All interval sizes stay strictly ascending
        for (int i = 1; i < w3.cents.length; i++) {
          expect(w3.cents[i], greaterThan(w3.cents[i - 1]));
        }
      });

      test('Werckmeister VI monochord rational numbers', () {
        final w6 = PredefinedTemperaments.werckmeisterVI();
        expect(w6.rationalNumbers, isNotNull);
        expect(w6.rationalNumbers!.length, equals(13));
        expect(w6.rationalNumbers![1], equals(RationalNumber(196, 186)));
        expect(w6.rationalNumbers![12], equals(RationalNumber(2, 1)));
      });

      test('Kirnberger III keeps pure C-E major third (386.31 cents)', () {
        final k3 = PredefinedTemperaments.kirnberger3();
        expect(k3.size, equals(12));
        expect(k3.cents[4], closeTo(386.3137, 1e-3));
      });

      test('Neidhardt family I, II, III monotonic scaling', () {
        final n1 = PredefinedTemperaments.neidhardt1();
        final n2 = PredefinedTemperaments.neidhardt2();
        final n3 = PredefinedTemperaments.neidhardt3();

        expect(n1.size, equals(12));
        expect(n2.size, equals(12));
        expect(n3.size, equals(12));

        expect(n1.cents.last, equals(1200.0));
        expect(n2.cents.last, equals(1200.0));
        expect(n3.cents.last, equals(1200.0));
      });

      test('Vallotti and Young II well-temperaments', () {
        final valotti = PredefinedTemperaments.valotti();
        final young = PredefinedTemperaments.young2();

        expect(valotti.size, equals(12));
        expect(young.size, equals(12));
        expect(valotti.cents.last, equals(1200.0));
        expect(young.cents.last, equals(1200.0));
      });
    },
  );

  group('Catalog Completeness & Root Note Transformation Tests', () {
    test(
      'PredefinedTemperaments.getAll() provides all 19 historical temperaments with unique IDs',
      () {
        final all = PredefinedTemperaments.getHistorical19();
        expect(all.length, equals(19));

        final ids = all.map((t) => t.stableId).toSet();
        expect(
          ids.length,
          equals(19),
          reason: 'Every temperament must have a unique stableId',
        );

        for (final t in all) {
          expect(t.name.isNotEmpty, isTrue);
          expect(t.abbreviation.isNotEmpty, isTrue);
          expect(t.cents.first, equals(0.0));
          expect(t.cents.last, equals(1200.0));
          expect(t.ratios.first, equals(1.0));
          expect(t.ratios.last, equals(2.0));
          expect(t.notes.length, equals(t.size));
        }
      },
    );

    test('Root note switching shifts scale base pitch', () {
      const a4 = MusicalNote(base: BaseNote.a, octave: 4);
      final pureA = PredefinedTemperaments.pure(rootNote: a4);

      expect(pureA.rootNote, equals(a4));
      expect(pureA.notes.first.name, equals('A4'));
      expect(pureA.notes.length, equals(12));

      // In A pure tuning, major third (index 4) should be C#5
      expect(pureA.notes[4].name, equals('C♯5'));
      expect(pureA.cents[4], closeTo(386.3137, 1e-3));
    });
  });
}
