import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/filters/outlier_removing_smoother.dart';

void main() {
  group('OutlierRemovingSmoothingBuffer Tests (Kotlin Baseline Parity)', () {
    test('Buffer constraint verification and outlier clearance', () {
      final buffer = OutlierRemovingSmoothingBuffer(
        maxSize: 3,
        minValue: 10.0,
        maxValue: 100.0,
        maxRelativeDeviation: 0.3,
        maxNumSuccessiveOutliers: 2,
      );

      // Out-of-bounds check 1 (value > maxValue)
      var success = buffer.append(150.0);
      expect(success, isFalse);
      expect(buffer.mean, equals(0.0));
      expect(buffer.numSuccessiveOutliers, equals(1));
      expect(buffer.size, equals(0));

      // Out-of-bounds check 2 (value < minValue)
      success = buffer.append(1.0);
      expect(success, isFalse);
      expect(buffer.mean, equals(0.0));
      expect(buffer.numSuccessiveOutliers, equals(2));
      expect(buffer.size, equals(0));

      // Add first valid value 50.0
      success = buffer.append(50.0);
      expect(success, isTrue);
      expect(buffer.mean, closeTo(50.0, 1e-6));
      expect(buffer.numSuccessiveOutliers, equals(0));
      expect(buffer.size, equals(1));

      // Mean of 50, 60 -> 55
      success = buffer.append(60.0);
      expect(success, isTrue);
      expect(buffer.mean, closeTo(55.0, 1e-6));
      expect(buffer.numSuccessiveOutliers, equals(0));
      expect(buffer.size, equals(2));

      // Mean of 50, 60, 55 -> 55
      success = buffer.append(55.0);
      expect(success, isTrue);
      expect(buffer.mean, closeTo(55.0, 1e-6));
      expect(buffer.numSuccessiveOutliers, equals(0));
      expect(buffer.size, equals(3));

      // Buffer full, wraps around: mean of 60, 55, 65 -> 60
      success = buffer.append(65.0);
      expect(success, isTrue);
      expect(buffer.mean, closeTo(60.0, 1e-6));
      expect(buffer.numSuccessiveOutliers, equals(0));
      expect(buffer.size, equals(3));

      // Mean of 55, 65, 61
      success = buffer.append(61.0);
      expect(success, isTrue);
      expect(buffer.mean, closeTo((55.0 + 65.0 + 61.0) / 3.0, 1e-6));
      expect(buffer.numSuccessiveOutliers, equals(0));
      expect(buffer.size, equals(3));

      // Outlier 15.0 deviates > 30% from ~60.3
      success = buffer.append(15.0);
      expect(success, isFalse);
      expect(buffer.mean, closeTo((55.0 + 65.0 + 61.0) / 3.0, 1e-6));
      expect(buffer.numSuccessiveOutliers, equals(1));
      expect(buffer.size, equals(3));

      // Another outlier 95.0
      success = buffer.append(95.0);
      expect(success, isFalse);
      expect(buffer.numSuccessiveOutliers, equals(2));
      expect(buffer.size, equals(3));

      // 3rd successive outlier exceeds maxNumSuccessiveOutliers (2) -> clears buffer
      success = buffer.append(95.0);
      expect(success, isFalse);
      expect(buffer.mean, equals(0.0));
      expect(buffer.numSuccessiveOutliers, equals(0));
      expect(buffer.size, equals(0));
    });
  });

  group('OutlierRemovingSmoother Tests (Kotlin Baseline Parity)', () {
    test('Multi-buffer smoothing and outlier rejection sequence', () {
      final smoother = OutlierRemovingSmoother(
        size: 3,
        minValue: 10.0,
        maxValue: 100.0,
        relativeDeviationToBeAnOutlier: 0.3,
        maxNumSuccessiveOutliers: 2,
        minNumValuesForValidMean: 2,
      );

      expect(smoother.smoothedValue, equals(0.0));

      // 1 value available; minimum required is 2 -> returns 0.0
      var smoothed = smoother(50.0);
      expect(smoothed, equals(0.0));

      // Mean of 50, 60 -> 55.0
      smoothed = smoother(60.0);
      expect(smoothed, closeTo(55.0, 1e-6));

      // Mean of 50, 60, 55 -> 55.0
      smoothed = smoother(55.0);
      expect(smoothed, closeTo(55.0, 1e-6));

      // Outlier 90.0: rejected, smoother returns 0.0, smoothedValue holds 55.0
      smoothed = smoother(90.0);
      expect(smoothed, equals(0.0));
      expect(smoother.smoothedValue, closeTo(55.0, 1e-6));

      // Outlier 92.0: rejected, smoother returns 0.0, smoothedValue holds 55.0
      smoothed = smoother(92.0);
      expect(smoothed, equals(0.0));
      expect(smoother.smoothedValue, closeTo(55.0, 1e-6));

      // New candidate sequence 90, 92, 91 converges
      smoothed = smoother(91.0);
      expect(smoothed, closeTo(91.0, 1e-6));
      expect(smoother.smoothedValue, closeTo(91.0, 1e-6));

      // Outlier 20.0 ignored; 95.0 added -> mean of 92, 91, 95
      smoother(20.0);
      smoothed = smoother(95.0);
      expect(smoothed, closeTo((92.0 + 91.0 + 95.0) / 3.0, 1e-6));
    });

    test('Reset clears all internal buffers', () {
      final smoother = OutlierRemovingSmoother(
        size: 3,
        minValue: 10.0,
        maxValue: 100.0,
      );
      smoother(50.0);
      smoother(52.0); // Within default 10% relative deviation
      expect(smoother.smoothedValue, closeTo(51.0, 1e-6));

      smoother.reset();
      expect(smoother.smoothedValue, equals(0.0));
      for (final b in smoother.buffers) {
        expect(b.size, equals(0));
      }
    });
  });
}
