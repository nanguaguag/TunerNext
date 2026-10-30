import 'dart:typed_data';

/// Encapsulates the autocorrelation sequence of an audio frame and provides
/// normalized values for UI plotting.
class AutoCorrelationData {
  /// Creates an [AutoCorrelationData] container for [size] lags with sampling interval [dt].
  AutoCorrelationData({required this.size, required this.dt})
    : times = Float32List(size),
      values = Float32List(size),
      plotValuesNormalized = Float32List(size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'Size must be positive.');
    }
    for (var i = 0; i < size; i++) {
      times[i] = i * dt;
    }
  }

  /// Number of correlation values / lags.
  final int size;

  /// Time interval between adjacent correlation points ($1 / f_s$).
  final double dt;

  /// Time shifts $\tau = i \cdot dt$ corresponding to each correlation entry.
  final Float32List times;

  /// Raw un-normalized correlation values.
  final Float32List values;

  /// Plotting values normalized strictly to the range `[0.0, 1.0]`.
  final Float32List plotValuesNormalized;

  /// The relative position of the 0.0 baseline within [plotValuesNormalized].
  double plotValuesNormalizedZero = 0.0;

  /// Returns the raw autocorrelation value at lag [index].
  double operator [](int index) => values[index];

  /// Recalculates [plotValuesNormalized] and [plotValuesNormalizedZero] based on [values].
  void updatePlotNormalized() {
    final r0 = values[0];
    if (r0 > 1e-9) {
      var minVal = double.infinity;
      var maxVal = double.negativeInfinity;
      for (var i = 0; i < size; i++) {
        final v = values[i];
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
      }

      final range = maxVal - minVal;
      if (range > 1e-9) {
        for (var i = 0; i < size; i++) {
          plotValuesNormalized[i] = (values[i] - minVal) / range;
        }
        plotValuesNormalizedZero = (0.0 - minVal) / range;
      } else {
        plotValuesNormalized.fillRange(0, size, 0.5);
        plotValuesNormalizedZero = 0.5;
      }
    } else {
      plotValuesNormalized.fillRange(0, size, 0.0);
      plotValuesNormalizedZero = 0.0;
    }
  }
}
