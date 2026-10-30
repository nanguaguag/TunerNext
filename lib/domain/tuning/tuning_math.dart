import 'dart:math' as math;

/// Core mathematical utility functions for acoustics, temperament ratios, and cent conversions.
///
/// Follows standard international acoustic and musical definitions:
/// - 1 octave = 1200 cents = ratio of 2:1
/// - 1 semitone (12-EDO) = 100 cents = ratio of 2^(1/12) ~ 1.059463
class TuningMath {
  TuningMath._();

  /// Natural logarithm of 2.0.
  static const double ln2 = math.ln2;

  /// Converts a positive frequency ratio into cents.
  ///
  /// Formula: `1200.0 * log2(ratio)`
  /// Returns [double.negativeInfinity] if [ratio] is non-positive.
  static double ratioToCents(double ratio) {
    if (ratio.isNaN) return double.nan;
    if (ratio <= 0.0) return double.negativeInfinity;
    return 1200.0 * (math.log(ratio) / ln2);
  }

  /// Converts an interval in cents into a frequency multiplication ratio.
  ///
  /// Formula: `2^(cents / 1200.0)`
  static double centsToRatio(double cents) {
    if (cents.isNaN) return double.nan;
    return math.pow(2.0, cents / 1200.0).toDouble();
  }

  /// Converts a cent offset relative to a reference frequency into absolute frequency (Hz).
  ///
  /// Formula: `referenceFrequency * 2^(cents / 1200.0)`
  static double centsToFrequency(double cents, double referenceFrequency) {
    if (cents.isNaN || referenceFrequency.isNaN) return double.nan;
    if (referenceFrequency <= 0.0) return 0.0;
    return referenceFrequency * centsToRatio(cents);
  }

  /// Converts an absolute frequency (Hz) into cents relative to a reference frequency.
  ///
  /// Formula: `1200.0 * log2(frequency / referenceFrequency)`
  /// Returns [double.negativeInfinity] if [frequency] is non-positive.
  static double frequencyToCents(double frequency, double referenceFrequency) {
    if (frequency.isNaN || referenceFrequency.isNaN) return double.nan;
    if (frequency <= 0.0 || referenceFrequency <= 0.0) {
      return double.negativeInfinity;
    }
    return ratioToCents(frequency / referenceFrequency);
  }

  /// Computes the signed cent deviation of [actualFrequency] relative to [targetFrequency].
  ///
  /// A positive deviation indicates sharp (+cents), while negative indicates flat (-cents).
  static double centsDeviation(double actualFrequency, double targetFrequency) {
    return frequencyToCents(actualFrequency, targetFrequency);
  }
}
