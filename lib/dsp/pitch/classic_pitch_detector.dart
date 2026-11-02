import 'dart:math' as math;
import 'dart:typed_data';

import '../correlation/auto_correlation.dart';
import '../correlation/correlation.dart';
import '../filters/acoustic_weighting.dart';
import 'pitch_detector_interface.dart';
import 'polynomial_fit.dart';

/// Checks if an index in an array is a local minimum within a specified neighborhood [radius].
bool isLocalMin(int i, List<double> data, [int radius = 1]) {
  final startIndex = math.max(0, i - radius);
  final endIndex = math.min(data.length, i + radius + 1);
  for (var j = startIndex; j < endIndex; j++) {
    if (i != j && data[j] < data[i]) {
      return false;
    }
  }
  return true;
}

/// Finds the index of the first local minimum in [data].
///
/// Bypasses the initial decline from the zero-lag autocorrelation peak $R_{xx}[0]$.
int findFirstMinimum(List<double> data, [int radius = 2]) {
  for (var i = radius; i < data.length - radius; i++) {
    if (isLocalMin(i, data, radius)) {
      return i;
    }
  }
  return data.length;
}

/// Result of frequency estimation from autocorrelation analysis.
class CorrelationBasedFrequency {
  /// Creates a [CorrelationBasedFrequency] container.
  CorrelationBasedFrequency(
    this.frequency,
    this.timeShift,
    this.correlationAtTimeShift,
  );

  /// Detected fundamental frequency in Hertz.
  double frequency;

  /// Time shift $\tau$ in seconds corresponding to the detected period.
  double timeShift;

  /// Autocorrelation peak magnitude at [timeShift].
  double correlationAtTimeShift;

  /// Updates all result fields in-place.
  void set(double frequency, double timeShift, double correlationAtTimeShift) {
    this.frequency = frequency;
    this.timeShift = timeShift;
    this.correlationAtTimeShift = correlationAtTimeShift;
  }
}

