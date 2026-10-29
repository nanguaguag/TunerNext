import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/fft/fft.dart';

void main() {
  group('FFT Complex and Real Tests', () {
    test('numFrequencies calculation', () {
      expect(FFT.numFrequenciesReal(32), equals(17));
      expect(FFT.numFrequenciesComplex(32), equals(16));
    });

    test('randomTestReal matches NumPy reference vectors', () {
      const numSamples = 16;
      final samples = Float32List.fromList([
        0.636962,
        0.269787,
        0.040974,
        0.016528,
        0.813270,
        0.912756,
        0.606636,
        0.729497,
        0.543625,
        0.935072,
        0.815854,
        0.002739,
        0.857404,
        0.033586,
        0.729655,
        0.175656,
      ]);

      // Expected NumPy FFT reference vector
      final expected = [
        8.119998,
        0.000000,
        -1.825091,
        -0.103294,
        0.319128,
        0.923080,
        0.887240,
        1.035459,
        0.658143,
        -1.226782,
        0.221303,
        -0.146095,
        -1.299304,
        -0.035848,
        1.089895,
        -1.461384,
        1.968761,
        0.000000,
      ];

      final fft = FFT(numSamples);
      final result = Float32List(numSamples + 2);
      fft.fftReal(samples, result);

      for (var i = 0; i < expected.length; i++) {
        expect(result[i], closeTo(expected[i], 1e-4));
      }

      // Test IFFT round-trip restoration
      final ifftResult = Float32List(numSamples);
      fft.ifftReal(result, ifftResult);
      for (var i = 0; i < numSamples; i++) {
        expect(2 * ifftResult[i] / numSamples, closeTo(samples[i], 1e-5));
      }
    });

    test('sinTest Real FFT extracts exact amplitude and offset', () {
      const numSamples = 32;
      const frequency = 1.0;
      const amp = 2.0;
      const offset = 2.3;

      final samples = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        samples[i] =
            offset + amp * math.sin(2 * math.pi * frequency * i / numSamples);
      }

      final fft = FFT(numSamples);
      final result = Float32List(numSamples + 2);
      fft.fftReal(samples, result);

      final offsetFFT = result[0] / numSamples;
      expect(offsetFFT, closeTo(offset, 1e-4));

      // Sine amplitude appears on bin 1 imaginary part (index 3)
      final ampFFT = -result[3] / numSamples * 2;
      expect(ampFFT, closeTo(amp, 1e-4));

      final ifftResult = Float32List(numSamples);
      fft.ifftReal(result, ifftResult);
      for (var i = 0; i < numSamples; i++) {
        expect(2 * ifftResult[i] / numSamples, closeTo(samples[i], 1e-5));
      }
    });
  });
}
