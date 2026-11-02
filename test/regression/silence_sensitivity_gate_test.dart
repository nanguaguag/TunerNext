import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/pipeline/tuner_dsp_pipeline.dart';

void main() {
  group('Regression Test: BUG-P1-04 Silence & Sensitivity Dynamic Gate', () {
    const sampleRate = 44100;
    const frameSize = 2048;

    Float32List generateSine(
      double freq,
      double durationSeconds,
      double amplitude,
    ) {
      final totalSamples = (durationSeconds * sampleRate).round();
      final samples = Float32List(totalSamples);
      for (var i = 0; i < totalSamples; i++) {
        samples[i] =
            amplitude * math.sin(2.0 * math.pi * freq * (i / sampleRate));
      }
      return samples;
    }

    Float32List generateNoise(int length, double rmsAmplitude) {
      final random = math.Random(12345);
      final samples = Float32List(length);
      for (var i = 0; i < length; i++) {
        samples[i] = (random.nextDouble() * 2.0 - 1.0) * rmsAmplitude * 1.732;
      }
      return samples;
    }

    test(
      'transformEnergyToLevelFrom0To100 matches Kotlin logarithmic formula',
      () {
        // 1e-7 -> 0.0
        expect(
          TunerDspPipeline.transformEnergyToLevelFrom0To100(1e-7),
          closeTo(0.0, 0.01),
        );
        // 1e-2 -> 100.0
        expect(
          TunerDspPipeline.transformEnergyToLevelFrom0To100(1e-2),
          closeTo(100.0, 0.01),
        );
        // 1e-4.5 (midpoint of -7 and -2 in log scale) -> 50.0
        expect(
          TunerDspPipeline.transformEnergyToLevelFrom0To100(
            math.pow(10, -4.5).toDouble(),
          ),
          closeTo(50.0, 0.1),
        );
      },
    );

    test(
      'Ambient microphone noise (RMS ~0.001) is rejected under default sensitivity 50',
      () {
        final pipeline = TunerDspPipeline(
          frameSize: frameSize,
          sensitivity: 50,
        );

        // Typical quiet room noise with RMS around 0.001
        final ambientNoise = generateNoise(frameSize, 0.001);
        final res = pipeline.process(ambientNoise, sampleRate: sampleRate);

        // Must be marked as silence, preventing random pitch hopping during quiet state
        expect(res.isSilence, isTrue);
        expect(res.rawFrequency, equals(0.0));
        expect(res.smoothedFrequency, equals(0.0));
      },
    );

    test(
      'Legitimate soft musical tone (RMS ~0.02) passes sensitivity 50 gate smoothly',
      () {
        final pipeline = TunerDspPipeline(
          frameSize: frameSize,
          sensitivity: 50,
        );

        // Soft 440 Hz tone, amplitude 0.03 -> RMS ~0.021
        final tone = generateSine(440.0, 0.1, 0.03);

        late TunerPipelineResult lastResult;
        for (var offset = 0; offset + frameSize <= tone.length; offset += 512) {
          final frame = tone.sublist(offset, offset + frameSize);
          lastResult = pipeline.process(frame, sampleRate: sampleRate);
        }

        expect(lastResult.isSilence, isFalse);
        expect(lastResult.rawFrequency, closeTo(440.0, 1.0));
        expect(lastResult.smoothedFrequency, closeTo(440.0, 1.0));
      },
    );

    test(
      'High sensitivity 90 allows ultra-weak signal detection while sensitivity 30 suppresses it',
      () {
        final pipelineHighSens = TunerDspPipeline(
          frameSize: frameSize,
          sensitivity: 90,
        );

        // Ultra-soft tone, amplitude 0.005 -> RMS ~0.0035, energy ~1.2e-5, level ~22
        final weakTone = generateSine(440.0, 0.05, 0.005).sublist(0, frameSize);

        final resHigh = pipelineHighSens.process(
          weakTone,
          sampleRate: sampleRate,
        );
        // Under sensitivity 90, required level is 10, so 22 >= 10 -> detected!
        expect(resHigh.isSilence, isFalse);

        final pipelineLowSens = TunerDspPipeline(
          frameSize: frameSize,
          sensitivity: 30,
        );
        final resLow = pipelineLowSens.process(
          weakTone,
          sampleRate: sampleRate,
        );
        // Under sensitivity 30, required level is 70, so 22 < 70 -> suppressed as silence!
        expect(resLow.isSilence, isTrue);
      },
    );
  });
}
