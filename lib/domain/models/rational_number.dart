/// Mathematical representation of an exact rational fraction (p / q).
class RationalNumber implements Comparable<RationalNumber> {
  RationalNumber(this.numerator, this.denominator) {
    if (denominator == 0) {
      throw ArgumentError('Denominator cannot be zero.');
    }
    _reduce();
  }

  int numerator;
  int denominator;

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

  bool get isZero => numerator == 0;

  double toDouble() => numerator / denominator;
  double toFloat() => toDouble();

  void _reduce() {
    if (denominator < 0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    final g = gcd(numerator, denominator);
    if (g > 1) {
      numerator ~/= g;
      denominator ~/= g;
    }
  }

  void setZero() {
    numerator = 0;
    denominator = 1;
  }

  RationalNumber operator +(RationalNumber other) {
    return RationalNumber(
      numerator * other.denominator + denominator * other.numerator,
      denominator * other.denominator,
    );
  }

  RationalNumber operator -(RationalNumber other) {
    return RationalNumber(
      numerator * other.denominator - denominator * other.numerator,
      denominator * other.denominator,
    );
  }

  RationalNumber operator *(RationalNumber other) {
    return RationalNumber(
      numerator * other.numerator,
      denominator * other.denominator,
    );
  }

  RationalNumber operator /(RationalNumber other) {
    if (other.numerator == 0) {
      throw ArgumentError('Division by zero rational number.');
    }
    return RationalNumber(
      numerator * other.denominator,
      denominator * other.numerator,
    );
  }

  RationalNumber operator -() => RationalNumber(-numerator, denominator);

  @override
  int compareTo(RationalNumber other) {
    return (numerator * other.denominator).compareTo(
      other.numerator * denominator,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RationalNumber &&
          numerator == other.numerator &&
          denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => '$numerator/$denominator';
}
