import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_pipeline_coordinator.dart';
import 'package:tuner_flutter/dsp/fft/fft.dart';

void main() {
  group('Regression Test: BUG-P1-05 Spectrum & Correlation High-Fidelity Rendering', () {
    const sampleRate = 44100;
    const windowSize = 2048;

    test(
      'Full spectrum resolution preserves multi-peak harmonic structure without step decimation',
      () {
        final fft = FFT(windowSize);
        final samples = Float32List(windowSize);

        // Generate rich tone: 440 Hz (f0), 880 Hz (2f0), 1320 Hz (3f0)
        for (var i = 0; i < windowSize; i++) {
          final t = i / sampleRate;
          samples[i] =
              0.5 * math.sin(2 * math.pi * 440.0 * t) +
              0.3 * math.sin(2 * math.pi * 880.0 * t) +
              0.2 * math.sin(2 * math.pi * 1320.0 * t);
        }

        final fftOut = Float32List(windowSize + 2);
        fft.fftReal(samples, fftOut);

        final numBins = windowSize ~/ 2 + 1;
        final powerSpectrum = Float32List(numBins);
        var minVal = double.infinity;
        var maxVal = double.negativeInfinity;
        for (var i = 0; i < numBins; i++) {
          final re = fftOut[2 * i];
          final im = fftOut[2 * i + 1];
          final ampSqr = re * re + im * im;
          powerSpectrum[i] = ampSqr;
          if (ampSqr < minVal) minVal = ampSqr;
          if (ampSqr > maxVal) maxVal = ampSqr;
        }
        final scale = (maxVal - minVal > 1e-9) ? 1.0 / (maxVal - minVal) : 1.0;
        for (var i = 0; i < numBins; i++) {
          powerSpectrum[i] = ((powerSpectrum[i] - minVal) * scale).clamp(
            0.0,
            1.0,
          );
        }

        final lineCoords =
            AudioPipelineCoordinator.convertSpectrumToLineCoordinates(
              powerSpectrum,
              sampleRate: sampleRate,
              windowSize: windowSize,
            );

        expect(lineCoords, isNotNull);
        // All 1025 bins must be preserved without 6-bin decimation dropping sharp peaks
        expect(lineCoords!.size, equals(numBins));

        // Locate peaks near 440, 880, 1320 Hz
        double findPeakNear(double targetFreq) {
          var highest = 0.0;
          for (var i = 0; i < lineCoords.size; i++) {
            final pt = lineCoords[i];
            if ((pt.dx - targetFreq).abs() < 25.0) {
              if (pt.dy > highest) highest = pt.dy;
            }
          }
          return highest;
        }

        // Fundamental and harmonics should stand out sharply as distinct prominent peaks
        expect(findPeakNear(440.0), closeTo(1.0, 0.05));
        expect(findPeakNear(880.0), greaterThan(0.2));
        expect(findPeakNear(1320.0), greaterThan(0.08));
      },
    );

    test(
      'Full correlation density preserves complete continuous wave points without jagged downsampling',
      () {
        const count = 1024;
        final values = Float32List(count);
        final times = Float32List(count);

        for (var i = 0; i < count; i++) {
          times[i] = i * (1.0 / sampleRate);
          values[i] = math.cos(2 * math.pi * 440.0 * times[i]);
        }

        final lineCoords =
            AudioPipelineCoordinator.convertCorrelationToLineCoordinates(
              values,
              times,
            );

        expect(lineCoords, isNotNull);
        // Must maintain full 1024 sample fidelity without 200-point decimation
        expect(lineCoords!.size, equals(count));
        expect(lineCoords[0].dy, closeTo(1.0, 0.001));
      },
    );
  });
}
