import 'dart:math' as math;
import 'dart:typed_data';
import '../correlation/auto_correlation.dart';
import '../correlation/correlation.dart';
import '../filters/acoustic_weighting.dart';
import 'pitch_detector_interface.dart';
import 'polynomial_fit.dart';

/// McLeod Pitch Method (MPM) pitch detection engine.
///
/// References:
/// Philip McLeod and Geoff Wyvill, "A Smarter Way to Find Pitch", ICMC 2005.
///
/// MPM evaluates the Normalized Square Difference Function (NSDF) and selects
/// the first peak exceeding a ratio [peakThresholdRatio] of the global maximum peak,
/// completely eliminating octave-doubling confusion typical of string instruments.
class McLeodPitchDetector implements PitchDetector {
  /// Creates an instance of [McLeodPitchDetector].
  ///
  /// - [cutoffClarity]: Minimum NSDF peak height (clarity) required to consider
  ///   the signal voiced (default 0.45).
  /// - [peakThresholdRatio]: Fractional multiplier $k$ applied to the global
  ///   maximum peak to select the first peak (default 0.85).
  McLeodPitchDetector({
    this.cutoffClarity = 0.45,
    this.peakThresholdRatio = 0.85,
  });

  /// Minimum periodicity clarity required to declare a voiced pitch.
  final double cutoffClarity;

  /// Threshold factor $k$ applied to the global maximum NSDF peak.
  final double peakThresholdRatio;

  Correlation? _correlator;
  AutoCorrelationData? _autoCorr;
  Float32List? _nsdfBuffer;

  /// Calculates the Normalized Square Difference Function (NSDF) directly from time-domain samples.
  ///
  /// Formula:
  /// $$n[\tau] = \frac{2 \sum_{j=0}^{W-1} x[j] x[j+\tau]}{\sum_{j=0}^{W-1} x[j]^2 + \sum_{j=0}^{W-1} x[j+\tau]^2}$$
  static void computeNsdfDirect(
    Float32List samples,
    Float32List nsdfOut, {
    int? maxLag,
  }) {
    final effectiveMaxLag =
        maxLag ?? math.min(samples.length ~/ 2, nsdfOut.length);
    final windowSize = samples.length - effectiveMaxLag;
    if (windowSize <= 0) return;

    var energy0 = 0.0;
    for (var j = 0; j < windowSize; j++) {
      final v = samples[j];
      energy0 += v * v;
    }

    var energyTau = energy0;
    nsdfOut[0] = 1.0;

    for (var tau = 1; tau < effectiveMaxLag; tau++) {
      final oldVal = samples[tau - 1];
      final newVal = samples[tau + windowSize - 1];
      energyTau = math.max(0.0, energyTau - oldVal * oldVal + newVal * newVal);

      var crossCorr = 0.0;
      for (var j = 0; j < windowSize; j++) {
        crossCorr += samples[j] * samples[j + tau];
      }

      final denom = energy0 + energyTau;
      nsdfOut[tau] = denom > 1e-9
          ? (2.0 * crossCorr / denom).clamp(-1.0, 1.0)
          : 0.0;
    }
  }

  /// Calculates the NSDF approximation from zero-padded autocorrelation values.
  ///
  /// For quasi-stationary frames:
  /// $$\sum x[j]^2 + \sum x[j+\tau]^2 \approx 2 R_{xx}[0] \cdot \frac{N - \tau}{N}$$
  static void computeNsdfFromCorrelation(
    AutoCorrelationData autoCorrelation,
    Float32List nsdfOut,
  ) {
    final r0 = autoCorrelation.values[0];
    if (r0 <= 1e-9 || r0.isNaN) {
      nsdfOut.fillRange(0, nsdfOut.length, 0.0);
      return;
    }

    final n = autoCorrelation.size;
    final limit = math.min(n ~/ 2, nsdfOut.length);
    nsdfOut[0] = 1.0;

    for (var tau = 1; tau < limit; tau++) {
      final taper = (n - tau) / n;
      final denom = 2.0 * r0 * taper;
      nsdfOut[tau] = denom > 1e-9
          ? (2.0 * autoCorrelation.values[tau] / denom).clamp(-1.0, 1.0)
          : 0.0;
    }
  }

  @override
  PitchDetectionResult detectPitch({
    required Float32List samples,
    required int sampleRate,
    double frequencyMin = 16.0,
    double frequencyMax = 20000.0,
    AcousticWeighting? weighting,
  }) {
    final size = samples.length;
    if (size < 64) return PitchDetectionResult.silence;

    // 1. RMS silence gate (ACOUSTIC-01 Layer 1)
    var sumSq = 0.0;
    for (var i = 0; i < size; i++) {
      final s = samples[i];
      sumSq += s * s;
    }
    final rms = math.sqrt(sumSq / size);
    if (rms < 1e-4) return PitchDetectionResult.silence;

    final dt = 1.0 / sampleRate;
    if (_correlator == null ||
        _correlator!.size != size ||
        _autoCorr?.size != size ||
        _autoCorr?.dt != dt) {
      _correlator = Correlation(size);
      _autoCorr = AutoCorrelationData(size: size, dt: dt);
      _nsdfBuffer = Float32List(size ~/ 2);
    }

    // 2. Fast autocorrelation via FFT with optional acoustic weighting
    _correlator!.correlateToData(
      samples,
      _autoCorr!,
      weighting: weighting,
      sampleRate: sampleRate,
    );

    final r0 = _autoCorr!.values[0];
    if (r0 <= 1e-9 || r0.isNaN) return PitchDetectionResult.silence;

    // 3. Compute NSDF sequence
    computeNsdfFromCorrelation(_autoCorr!, _nsdfBuffer!);

    // 4. Calculate search range for candidate lags
    final limit = size ~/ 2;
    final minLag = (frequencyMax > 0.0)
        ? (sampleRate / frequencyMax).floor().clamp(1, limit - 2)
        : 1;
    final maxLag = (frequencyMin > 0.0)
        ? (sampleRate / frequencyMin).ceil().clamp(minLag + 1, limit - 1)
        : limit - 1;

    if (minLag >= maxLag) return PitchDetectionResult.silence;

    // 5. Search for positive local maxima
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
        noiseRatio: 1.0,
      );
    }

    // 6. First-Peak Thresholding: select FIRST peak >= threshold
    final threshold = maxPeakVal * peakThresholdRatio;
    var chosenLagIndex = -1;
    for (final idx in peakIndices) {
      if (_nsdfBuffer![idx] >= threshold) {
        chosenLagIndex = idx;
        break;
      }
    }

    if (chosenLagIndex < 1 || chosenLagIndex >= limit - 1) {
      return PitchDetectionResult.silence;
    }

    // 7. Parabolic interpolation for sub-sample accuracy
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
