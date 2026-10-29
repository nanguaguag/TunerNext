import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/musical_scale/musical_scale_frequencies.dart';
import 'package:tuner_flutter/domain/stretchtuning/stretch_tuning.dart';
import 'package:tuner_flutter/domain/temperaments/temperament_models.dart';

void main() {
  group('MusicalScaleFrequencies Tests (matching Kotlin test baseline)', () {
    test(
      'Equal temperament 12-tone frequency generation and octave doubling',
      () {
        final cents = List<double>.generate(13, (i) => i * 100.0);
        const referenceFrequency = 440.0;
        const frequencyMin = 10.0;
        const frequencyMax = 16000.0;

        final frequencies = MusicalScaleFrequencies.create(
          cents: cents,
          referenceIndexWithinOctave: 0,
          referenceFrequency: referenceFrequency,
          frequencyMin: frequencyMin,
          frequencyMax: frequencyMax,
          stretchTuning: PredefinedStretchTunings.none(),
        );

        // Check octave doubling and halving
        expect(frequencies[0], closeTo(referenceFrequency, 1e-4));
        expect(
          frequencies[cents.length - 1],
          closeTo(2 * referenceFrequency, 1e-4),
        );
        expect(
          frequencies[-cents.length + 1],
          closeTo(referenceFrequency / 2, 1e-4),
        );

        // Check frequency bounds
        expect(
          frequencies[frequencies.indexStart],
          greaterThanOrEqualTo(frequencyMin),
        );
        expect(
          frequencies[frequencies.indexEnd - 1],
          lessThanOrEqualTo(frequencyMax),
        );

        // Check equal temperament 100-cent steps
        for (
          var i = frequencies.indexStart + 1;
          i < frequencies.indexEnd;
          i++
        ) {
          final prev = frequencies[i - 1];
          final curr = frequencies[i];
          final expected = centsToFrequency(100.0, prev);
          expect(curr, closeTo(expected, 1e-3));
        }

        // Check closest note index resolution
        expect(frequencies.getClosestFrequencyIndex(referenceFrequency), 0);
        expect(
          frequencies.getClosestFrequencyIndex(2 * referenceFrequency),
          12,
        );
        expect(
          frequencies.getClosestFrequencyIndex(frequencyMin),
          frequencies.indexStart,
        );
        expect(
          frequencies.getClosestFrequencyIndex(frequencyMax),
          frequencies.indexEnd - 1,
        );

        // Check fractional note indices
        expect(
          frequencies.getFrequencyIndex(referenceFrequency),
          closeTo(0.0, 1e-4),
        );
        final fPlus30Cents = centsToFrequency(30.0, referenceFrequency);
        expect(frequencies.getFrequencyIndex(fPlus30Cents), closeTo(0.3, 1e-2));

        final fMinus50Cents = centsToFrequency(-50.0, referenceFrequency);
        expect(
          frequencies.getFrequencyIndex(fMinus50Cents),
          closeTo(-0.5, 1e-2),
        );
      },
    );
  });
}
