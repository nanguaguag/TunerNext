import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/correlation/auto_correlation.dart';
import 'package:tuner_flutter/dsp/correlation/correlation.dart';

/// Direct time-domain discrete autocorrelation:
/// $$R[i] = \sum_{j=0}^{N-1-i} x[j+i] \cdot x[j]$$
Float32List classicDirectCorrelation(Float32List values) {
  final result = Float32List(values.length);
  for (var i = 0; i < values.length; i++) {
    var v = 0.0;
    for (var j = 0; j < values.length - i; j++) {
      v += values[j + i] * values[j];
    }
    result[i] = v;
  }
  return result;
}

void main() {
  group('Correlation Tests matching Kotlin CorrelationTest.kt baseline', () {
    test(
      'Random test vector aligns with Kotlin baseline and direct correlation',
      () {
        final values = Float32List.fromList([
          0.63696,
          0.26979,
          0.04097,
          0.01653,
          0.81327,
          0.91276,
          0.60664,
          0.72950,
          0.54362,
          0.93507,
          0.81585,
          0.00274,
          0.85740,
          0.03359,
          0.72966,
          0.17566,
        ]);

        // Expected reference values from Kotlin CorrelationTest.kt
        final expected = [
          6.01020,
          3.78942,
          4.02729,
          3.51248,
          3.68700,
          3.76005,
          2.39249,
          2.09610,
          1.93074,
          1.62987,
          1.30983,
          0.38935,
          0.58799,
          0.22544,
          0.51215,
          0.11189,
        ];

        // 1. Verify direct convolution formula
        final direct = classicDirectCorrelation(values);
        for (var i = 0; i < values.length; i++) {
          expect(direct[i], closeTo(expected[i], 1e-4));
        }

        // 2. Verify FFT-based Correlation processor
        final correlator = Correlation(
          values.length,
          windowType: WindowingFunction.tophat,
        );
        final result = Float32List(values.length);
        correlator.correlate(values, result, disableWindow: true);

        for (var i = 0; i < values.length; i++) {
          // Output from FFT autocorrelation is scaled by N = values.length
          expect(
            result[i] / values.length,
            closeTo(expected[i], 1e-4),
            reason: 'Mismatch at lag $i',
          );
        }
      },
    );

    test('Sine wave autocorrelation displays prominent periodic peak', () {
      const size = 128;
      const sampleRate = 128.0;
      const freq = 8.0; // Period = 16 samples
      const periodSamples = 16;

      final sine = Float32List(size);
      for (var i = 0; i < size; i++) {
        sine[i] = math.sin(2 * math.pi * freq * i / sampleRate);
      }

      final correlator = Correlation(
        size,
        windowType: WindowingFunction.tophat,
      );
      final result = Float32List(size);
      correlator.correlate(sine, result);

      // Peak at lag 0 (energy sum = N * 0.5 for unit sine)
      final r0 = result[0] / size;
      expect(r0, closeTo(size * 0.5, 1.0));

      // Strong peak at lag = periodSamples: (size - periodSamples) * 0.5
      final rPeriod = result[periodSamples] / size;
      expect(rPeriod, closeTo((size - periodSamples) * 0.5, 1.0));

      // Valley at half-period (negative peak)
      final rHalfPeriod = result[periodSamples ~/ 2] / size;
      expect(rHalfPeriod < 0.0, isTrue);
    });

    test('correlate with external spectrum buffer captures valid spectrum', () {
      const size = 32;
      final values = Float32List(size);
      for (var i = 0; i < size; i++) {
        values[i] = (i % 4 == 0) ? 1.0 : 0.0;
      }

      final correlator = Correlation(
        size,
        windowType: WindowingFunction.tophat,
      );
      final result = Float32List(size);
      final spectrum = Float32List(2 * size + 2);

      correlator.correlate(values, result, spectrum: spectrum);

      // Verify spectrum contains non-zero entries
      var hasNonZero = false;
      for (var i = 0; i < spectrum.length; i++) {
        if (spectrum[i].abs() > 1e-6) {
          hasNonZero = true;
          break;
        }
      }
      expect(hasNonZero, isTrue);
    });

    test(
      'AutoCorrelationData normalizes values and updates plot ranges accurately',
      () {
        const size = 16;
        final autoCorr = AutoCorrelationData(size: size, dt: 1.0 / 1000.0);

        expect(autoCorr.times[0], equals(0.0));
        expect(autoCorr.times[1], closeTo(0.001, 1e-6));
        expect(autoCorr.times[15], closeTo(0.015, 1e-6));

        // Simulate correlation output: min = -2.0, max = +2.0
        autoCorr.values[0] = 2.0;
        autoCorr.values[1] = -2.0;
        autoCorr.values[2] = 0.0;
        for (var i = 3; i < size; i++) {
          autoCorr.values[i] = 1.0;
        }

        autoCorr.updatePlotNormalized();

        // Range is [-2, 2] -> span = 4.0
        // v = 2.0 -> (2 - (-2)) / 4 = 1.0
        expect(autoCorr.plotValuesNormalized[0], closeTo(1.0, 1e-6));
        // v = -2.0 -> (-2 - (-2)) / 4 = 0.0
        expect(autoCorr.plotValuesNormalized[1], closeTo(0.0, 1e-6));
        // v = 0.0 -> (0 - (-2)) / 4 = 0.5
        expect(autoCorr.plotValuesNormalized[2], closeTo(0.5, 1e-6));
        // Zero baseline position = 0.5
        expect(autoCorr.plotValuesNormalizedZero, closeTo(0.5, 1e-6));
      },
    );

    test('correlateToData automatically updates AutoCorrelationData', () {
      const size = 32;
      final values = Float32List(size);
      for (var i = 0; i < size; i++) {
        values[i] = math.cos(2 * math.pi * 2 * i / size);
      }

      final correlator = Correlation(size);
      final autoCorr = AutoCorrelationData(size: size, dt: 0.1);

      correlator.correlateToData(values, autoCorr);

      expect(autoCorr[0], greaterThan(0.0));
      expect(autoCorr.plotValuesNormalized[0], closeTo(1.0, 1e-4));
      expect(autoCorr.plotValuesNormalizedZero, greaterThanOrEqualTo(0.0));
      expect(autoCorr.plotValuesNormalizedZero, lessThanOrEqualTo(1.0));
    });

    test('Throws ArgumentError on invalid size or buffer capacities', () {
      expect(() => Correlation(0), throwsArgumentError);
      expect(() => Correlation(15), throwsArgumentError);
      expect(() => Correlation(-32), throwsArgumentError);

      final correlator = Correlation(16);
      expect(
        () => correlator.correlate(Float32List(15), Float32List(16)),
        throwsArgumentError,
      );
      expect(
        () => correlator.correlate(Float32List(16), Float32List(15)),
        throwsArgumentError,
      );
      expect(
        () => correlator.correlate(
          Float32List(16),
          Float32List(16),
          spectrum: Float32List(30), // requires 2 * 16 + 2 = 34
        ),
        throwsArgumentError,
      );
    });
  });
}
