import 'dart:math' as math;
import '../fft/frequency_spectrum.dart';

/// Computes high-accuracy fundamental or harmonic frequencies at spectral peak indices
/// using 3-bin Jacobsen parabolic interpolation and cross-frame Phase Vocoder phase unwrapping.
class AccurateSpectrumPeakFrequency {
  /// Creates an [AccurateSpectrumPeakFrequency] estimator.
  ///
  /// - [spec1]: First frequency spectrum (earlier frame). Can be null if [spec2] is provided.
  /// - [spec2]: Second frequency spectrum (later frame). Can be null if [spec1] is provided.
  /// - [timeShiftBetweenSpecs]: Physical time shift $\Delta t$ between [spec1] and [spec2]
  ///   (`start_time_spec2 - start_time_spec1`) in seconds.
  /// - [useJacobsen]: Whether to apply Jacobsen 3-bin interpolation on the seed bin.
  AccurateSpectrumPeakFrequency({
    this.spec1,
    this.spec2,
    this.timeShiftBetweenSpecs = 0.0,
    this.useJacobsen = true,
  }) : df = spec1?.df ?? spec2?.df ?? 1.0 {
    if (spec1 == null && spec2 == null) {
      throw ArgumentError('At least one of spec1 or spec2 must be non-null.');
    }
    if (spec1 != null && spec2 != null && spec1!.size != spec2!.size) {
      throw ArgumentError(
        'spec1 and spec2 must have identical sizes (${spec1!.size} vs ${spec2!.size}).',
      );
    }
  }

  /// Earlier frequency spectrum.
  final FrequencySpectrum? spec1;

  /// Later frequency spectrum.
  final FrequencySpectrum? spec2;

  /// Time interval $\Delta t$ between frames in seconds.
  double timeShiftBetweenSpecs;

  /// Whether to use Jacobsen quadratic interpolation to refine bin index.
  bool useJacobsen;

  /// Frequency resolution $\Delta f$ in Hertz.
  final double df;

  /// Computes the accurate frequency at spectral bin [index].
  double getFrequency(int index) {
    final activeSpec = spec2 ?? spec1;
    var jacobsenOffset = 0.0;

    if (useJacobsen &&
        activeSpec != null &&
        index > 0 &&
        index < activeSpec.size - 1) {
      final nr = activeSpec.real(index - 1) - activeSpec.real(index + 1);
      final ni = activeSpec.imag(index - 1) - activeSpec.imag(index + 1);
      final dr =
          2.0 * activeSpec.real(index) -
          activeSpec.real(index - 1) -
          activeSpec.real(index + 1);
      final di =
          2.0 * activeSpec.imag(index) -
          activeSpec.imag(index - 1) -
          activeSpec.imag(index + 1);
      final denom = dr * dr + di * di;
      if (denom > 1e-12) {
        jacobsenOffset = ((nr * dr + ni * di) / denom).clamp(-0.5, 0.5);
      }
    }

    final freqSeed = (index + jacobsenOffset) * df;

    if (spec1 == null || spec2 == null || timeShiftBetweenSpecs == 0.0) {
      return freqSeed;
    }

    final phase1 = math.atan2(spec1!.imag(index), spec1!.real(index));
    final phase2 = math.atan2(spec2!.imag(index), spec2!.real(index));

    var dPhase = phase2 - phase1;
    while (dPhase < -math.pi) {
      dPhase += 2.0 * math.pi;
    }
    while (dPhase > math.pi) {
      dPhase -= 2.0 * math.pi;
    }

    final twoPi = 2.0 * math.pi;
    final numWaves = (timeShiftBetweenSpecs * freqSeed - dPhase / twoPi)
        .round();

    return (numWaves + dPhase / twoPi) / timeShiftBetweenSpecs;
  }

  /// Convenience subscript operator delegating to [getFrequency].
  double operator [](int index) => getFrequency(index);
}