/// Searches for the fundamental frequency from an autocorrelation sequence.
///
/// Implements subharmonic penalty and verification:
/// - Evaluates candidates at `peak / 2, peak / 3, ...` up to `maximumDivision`.
/// - If a shorter lag peak exceeds [subharmonicPeakRatio] of the global peak,
///   it is selected to prevent subharmonic / octave jumping.
/// - Enforces silence threshold: rejects peaks where `maximumValue < 0.15 * R[0]` (ACOUSTIC-01).
void findCorrelationBasedFrequency(
  CorrelationBasedFrequency results,
  AutoCorrelationData correlation, {
  double frequencyMin = 0.0,
  double frequencyMax = 0.0,
  double subharmonicsTolerance = 0.05,
  double subharmonicPeakRatio = 0.8,
}) {
  bool isLocalMax(int i) =>
      correlation[i] >= correlation[i - 1] &&
      correlation[i] >= correlation[i + 1];

  final globalIndexEnd = (frequencyMin > 0.0)
      ? math.min(
          correlation.size - 1,
          (1.0 / (correlation.dt * frequencyMin)).toInt() + 1,
        )
      : correlation.size - 1;

  final firstLocalMinimum = findFirstMinimum(correlation.values);

  final globalIndexBegin = (frequencyMax > 0.0)
      ? math.max(
          (1.0 / (correlation.dt * frequencyMax)).ceil(),
          firstLocalMinimum,
        )
      : firstLocalMinimum;

  if (globalIndexBegin >= globalIndexEnd) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  var globalMaximumIndex = 0;
  var maximumValue = double.negativeInfinity;

  // Search for the global maximum within the admissible frequency range
  for (var i = globalIndexBegin; i < globalIndexEnd; i++) {
    if (correlation[i] > maximumValue && isLocalMax(i)) {
      globalMaximumIndex = i;
      maximumValue = correlation[i];
    }
  }

  if (globalMaximumIndex <= 0 || maximumValue <= 0.0) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  // ACOUSTIC-01: Reject if peak amplitude is too weak compared to energy at zero lag
  if (correlation[0] > 0.0 && maximumValue < 0.15 * correlation[0]) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  final initialFit = getPeakOfPolynomialFitArray(
    globalMaximumIndex,
    correlation.values,
  );
  var fittedMaximumIndex = initialFit.timeOrIndex;
  var fittedPeak = initialFit.value;

  // Check subharmonics (peak/2, peak/3, ...) to prefer the true fundamental period
  final requiredMaximumValue = subharmonicPeakRatio * fittedPeak;
  final maximumDivision = (fittedMaximumIndex / globalIndexBegin).ceil();

  for (var division = maximumDivision; division >= 2; division--) {
    var indexBegin = (fittedMaximumIndex / (division + subharmonicsTolerance))
        .ceil();
    indexBegin = math.max(indexBegin, 1);

    var indexEnd =
        (fittedMaximumIndex / (division - subharmonicsTolerance)).toInt() + 1;
    indexEnd = math.min(indexEnd, correlation.size - 1);

    if (indexEnd - indexBegin < 1) {
      indexBegin = (fittedMaximumIndex / division).round();
      indexEnd = indexBegin + 1;
    }

    var localMaximum = double.negativeInfinity;
    var localMaximumIndex = 0;
    for (var i = indexBegin; i < indexEnd; i++) {
      if (correlation[i] > localMaximum && isLocalMax(i)) {
        localMaximum = correlation[i];
        localMaximumIndex = i;
      }
    }

    if (localMaximumIndex > 0) {
      final localFit = getPeakOfPolynomialFitArray(
        localMaximumIndex,
        correlation.values,
      );
      if (localFit.value >= requiredMaximumValue) {
        fittedMaximumIndex = localFit.timeOrIndex;
        fittedPeak = localFit.value;
        break;
      }
    }
  }

  if (fittedMaximumIndex <= 0.0 || correlation.dt <= 0.0) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  results.set(
    1.0 / (fittedMaximumIndex * correlation.dt),
    fittedMaximumIndex * correlation.dt,
    fittedPeak,
  );
}

/// Simple hill-climbing frequency finder initialized from a prior frequency estimate.
void findCorrelationBasedFrequencySimple({
  required CorrelationBasedFrequency results,
  required AutoCorrelationData correlation,
  required double frequencyPrevious,
  double frequencyMin = 0.0,
  double frequencyMax = 0.0,
}) {
  final globalIndexEnd = (frequencyMin > 0.0)
      ? math.min(
          correlation.size - 1,
          (1.0 / (correlation.dt * frequencyMin)).toInt() + 1,
        )
      : correlation.size - 1;

  final firstLocalMinimum = findFirstMinimum(correlation.values);

  final globalIndexBegin = (frequencyMax > 0.0)
      ? math.max(
          (1.0 / (correlation.dt * frequencyMax)).ceil(),
          firstLocalMinimum,
        )
      : 1;

  if (globalIndexBegin >= globalIndexEnd || frequencyPrevious <= 0.0) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  final searchIndexStart = (1.0 / (correlation.dt * frequencyPrevious))
      .round()
      .clamp(globalIndexBegin, globalIndexEnd);

  var i = searchIndexStart;
  while (i < globalIndexEnd && correlation[i + 1] > correlation[i]) {
    i += 1;
  }

  while (i > globalIndexBegin && correlation[i - 1] > correlation[i]) {
    i -= 1;
  }

  final fit = getPeakOfPolynomialFitArray(i, correlation.values);
  final fittedMaximumIndex = fit.timeOrIndex;
  final fittedPeak = fit.value;

  if (fittedMaximumIndex <= 0.0 || correlation.dt <= 0.0 || fittedPeak <= 0.0) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  if (correlation[0] > 0.0 && fittedPeak < 0.15 * correlation[0]) {
    results.set(0.0, 0.0, 0.0);
    return;
  }

  results.set(
    1.0 / (fittedMaximumIndex * correlation.dt),
    fittedMaximumIndex * correlation.dt,
    fittedPeak,
  );
}

