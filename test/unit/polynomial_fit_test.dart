import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/pitch/polynomial_fit.dart';

void main() {
  group('Polynomial Fit Peak Finding Tests', () {
    test('Recovers exact vertex of arbitrary quadratic polynomial', () {
      const tPeak = 0.45;
      double polynomial(double x) => -(x - tPeak) * (x - tPeak) + 0.23;
      const dt = 12.0;
      const tc = tPeak - 0.6 * dt;

      final fit = getPeakOfPolynomialFit(
        polynomial(tc - dt),
        polynomial(tc),
        polynomial(tc + dt),
        tc,
        dt,
      );

      expect(fit.timeOrIndex, closeTo(tPeak, 1e-4));
      expect(fit.value, closeTo(polynomial(tPeak), 1e-4));
    });

    test('Symmetric peak yields exact zero offset', () {
      final fit = getPeakOfPolynomialFit(0.5, 1.0, 0.5, 10.0, 1.0);
      expect(fit.timeOrIndex, equals(10.0));
      expect(fit.value, equals(1.0));
    });

    test('Asymmetric peak shifts towards larger neighbor', () {
      // valueRight (0.8) > valueLeft (0.4) with center 1.0 -> vertex is shifted right
      final fit = getPeakOfPolynomialFit(0.4, 1.0, 0.8, 5.0, 1.0);
      expect(fit.timeOrIndex, greaterThan(5.0));
      expect(fit.value, greaterThan(1.0));
    });

    test(
      'Zero denominator and colinear/flat degenerate cases handled safely',
      () {
        // Flat points
        final flatFit = getPeakOfPolynomialFit(1.0, 1.0, 1.0, 2.0, 1.0);
        expect(flatFit.timeOrIndex, equals(2.0));
        expect(flatFit.value, equals(1.0));

        // Colinear line (slope = 1) -> denom = 0 + 2 - 2*1 = 0
        final lineFit = getPeakOfPolynomialFit(0.0, 1.0, 2.0, 3.0, 1.0);
        expect(lineFit.timeOrIndex, equals(3.0));
        expect(lineFit.value, equals(1.0));
      },
    );

    test(
      'getPeakOfPolynomialFitArray handles boundaries and interior points',
      () {
        final data = [0.1, 0.5, 1.2, 0.9, 0.3];

        // Left boundary index 0
        final leftBound = getPeakOfPolynomialFitArray(0, data);
        expect(leftBound.timeOrIndex, equals(0.0));
        expect(leftBound.value, equals(0.1));

        // Right boundary index 4
        final rightBound = getPeakOfPolynomialFitArray(4, data);
        expect(rightBound.timeOrIndex, equals(4.0));
        expect(rightBound.value, equals(0.3));

        // Interior peak around index 2 (values: 0.5, 1.2, 0.9)
        final peak = getPeakOfPolynomialFitArray(2, data);
        expect(peak.timeOrIndex, greaterThan(1.5));
        expect(peak.timeOrIndex, lessThan(2.5));
        expect(peak.value, greaterThan(1.2));
      },
    );
  });
}
