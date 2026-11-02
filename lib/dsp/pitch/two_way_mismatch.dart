import 'dart:math' as math;
import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';
import '../correlation/auto_correlation.dart';
import '../correlation/correlation.dart';
import '../filters/acoustic_weighting.dart';
import 'pitch_detector_interface.dart';
import 'polynomial_fit.dart';

/// Peak information extracted from the frequency magnitude spectrum.
class SpectralPeak {
  /// Creates a [SpectralPeak] with [frequency] in Hertz and linear [amplitude].
  const SpectralPeak(this.frequency, this.amplitude);

  /// Center frequency of this spectral peak in Hertz.
  final double frequency;

  /// Absolute linear amplitude of this spectral peak.
  final double amplitude;

  @override
  String toString() =>
      'SpectralPeak(f: ${frequency.toStringAsFixed(2)} Hz, a: ${amplitude.toStringAsFixed(4)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpectralPeak &&
          runtimeType == other.runtimeType &&
          frequency == other.frequency &&
          amplitude == other.amplitude;

  @override
  int get hashCode => Object.hash(frequency, amplitude);
}

/// Result of Two-Way Mismatch fundamental estimation.
class TwmResult {
  /// Creates a [TwmResult] container.
  const TwmResult({
    required this.frequency,
    required this.error,
    required this.confidence,
  });

  /// Detected fundamental frequency in Hertz, or 0.0 if unresolved.
  final double frequency;

  /// Normalized mismatch error. Lower indicates a tighter harmonic fit.
  final double error;

  /// Detection confidence metric in [0.0, 1.0].
  final double confidence;

  /// Constant representing unvoiced or unresolved estimation.
  static const unvoiced = TwmResult(
    frequency: 0.0,
    error: double.infinity,
    confidence: 0.0,
  );
}

/// Two-Way Mismatch (TWM) fundamental frequency pitch estimator.
///
/// References:
/// Maher & Beauchamp, "Fundamental Frequency Estimation of Musical Sounds using
/// a Two-Way Mismatch Procedure", J. Acoust. Soc. Am. 95(4), 1994.
///
/// TWM balances:
/// 1. Predicted-to-Measured error ($Err_{p\to m}$): How well predicted harmonics match measured peaks.
/// 2. Measured-to-Predicted error ($Err_{m\to p}$): Penalizes measured peaks not explained by predicted series.
///
/// This bidirectional metric successfully identifies missing fundamentals on heavy strings (cello/bass)
/// and incorporates string stiffness inharmonicity compensation $f_n = n \cdot f_0 \sqrt{1 + B n^2}$.
class TwoWayMismatchDetector implements PitchDetector {
  /// Creates a [TwoWayMismatchDetector] instance.
  ///
  /// - [maxHarmonics]: Maximum number of predicted harmonics to evaluate (default 10).
  /// - [inharmonicity]: String inharmonicity stiffness coefficient $B$ (default 0.0).
  /// - [rho]: Weight of measured-to-predicted error (default 1.0).
  /// - [maxMismatchError]: Maximum acceptable mismatch error threshold (default 0.40).
  TwoWayMismatchDetector({
    this.maxHarmonics = 10,
    this.inharmonicity = 0.0,
    this.rho = 1.0,
    this.maxMismatchError = 0.40,
  });

  final int maxHarmonics;
  final double inharmonicity;
  final double rho;
  final double maxMismatchError;

  Correlation? _correlator;
  AutoCorrelationData? _autoCorr;
  Float32List? _spectrumBuffer;

