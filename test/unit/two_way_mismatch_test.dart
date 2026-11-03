import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/pitch/two_way_mismatch.dart';

void main() {
  group('Two-Way Mismatch (TWM) Unit Tests matching Kotlin baseline', () {
    test('idealHarmonicSeries identifies fundamental with minimal error', () {
      const fundamental = 220.0; // A3
      final peaks = [
        const SpectralPeak(220.0, 1.0),
        const SpectralPeak(440.0, 0.8),
        const SpectralPeak(660.0, 0.6),
        const SpectralPeak(880.0, 0.4),
        const SpectralPeak(1100.0, 0.2),
      ];

      final result = TwoWayMismatchDetector.findPitchFromPeaks(
        peaks,
        frequencyMin: 50.0,
        frequencyMax: 1500.0,
      );

      expect(
        result.frequency,
        closeTo(fundamental, 2.0),
        reason: 'Detected fundamental should match 220Hz',
      );
      expect(result.error, lessThan(0.05));
      expect(result.confidence, greaterThan(0.9));
    });

    test(
      'missingFundamental identifies virtual pitch (resolves BUG-05 ACOUSTIC-03)',
      () {
        // Missing fundamental scenario: 220Hz is completely absent from the spectrum.
        // Only overtones at 440, 660, 880, 1100Hz exist (characteristic of cello/bass strings).
        // TWM must successfully reconstruct 220Hz because selecting 440Hz would leave
        // the observed 660Hz and 1100Hz peaks completely unexplained by predicted harmonics.
        final peaks = [
          const SpectralPeak(440.0, 0.9),
          const SpectralPeak(660.0, 0.8),
          const SpectralPeak(880.0, 0.5),
          const SpectralPeak(1100.0, 0.3),
        ];

        final result = TwoWayMismatchDetector.findPitchFromPeaks(
          peaks,
          frequencyMin: 100.0,
          frequencyMax: 1500.0,
        );

        expect(
          result.frequency,
          closeTo(220.0, 2.0),
          reason:
              'Missing fundamental should be accurately reconstructed as 220Hz virtual pitch',
        );
        expect(result.confidence, greaterThan(0.6));
      },
    );

    test('inharmonicSeries accommodates string stiffness coefficient B', () {
      const b = 0.0004;
      const f0 = 100.0;
      final peaks = <SpectralPeak>[];
      for (var n = 1; n <= 6; n++) {
        final fn = n * f0 * math.sqrt(1.0 + b * n * n);
        peaks.add(SpectralPeak(fn, 1.0 / n));
      }

      final mismatch = TwoWayMismatchDetector.computeMismatch(
        100.0,
        peaks,
        inharmonicity: b,
      );

      expect(
        mismatch,
        lessThan(0.05),
        reason: 'Mismatch with inharmonicity factor should be very low',
      );
    });

    test('detectPitch on time-domain PCM samples with missing fundamental', () {
      const sampleRate = 44100;
      const f0 = 150.0; // Fundamental (absent in time series)
      const numSamples = 2048;

      // Construct signal with 2nd, 3rd, 4th, 5th harmonics only
      final samples = Float32List(numSamples);
      for (var i = 0; i < numSamples; i++) {
        final t = i / sampleRate;
        samples[i] =
            0.8 * math.sin(2.0 * math.pi * 2.0 * f0 * t) + // 300 Hz
            1.0 * math.sin(2.0 * math.pi * 3.0 * f0 * t) + // 450 Hz
            0.6 * math.sin(2.0 * math.pi * 4.0 * f0 * t) + // 600 Hz
            0.4 * math.sin(2.0 * math.pi * 5.0 * f0 * t); // 750 Hz
      }

      final detector = TwoWayMismatchDetector(maxMismatchError: 0.45);
      final result = detector.detectPitch(
        samples: samples,
        sampleRate: sampleRate,
        frequencyMin: 80.0,
        frequencyMax: 1000.0,
      );

      expect(result.isSilence, isFalse);
      expect(
        result.frequency,
        closeTo(f0, 4.0),
        reason:
            'Time-domain PCM detection should reconstruct 150 Hz missing fundamental',
      );
      expect(result.confidence, greaterThan(0.5));
    });

    test('silence and insufficient peaks return silent result', () {
      final detector = TwoWayMismatchDetector();
      final zeroSamples = Float32List(1024);

      final result = detector.detectPitch(
        samples: zeroSamples,
        sampleRate: 44100,
      );

      expect(result.isSilence, isTrue);
      expect(result.frequency, equals(0.0));

      final emptyPeaks = TwoWayMismatchDetector.findPitchFromPeaks(const []);
      expect(emptyPeaks.frequency, equals(0.0));
      expect(emptyPeaks.confidence, equals(0.0));
    });

    test(
      'high-frequency whistle tone (1600 Hz) does not fall into subharmonic trap',
      () {
        final detector = TwoWayMismatchDetector();
        const sampleRate = 44100;
        const freq = 1620.0;
        const size = 2048;

        final samples = Float32List(size);
        for (var i = 0; i < size; i++) {
          samples[i] = 0.8 * math.sin(2.0 * math.pi * freq * (i / sampleRate));
        }

        final result = detector.detectPitch(
          samples: samples,
          sampleRate: sampleRate,
        );

        expect(result.isSilence, isFalse);
        expect(result.frequency, closeTo(1620.0, 5.0));
        expect(result.confidence, greaterThan(0.5));
      },
    );
  });
}
