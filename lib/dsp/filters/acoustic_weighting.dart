import 'dart:math' as math;
import '../../domain/models/dsp_enums.dart';

/// Frequency weighting curve implementation adhering to IEC 61672-1:2013 standard.
abstract class AcousticWeighting {
  /// The weighting mode represented by this instance.
  AcousticWeightingMode get mode;

  /// Applies the weighting curve to the given [amplitude] at frequency [freq] in Hertz.
  double applyToAmplitude(double amplitude, double freq);

  /// Factory creating the concrete weighting instance corresponding to [mode].
  factory AcousticWeighting.fromMode(AcousticWeightingMode mode) {
    switch (mode) {
      case AcousticWeightingMode.aWeighting:
        return AcousticAWeighting();
      case AcousticWeightingMode.cWeighting:
        return AcousticCWeighting();
      case AcousticWeightingMode.none:
        return AcousticZeroWeighting();
    }
  }
}

/// Flat / zero acoustic weighting (leaves amplitude unmodified).
class AcousticZeroWeighting implements AcousticWeighting {
  @override
  AcousticWeightingMode get mode => AcousticWeightingMode.none;

  @override
  double applyToAmplitude(double amplitude, double freq) => amplitude;
}

/// Standard IEC 61672-1:2013 A-weighting filter mimicking the human ear 40-phon curve.
class AcousticAWeighting implements AcousticWeighting {
  /// Creates an [AcousticAWeighting] instance and precomputes 1000 Hz reference normalization.
  AcousticAWeighting() {
    _weightingNonNormalized1000 = _getWeightingFactorNonNormalized(1000.0);
  }

  late final double _weightingNonNormalized1000;

  @override
  AcousticWeightingMode get mode => AcousticWeightingMode.aWeighting;

  @override
  double applyToAmplitude(double amplitude, double freq) {
    if (freq <= 0.0) return 0.0;
    return amplitude *
        (_getWeightingFactorNonNormalized(freq) / _weightingNonNormalized1000);
  }

  /// Calculates non-normalized A-weighting magnitude response:
  /// $$R_A(f) = \frac{(12194 \cdot f^2)^2}{(f^2 + 20.6^2) \sqrt{(f^2 + 107.7^2)(f^2 + 737.9^2)} (f^2 + 12194^2)}$$
  double _getWeightingFactorNonNormalized(double freq) {
    final fsqr = freq * freq;
    final numerator = math.pow(12194.0 * fsqr, 2);
    final denom =
        (fsqr + math.pow(20.6, 2)) *
        math.sqrt((fsqr + math.pow(107.7, 2)) * (fsqr + math.pow(737.9, 2))) *
        (fsqr + math.pow(12194.0, 2));
    if (denom <= 0.0) return 0.0;
    return numerator / denom;
  }
}

/// Standard IEC 61672-1:2013 C-weighting filter for high SPL or wideband acoustic evaluation.
class AcousticCWeighting implements AcousticWeighting {
  /// Creates an [AcousticCWeighting] instance and precomputes 1000 Hz reference normalization.
  AcousticCWeighting() {
    _weightingNonNormalized1000 = _getWeightingFactorNonNormalized(1000.0);
  }

  late final double _weightingNonNormalized1000;

  @override
  AcousticWeightingMode get mode => AcousticWeightingMode.cWeighting;

  @override
  double applyToAmplitude(double amplitude, double freq) {
    if (freq <= 0.0) return 0.0;
    return amplitude *
        (_getWeightingFactorNonNormalized(freq) / _weightingNonNormalized1000);
  }

  /// Calculates non-normalized C-weighting magnitude response:
  /// $$R_C(f) = \frac{12194 \cdot f^2}{(f^2 + 20.6^2)(f^2 + 12194^2)}$$
  double _getWeightingFactorNonNormalized(double freq) {
    final fsqr = freq * freq;
    final numerator = 12194.0 * fsqr;
    final denom = (fsqr + math.pow(20.6, 2)) * (fsqr + math.pow(12194.0, 2));
    if (denom <= 0.0) return 0.0;
    return numerator / denom;
  }
}
