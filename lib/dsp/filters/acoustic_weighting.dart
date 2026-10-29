import 'dart:math' as math;
import '../../domain/models/dsp_enums.dart';

/// Frequency weighting curve for human auditory response modeling.
abstract class AcousticWeighting {
  /// The weighting mode represented by this instance.
  AcousticWeightingMode get mode;

  /// Applies weighting factor to amplitude at frequency [freq] in Hertz.
  double applyToAmplitude(double amplitude, double freq);

  /// Factory creating concrete weighting curve instance from enum.
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

/// Flat / zero weighting curve (leaves amplitude unchanged).
class AcousticZeroWeighting implements AcousticWeighting {
  @override
  AcousticWeightingMode get mode => AcousticWeightingMode.none;

  @override
  double applyToAmplitude(double amplitude, double freq) => amplitude;
}

/// Standard IEC 61672-1:2013 A-weighting filter.
class AcousticAWeighting implements AcousticWeighting {
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

/// Standard IEC 61672-1:2013 C-weighting filter.
class AcousticCWeighting implements AcousticWeighting {
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

  double _getWeightingFactorNonNormalized(double freq) {
    final fsqr = freq * freq;
    final numerator = math.pow(12194.0, 2) * fsqr;
    final denom = (fsqr + math.pow(20.6, 2)) * (fsqr + math.pow(12194.0, 2));
    if (denom <= 0.0) return 0.0;
    return numerator / denom;
  }
}
