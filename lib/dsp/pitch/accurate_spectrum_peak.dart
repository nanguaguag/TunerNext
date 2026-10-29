import 'dart:math' as math;
import 'dart:typed_data';

/// High-accuracy frequency estimator utilizing phase vocoder inter-frame phase difference
/// and 3-bin complex Jacobsen interpolation.
class AccurateSpectrumPeakFrequency {
  AccurateSpectrumPeakFrequency({required this.df, this.useJacobsen = true});

  /// Frequency spacing per FFT bin (fs / N).
  final double df;

  /// Whether to apply 3-bin complex Jacobsen interpolation.
  final bool useJacobsen;

  /// Estimates sub-bin accurate frequency at spectral bin [index].
  ///
  /// [currentSpectrum] is the interleaved complex spectrum `[re0, im0, re1, im1, ...]`.
  /// [previousSpectrum] is the previous frame's spectrum (optional).
  /// [timeShift] is the time elapsed between the two spectra in seconds.
  double computeFrequency(
    int index,
    Float32List currentSpectrum, {
    Float32List? previousSpectrum,
    double timeShift = 0.0,
    double? rawFrequency,
  }) {
    final numBins = currentSpectrum.length ~/ 2;
    if (index < 0 || index >= numBins) return rawFrequency ?? (index * df);

    var jacobsenOffset = 0.0;
    if (useJacobsen && index > 0 && index < numBins - 1) {
      final rePrev = currentSpectrum[2 * (index - 1)];
      final imPrev = currentSpectrum[2 * (index - 1) + 1];
      final reCurr = currentSpectrum[2 * index];
      final imCurr = currentSpectrum[2 * index + 1];
      final reNext = currentSpectrum[2 * (index + 1)];
      final imNext = currentSpectrum[2 * (index + 1) + 1];

      final nr = rePrev - reNext;
      final ni = imPrev - imNext;
      final dr = 2.0 * reCurr - rePrev - reNext;
      final di = 2.0 * imCurr - imPrev - imNext;
      final denom = dr * dr + di * di;

      if (denom > 1e-12) {
        jacobsenOffset = ((nr * dr + ni * di) / denom).clamp(-0.5, 0.5);
      }
    }

    final freqSeed = useJacobsen
        ? (index + jacobsenOffset) * df
        : (rawFrequency ?? (index * df));
    if (previousSpectrum == null || timeShift <= 0.0) {
      return freqSeed;
    }

    final re1 = previousSpectrum[2 * index];
    final im1 = previousSpectrum[2 * index + 1];
    final re2 = currentSpectrum[2 * index];
    final im2 = currentSpectrum[2 * index + 1];

    final phase1 = math.atan2(im1, re1);
    final phase2 = math.atan2(im2, re2);

    var dPhase = phase2 - phase1;
    // Symmetrical phase unwrapping
    if (dPhase < -math.pi) {
      dPhase += 2.0 * math.pi;
    } else if (dPhase > math.pi) {
      dPhase -= 2.0 * math.pi;
    }

    final numWaves = (timeShift * freqSeed - dPhase / (2.0 * math.pi)).round();
    return (numWaves + dPhase / (2.0 * math.pi)) / timeShift;
  }
}
