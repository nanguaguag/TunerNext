import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/pipeline/tuner_dsp_pipeline.dart';

void main() {
  group(
    'Regression Test: BUG-P1-03 Smoother Outlier Resilience and Noise Rejection',
    () {
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

      Float32List generateWhiteNoise(int length, [double amplitude = 0.3]) {
        final random = math.Random(42);
        final samples = Float32List(length);
        for (var i = 0; i < length; i++) {
          samples[i] = (random.nextDouble() * 2.0 - 1.0) * amplitude;
        }
        return samples;
      }

      test('Outlier during warmup does not leak raw outlier frequency', () {
        final pipeline = TunerDspPipeline(
          frameSize: frameSize,
          smootherOrder: 3,
        );

        // Frame 1: 1500 Hz whistle
        final frame1 = generateSine(1500.0, 0.05).sublist(0, frameSize);
        final res1 = pipeline.process(frame1, sampleRate: sampleRate);
        expect(res1.rawFrequency, closeTo(1500.0, 1.0));
        expect(res1.smoothedFrequency, closeTo(1500.0, 1.0));

        // Frame 2: Outlier 4000 Hz spike
        final frame2 = generateSine(4000.0, 0.05).sublist(0, frameSize);
        final res2 = pipeline.process(frame2, sampleRate: sampleRate);
        expect(res2.rawFrequency, closeTo(4000.0, 5.0));
        // Outlier is rejected, smoothedFrequency holds the 1500 Hz mean, NEVER leaking 4000 Hz!
        expect(res2.smoothedFrequency, closeTo(1500.0, 1.0));
      });

      test(
        'Steady state suppresses transient outlier burst by maintaining smoothed mean',
        () {
          final pipeline = TunerDspPipeline(
            frameSize: frameSize,
            smootherOrder: 3,
          );

          // Feed 3 steady frames of 1000 Hz whistle
          final steadyFrame = generateSine(1000.0, 0.05).sublist(0, frameSize);
          for (var i = 0; i < 3; i++) {
            pipeline.process(steadyFrame, sampleRate: sampleRate);
          }

          // Inject 1 frame of transient high-frequency glitch (e.g. 3500 Hz click/spike)
          final glitchFrame = generateSine(3500.0, 0.05).sublist(0, frameSize);
          final glitchRes = pipeline.process(
            glitchFrame,
            sampleRate: sampleRate,
          );

          // Raw detects 3500 Hz
          expect(glitchRes.rawFrequency, closeTo(3500.0, 5.0));
          // Smoothed must NOT jump to 3500 Hz; it must hold the steady ~1000 Hz mean
          expect(glitchRes.smoothedFrequency, closeTo(1000.0, 2.0));
        },
      );

      test(
        'Turbulent air noise is rejected by noise threshold without polluting smoother',
        () {
          final pipeline = TunerDspPipeline(
            frameSize: frameSize,
            minConfidence: 0.25,
            maxNoiseRatio: 0.80,
          );

          final whiteNoise = generateWhiteNoise(frameSize, 0.4);
          final res = pipeline.process(whiteNoise, sampleRate: sampleRate);

          // Should be flagged as silence / unvoiced due to high noise / low confidence
          expect(res.isSilence, isTrue);
          expect(res.smoothedFrequency, equals(0.0));
        },
      );
    },
  );
}
