import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/analysis/offline_audio_analyzer.dart';

void main() {
  group('OfflineAudioAnalyzer Unit Tests', () {
    test('Analyzes pure sine wave and binary searches frame by time', () async {
      const sampleRate = 44100;
      const durationSec = 1.0;
      final numSamples = (sampleRate * durationSec).toInt();
      final samples = Float32List(numSamples);

      // Generate 440 Hz pure tone
      for (var i = 0; i < numSamples; i++) {
        samples[i] = math.sin(2 * math.pi * 440.0 * i / sampleRate) * 0.8;
      }

      final result = await OfflineAudioAnalyzer.analyze(
        samples: samples,
        sampleRate: sampleRate,
        windowSize: 2048,
        stride: 512,
        algorithm: PitchAlgorithm.mpm,
      );

      expect(result.frames.isNotEmpty, isTrue);
      expect(result.durationSeconds, closeTo(1.0, 0.01));

      // Check middle frame
      final midFrame = result.getFrameAt(0.5);
      expect(midFrame.isSilence, isFalse);
      expect(midFrame.frequency, closeTo(440.0, 3.0));
      expect(midFrame.confidence, greaterThan(0.8));
      expect(midFrame.spectrum, isNotNull);
      expect(midFrame.correlation, isNotNull);

      // Check boundary search
      final startFrame = result.getFrameAt(0.0);
      expect(startFrame.timeSeconds, closeTo(0.0, 0.05));

      final endFrame = result.getFrameAt(2.0); // beyond end
      expect(
        endFrame.timeSeconds,
        closeTo(result.frames.last.timeSeconds, 0.01),
      );

      final freqs = result.extractFrequencies();
      expect(freqs.length, equals(result.frames.length));
    });
  });
}
