import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/correlation/auto_correlation.dart';
import 'package:tuner_flutter/dsp/pitch/classic_pitch_detector.dart';

void main() {
  group('CorrelationBasedFrequency Tests (Parity with Kotlin Baseline)', () {
    test('checkPeaks with subharmonic tolerance selection', () {
      const numTotal = 1200;
      const peak1 = 1000;
      const peak2 = 251;
      const dt = 0.1;

      final correlation = AutoCorrelationData(size: numTotal, dt: dt);
      correlation.values.fillRange(0, numTotal, 0.0);
      correlation.values[peak1] = 100.0;
      correlation.values[peak2] = 98.0;

      // With strict tolerance (0.01), peak2 (251) is not recognized as a subharmonic of 1000 (1000/4 = 250)
      var tolerance = 0.01;
      final result1 = CorrelationBasedFrequency(0, 0, 0);
      findCorrelationBasedFrequency(
        result1,
        correlation,
        subharmonicsTolerance: tolerance,
      );
      expect(result1.timeShift, closeTo(dt * peak1, 1e-5));
      expect(result1.frequency, closeTo(1.0 / (dt * peak1), 1e-5));
      expect(result1.correlationAtTimeShift, closeTo(correlation[peak1], 1e-5));

      // With wider tolerance (0.05), peak2 is recognized within range (1000 / 4) and preferred
      tolerance = 0.05;
      final result2 = CorrelationBasedFrequency(0, 0, 0);
      findCorrelationBasedFrequency(
        result2,
        correlation,
        subharmonicsTolerance: tolerance,
      );
      expect(result2.timeShift, closeTo(dt * peak2, 1e-5));
      expect(result2.frequency, closeTo(1.0 / (dt * peak2), 1e-5));
      expect(result2.correlationAtTimeShift, closeTo(correlation[peak2], 1e-5));

      // Restrict frequency around peak1, so peak2 won't be searched
      final result3 = CorrelationBasedFrequency(0, 0, 0);
      findCorrelationBasedFrequency(
        result3,
        correlation,
        frequencyMin: 1.0 / (dt * (peak1 + 20)),
        frequencyMax: 1.0 / (dt * (peak1 - 20)),
        subharmonicsTolerance: tolerance,
      );
      expect(result3.frequency, closeTo(1.0 / (dt * peak1), 1e-5));
    });

    test('checkZeroCorrelationReturnsZeroFrequency', () {
      final correlation = AutoCorrelationData(size: 1200, dt: 0.001);
      correlation.values.fillRange(0, 1200, 0.0);

      final result = CorrelationBasedFrequency(-1, -1, -1);
      findCorrelationBasedFrequency(result, correlation);
      expect(result.frequency, equals(0.0));
      expect(result.timeShift, equals(0.0));
      expect(result.correlationAtTimeShift, equals(0.0));
    });

    test('checkSimpleZeroCorrelationReturnsZeroFrequency', () {
      final correlation = AutoCorrelationData(size: 1200, dt: 0.001);
      correlation.values.fillRange(0, 1200, 0.0);

      final result = CorrelationBasedFrequency(-1, -1, -1);
      findCorrelationBasedFrequencySimple(
        results: result,
        correlation: correlation,
        frequencyMin: 40.0,
        frequencyMax: 2000.0,
        frequencyPrevious: 440.0,
      );
      expect(result.frequency, equals(0.0));
      expect(result.timeShift, equals(0.0));
      expect(result.correlationAtTimeShift, equals(0.0));
    });

    test('findCorrelationBasedFrequencySimple local maximum tracking', () {
      const size = 500;
      const dt = 1.0 / 44100.0;
      final correlation = AutoCorrelationData(size: size, dt: dt);
      correlation.values.fillRange(0, size, 0.0);
      correlation.values[0] = 100.0; // r0 energy reference

      // Peak around index 100 (approx 441 Hz)
      correlation.values[99] = 70.0;
      correlation.values[100] = 80.0;
      correlation.values[101] = 68.0;

      final result = CorrelationBasedFrequency(0, 0, 0);
      findCorrelationBasedFrequencySimple(
        results: result,
        correlation: correlation,
        frequencyPrevious: 450.0, // starts near index 98
        frequencyMin: 100.0,
        frequencyMax: 1000.0,
      );

      expect(result.frequency, closeTo(441.0, 5.0));
      expect(result.correlationAtTimeShift, greaterThan(75.0));
    });
  });

  group('ClassicPitchDetector Tests', () {
    test('Silence detection on low RMS input', () {
      final detector = ClassicPitchDetector(frameSize: 1024);
      final silenceSamples = Float32List(1024); // all zeroes
      final result = detector.detectPitch(
        samples: silenceSamples,
        sampleRate: 44100,
      );

      expect(result.isSilence, isTrue);
      expect(result.frequency, equals(0.0));
    });

    test('Detects 440 Hz (A4) pure tone with high confidence', () {
      final detector = ClassicPitchDetector(frameSize: 2048);
      const sampleRate = 44100;
      const targetFreq = 440.0;
      final samples = Float32List(2048);

      for (var i = 0; i < 2048; i++) {
        samples[i] = math.sin(2.0 * math.pi * targetFreq * (i / sampleRate));
      }

      final result = detector.detectPitch(
        samples: samples,
        sampleRate: sampleRate,
        frequencyMin: 50.0,
        frequencyMax: 2000.0,
      );

      expect(result.isSilence, isFalse);
      expect(result.frequency, closeTo(targetFreq, 0.5));
      expect(result.confidence, greaterThan(0.95));
      expect(result.periodSamples, closeTo(sampleRate / targetFreq, 0.2));
    });

    test('Detects 82.41 Hz (Guitar Low E) with subharmonic avoidance', () {
      final detector = ClassicPitchDetector(frameSize: 2048);
      const sampleRate = 44100;
      const targetFreq = 82.41;
      final samples = Float32List(2048);

      for (var i = 0; i < 2048; i++) {
        samples[i] = math.sin(2.0 * math.pi * targetFreq * (i / sampleRate));
      }

      final result = detector.detectPitch(
        samples: samples,
        sampleRate: sampleRate,
        frequencyMin: 40.0,
        frequencyMax: 500.0,
      );

      expect(result.isSilence, isFalse);
      // Raw uncompensated autocorrelation triangle window effect shifts peak slightly at large lags (tau ~ 535)
      expect(result.frequency, closeTo(targetFreq, 0.8));
      // Due to unnormalized correlation (triangle tapering 1 - tau/N), confidence is approx (2048 - 535)/2048 = 0.74
      expect(result.confidence, greaterThan(0.70));
    });

    test('Reset clears internal buffers and results', () {
      final detector = ClassicPitchDetector(frameSize: 1024);
      detector.reset();
      // Should remain valid and not crash
      final result = detector.detectPitch(
        samples: Float32List(1024),
        sampleRate: 44100,
      );
      expect(result.isSilence, isTrue);
    });
  });
}