  /// Computes bidirectional mismatch error for fundamental candidate [fCand].
  static double computeMismatch(
    double fCand,
    List<SpectralPeak> peaks, {
    int maxHarmonics = 10,
    double inharmonicity = 0.0,
    double rho = 1.0,
  }) {
    if (fCand <= 0.0 || peaks.isEmpty) return double.infinity;

    var maxAmp = 0.0;
    for (final p in peaks) {
      if (p.amplitude > maxAmp) maxAmp = p.amplitude;
    }
    if (maxAmp <= 0.0) return double.infinity;

    final maxObservedFreq = peaks.last.frequency;

    // 1. Predicted-to-Measured Error
    var errPtoM = 0.0;
    var numHarmonicsEvaluated = 0;

    for (var n = 1; n <= maxHarmonics; n++) {
      final fPred = n * fCand * math.sqrt(1.0 + inharmonicity * n * n);
      if (fPred > maxObservedFreq * 1.2) break;

      var minDiff = double.infinity;
      for (final p in peaks) {
        final diff = (p.frequency - fPred).abs();
        if (diff < minDiff) minDiff = diff;
      }

      final relativeDiff = math.min(0.5, minDiff / fPred);
      final harmonicWeight = 1.0 / math.sqrt(n);
      errPtoM += relativeDiff * harmonicWeight;
      numHarmonicsEvaluated++;
    }

    if (numHarmonicsEvaluated == 0) return double.infinity;
    final normErrPtoM = errPtoM / numHarmonicsEvaluated;

    // 2. Measured-to-Predicted Error (penalizes unexplained measured peaks)
    var errMtoP = 0.0;
    var totalPeakWeight = 0.0;

    for (final p in peaks) {
      var minDiff = double.infinity;
      for (var n = 1; n <= maxHarmonics; n++) {
        final fPred = n * fCand * math.sqrt(1.0 + inharmonicity * n * n);
        final diff = (p.frequency - fPred).abs();
        if (diff < minDiff) minDiff = diff;
      }

      final relativeDiff = math.min(0.5, minDiff / p.frequency);
      final ampWeight = p.amplitude / maxAmp;
      errMtoP += relativeDiff * ampWeight;
      totalPeakWeight += ampWeight;
    }

    final normErrMtoP = totalPeakWeight > 0.0
        ? (errMtoP / totalPeakWeight)
        : 0.5;

    return normErrPtoM + rho * normErrMtoP;
  }

  /// Identifies the best fundamental frequency from a list of sorted [peaks].
  static TwmResult findPitchFromPeaks(
    List<SpectralPeak> peaks, {
    double frequencyMin = 20.0,
    double frequencyMax = 4000.0,
    List<double> initialCandidates = const [],
    double inharmonicity = 0.0,
    double rho = 1.0,
    double maxMismatchError = 0.40,
    int maxHarmonics = 10,
  }) {
    if (peaks.length < 2) {
      if (peaks.length == 1 &&
          peaks[0].frequency >= frequencyMin &&
          peaks[0].frequency <= frequencyMax) {
        return TwmResult(
          frequency: peaks[0].frequency,
          error: 0.0,
          confidence: 1.0,
        );
      }
      return TwmResult.unvoiced;
    }

    final candidates = <double>{};
    for (final c in initialCandidates) {
      if (c >= frequencyMin && c <= frequencyMax) {
        candidates.add(c);
      }
    }

    // Candidate generation from top peaks and subharmonics
    final topPeaks = peaks.take(8).toList();
    for (final p in topPeaks) {
      for (var div = 1; div <= 8; div++) {
        final cand = p.frequency / div;
        if (cand >= frequencyMin && cand <= frequencyMax) {
          candidates.add(cand);
        }
      }
    }

    // Candidate generation from adjacent overtone differences (harmonic spacing)
    final sortedByFreq = List<SpectralPeak>.from(peaks)
      ..sort((a, b) => a.frequency.compareTo(b.frequency));
    for (var i = 0; i < sortedByFreq.length - 1; i++) {
      final diff = sortedByFreq[i + 1].frequency - sortedByFreq[i].frequency;
      if (diff >= frequencyMin && diff <= frequencyMax) {
        candidates.add(diff);
      }
    }

    if (candidates.isEmpty) return TwmResult.unvoiced;

    var bestCandidate = 0.0;
    var minError = double.infinity;

    for (final cand in candidates) {
      final error = computeMismatch(
        cand,
        sortedByFreq,
        maxHarmonics: maxHarmonics,
        inharmonicity: inharmonicity,
        rho: rho,
      );
      if (error < minError) {
        minError = error;
        bestCandidate = cand;
      }
    }

    if (bestCandidate <= 0.0 || minError > maxMismatchError) {
      return TwmResult(frequency: 0.0, error: minError, confidence: 0.0);
    }

    // Quadratic interpolation refinement around the minimum error
    var refinedFreq = bestCandidate;
    if (minError > 0.005) {
      final step = bestCandidate * 0.005;
      final e0 = computeMismatch(
        bestCandidate - step,
        sortedByFreq,
        maxHarmonics: maxHarmonics,
        inharmonicity: inharmonicity,
        rho: rho,
      );
      final e1 = minError;
      final e2 = computeMismatch(
        bestCandidate + step,
        sortedByFreq,
        maxHarmonics: maxHarmonics,
        inharmonicity: inharmonicity,
        rho: rho,
      );

      final denom = 2.0 * (e0 - 2.0 * e1 + e2);
      if (denom.abs() > 1e-9) {
        final delta = ((e0 - e2) / denom).clamp(-1.0, 1.0);
        refinedFreq = (bestCandidate + delta * step).clamp(
          frequencyMin,
          frequencyMax,
        );
      }
    }

    final confidence = (1.0 - minError).clamp(0.0, 1.0);
    return TwmResult(
      frequency: refinedFreq,
      error: minError,
      confidence: confidence,
    );
  }

