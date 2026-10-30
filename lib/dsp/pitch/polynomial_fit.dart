/// Represents the calculated extremum (peak) of a parabola fitted through three consecutive points.
class MaximumOfPolynomialFit {
  /// Creates a [MaximumOfPolynomialFit] with [timeOrIndex] and [value].
  const MaximumOfPolynomialFit(this.timeOrIndex, this.value);

  /// Abscissa (time or continuous fractional index) of the fitted peak.
  final double timeOrIndex;

  /// Peak amplitude value at the extremum.
  final double value;

  @override
  String toString() =>
      'MaximumOfPolynomialFit(timeOrIndex: $timeOrIndex, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaximumOfPolynomialFit &&
          runtimeType == other.runtimeType &&
          timeOrIndex == other.timeOrIndex &&
          value == other.value;

  @override
  int get hashCode => Object.hash(timeOrIndex, value);
}

/// Computes the extremum of a parabola passing through three equally spaced points:
/// - [valueLeft] at `timeCenter - dt`
/// - [valueCenter] at `timeCenter`
/// - [valueRight] at `timeCenter + dt`
///
/// Guarded against zero-denominator and colinear degenerate points.
MaximumOfPolynomialFit getPeakOfPolynomialFit(
  double valueLeft,
  double valueCenter,
  double valueRight,
  double timeCenter,
  double dt,
) {
  final denom = valueLeft - 2.0 * valueCenter + valueRight;
  if ((valueLeft == valueCenter && valueRight == valueCenter) ||
      denom.abs() < 1e-12) {
    return MaximumOfPolynomialFit(timeCenter, valueCenter);
  }

  final a = 0.5 * (valueLeft + valueRight) - valueCenter;
  final b = 0.5 * (valueRight - valueLeft);
  final c = valueCenter;
  final tRel = (valueLeft - valueRight) / (2.0 * denom);

  return MaximumOfPolynomialFit(
    dt * tRel + timeCenter,
    a * tRel * tRel + b * tRel + c,
  );
}

/// Finds the parabolic peak continuous index and amplitude around [indexCenter].
///
/// If [indexCenter] lies on the boundary (`<= 0` or `>= data.length - 1`),
/// returns the center point without interpolation.
MaximumOfPolynomialFit getPeakOfPolynomialFitArray(
  int indexCenter,
  List<double> data,
) {
  if (indexCenter <= 0 || indexCenter >= data.length - 1) {
    return MaximumOfPolynomialFit(indexCenter.toDouble(), data[indexCenter]);
  }
  return getPeakOfPolynomialFit(
    data[indexCenter - 1],
    data[indexCenter],
    data[indexCenter + 1],
    indexCenter.toDouble(),
    1.0,
  );
}
