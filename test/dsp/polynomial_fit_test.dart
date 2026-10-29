import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/pitch/polynomial_fit.dart';

void main() {
  group('Polynomial Fit Tests', () {
    test('Exact peak recovery of continuous quadratic curve', () {
      // f(x) = -(x - 2.3)^2 + 5.0
      // x = 1 -> -1.69 + 5 = 3.31
      // x = 2 -> -0.09 + 5 = 4.91
      // x = 3 -> -0.49 + 5 = 4.51
      const y0 = 3.31;
      const y1 = 4.91;
      const y2 = 4.51;

      final fit = getPeakOfPolynomialFit(y0, y1, y2, 2.0, 1.0);
      expect(fit.timeOrIndex, closeTo(2.3, 1e-4));
      expect(fit.value, closeTo(5.0, 1e-4));
    });

    test('Boundary fallback when index is on edge', () {
      final data = [1.0, 2.0, 3.0, 2.5];
      final fitStart = getPeakOfPolynomialFitArray(0, data);
      expect(fitStart.timeOrIndex, equals(0.0));
      expect(fitStart.value, equals(1.0));

      final fitEnd = getPeakOfPolynomialFitArray(3, data);
      expect(fitEnd.timeOrIndex, equals(3.0));
      expect(fitEnd.value, equals(2.5));
    });

    test('Flat line returns center value without division by zero', () {
      final fit = getPeakOfPolynomialFit(3.0, 3.0, 3.0, 5.0, 1.0);
      expect(fit.timeOrIndex, equals(5.0));
      expect(fit.value, equals(3.0));
    });
  });
}
