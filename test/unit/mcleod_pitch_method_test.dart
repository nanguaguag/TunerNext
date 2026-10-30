import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/correlation/auto_correlation.dart';
import 'package:tuner_flutter/dsp/correlation/correlation.dart';
import 'package:tuner_flutter/dsp/pitch/mcleod_pitch_method.dart';

void main() {
  group('McLeod Pitch Method (MPM) Unit Tests', () {
    test('pureSineWave detects exact pitch with high clarity', () {
      const sampleRate = 44100;
      const targetFreq = 440.0;
      const numSamples = 2048;

      final samples = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        samples[i] = math.sin(2.0 * math.pi * targetFreq * i / sampleRate);
      }

      final detector = McLeodPitchDetector();
      final result = detector.detectPitch(
        samples: samples,
        sampleRate: sampleRate,
        frequencyMin: 50.0,
        frequencyMax: 2000.0,
      );

      expect(result.isSilence, isFalse);
      expect(result.confidence, greaterThan(0.9));
      expect(result.frequency, closeTo(440.0, 1.0));
    });

    test('harmonicViolinTone with strong second harmonic rejects octave doubling', () {
      // In string instruments (e.g. violin bowing attack), the 2nd harmonic energy can
      // temporarily surpass the fundamental. MPM's first-peak ratio (0.85) rule must
      // correctly capture the base fundamental (330 Hz, E4) rather than 660 Hz.
      const sampleRate = 44100;
      const fundamental = 330.0; // E4
      const numSamples = 2048;

      final samples = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        final t = i / sampleRate;
        samples[i] =
            0.6 * math.sin(2.0 * math.pi * fundamental * t) +
            1.0 *
                math.sin(
                  2.0 * math.pi * fundamental * 2.0 * t,
                ) + // 2nd harmonic
            0.5 *
                math.sin(2.0 * math.pi * fundamental * 3.0 * t); // 3rd harmonic
      }

      final detector = McLeodPitchDetector(peakThresholdRatio: 0.85);
      final result = detector.detectPitch(
        samples: samples,
        sampleRate: sampleRate,
        frequencyMin: 100.0,
        frequencyMax: 2000.0,
      );

      expect(result.isSilence, isFalse);
      expect(result.confidence, greaterThan(0.6));
      expect(
        result.frequency,
        closeTo(330.0, 2.0),
        reason:
            'Should identify 330 Hz fundamental, avoiding 660 Hz octave doubling',
      );
    });

    test('silence and low energy inputs report unvoiced / zero frequency', () {
      const sampleRate = 44100;
      final zeroSamples = Float32List(2048);

      final detector = McLeodPitchDetector();
      final result = detector.detectPitch(
        samples: zeroSamples,
        sampleRate: sampleRate,
      );

      expect(result.isSilence, isTrue);
      expect(result.frequency, equals(0.0));
      expect(result.confidence, equals(0.0));
    });

    test('random white noise is rejected by cutoff clarity', () {
      const sampleRate = 44100;
      const numSamples = 2048;
      final random = math.Random(42);

      final noise = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        noise[i] = (random.nextDouble() * 2.0 - 1.0) * 0.1;
      }

      final detector = McLeodPitchDetector(cutoffClarity: 0.45);
      final result = detector.detectPitch(
        samples: noise,
        sampleRate: sampleRate,
        frequencyMin: 50.0,
        frequencyMax: 2000.0,
      );

      expect(result.isSilence, isTrue);
      expect(result.frequency, equals(0.0));
    });

    test(
      'computeNsdfDirect and computeNsdfFromCorrelation peak positions align',
      () {
        const sampleRate = 44100;
        const freq = 440.0;
        const numSamples = 1024;
        const periodSamples = sampleRate / freq; // ~100.22 samples

        final samples = Float32List(numSamples);
        for (var i = 0; i < numSamples; i++) {
          samples[i] = math.sin(2.0 * math.pi * freq * i / sampleRate);
        }

        // Direct calculation
        final nsdfDirect = Float32List(numSamples ~/ 2);
        McLeodPitchDetector.computeNsdfDirect(samples, nsdfDirect);

        // FFT Autocorrelation calculation
        final autoCorr = AutoCorrelationData(
          size: numSamples,
          dt: 1.0 / sampleRate,
        );
        final correlator = Correlation(numSamples);
        correlator.correlateToData(samples, autoCorr);

        final nsdfFromCorr = Float32List(numSamples ~/ 2);
        McLeodPitchDetector.computeNsdfFromCorrelation(autoCorr, nsdfFromCorr);

        // Both should have maximum peak near lag 100
        final expectedLag = periodSamples.round();
        expect(nsdfDirect[expectedLag], greaterThan(0.85));
        expect(nsdfFromCorr[expectedLag], greaterThan(0.85));
        expect(
          (nsdfDirect[expectedLag] - nsdfFromCorr[expectedLag]).abs(),
          lessThan(0.15),
        );
      },
    );

    test('reset clears internal buffer', () {
      final detector = McLeodPitchDetector();
      expect(() => detector.reset(), returnsNormally);
    });
  });
}
