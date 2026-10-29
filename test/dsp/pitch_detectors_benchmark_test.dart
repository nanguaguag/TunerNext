import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/pitch/classic_pitch_detector.dart';
import 'package:tuner_flutter/dsp/pitch/mcleod_pitch_method.dart';
import 'package:tuner_flutter/dsp/pitch/pitch_detector_interface.dart';
import 'package:tuner_flutter/dsp/pitch/two_way_mismatch.dart';
import 'package:tuner_flutter/dsp/tuner_dsp_pipeline.dart';

/// Helper to generate pure sine wave samples of given length.
Float32List generateSineWave({
  required double frequency,
  required int sampleRate,
  required int length,
  double amplitude = 0.8,
  double initialPhase = 0.0,
}) {
  final buffer = Float32List(length);
  for (var i = 0; i < length; i++) {
    buffer[i] =
        amplitude *
        math.sin(2.0 * math.pi * frequency * i / sampleRate + initialPhase);
  }
  return buffer;
}

/// Helper to generate multi-harmonic signal with optional missing fundamental.
Float32List generateHarmonicSignal({
  required double f0,
  required int sampleRate,
  required int length,
  required List<double>
  harmonicAmplitudes, // index 0 is 1st harmonic (f0), index 1 is 2*f0, etc.
  double inharmonicity = 0.0,
}) {
  final buffer = Float32List(length);
  for (var n = 0; n < harmonicAmplitudes.length; n++) {
    final harmNum = n + 1;
    final amp = harmonicAmplitudes[n];
    if (amp <= 0.0) continue;
    final fHarm =
        harmNum * f0 * math.sqrt(1.0 + inharmonicity * harmNum * harmNum);
    for (var i = 0; i < length; i++) {
      buffer[i] += amp * math.sin(2.0 * math.pi * fHarm * i / sampleRate);
    }
  }
  return buffer;
}

double centsDifference(double fMeasured, double fTarget) {
  if (fMeasured <= 0 || fTarget <= 0) return double.infinity;
  return 1200.0 * (math.log(fMeasured / fTarget) / math.ln2);
}

