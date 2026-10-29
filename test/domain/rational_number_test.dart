import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/rational_number.dart';

void main() {
  group('RationalNumber Unit Tests', () {
    test('Constructing simplifies fractions via GCD', () {
      final r1 = RationalNumber(4, 6);
      expect(r1.numerator, 2);
      expect(r1.denominator, 3);
      expect(r1.toDouble(), closeTo(2 / 3, 1e-9));

      final r2 = RationalNumber(81, 80);
      expect(r2.numerator, 81);
      expect(r2.denominator, 80);
    });

    test('Negative signs are normalized to numerator', () {
      final r = RationalNumber(3, -5);
      expect(r.numerator, -3);
      expect(r.denominator, 5);
    });

    test('Zero denominator throws ArgumentError', () {
      expect(() => RationalNumber(1, 0), throwsArgumentError);
    });

    test('Arithmetic operations preserve exact fractions', () {
      final a = RationalNumber(3, 2); // Pure fifth
      final b = RationalNumber(4, 3); // Pure fourth

      final product = a * b; // 12/6 = 2/1 (Octave)
      expect(product.numerator, 2);
      expect(product.denominator, 1);

      final diff = a - b; // 3/2 - 4/3 = (9 - 8)/6 = 1/6
      expect(diff.numerator, 1);
      expect(diff.denominator, 6);

      final div = a / b; // (3/2) / (4/3) = 9/8 (Major whole tone)
      expect(div.numerator, 9);
      expect(div.denominator, 8);
    });

    test('Comparison and equality work correctly', () {
      final a = RationalNumber(2, 3);
      final b = RationalNumber(4, 6);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final c = RationalNumber(3, 4);
      expect(a.compareTo(c), lessThan(0));
      expect(c.compareTo(a), greaterThan(0));
    });
  });
}
