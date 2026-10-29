import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/post_processing/outlier_removing_smoother.dart';

void main() {
  group('OutlierRemovingSmoother Tests', () {
    test('Moving average convergence on steady pitch', () {
      final smoother = OutlierRemovingSmoother(
        size: 5,
        minValue: 20.0,
        maxValue: 2000.0,
        relativeDeviationToBeAnOutlier: 0.1,
        minNumValuesForValidMean: 2,
      );

      // Feed sequence of 440 Hz
      expect(
        smoother.smooth(440.0),
        equals(0.0),
      ); // 1st sample, < minNumValues (2)
      expect(
        smoother.smooth(440.0),
        closeTo(440.0, 1e-4),
      ); // 2nd sample reaches valid mean
      expect(smoother.smooth(440.0), closeTo(440.0, 1e-4));
    });

    test('Single outlier does not contaminate smoothed mean', () {
      final smoother = OutlierRemovingSmoother(
        size: 5,
        minValue: 20.0,
        maxValue: 2000.0,
        relativeDeviationToBeAnOutlier: 0.1,
        minNumValuesForValidMean: 2,
      );

      smoother.smooth(440.0);
      smoother.smooth(440.0);
      expect(smoother.smoothedValue, closeTo(440.0, 1e-4));

      // Introduce a 600 Hz outlier (> 10% deviation)
      final out = smoother.smooth(600.0);
      // Smoother rejects the outlier, returning 0.0 or keeping previous valid buffer
      expect(out, equals(0.0));

      // Next steady value resumes smooth mean
      expect(smoother.smooth(440.0), closeTo(440.0, 1e-4));
    });
  });
}
