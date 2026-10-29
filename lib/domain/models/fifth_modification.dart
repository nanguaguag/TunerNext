import 'dart:math' as math;
import 'rational_number.dart';

/// Modification of a pure fifth by fractional powers of standard musical commas.
///
/// Standard musical commas:
/// - Pythagorean Comma: 531441 / 524288 (~23.46 cents)
/// - Syntonic Comma: 81 / 80 (~21.51 cents)
/// - Schisma: 32805 / 32768 (~1.9537 cents)
///
/// Relationships:
/// 1 Pythagorean Comma = 1 Syntonic Comma + 1 Schisma.
class FifthModification {
  FifthModification({
    RationalNumber? pythagoreanComma,
    RationalNumber? syntonicComma,
    RationalNumber? schisma,
  }) : pythagoreanComma = pythagoreanComma ?? RationalNumber(0, 1),
       syntonicComma = syntonicComma ?? RationalNumber(0, 1),
       schisma = schisma ?? RationalNumber(0, 1) {
    simplify();
  }

  static final pythagoreanCommaRatio = RationalNumber(531441, 524288);
  static final syntonicCommaRatio = RationalNumber(81, 80);
  static final schismaRatio = RationalNumber(32805, 32768);

  RationalNumber pythagoreanComma;
  RationalNumber syntonicComma;
  RationalNumber schisma;

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
    final result = FifthModification(
      pythagoreanComma: pythagoreanComma + other.pythagoreanComma,
      syntonicComma: syntonicComma + other.syntonicComma,
      schisma: schisma + other.schisma,
    );
    result.simplify();
    return result;
  }

  FifthModification operator -(FifthModification other) {
    final result = FifthModification(
      pythagoreanComma: pythagoreanComma - other.pythagoreanComma,
      syntonicComma: syntonicComma - other.syntonicComma,
      schisma: schisma - other.schisma,
    );
    result.simplify();
    return result;
  }

  FifthModification operator -() => FifthModification(
    pythagoreanComma: -pythagoreanComma,
    syntonicComma: -syntonicComma,
    schisma: -schisma,
  );

  void simplify() {
    if (syntonicComma == schisma && !syntonicComma.isZero) {
      pythagoreanComma = pythagoreanComma + schisma;
      schisma.setZero();
      syntonicComma.setZero();
    } else if (pythagoreanComma == -schisma && !pythagoreanComma.isZero) {
      syntonicComma = syntonicComma + pythagoreanComma;
      schisma.setZero();
      pythagoreanComma.setZero();
    } else if (pythagoreanComma == -syntonicComma && !pythagoreanComma.isZero) {
      schisma = schisma + pythagoreanComma;
      pythagoreanComma.setZero();
      syntonicComma.setZero();
    }
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
}