/// Classic Autocorrelation pitch detector implementing [PitchDetector].
///
/// Integrates:
/// 1. Time-domain RMS silence gating.
/// 2. Wiener-Khinchin $2N$ zero-padded autocorrelation.
/// 3. Initial drop bypass and subharmonic mitigation.
/// 4. Second-layer peak energy gating ($R_{xx}[\tau] \ge 0.15 \cdot R_{xx}[0]$).
/// 5. 3-point parabolic interpolation for sub-sample accuracy.
class ClassicPitchDetector implements PitchDetector {
  /// Creates a [ClassicPitchDetector] for frames of [frameSize] samples.
  ClassicPitchDetector({
    required this.frameSize,
    this.silenceThresholdRms = 1e-4,
    this.subharmonicsTolerance = 0.05,
    this.subharmonicPeakRatio = 0.8,
  }) : _correlation = Correlation(frameSize),
       _autoCorrData = AutoCorrelationData(
         size: frameSize,
         dt: 1.0, // Updated on each detect call with actual sampleRate
       );

  /// Number of samples per analysis frame. Must be a power of 2.
  final int frameSize;

  /// Time-domain root-mean-square silence threshold.
  final double silenceThresholdRms;

  /// Relative lag tolerance when searching for subharmonic peaks.
  final double subharmonicsTolerance;

  /// Amplitude ratio requirement to accept an earlier subharmonic peak.
  final double subharmonicPeakRatio;

  final Correlation _correlation;
  AutoCorrelationData _autoCorrData;
  final CorrelationBasedFrequency _result = CorrelationBasedFrequency(0, 0, 0);

  @override
  PitchDetectionResult detectPitch({
    required Float32List samples,
    required int sampleRate,
    double frequencyMin = 16.0,
    double frequencyMax = 20000.0,
    AcousticWeighting? weighting,
  }) {
    if (samples.length < frameSize || sampleRate <= 0) {
      return PitchDetectionResult.silence;
    }

    // Step 1: RMS energy silence gate
    var sumSq = 0.0;
    for (var i = 0; i < frameSize; i++) {
      final s = samples[i];
      sumSq += s * s;
    }
    final rms = math.sqrt(sumSq / frameSize);
    if (rms < silenceThresholdRms) {
      return PitchDetectionResult.silence;
    }

    // Step 2: Compute autocorrelation
    final dt = 1.0 / sampleRate;
    if (_autoCorrData.dt != dt) {
      _autoCorrData = AutoCorrelationData(size: frameSize, dt: dt);
    }
    _correlation.correlate(
      samples,
      _autoCorrData.values,
      weighting: weighting,
      sampleRate: sampleRate,
    );

    // Step 3: Peak detection and subharmonic suppression
    findCorrelationBasedFrequency(
      _result,
      _autoCorrData,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
      subharmonicsTolerance: subharmonicsTolerance,
      subharmonicPeakRatio: subharmonicPeakRatio,
    );

    if (_result.frequency <= 0.0 || _result.timeShift <= 0.0) {
      return PitchDetectionResult.silence;
    }

    final r0 = _autoCorrData.values[0];
    final confidence = (r0 > 1e-9)
        ? (_result.correlationAtTimeShift / r0).clamp(0.0, 1.0)
        : 0.0;

    return PitchDetectionResult(
      frequency: _result.frequency,
      confidence: confidence,
      periodSamples: _result.timeShift * sampleRate,
      isSilence: false,
      noiseRatio: (1.0 - confidence).clamp(0.0, 1.0),
    );
  }

  @override
  void reset() {
    _autoCorrData.values.fillRange(0, _autoCorrData.size, 0.0);
    _result.set(0.0, 0.0, 0.0);
  }
}
