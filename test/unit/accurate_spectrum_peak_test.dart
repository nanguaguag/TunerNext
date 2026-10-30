import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/fft/fft.dart';
import 'package:tuner_flutter/dsp/fft/frequency_spectrum.dart';
import 'package:tuner_flutter/dsp/pitch/accurate_spectrum_peak.dart';

class _AccuracyTestResult {
  const _AccuracyTestResult({
    required this.frequency,
    required this.errorLow,
    required this.errorHigh,
  });

  final double frequency;
  final double errorLow;
  final double errorHigh;
}

_AccuracyTestResult _testAccuracy({
  required int numSamples,
  required double frequencyIndexFloat,
  required double relativeShift,
}) {
  const timeSeriesDuration = 3.0;
  final frequencyIndex = frequencyIndexFloat.round();
  final frequency = frequencyIndexFloat / timeSeriesDuration;
  final timeShift = relativeShift * timeSeriesDuration;

  double func(double x) => math.sin(2.0 * math.pi * frequency * x);

  const df = 1.0 / timeSeriesDuration;
  final dt = timeSeriesDuration / numSamples;

  final values1 = Float32List(numSamples);
  final values2 = Float32List(numSamples);

  for (var i = 0; i < numSamples; i++) {
    final t1 = i * dt;
    final t2 = t1 + timeShift;
    values1[i] = func(t1);
    values2[i] = func(t2);
  }

  final spec1 = FrequencySpectrum(numSamples ~/ 2 + 1, df);
  final spec2 = FrequencySpectrum(numSamples ~/ 2 + 1, df);

  final fft = FFT(numSamples);
  fft.fftReal(values1, spec1.spectrum);
  fft.fftReal(values2, spec2.spectrum);

  final spectrumPeakFrequency = AccurateSpectrumPeakFrequency(
    spec1: spec1,
    spec2: spec2,
    timeShiftBetweenSpecs: timeShift,
  );
  final frequencyHighAccuracy = spectrumPeakFrequency[frequencyIndex];

  final errorLowAccuracy =
      (frequency - frequencyIndex * df).abs() / frequency * 100.0;
  final errorHighAccuracy =
      (frequency - frequencyHighAccuracy).abs() / frequency * 100.0;

  return _AccuracyTestResult(
    frequency: frequencyHighAccuracy,
    errorLow: errorLowAccuracy,
    errorHigh: errorHighAccuracy,
  );
}

void main() {
  group('AccurateSpectrumPeakFrequency Tests', () {
    test('Phase vocoder with positive relative shift (0.4)', () {
      const numSamples = 64;
      const relativeShift = 0.4;

      var freqIndexFloat = 5.0;
      while (freqIndexFloat < 12.0) {
        freqIndexFloat += 0.1;
        final res = _testAccuracy(
          numSamples: numSamples,
          frequencyIndexFloat: freqIndexFloat,
          relativeShift: relativeShift,
        );

        // High accuracy error must be strictly better or equal to coarse bin quantization error
        expect(res.errorHigh, lessThanOrEqualTo(res.errorLow + 1e-4));
        // High accuracy relative percentage error should be well within 1%
        expect(res.errorHigh, lessThan(1.0));
      }
    });

    test('Phase vocoder with negative relative shift (-0.4)', () {
      const numSamples = 64;
      const relativeShift = -0.4;

      var freqIndexFloat = 5.0;
      while (freqIndexFloat < 12.0) {
        freqIndexFloat += 0.1;
        final res = _testAccuracy(
          numSamples: numSamples,
          frequencyIndexFloat: freqIndexFloat,
          relativeShift: relativeShift,
        );

        expect(res.errorHigh, lessThanOrEqualTo(res.errorLow + 1e-4));
        expect(res.errorHigh, lessThan(1.0));
      }
    });

    test('Single spectrum fallback with Jacobsen quadratic interpolation', () {
      const numSamples = 128;
      const sampleRate = 44100.0;
      final dt = 1.0 / sampleRate;
      final df = sampleRate / numSamples;

      // Pure tone at 440.0 Hz
      const targetFreq = 440.0;
      final values = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        values[i] = math.sin(2.0 * math.pi * targetFreq * (i * dt));
      }

      final spec = FrequencySpectrum(numSamples ~/ 2 + 1, df);
      final fft = FFT(numSamples);
      fft.fftReal(values, spec.spectrum);

      // Seed bin
      final peakBin = (targetFreq / df).round();

      // Estimate using only spec1 and Jacobsen
      final estimator = AccurateSpectrumPeakFrequency(
        spec1: spec,
        useJacobsen: true,
      );
      final estimatedFreq = estimator[peakBin];

      // Error must be significantly smaller than half the bin spacing (df / 2)
      final binResolution = df;
      final error = (estimatedFreq - targetFreq).abs();
      expect(error, lessThan(binResolution * 0.25));
    });

    test('Invalid arguments trigger ArgumentError', () {
      expect(
        () => AccurateSpectrumPeakFrequency(spec1: null, spec2: null),
        throwsArgumentError,
      );

      final s1 = FrequencySpectrum(16, 1.0);
      final s2 = FrequencySpectrum(32, 1.0);
      expect(
        () => AccurateSpectrumPeakFrequency(spec1: s1, spec2: s2),
        throwsArgumentError,
      );
    });
  });
}