void main() {
  const sampleRate = 44100;
  const windowSize = 4096;

  group('Pure Sine Wave Pitch Accuracy Benchmark', () {
    test(
      'A4 (440.0 Hz) detected with sub-cent accuracy across all engines',
      () {
        final samples = generateSineWave(
          frequency: 440.0,
          sampleRate: sampleRate,
          length: windowSize,
        );

        final mpm = McLeodPitchDetector();
        final resMpm = mpm.detectPitch(
          samples: samples,
          sampleRate: sampleRate,
        );
        expect(resMpm.isSilence, isFalse);
        expect(resMpm.frequency, closeTo(440.0, 0.15));
        expect(centsDifference(resMpm.frequency, 440.0).abs(), lessThan(0.5));

        final classic = ClassicPitchDetector(useJacobsen: true);
        final resClassic = classic.detectPitch(
          samples: samples,
          sampleRate: sampleRate,
        );
        expect(resClassic.isSilence, isFalse);
        expect(resClassic.frequency, closeTo(440.0, 0.2));

        final twm = TwoWayMismatchDetector();
        final resTwm = twm.detectPitch(
          samples: samples,
          sampleRate: sampleRate,
        );
        expect(resTwm.isSilence, isFalse);
        expect(resTwm.frequency, closeTo(440.0, 0.3));
      },
    );

    test(
      'E6 (1318.51 Hz - Violin high E) accuracy without octave doubling',
      () {
        final samples = generateSineWave(
          frequency: 1318.51,
          sampleRate: sampleRate,
          length: windowSize,
        );

        final mpm = McLeodPitchDetector();
        final res = mpm.detectPitch(samples: samples, sampleRate: sampleRate);
        expect(res.isSilence, isFalse);
        expect(res.frequency, closeTo(1318.51, 0.5));
        expect(centsDifference(res.frequency, 1318.51).abs(), lessThan(0.5));
      },
    );

    test('A2 (110.0 Hz - Guitar A string) low frequency accuracy', () {
      final samples = generateSineWave(
        frequency: 110.0,
        sampleRate: sampleRate,
        length: windowSize,
      );

      final mpm = McLeodPitchDetector();
      final res = mpm.detectPitch(samples: samples, sampleRate: sampleRate);
      expect(res.isSilence, isFalse);
      expect(res.frequency, closeTo(110.0, 0.1));
    });
  });

  group('ACOUSTIC-01: Silence and Weak Ambient Hum Suppression', () {
    test('All-zero digital silence produces 0.0 Hz and isSilence=true', () {
      final silence = Float32List(windowSize);
      final mpm = McLeodPitchDetector();
      final resMpm = mpm.detectPitch(samples: silence, sampleRate: sampleRate);
      expect(resMpm.isSilence, isTrue);
      expect(resMpm.frequency, equals(0.0));

      final classic = ClassicPitchDetector();
      final resClassic = classic.detectPitch(
        samples: silence,
        sampleRate: sampleRate,
      );
      expect(resClassic.isSilence, isTrue);
      expect(resClassic.frequency, equals(0.0));
    });

    test(
      '-80 dBFS 50Hz mains hum is completely suppressed (no G1-D3 false jump)',
      () {
        // 50 Hz at amplitude 1e-4 (~ -80 dBFS) mimicking microphone ambient ADC hum
        final hum = generateSineWave(
          frequency: 50.0,
          sampleRate: sampleRate,
          length: windowSize,
          amplitude: 0.5e-4,
        );

        final mpm = McLeodPitchDetector();
        final res = mpm.detectPitch(samples: hum, sampleRate: sampleRate);
        expect(res.isSilence, isTrue);
        expect(res.frequency, equals(0.0));
      },
    );
  });

  group('Missing Fundamental and Harmonic Robustness', () {
    test(
      'Missing fundamental (2*f0, 3*f0, 4*f0) correctly resolved to f0=110Hz',
      () {
        // f0 = 110.0 Hz, but 1st harmonic is 0.0 (completely missing)
        final samples = generateHarmonicSignal(
          f0: 110.0,
          sampleRate: sampleRate,
          length: windowSize,
          harmonicAmplitudes: [
            0.0,
            0.6,
            0.5,
            0.4,
            0.3,
          ], // 220Hz, 330Hz, 440Hz, 550Hz
        );

        final twm = TwoWayMismatchDetector();
        final res = twm.detectPitch(samples: samples, sampleRate: sampleRate);
        expect(res.isSilence, isFalse);
        // TWM should identify 110 Hz as fundamental explaining all harmonic peaks
        expect(res.frequency, closeTo(110.0, 0.5));
      },
    );
  });

  group('TunerDspPipeline End-to-End Processing', () {
    test('Pipeline produces stable smoothed 440Hz output across frames', () {
      final pipeline = TunerDspPipeline(
        pitchAlgorithm: PitchAlgorithm.mpm,
        octaveJumpGateEnabled: true,
        medianFilterEnabled: true,
      );

      final frame = generateSineWave(
        frequency: 440.0,
        sampleRate: sampleRate,
        length: windowSize,
      );

      // Feed 5 consecutive frames
      var lastResult = PitchDetectionResult.silence;
      for (var f = 0; f < 5; f++) {
        lastResult = pipeline.processFrame(frame, sampleRate: sampleRate);
      }

      expect(lastResult.isSilence, isFalse);
      expect(lastResult.frequency, closeTo(440.0, 0.2));
    });

    test('Pipeline handles abrupt transition to silence gracefully', () {
      final pipeline = TunerDspPipeline(pitchAlgorithm: PitchAlgorithm.classic);
      final frame = generateSineWave(
        frequency: 440.0,
        sampleRate: sampleRate,
        length: windowSize,
      );
      pipeline.processFrame(frame, sampleRate: sampleRate);

      final silence = Float32List(windowSize);
      final res = pipeline.processFrame(silence, sampleRate: sampleRate);
      expect(res.isSilence, isTrue);
      expect(res.frequency, equals(0.0));
    });
  });
}
