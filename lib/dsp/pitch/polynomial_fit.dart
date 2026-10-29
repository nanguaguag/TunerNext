/// Extremum of a parabola fitted through three consecutive points.
class MaximumOfPolynomialFit {
  const MaximumOfPolynomialFit(this.timeOrIndex, this.value);

  /// Abscissa (time or fractional index) of the fitted peak.
  final double timeOrIndex;

  /// Peak amplitude value at the extremum.
  final double value;
}

/// Computes the peak of a parabola passing through three equally spaced points:
/// [valueLeft] at `timeCenter - dt`, [valueCenter] at `timeCenter`, and [valueRight] at `timeCenter + dt`.
MaximumOfPolynomialFit getPeakOfPolynomialFit(
  double valueLeft,
  double valueCenter,
  double valueRight,
  double timeCenter,
  double dt,
) {
  final denom = valueLeft - 2 * valueCenter + valueRight;
  if ((valueLeft == valueCenter && valueRight == valueCenter) || denom == 0.0) {
    return MaximumOfPolynomialFit(timeCenter, valueCenter);
  }

  final a = 0.5 * (valueLeft + valueRight) - valueCenter;
  final b = 0.5 * (valueRight - valueLeft);
  final c = valueCenter;
  final tRel = (valueLeft - valueRight) / (2 * denom);

  return MaximumOfPolynomialFit(
    dt * tRel + timeCenter,
    a * tRel * tRel + b * tRel + c,
  );
}

/// Finds the parabolic peak index as a continuous floating-point value around [indexCenter].
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
