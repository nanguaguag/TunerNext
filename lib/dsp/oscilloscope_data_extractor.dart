// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'correlation/auto_correlation.dart';

/// Container for extracted oscilloscope plot buffers.
class ExtractedOscilloscopeData {
  const ExtractedOscilloscopeData({
    this.spectrum,
    this.correlation,
    this.correlationZero = 0.0,
  });

  final Float32List? spectrum;
  final Float32List? correlation;
  final double correlationZero;
}

/// Helper for extracting normalized frequency spectrum and autocorrelation
/// waveforms from an audio frame for real-time oscilloscope visualization.
class OscilloscopeDataExtractor {
  OscilloscopeDataExtractor({
    required this.windowSize,
    required this.sampleRate,
  }) : _correlationComputer = CorrelationComputer(windowSize),
       _autoCorrData = AutoCorrelationData(
         size: windowSize,
         dt: 1.0 / sampleRate,
       ),
       _rawSpectrumBuffer = Float32List(2 * windowSize + 2);

  final int windowSize;
  final int sampleRate;
  final CorrelationComputer _correlationComputer;
  final AutoCorrelationData _autoCorrData;
  final Float32List _rawSpectrumBuffer;

  ExtractedOscilloscopeData extract({
    required Float32List samples,
    required bool exportSpectrum,
    required bool exportCorrelation,
  }) {
    if (!exportSpectrum && !exportCorrelation) {
      return const ExtractedOscilloscopeData();
    }

    _correlationComputer.compute(
      samples,
      _autoCorrData,
      spectrumOut: _rawSpectrumBuffer,
    );

    Float32List? correlation;
    var correlationZero = 0.0;
    if (exportCorrelation) {
      correlation = Float32List.fromList(_autoCorrData.plotValuesNormalized);
      correlationZero = _autoCorrData.plotValuesNormalizedZero;
    }

    Float32List? spectrum;
    if (exportSpectrum) {
      final n = windowSize;
      final spec = Float32List(n + 1);
      var minP = double.infinity;
      var maxP = double.negativeInfinity;

      for (var i = 0; i <= n; i++) {
        final re = _rawSpectrumBuffer[2 * i];
        final im = _rawSpectrumBuffer[2 * i + 1];
        final p = re * re + im * im;
        spec[i] = p;
        if (p < minP) minP = p;
        if (p > maxP) maxP = p;
      }

      final range = maxP - minP;
      if (range > 1e-9) {
        final invRange = 1.0 / range;
        for (var i = 0; i <= n; i++) {
          spec[i] = math.max(0.0, (spec[i] - minP) * invRange);
        }
      } else {
        spec.fillRange(0, n + 1, 0.0);
      }
      spectrum = spec;
    }

    return ExtractedOscilloscopeData(
      spectrum: spectrum,
      correlation: correlation,
      correlationZero: correlationZero,
    );
  }
}
