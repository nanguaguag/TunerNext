import 'dart:math' as math;
import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';
import '../correlation/auto_correlation.dart';
import 'pitch_detector_interface.dart';
import 'polynomial_fit.dart';

/// Peak information extracted from the frequency spectrum.
class SpectralPeak {
  const SpectralPeak(this.frequency, this.amplitude);
  final double frequency;
  final double amplitude;
}

/// Two-Way Mismatch (TWM) pitch estimator.
///
/// Compares predicted harmonic series with detected spectral peaks using
/// a bidirectional error metric that penalizes both missing predicted harmonics
/// and unexplained measured peaks, preventing octave-halving and octave-doubling errors.
class TwoWayMismatchDetector implements PitchDetector {
  TwoWayMismatchDetector({
    this.maxHarmonics = 10,
    this.inharmonicity = 0.0,
    this.rho = 1.0,
    this.maxMismatchError = 0.50,
  });

  final int maxHarmonics;
  final double inharmonicity;
  final double rho;
  final double maxMismatchError;

  CorrelationComputer? _correlator;
  AutoCorrelationData? _autoCorr;
  Float32List? _spectrumStorage;

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
    _correlator ??= CorrelationComputer(
      size,
      windowType: WindowingFunction.hanning,
    );
    _autoCorr ??= AutoCorrelationData(size: size, dt: dt);
    _spectrumStorage ??= Float32List(2 * size + 2);

    _correlator!.compute(samples, _autoCorr!, spectrumOut: _spectrumStorage!);

    final peaks = extractPeaks(
      _spectrumStorage!,
      sampleRate,
      2 * size,
      frequencyMin,
      frequencyMax,
    );
    if (peaks.isEmpty) return PitchDetectionResult.silence;

    // Generate candidate fundamental frequencies from top spectral peaks, adjacent differences, and subharmonics
    final candidates = <double>{};
    for (var i = 0; i < math.min(peaks.length, 6); i++) {
      final f = peaks[i].frequency;
      if (f >= frequencyMin && f <= frequencyMax) candidates.add(f);
      for (var div = 2; div <= 4; div++) {
        final subF = f / div;
        if (subF >= frequencyMin && subF <= frequencyMax) candidates.add(subF);
      }
    }

    final sortedByFreq = List<SpectralPeak>.from(peaks)
      ..sort((a, b) => a.frequency.compareTo(b.frequency));
    for (var i = 0; i < sortedByFreq.length - 1; i++) {
      final diffF = sortedByFreq[i + 1].frequency - sortedByFreq[i].frequency;
      if (diffF >= frequencyMin && diffF <= frequencyMax) {
        candidates.add(diffF);
      }
    }

    if (candidates.isEmpty) return PitchDetectionResult.silence;

    var bestFreq = 0.0;
    var minError = double.infinity;

    for (final fCand in candidates) {
      final err = computeMismatch(
        fCand,
        peaks,
        maxHarmonics: maxHarmonics,
        inharmonicity: inharmonicity,
        rho: rho,
      );
      if (err < minError) {
        minError = err;
        bestFreq = fCand;
      }
    }

    if (minError > maxMismatchError || bestFreq <= 0.0) {
      return PitchDetectionResult.silence;
    }

    final confidence = (1.0 - minError).clamp(0.0, 1.0);
    return PitchDetectionResult(
      frequency: bestFreq,
      confidence: confidence,
      periodSamples: sampleRate / bestFreq,
      isSilence: false,
      noiseRatio: minError.clamp(0.0, 1.0),
      harmonicEnergy: rms,
    );
  }

  /// Extracts spectral peaks from complex spectrum.
  static List<SpectralPeak> extractPeaks(
    Float32List spectrum,
    int sampleRate,
    int fftSize,
    double fMin,
    double fMax, {
    int maxPeaks = 20,
    double thresholdRatio = 0.02,
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

    final minAmp = maxAmp * thresholdRatio;
    final peaks = <SpectralPeak>[];

    final startBin = math.max(1, (fMin / df).floor());
    final endBin = math.min(numBins - 2, (fMax / df).ceil());

    for (var i = startBin; i <= endBin; i++) {
      final amp = amplitudes[i];
      if (amp >= minAmp &&
          amp >= amplitudes[i - 1] &&
          amp >= amplitudes[i + 1]) {
        // Parabolic peak interpolation
        final fit = getPeakOfPolynomialFit(
          amplitudes[i - 1],
          amp,
          amplitudes[i + 1],
          i.toDouble(),
          1.0,
        );
        final peakFreq = fit.timeOrIndex * df;
        peaks.add(SpectralPeak(peakFreq, amp));
      }
    }

    peaks.sort((a, b) => b.amplitude.compareTo(a.amplitude));
    final filteredPeaks = <SpectralPeak>[];
    for (final p in peaks) {
      final isSideLobe = filteredPeaks.any(
        (existing) => (existing.frequency - p.frequency).abs() < 25.0,
      );
      if (!isSideLobe) {
        filteredPeaks.add(p);
      }
    }
    if (filteredPeaks.length > maxPeaks) {
      return filteredPeaks.sublist(0, maxPeaks);
    }
    return filteredPeaks;
  }

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
    var maxPeakFreq = 0.0;
    for (final p in peaks) {
      if (p.amplitude > maxAmp) maxAmp = p.amplitude;
      if (p.frequency > maxPeakFreq) maxPeakFreq = p.frequency;
    }
    if (maxAmp <= 0.0) return double.infinity;

    // 1. Predicted-to-Measured error
    var errPtoM = 0.0;
    var totalPtoMWeight = 0.0;

    for (var n = 1; n <= maxHarmonics; n++) {
      final fPred = n * fCand * math.sqrt(1.0 + inharmonicity * n * n);
      if (fPred > maxPeakFreq + 0.5 * fCand) break;
      var minDiff = double.infinity;

      for (final p in peaks) {
        final diff = (p.frequency - fPred).abs();
        if (diff < minDiff) minDiff = diff;
      }

      final relDiff = (minDiff / fPred) <= 0.08 ? (minDiff / fPred) : 1.0;
      final weight = 1.0 / math.sqrt(n);
      errPtoM += relDiff * weight;
      totalPtoMWeight += weight;
    }

    if (totalPtoMWeight <= 0.0) return double.infinity;
    final normErrPtoM = errPtoM / totalPtoMWeight;

    // 2. Measured-to-Predicted error (penalizes unexplained measured peaks)
    var errMtoP = 0.0;
    var totalAmpWeight = 0.0;

    for (final p in peaks) {
      var minDiff = double.infinity;
      for (var n = 1; n <= maxHarmonics; n++) {
        final fPred = n * fCand * math.sqrt(1.0 + inharmonicity * n * n);
        final diff = (p.frequency - fPred).abs();
        if (diff < minDiff) minDiff = diff;
      }

      final relDiff = (minDiff / p.frequency) <= 0.08
          ? (minDiff / p.frequency)
          : 1.0;
      final ampWeight = p.amplitude / maxAmp;
      errMtoP += relDiff * ampWeight;
      totalAmpWeight += ampWeight;
    }

    final normErrMtoP = totalAmpWeight > 0.0 ? (errMtoP / totalAmpWeight) : 0.5;
    return normErrPtoM + rho * normErrMtoP;
  }

  @override
  void reset() {}
}
