import 'dart:math' as math;
import 'rational_number.dart';

/// Represents a modification to a musical fifth interval by fractional parts
/// of three historical microtonal commas:
/// - Pythagorean comma (PC): ratio 531441 / 524288 (~23.46 cents)
/// - Syntonic comma (SC): ratio 81 / 80 (~21.51 cents)
/// - Schisma (S): ratio 32805 / 32768 (~1.95 cents)
///
/// Law: 1 PC = 1 SC + 1 S
class FifthModification {
  FifthModification({
    RationalNumber? pythagoreanComma,
    RationalNumber? syntonicComma,
    RationalNumber? schisma,
  }) : pythagoreanComma = pythagoreanComma ?? RationalNumber.zero,
       syntonicComma = syntonicComma ?? RationalNumber.zero,
       schisma = schisma ?? RationalNumber.zero {
    _simplify();
  }

  static final RationalNumber pythagoreanCommaRatio = RationalNumber(
    531441,
    524288,
  );
  static final RationalNumber syntonicCommaRatio = RationalNumber(81, 80);
  static final RationalNumber schismaRatio = RationalNumber(32805, 32768);

  RationalNumber pythagoreanComma;
  RationalNumber syntonicComma;
  RationalNumber schisma;

  void _simplify() {
    if (syntonicComma == schisma && !syntonicComma.isZero) {
      pythagoreanComma = pythagoreanComma + schisma;
      schisma = RationalNumber.zero;
      syntonicComma = RationalNumber.zero;
    } else if (pythagoreanComma == -schisma && !pythagoreanComma.isZero) {
      syntonicComma = syntonicComma + pythagoreanComma;
      schisma = RationalNumber.zero;
      pythagoreanComma = RationalNumber.zero;
    } else if (pythagoreanComma == -syntonicComma && !pythagoreanComma.isZero) {
      schisma = schisma + pythagoreanComma;
      pythagoreanComma = RationalNumber.zero;
      syntonicComma = RationalNumber.zero;
    }
  }

  /// Converts the comma fractions to their composite multiplicative frequency ratio.
  double toDouble() {
    return math
            .pow(pythagoreanCommaRatio.toDouble(), pythagoreanComma.toDouble())
            .toDouble() *
        math
            .pow(syntonicCommaRatio.toDouble(), syntonicComma.toDouble())
            .toDouble() *
        math.pow(schismaRatio.toDouble(), schisma.toDouble()).toDouble();
  }

  FifthModification operator +(FifthModification other) {
    return FifthModification(
      pythagoreanComma: pythagoreanComma + other.pythagoreanComma,
      syntonicComma: syntonicComma + other.syntonicComma,
      schisma: schisma + other.schisma,
    );
  }

  FifthModification operator -(FifthModification other) {
    return FifthModification(
      pythagoreanComma: pythagoreanComma - other.pythagoreanComma,
      syntonicComma: syntonicComma - other.syntonicComma,
      schisma: schisma - other.schisma,
    );
  }

  FifthModification operator -() {
    return FifthModification(
      pythagoreanComma: -pythagoreanComma,
      syntonicComma: -syntonicComma,
      schisma: -schisma,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FifthModification &&
          pythagoreanComma == other.pythagoreanComma &&
          syntonicComma == other.syntonicComma &&
          schisma == other.schisma;

  @override
  int get hashCode => Object.hash(pythagoreanComma, syntonicComma, schisma);

  @override
  String toString() =>
      'FifthMod(PC: $pythagoreanComma, SC: $syntonicComma, S: $schisma)';
}
