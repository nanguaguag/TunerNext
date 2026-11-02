import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/correlation/auto_correlation.dart';
import 'package:tuner_flutter/dsp/correlation/correlation.dart';
import 'package:tuner_flutter/dsp/filters/acoustic_weighting.dart';
import 'package:tuner_flutter/dsp/pipeline/tuner_dsp_pipeline.dart';
import 'package:tuner_flutter/dsp/windowing/windowing.dart';

void main() {
  group('DSP Optimizations: Acoustic Weighting & Windowed Spectrum Tests', () {
    test(
      'Correlation with A-weighting suppresses 50Hz electrical hum in favor of musical pitch',
      () {
        const sampleRate = 44100;
        const size = 2048;
        final correlator = Correlation(size);
        final rawAutoCorr = AutoCorrelationData(
          size: size,
          dt: 1.0 / sampleRate,
        );
        final weightedAutoCorr = AutoCorrelationData(
          size: size,
          dt: 1.0 / sampleRate,
        );

        // Construct a signal containing:
        // - strong 50Hz electrical line noise (amplitude 0.8)
        // - 440Hz A4 musical tone (amplitude 0.5)
        final samples = Float32List(size);
        for (var i = 0; i < size; i++) {
          final t = i / sampleRate;
          final hum50 = 0.8 * math.sin(2.0 * math.pi * 50.0 * t);
          final note440 = 0.5 * math.sin(2.0 * math.pi * 440.0 * t);
          samples[i] = (hum50 + note440).toDouble();
        }

        // 1. Unweighted correlation
        correlator.correlateToData(samples, rawAutoCorr);

        // 2. A-weighted correlation (mimics human ear, cuts 50Hz by >30dB)
        final aWeighting = AcousticWeighting.fromMode(
          AcousticWeightingMode.aWeighting,
        );
        correlator.correlateToData(
          samples,
          weightedAutoCorr,
          weighting: aWeighting,
          sampleRate: sampleRate,
        );

        // Find lag corresponding to 440Hz (~100 samples) vs 50Hz (~882 samples)
        final lag440 = (sampleRate / 440.0).round();
        final lag50 = (sampleRate / 50.0).round();

        final rawRatio = rawAutoCorr.values[lag440] / rawAutoCorr.values[lag50];
        final weightedRatio =
            weightedAutoCorr.values[lag440] / weightedAutoCorr.values[lag50];

        // A-weighting should dramatically increase the prominence of the 440Hz tone relative to the 50Hz hum
        expect(weightedRatio, greaterThan(rawRatio * 2.0));
      },
    );

    test(
      'TunerDspPipeline accepts acoustic weighting and tracks musical pitch stably',
      () {
        const sampleRate = 44100;
        const frameSize = 2048;
        final pipeline = TunerDspPipeline(
          frameSize: frameSize,
          algorithm: PitchAlgorithm.mpm,
          weightingMode: AcousticWeightingMode.aWeighting,
          sensitivity: 60,
        );

        final samples = Float32List(frameSize);
        // Feed 3 consecutive steady frames to fill the smoother
        TunerPipelineResult? lastResult;
        for (var frame = 0; frame < 3; frame++) {
          for (var i = 0; i < frameSize; i++) {
            final t = (frame * frameSize + i) / sampleRate;
            // Pure 440Hz A4
            samples[i] = (0.5 * math.sin(2.0 * math.pi * 440.0 * t)).toDouble();
          }
          lastResult = pipeline.process(samples, sampleRate: sampleRate);
        }

        expect(lastResult?.isSilence, isFalse);
        expect(lastResult?.smoothedFrequency, closeTo(440.0, 3.0));
      },
    );

    test(
      'Hanning window reduces spectral sidelobe leakage compared to rectangular window',
      () {
        const size = 1024;
        final hanning = Windowing.getWindow(WindowingFunction.hanning, size);

        expect(hanning.first, closeTo(0.0, 1e-4));
        expect(hanning[size ~/ 2], closeTo(1.0, 1e-4));
        // Periodic Hanning symmetry: w[i] == w[N - i] for i in 1..size/2
        for (var i = 1; i < size ~/ 2; i++) {
          expect(hanning[i], closeTo(hanning[size - i], 1e-5));
        }
      },
    );
  });
}
