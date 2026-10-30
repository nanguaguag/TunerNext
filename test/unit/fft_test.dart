import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/fft/fft.dart';

void main() {
  group('BitReverse Helper Tests', () {
    test(
      'bitReverse computes correct bit reversal for multiple bit widths',
      () {
        // 3-bit reversal: 001 (1) -> 100 (4), 011 (3) -> 110 (6)
        expect(bitReverse(0, 3), equals(0));
        expect(bitReverse(1, 3), equals(4));
        expect(bitReverse(2, 3), equals(2));
        expect(bitReverse(3, 3), equals(6));
        expect(bitReverse(4, 3), equals(1));
        expect(bitReverse(5, 3), equals(5));
        expect(bitReverse(6, 3), equals(3));
        expect(bitReverse(7, 3), equals(7));

        // 4-bit reversal: 0001 (1) -> 1000 (8), 0011 (3) -> 1100 (12)
        expect(bitReverse(1, 4), equals(8));
        expect(bitReverse(3, 4), equals(12));
      },
    );

    test('bitReverse involution property holds: rev(rev(x)) == x', () {
      for (var bits = 1; bits <= 8; bits++) {
        final maxVal = 1 << bits;
        for (var x = 0; x < maxVal; x++) {
          expect(bitReverse(bitReverse(x, bits), bits), equals(x));
        }
      }
    });
  });

  group('FFT Construction and Frequency Mapping Tests', () {
    test('Constructor accepts positive powers of 2', () {
      expect(() => FFT(2), returnsNormally);
      expect(() => FFT(4), returnsNormally);
      expect(() => FFT(16), returnsNormally);
      expect(() => FFT(4096), returnsNormally);
      expect(() => FFT(8192), returnsNormally);
    });

    test('Constructor rejects non-powers of 2, 0, and negative sizes', () {
      expect(() => FFT(0), throwsArgumentError);
      expect(() => FFT(-16), throwsArgumentError);
      expect(() => FFT(15), throwsArgumentError);
      expect(() => FFT(100), throwsArgumentError);
      expect(() => FFT(4095), throwsArgumentError);
    });

    test('numFrequencies calculations for real and complex', () {
      expect(FFT.numFrequenciesReal(16), equals(9));
      expect(FFT.numFrequenciesReal(32), equals(17));
      expect(FFT.numFrequenciesReal(4096), equals(2049));

      expect(FFT.numFrequenciesComplex(16), equals(8));
      expect(FFT.numFrequenciesComplex(32), equals(16));
      expect(FFT.numFrequenciesComplex(4096), equals(2048));
    });

    test('Frequency resolution and bin index mapping', () {
      const size = 32;
      // numValues = size / 2 = 16 complex points.
      // With dt = 1/16, total duration T = dt * numValues = 1.0s, delta f = 1.0 Hz.
      const dt = 1.0 / 16.0;

      // Real frequency mapping: bin 0 -> 0Hz, bin 1 -> 0.5Hz, bin 16 -> 8Hz
      // delta f_real = 1 / (dt * size) = 1 / (1/16 * 32) = 0.5 Hz
      expect(FFT.getFrequencyReal(0, size, dt), closeTo(0.0, 1e-6));
      expect(FFT.getFrequencyReal(1, size, dt), closeTo(0.5, 1e-6));
      expect(FFT.getFrequencyReal(16, size, dt), closeTo(8.0, 1e-6));

      // Complex frequency mapping: numValues = 16 (half = 8)
      // Positive bins: 0 -> 0Hz, 1 -> 1Hz, 7 -> 7Hz
      expect(FFT.getFrequencyComplex(0, size, dt), closeTo(0.0, 1e-6));
      expect(FFT.getFrequencyComplex(1, size, dt), closeTo(1.0, 1e-6));
      // Negative bins: 8 -> -8Hz, 15 -> -1Hz
      expect(FFT.getFrequencyComplex(8, size, dt), closeTo(-8.0, 1e-6));
      expect(FFT.getFrequencyComplex(15, size, dt), closeTo(-1.0, 1e-6));
    });
  });

  group('Complex FFT / IFFT Tests', () {
    test('sinTestComplex: forward FFT spectrum and roundtrip IFFT', () {
      const numSamples = 16;
      const frequency = 1.0;
      const amp = 2.0;
      const offset = 2.3;

      // 16 complex numbers -> 32 float elements [re0, im0, re1, im1, ...]
      final samples = Float32List(2 * numSamples);
      for (var i = 0; i < numSamples; i++) {
        samples[2 * i] =
            offset + amp * math.sin(2 * math.pi * frequency * i / numSamples);
        samples[2 * i + 1] = 0.0;
      }

      final fft = FFT(2 * numSamples);
      final result = Float32List(2 * numSamples);
      fft.fft(samples, result);

      // Verify DC offset on bin 0
      final offsetFFT = result[0] / numSamples;
      expect(offsetFFT, closeTo(offset, 1e-5));

      // Sine of frequency 1 appears at bin 1 and conjugate at bin (numSamples - 1)
      final ampFFT = -result[3] / numSamples * 2;
      final ampFFT2 = -result[2 * (numSamples + 1) - 3] / numSamples * 2;
      expect(ampFFT, closeTo(amp, 1e-5));
      expect(ampFFT2, closeTo(-ampFFT, 1e-5));

      // Verify full reconstruction via IFFT
      final ifftResult = Float32List(2 * numSamples);
      fft.ifft(result, ifftResult);
      for (var i = 0; i < samples.length; i++) {
        expect(ifftResult[i] / numSamples, closeTo(samples[i], 1e-5));
      }
    });

    test('randomTestComplex: matches NumPy FFT reference vectors exactly', () {
      const numSamples = 16;
      final samples = Float32List.fromList([
        0.636962,
        0.863179,
        0.269787,
        0.541461,
        0.040974,
        0.299712,
        0.016528,
        0.422687,
        0.813270,
        0.028320,
        0.912756,
        0.124283,
        0.606636,
        0.670624,
        0.729497,
        0.647190,
        0.543625,
        0.615385,
        0.935072,
        0.383678,
        0.815854,
        0.997210,
        0.002739,
        0.980835,
        0.857404,
        0.685542,
        0.033586,
        0.650459,
        0.729655,
        0.688447,
        0.175656,
        0.388921,
      ]);

      // Reference values computed via numpy.fft.fft
      final numpyExpected = [
        8.119998,
        8.987933,
        -3.830690,
        -0.441174,
        0.623124,
        1.534330,
        1.837989,
        1.754941,
        -0.081609,
        -1.690349,
        0.869224,
        0.591218,
        -0.871009,
        0.882308,
        1.410356,
        -1.589122,
        1.968761,
        0.708904,
        0.769433,
        1.333645,
        -1.727598,
        0.954003,
        -0.426617,
        0.883407,
        1.397895,
        0.763215,
        -0.063509,
        -0.315977,
        0.015132,
        -0.311831,
        0.180508,
        -0.234587,
      ];

      final fft = FFT(2 * numSamples);
      final result = Float32List(2 * numSamples);
      fft.fft(samples, result);

      for (var i = 0; i < numpyExpected.length; i++) {
        expect(result[i], closeTo(numpyExpected[i], 1e-4));
      }

      // Reconstruct via IFFT
      final ifftResult = Float32List(2 * numSamples);
      fft.ifft(result, ifftResult);

      for (var i = 0; i < samples.length; i++) {
        expect(ifftResult[i] / numSamples, closeTo(samples[i], 1e-5));
      }
    });
  });

  group('Real FFT / IFFT Tests (Real-Valued Transforms)', () {
    test(
      'randomTestReal: matches NumPy rfft reference vector and IFFT restores',
      () {
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

        // Expected reference computed via numpy.fft.rfft
        final numpyExpected = [
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

        // Verify DC and Nyquist imaginary parts are zero
        expect(result[1], equals(0.0));
        expect(result[numSamples + 1], equals(0.0));

        for (var i = 0; i < numpyExpected.length; i++) {
          expect(result[i], closeTo(numpyExpected[i], 1e-4));
        }

        // Invert back to time domain
        final ifftResult = Float32List(numSamples);
        fft.ifftReal(result, ifftResult);

        for (var i = 0; i < numSamples; i++) {
          expect(2.0 * ifftResult[i] / numSamples, closeTo(samples[i], 1e-5));
        }
      },
    );

    test('sinTest: pure sine wave amplitude and DC offset extraction', () {
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

      // DC offset is in result[0] / numSamples
      final offsetFFT = result[0] / numSamples;
      expect(offsetFFT, closeTo(offset, 1e-5));

      // Sine wave amplitude is in bin 1 imaginary part (-result[3] / numSamples * 2)
      final ampFFT = -result[3] / numSamples * 2;
      expect(ampFFT, closeTo(amp, 1e-5));

      // IFFT reconstruction
      final ifftResult = Float32List(numSamples);
      fft.ifftReal(result, ifftResult);
      for (var i = 0; i < numSamples; i++) {
        expect(2.0 * ifftResult[i] / numSamples, closeTo(samples[i], 1e-5));
      }
    });

    test('cosTest: pure cosine wave amplitude and DC offset extraction', () {
      const numSamples = 32;
      const frequency = 2.0;
      const amp = 2.0;
      const offset = 2.3;

      final samples = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        samples[i] =
            offset + amp * math.cos(2 * math.pi * frequency * i / numSamples);
      }

      final fft = FFT(numSamples);
      final result = Float32List(numSamples + 2);
      fft.fftReal(samples, result);

      final offsetFFT = result[0] / numSamples;
      expect(offsetFFT, closeTo(offset, 1e-5));

      // Cosine at frequency 2 appears on bin 2 real part (index 2 * 2 = 4)
      final ampFFT = result[4] / numSamples * 2;
      expect(ampFFT, closeTo(amp, 1e-5));
    });

    test(
      'Dirac delta impulse yields uniform flat spectrum and restores cleanly',
      () {
        const numSamples = 64;
        final samples = Float32List(numSamples);
        samples[0] = 1.0; // delta[0] = 1

        final fft = FFT(numSamples);
        final result = Float32List(numSamples + 2);
        fft.fftReal(samples, result);

        // Delta FFT has constant real part = 1.0, imaginary part = 0.0 across all bins
        final numBins = FFT.numFrequenciesReal(numSamples);
        for (var b = 0; b < numBins; b++) {
          expect(result[2 * b], closeTo(1.0, 1e-5));
          expect(result[2 * b + 1], closeTo(0.0, 1e-5));
        }

        final ifftResult = Float32List(numSamples);
        fft.ifftReal(result, ifftResult);
        expect(2.0 * ifftResult[0] / numSamples, closeTo(1.0, 1e-5));
        for (var i = 1; i < numSamples; i++) {
          expect(2.0 * ifftResult[i] / numSamples, closeTo(0.0, 1e-5));
        }
      },
    );
  });

  group('FORK-NEW-02 Overwrite Bug Regression Tests', () {
    test(
      'Middle bin frequency (Nyquist / 2) does not suffer from in-place overwriting',
      () {
        // Test across multiple sizes to verify index i = halfSize / 2
        for (final size in [16, 32, 64, 128, 512, 1024]) {
          final halfSize = size ~/ 2;
          final middleBin = halfSize ~/ 2; // Nyquist / 2

          final samples = Float32List(size);
          for (var i = 0; i < size; i++) {
            // Pure tone right at Nyquist / 2
            samples[i] = math.sin(2 * math.pi * middleBin * i / size);
          }

          final fft = FFT(size);
          final result = Float32List(size + 2);
          fft.fftReal(samples, result);

          // Imaginary part of middleBin should be -size / 2
          final expectedIm = -size / 2.0;
          expect(
            result[2 * middleBin + 1],
            closeTo(expectedIm, 1e-3),
            reason:
                'Middle bin $middleBin imaginary part was corrupted for size $size',
          );

          // All other bins should be zero
          for (var b = 0; b < FFT.numFrequenciesReal(size); b++) {
            if (b != middleBin) {
              expect(result[2 * b], closeTo(0.0, 1e-3));
              expect(result[2 * b + 1], closeTo(0.0, 1e-3));
            }
          }

          // IFFT round-trip accuracy
          final ifftResult = Float32List(size);
          fft.ifftReal(result, ifftResult);
          for (var i = 0; i < size; i++) {
            expect(
              2.0 * ifftResult[i] / size,
              closeTo(samples[i], 1e-4),
              reason: 'IFFT restoration failed at sample $i for size $size',
            );
          }
        }
      },
    );
  });

  group('Input / Output Buffer Validation Tests', () {
    test('Throws ArgumentError on insufficient input/output lengths', () {
      final fft = FFT(16);

      // Complex FFT
      expect(
        () => fft.fft(Float32List(15), Float32List(16)),
        throwsArgumentError,
      );
      expect(
        () => fft.fft(Float32List(16), Float32List(15)),
        throwsArgumentError,
      );

      // Complex IFFT
      expect(
        () => fft.ifft(Float32List(15), Float32List(16)),
        throwsArgumentError,
      );
      expect(
        () => fft.ifft(Float32List(16), Float32List(15)),
        throwsArgumentError,
      );

      // Real FFT
      expect(
        () => fft.fftReal(Float32List(15), Float32List(18)),
        throwsArgumentError,
      );
      expect(
        () => fft.fftReal(Float32List(16), Float32List(17)),
        throwsArgumentError,
      );

      // Real IFFT
      expect(
        () => fft.ifftReal(Float32List(17), Float32List(16)),
        throwsArgumentError,
      );
      expect(
        () => fft.ifftReal(Float32List(18), Float32List(15)),
        throwsArgumentError,
      );
    });
  });
}
