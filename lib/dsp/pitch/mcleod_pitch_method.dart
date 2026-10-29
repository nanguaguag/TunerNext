import 'dart:math' as math;
import 'dart:typed_data';
import '../correlation/auto_correlation.dart';
import 'pitch_detector_interface.dart';
import 'polynomial_fit.dart';

/// McLeod Pitch Method (MPM) pitch detector.
///
/// References:
/// Philip McLeod and Geoff Wyvill, "A Smarter Way to Find Pitch", ICMC 2005.
///
/// Utilizes the Normalized Square Difference Function (NSDF) with first-peak thresholding
/// to eliminate octave-doubling errors typical of violin bowing transients and woodwinds.
class McLeodPitchDetector implements PitchDetector {
  McLeodPitchDetector({
    this.cutoffClarity = 0.45,
    this.peakThresholdRatio = 0.85,
  });

  /// Minimum periodicity clarity required to declare a voiced pitch.
  final double cutoffClarity;

  /// Threshold factor k applied to the global maximum NSDF peak.
  final double peakThresholdRatio;

  CorrelationComputer? _correlator;
  AutoCorrelationData? _autoCorr;
  Float32List? _nsdfBuffer;

  @override
  PitchDetectionResult detectPitch({
    required Float32List samples,
    required int sampleRate,
    double frequencyMin = 16.0,
    double frequencyMax = 20000.0,
    int? framePosition,
  }) {
    final size = samples.length;
    if (size < 64) return PitchDetectionResult.silence;

    // Check RMS silence threshold
    var sumSq = 0.0;
    for (var i = 0; i < size; i++) {
      sumSq += samples[i] * samples[i];
    }
    final rms = math.sqrt(sumSq / size);
    if (rms < 1e-4) return PitchDetectionResult.silence;

    final dt = 1.0 / sampleRate;
    _correlator ??= CorrelationComputer(size);
    _autoCorr ??= AutoCorrelationData(size: size, dt: dt);
    _nsdfBuffer ??= Float32List(size);

    _correlator!.compute(samples, _autoCorr!);

    final r0 = _autoCorr!.values[0];
    if (r0 <= 1e-9 || r0.isNaN) return PitchDetectionResult.silence;

    // 1. Compute NSDF from precomputed zero-padded autocorrelation
    _nsdfBuffer![0] = 1.0;
    final limit = size ~/ 2;
    for (var tau = 1; tau < limit; tau++) {
      final taper = (size - tau) / size;
      final denom = 2.0 * r0 * taper;
      if (denom > 1e-9) {
        final nsdfVal = (2.0 * _autoCorr!.values[tau] / denom).clamp(-1.0, 1.0);
        _nsdfBuffer![tau] = nsdfVal;
      } else {
        _nsdfBuffer![tau] = 0.0;
      }
    }

    // 2. Identify candidate lags within allowed frequency bounds
    final minLag = (frequencyMax > 0.0)
        ? (sampleRate / frequencyMax).floor().clamp(1, limit - 2)
        : 1;
    final maxLag = (frequencyMin > 0.0)
        ? (sampleRate / frequencyMin).ceil().clamp(minLag + 1, limit - 1)
        : limit - 1;

    if (minLag >= maxLag) return PitchDetectionResult.silence;

    // 3. Find all positive local maxima and record global maximum peak
    final peakIndices = <int>[];
    var maxPeakVal = double.negativeInfinity;

    for (var tau = minLag; tau < maxLag; tau++) {
      final val = _nsdfBuffer![tau];
      if (val > 0.0 &&
          val >= _nsdfBuffer![tau - 1] &&
          val >= _nsdfBuffer![tau + 1]) {
        peakIndices.add(tau);
        if (val > maxPeakVal) {
          maxPeakVal = val;
        }
      }
    }

    if (peakIndices.isEmpty || maxPeakVal < cutoffClarity) {
      return PitchDetectionResult(
        frequency: 0.0,
        confidence: maxPeakVal.clamp(0.0, 1.0),
        periodSamples: 0.0,
        isSilence: true,
      );
    }

    // 4. Select the FIRST peak that reaches peakThresholdRatio * maxPeakVal
    // (Key step eliminating octave doubling / subharmonic confusion)
    final threshold = maxPeakVal * peakThresholdRatio;
    var chosenLagIndex = peakIndices.first;
    for (final idx in peakIndices) {
      if (_nsdfBuffer![idx] >= threshold) {
        chosenLagIndex = idx;
        break;
      }
    }

    // 5. Parabolic refinement of peak
    final fit = getPeakOfPolynomialFit(
      _nsdfBuffer![chosenLagIndex - 1],
      _nsdfBuffer![chosenLagIndex],
      _nsdfBuffer![chosenLagIndex + 1],
      chosenLagIndex.toDouble(),
      1.0,
    );

    final fittedLag = fit.timeOrIndex;
    final clarity = fit.value.clamp(0.0, 1.0);

    if (fittedLag <= 0.0 || clarity < cutoffClarity) {
      return PitchDetectionResult.silence;
    }

    final frequency = sampleRate / fittedLag;
    if (frequency < frequencyMin || frequency > frequencyMax) {
      return PitchDetectionResult.silence;
    }

    return PitchDetectionResult(
      frequency: frequency,
      confidence: clarity,
      periodSamples: fittedLag,
      isSilence: false,
      noiseRatio: (1.0 - clarity).clamp(0.0, 1.0),
      harmonicEnergy: rms,
    );
  }

  @override
  void reset() {
    _nsdfBuffer?.fillRange(0, _nsdfBuffer!.length, 0.0);
  }
}