  /// Extracts spectral peaks from the complex spectrum of size [fftSize].
  static List<SpectralPeak> extractPeaks(
    Float32List spectrum,
    int sampleRate,
    int fftSize,
    double fMin,
    double fMax, {
    int maxPeaks = 16,
    double relativeThreshold = 0.02,
  }) {
    final numBins = fftSize ~/ 2;
    final df = sampleRate / fftSize;
    final amplitudes = Float32List(numBins);
    var maxAmp = 0.0;

    for (var i = 0; i < numBins; i++) {
      final re = spectrum[2 * i];
      final im = spectrum[2 * i + 1];
      final amp = math.sqrt(re * re + im * im);
      amplitudes[i] = amp;
      if (amp > maxAmp) maxAmp = amp;
    }

    if (maxAmp <= 1e-9) return const [];

    final minAmp = maxAmp * relativeThreshold;
    final peaks = <SpectralPeak>[];

    final startBin = math.max(1, (fMin / df).floor());
    final endBin = math.min(numBins - 2, (fMax / df).ceil());

    for (var i = startBin; i <= endBin; i++) {
      final amp = amplitudes[i];
      if (amp >= minAmp &&
          amp >= amplitudes[i - 1] &&
          amp >= amplitudes[i + 1]) {
        // Continuous peak interpolation via polynomial fit
        final fit = getPeakOfPolynomialFit(
          amplitudes[i - 1],
          amp,
          amplitudes[i + 1],
          i.toDouble(),
          1.0,
        );
        final peakFreq = fit.timeOrIndex * df;
        peaks.add(SpectralPeak(peakFreq, fit.value));
      }
    }

    peaks.sort((a, b) => b.amplitude.compareTo(a.amplitude));
    final filteredPeaks = <SpectralPeak>[];
    for (final p in peaks) {
      final isSideLobe = filteredPeaks.any(
        (existing) => (existing.frequency - p.frequency).abs() < (df * 1.5),
      );
      if (!isSideLobe) {
        filteredPeaks.add(p);
      }
    }

    final topPeaks = filteredPeaks.take(maxPeaks).toList();
    topPeaks.sort((a, b) => a.frequency.compareTo(b.frequency));
    return topPeaks;
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

    // RMS silence check
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
      _correlator = Correlation(size, windowType: WindowingFunction.hanning);
      _autoCorr = AutoCorrelationData(size: size, dt: dt);
      _spectrumBuffer = Float32List(2 * size + 2);
    }

    _correlator!.correlate(
      samples,
      _autoCorr!.values,
      spectrum: _spectrumBuffer,
    );

    final peaks = extractPeaks(
      _spectrumBuffer!,
      sampleRate,
      2 * size,
      frequencyMin,
      frequencyMax,
    );

    if (peaks.isEmpty) return PitchDetectionResult.silence;

    final twmResult = findPitchFromPeaks(
      peaks,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
      inharmonicity: inharmonicity,
      rho: rho,
      maxMismatchError: maxMismatchError,
      maxHarmonics: maxHarmonics,
    );

    if (twmResult.frequency <= 0.0 || twmResult.confidence <= 0.0) {
      return PitchDetectionResult.silence;
    }

    return PitchDetectionResult(
      frequency: twmResult.frequency,
      confidence: twmResult.confidence,
      periodSamples: sampleRate / twmResult.frequency,
      isSilence: false,
      noiseRatio: twmResult.error.clamp(0.0, 1.0),
      harmonicEnergy: rms,
      inharmonicity: inharmonicity,
    );
  }

  @override
  void reset() {}
}
