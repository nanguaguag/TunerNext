import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/pipeline/tuner_dsp_pipeline.dart';

void main() {
  group('TunerDspPipeline Unit Tests', () {
    const sampleRate = 44100;
    const frameSize = 2048;

    Float32List generateSine(
      double freq,
      double durationSeconds, [
      double amplitude = 0.8,
    ]) {
      final totalSamples = (durationSeconds * sampleRate).round();
      final samples = Float32List(totalSamples);
      for (var i = 0; i < totalSamples; i++) {
        samples[i] =
            amplitude * math.sin(2.0 * math.pi * freq * (i / sampleRate));
      }
      return samples;
    }

    test(
      'Silence or low-energy input produces silent result and resets pipeline',
      () {
        final pipeline = TunerDspPipeline(frameSize: frameSize);
        final silenceSamples = Float32List(frameSize);

        final result = pipeline.process(silenceSamples, sampleRate: sampleRate);

        expect(result.isSilence, isTrue);
        expect(result.rawFrequency, equals(0.0));
        expect(result.smoothedFrequency, equals(0.0));
        expect(result.confidence, equals(0.0));
      },
    );

    test('MPM mode accurately detects and smooths steady 440 Hz tone', () {
      final pipeline = TunerDspPipeline(
        frameSize: frameSize,
        algorithm: PitchAlgorithm.mpm,
      );

      final sine = generateSine(440.0, 0.2); // multiple frames

      late TunerPipelineResult lastResult;
      // Feed 3 consecutive frames to warm up the smoother
      for (var offset = 0; offset + frameSize <= sine.length; offset += 512) {
        final frame = sine.sublist(offset, offset + frameSize);
        lastResult = pipeline.process(frame, sampleRate: sampleRate);
      }

      expect(lastResult.isSilence, isFalse);
      expect(lastResult.algorithm, equals(PitchAlgorithm.mpm));
      expect(lastResult.rawFrequency, closeTo(440.0, 0.5));
      expect(lastResult.smoothedFrequency, closeTo(440.0, 0.5));
      expect(lastResult.confidence, greaterThan(0.95));
      expect(lastResult.executionTime, greaterThan(Duration.zero));
    });

    test('Runtime algorithm switching between MPM, Classic and TWM', () {
      final pipeline = TunerDspPipeline(
        frameSize: frameSize,
        algorithm: PitchAlgorithm.mpm,
      );

      final frame = generateSine(440.0, 0.05).sublist(0, frameSize);

      // MPM
      var res = pipeline.process(frame, sampleRate: sampleRate);
      expect(res.algorithm, equals(PitchAlgorithm.mpm));
      expect(res.rawFrequency, closeTo(440.0, 0.5));

      // Switch to Classic
      pipeline.setAlgorithm(PitchAlgorithm.classic);
      expect(pipeline.algorithm, equals(PitchAlgorithm.classic));
      res = pipeline.process(frame, sampleRate: sampleRate);
      expect(res.algorithm, equals(PitchAlgorithm.classic));
      expect(res.rawFrequency, closeTo(440.0, 0.5));

      // Switch to TWM
      pipeline.setAlgorithm(PitchAlgorithm.twm);
      expect(pipeline.algorithm, equals(PitchAlgorithm.twm));
      res = pipeline.process(frame, sampleRate: sampleRate);
      expect(res.algorithm, equals(PitchAlgorithm.twm));
      expect(res.rawFrequency, closeTo(440.0, 2.0));
    });

    test(
      'Octave jump gate inside pipeline folds back transient second harmonic burst',
      () {
        final pipeline = TunerDspPipeline(
          frameSize: frameSize,
          algorithm: PitchAlgorithm.mpm,
          useOctaveJumpGate: true,
        );

        final frame440 = generateSine(440.0, 0.05).sublist(0, frameSize);
        final frame880 = generateSine(880.0, 0.05).sublist(0, frameSize);

        // Baseline A4 (440 Hz)
        var res = pipeline.process(frame440, sampleRate: sampleRate);
        expect(res.rawFrequency, closeTo(440.0, 0.5));

        // Single frame octave jump (880 Hz): raw is 880, but smoothed / gated should fold back to 440
        res = pipeline.process(frame880, sampleRate: sampleRate);
        expect(res.rawFrequency, closeTo(880.0, 0.5));
        expect(res.smoothedFrequency, closeTo(440.0, 0.5));
      },
    );

    test('Reset completely clears pipeline history', () {
      final pipeline = TunerDspPipeline(frameSize: frameSize);
      final frame = generateSine(440.0, 0.05).sublist(0, frameSize);

      pipeline.process(frame, sampleRate: sampleRate);
      pipeline.reset();

      final silence = Float32List(frameSize);
      final res = pipeline.process(silence, sampleRate: sampleRate);
      expect(res.isSilence, isTrue);
    });
  });
}
