import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/stretch_tuning/predefined_stretch_tunings.dart';
import 'package:tuner_flutter/domain/stretch_tuning/stretch_tuning.dart';
import 'package:tuner_flutter/domain/tuning/musical_scale_frequencies.dart';

void main() {
  group('NoStretch StretchTuning Tests', () {
    final noStretch = PredefinedStretchTunings.noStretch();

    test('Zero stretch behavior on empty curve', () {
      expect(noStretch.isEmpty, isTrue);
      expect(noStretch.size, equals(0));
      expect(noStretch.isMonotonic, isTrue);

      for (final f in [27.5, 110.0, 440.0, 880.0, 4186.0]) {
        expect(noStretch.getStretchedFrequency(f, 440.0), equals(f));
        expect(noStretch.getStretchInCents(f, 440.0), equals(0.0));
      }
    });
  });

  group('Railsback Curve Domain Model Tests', () {
    final railsback = PredefinedStretchTunings.railsback();

    test('Structural properties of standard Railsback curve', () {
      expect(railsback.size, equals(32));
      expect(railsback.isMonotonic, isTrue);
      expect(railsback.stableId, equals(PredefinedStretchTunings.idRailsback));
      expect(railsback.unstretchedFrequencies.first, closeTo(28.409, 1e-3));
      expect(railsback.unstretchedFrequencies.last, closeTo(4201.967, 1e-3));
    });

    test('Reference pitch A440 has exactly zero stretch', () {
      expect(railsback.getStretchInCents(440.0, 440.0), closeTo(0.0, 1e-9));
      expect(
        railsback.getStretchedFrequency(440.0, 440.0),
        closeTo(440.0, 1e-9),
      );
    });

    test(
      'Bass flattening and treble sharpening conform to piano acoustics',
      () {
        // Bass A0 (~28.4 Hz): flattened by ~35.95 cents
        final bassCents = railsback.getStretchInCents(28.409, 440.0);
        expect(bassCents, closeTo(-35.949, 1e-2));
        final bassStretched = railsback.getStretchedFrequency(28.409, 440.0);
        expect(bassStretched, lessThan(28.409));
        expect(bassStretched, closeTo(27.825, 0.05));

        // Treble C8 (~4202 Hz): sharpened by ~32.07 cents
        final trebleCents = railsback.getStretchInCents(4201.967, 440.0);
        expect(trebleCents, closeTo(32.065, 1e-2));
        final trebleStretched = railsback.getStretchedFrequency(
          4201.967,
          440.0,
        );
        expect(trebleStretched, greaterThan(4201.967));
        expect(trebleStretched, closeTo(4280.26, 0.5));
      },
    );

    test('Continuous logarithmic interpolation between control points', () {
      // 100 Hz is between 87.792 Hz (-4.509 cents) and 103.146 Hz (-3.601 cents)
      final cents100 = railsback.getStretchInCents(100.0, 440.0);
      expect(cents100, greaterThan(-4.509));
      expect(cents100, lessThan(-3.601));

      // 1000 Hz is between 985.037 Hz (+2.156 cents) and 1157.318 Hz (+3.549 cents)
      final cents1000 = railsback.getStretchInCents(1000.0, 440.0);
      expect(cents1000, greaterThan(2.156));
      expect(cents1000, lessThan(3.549));
    });

    test('Logarithmic extrapolation beyond boundary control points', () {
      // Below lowest point (< 28.4 Hz)
      final subBassCents = railsback.getStretchInCents(20.0, 440.0);
      expect(subBassCents, lessThan(-35.949));

      // Above highest point (> 4202 Hz)
      final ultraTrebleCents = railsback.getStretchInCents(5000.0, 440.0);
      expect(ultraTrebleCents, greaterThan(32.065));
    });

    test('Alternate reference pitch normalization (A = 442 Hz)', () {
      expect(railsback.getStretchInCents(442.0, 442.0), closeTo(0.0, 1e-9));
      expect(
        railsback.getStretchedFrequency(442.0, 442.0),
        closeTo(442.0, 1e-9),
      );
    });
  });

  group('Interactive Control Point Editing (add, modify, remove)', () {
    test(
      'Add, modify, and remove control points maintain immutability and order',
      () {
        final curve = StretchTuning(
          unstretchedFrequencies: [100.0, 400.0],
          stretchInCents: [-5.0, 5.0],
        );

        expect(curve.size, equals(2));

        // 1. Add middle control point (200 Hz, 0 cents)
        final withAdded = curve.add(200.0, 0.0);
        expect(withAdded.size, equals(3));
        expect(withAdded.unstretchedFrequencies, equals([100.0, 200.0, 400.0]));
        expect(withAdded.stretchInCents, equals([-5.0, 0.0, 5.0]));
        expect(curve.size, equals(2)); // Original untouched

        // 2. Modify middle control point
        final key200 = withAdded.keys[1];
        final modified = withAdded.modify(200.0, 1.5, key200);
        expect(modified.stretchInCents[1], equals(1.5));

        // 3. Remove control point
        final removed = modified.remove(key200);
        expect(removed.size, equals(2));
        expect(removed.unstretchedFrequencies, equals([100.0, 400.0]));
      },
    );

    test('Monotonicity verification flags frequency inversions', () {
      final valid = StretchTuning(
        unstretchedFrequencies: [100.0, 200.0],
        stretchInCents: [0.0, 0.0],
      );
      expect(valid.isMonotonic, isTrue);

      // Severe stretch inversion: 200 Hz pulled down by -2400 cents (~50 Hz)
      final invalid = StretchTuning(
        unstretchedFrequencies: [100.0, 200.0],
        stretchInCents: [0.0, -2400.0],
      );
      expect(invalid.isMonotonic, isFalse);
    });
  });

  group('MusicalScaleFrequencies Stretch Tuning Integration', () {
    test('Railsback curve accurately stretches 12-EDO scale table', () {
      final railsback = PredefinedStretchTunings.railsback();
      final cents = List<double>.generate(13, (i) => i * 100.0);

      final stretchedScale = MusicalScaleFrequencies.create(
        cents: cents,
        referenceIndexWithinOctave: 9, // A4
        referenceFrequency: 440.0,
        frequencyMin: 20.0,
        frequencyMax: 5000.0,
        stretchFunction: (f) => railsback.getStretchedFrequency(f, 440.0),
      );

      final unstretchedScale = MusicalScaleFrequencies.create(
        cents: cents,
        referenceIndexWithinOctave: 9, // A4
        referenceFrequency: 440.0,
        frequencyMin: 20.0,
        frequencyMax: 5000.0,
      );

      // Reference note (A4, index 0) must remain strictly 440.0 Hz
      expect(stretchedScale[0], closeTo(440.0, 1e-5));
      expect(unstretchedScale[0], closeTo(440.0, 1e-5));

      // A0 (4 octaves down = index -48): stretched must be lower than unstretched
      expect(stretchedScale[-48], lessThan(unstretchedScale[-48]));

      // A7 (3 octaves up = index +36): stretched must be higher than unstretched
      expect(stretchedScale[36], greaterThan(unstretchedScale[36]));
    });
  });
}
