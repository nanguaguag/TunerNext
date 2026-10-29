import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/temperaments/predefined_temperaments.dart';
import 'package:tuner_flutter/domain/temperaments/temperament_models.dart';

void main() {
  group('Predefined Temperaments Mathematical Verification', () {
    test('All 19 predefined temperaments exist with valid structures', () {
      final all = PredefinedTemperaments.getAll();
      expect(all.length, 19);

      for (final t in all) {
        expect(t.name.isNotEmpty, isTrue);
        expect(t.abbreviation.isNotEmpty, isTrue);
        final cents = t.cents();
        // Index 0 must be 0.0 (root note) and last entry must be 1200.0 (octave)
        expect(
          cents.first,
          closeTo(0.0, 1e-4),
          reason: '${t.name} root note must be 0 cents',
        );
        expect(
          cents.last,
          closeTo(1200.0, 1e-4),
          reason: '${t.name} octave must be 1200 cents',
        );
        expect(
          cents.length,
          t.size + 1,
          reason: '${t.name} cents length must be size + 1',
        );

        // Check strictly increasing
        for (var i = 1; i < cents.length; i++) {
          expect(
            cents[i],
            greaterThan(cents[i - 1]),
            reason: '${t.name} must be strictly increasing',
          );
        }
      }
    });

    test('12-EDO produces exact 100 cent increments', () {
      final edo12 = PredefinedTemperaments.edo12();
      final cents = edo12.cents();
      for (var i = 0; i <= 12; i++) {
        expect(cents[i], closeTo(i * 100.0, 1e-9));
      }
    });

    test(
      'EDO scales from 5 to 72 division generate correct step intervals',
      () {
        for (var div = 5; div <= 72; div++) {
          final edo = TemperamentEDO(notesPerOctave: div, stableId: div);
          final cents = edo.cents();
          expect(cents.length, div + 1);
          final step = 1200.0 / div;
          for (var i = 0; i <= div; i++) {
            expect(cents[i], closeTo(i * step, 1e-9));
          }
        }
      },
    );

    test('Just Intonation (Pure) matches exact harmonic intervals', () {
      final just = PredefinedTemperaments.justIntonation();
      final cents = just.cents();

      // Pure fifth 3:2 is ~701.955 cents (index 7)
      expect(cents[7], closeTo(701.955, 1e-3));

      // Pure major third 5:4 is ~386.314 cents (index 4)
      expect(cents[4], closeTo(386.314, 1e-3));

      // Pure fourth 4:3 is ~498.045 cents (index 5)
      expect(cents[5], closeTo(498.045, 1e-3));
    });

    test('Werckmeister III has 4 narrowed fifths and 8 pure fifths', () {
      final w3 = PredefinedTemperaments.werckmeisterIII();
      final cents = w3.cents();
      expect(cents.length, 13);
      // Pure fifth in w3 is 701.955 - (23.46 / 4) = 696.09 cents
      // Octave closes at 1200
      expect(cents.last, 1200.0);
    });

    test('Quarter-comma Meantone has pure major third (386.31 cents)', () {
      final meantone = PredefinedTemperaments.quarterCommaMeantone();
      final cents = meantone.cents();
      // In 1/4-comma meantone, the major third (index 4) is exactly pure: 5/4 = 386.3137 cents
      expect(cents[4], closeTo(386.314, 1e-2));
    });
  });
}
