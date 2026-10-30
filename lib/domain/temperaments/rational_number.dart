import 'dart:math' as math;

/// Represents an exact rational fraction (numerator / denominator) with automatic reduction
/// to lowest terms, adhering to mathematical and musical acoustical requirements.
class RationalNumber implements Comparable<RationalNumber> {
  RationalNumber(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError.value(
        denominator,
        'denominator',
        'Denominator cannot be zero',
      );
    }

    var n = numerator;
    var d = denominator;

    if (d < 0) {
      n = -n;
      d = -d;
    }

    final g = gcd(n.abs(), d.abs());
    _numerator = n ~/ g;
    _denominator = d ~/ g;
  }

  /// Zero fraction (0 / 1).
  static final RationalNumber zero = RationalNumber(0, 1);

  /// Unit fraction (1 / 1).
  static final RationalNumber one = RationalNumber(1, 1);

  late final int _numerator;
  late final int _denominator;

  /// The numerator of the reduced fraction.
  int get numerator => _numerator;

  /// The denominator of the reduced fraction (guaranteed > 0).
  int get denominator => _denominator;

  /// Returns true if this fraction equals zero.
  bool get isZero => _numerator == 0;

  /// Converts this rational number to a double-precision float.
  double toDouble() => _numerator / _denominator;

  /// Greatest common divisor via Euclidean algorithm.
  static int gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x;
  }

  /// Calculates this rational number raised to integer power [exponent].
  RationalNumber pow(int exponent) {
    if (exponent == 0) return RationalNumber.one;
    if (exponent > 0) {
      return RationalNumber(
        math.pow(_numerator, exponent).toInt(),
        math.pow(_denominator, exponent).toInt(),
      );
    } else {
      final pos = -exponent;
      return RationalNumber(
        math.pow(_denominator, pos).toInt(),
        math.pow(_numerator, pos).toInt(),
      );
    }
  }

  RationalNumber operator +(RationalNumber other) {
    return RationalNumber(
      _numerator * other._denominator + _denominator * other._numerator,
      _denominator * other._denominator,
    );
  }

  RationalNumber operator -(RationalNumber other) {
    return RationalNumber(
      _numerator * other._denominator - _denominator * other._numerator,
      _denominator * other._denominator,
    );
  }

  RationalNumber operator *(RationalNumber other) {
    return RationalNumber(
      _numerator * other._numerator,
      _denominator * other._denominator,
    );
  }

  RationalNumber operator /(RationalNumber other) {
    if (other.isZero) {
      throw ArgumentError('Cannot divide by zero rational number');
    }
    return RationalNumber(
      _numerator * other._denominator,
      _denominator * other._numerator,
    );
  }

  RationalNumber operator -() => RationalNumber(-_numerator, _denominator);

  @override
  int compareTo(RationalNumber other) {
    final diff =
        _numerator * other._denominator - other._numerator * _denominator;
    if (diff < 0) return -1;
    if (diff > 0) return 1;
    return 0;
  }

  bool operator <(RationalNumber other) => compareTo(other) < 0;
  bool operator <=(RationalNumber other) => compareTo(other) <= 0;
  bool operator >(RationalNumber other) => compareTo(other) > 0;
  bool operator >=(RationalNumber other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RationalNumber &&
          _numerator == other._numerator &&
          _denominator == other._denominator;

  @override
  int get hashCode => Object.hash(_numerator, _denominator);

  @override
  String toString() =>
      _denominator == 1 ? '$_numerator' : '$_numerator/$_denominator';
}
