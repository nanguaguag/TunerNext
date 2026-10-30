import 'dart:math' as math;
import 'dart:typed_data';

/// Buffer used by [OutlierRemovingSmoother] for incremental mean calculation and outlier tracking.
class OutlierRemovingSmoothingBuffer {
  /// Creates an [OutlierRemovingSmoothingBuffer].
  OutlierRemovingSmoothingBuffer({
    required this.maxSize,
    required this.minValue,
    required this.maxValue,
    required this.maxRelativeDeviation,
    required this.maxNumSuccessiveOutliers,
  }) : _values = Float32List(maxSize);

  /// Maximum number of values held in the circular buffer.
  final int maxSize;

  /// Lower bound for acceptable values.
  final double minValue;

  /// Upper bound for acceptable values.
  final double maxValue;

  /// Maximum relative deviation from the mean for a value to be accepted.
  final double maxRelativeDeviation;

  /// Successive outlier threshold before the buffer is cleared.
  final int maxNumSuccessiveOutliers;

  final Float32List _values;
  int _indexZero = 0;

  /// Current number of successive outliers observed.
  int numSuccessiveOutliers = 0;

  /// Current count of active values in the buffer.
  int size = 0;

  /// Running arithmetic mean of values in the buffer.
  double mean = 0.0;

  /// Clears all stored values and resets the mean.
  void clear() {
    _indexZero = 0;
    size = 0;
    mean = 0.0;
    numSuccessiveOutliers = 0;
  }

  /// Attempts to append a [value] to the buffer.
  ///
  /// Returns `true` if accepted; returns `false` and increments outlier count if rejected.
  bool append(double value) {
    if (maxSize == 0) {
      return false;
    }

    if (value < minValue ||
        value > maxValue ||
        computeDeviation(value) > maxRelativeDeviation) {
      incrementOutlierCount();
      return false;
    } else {
      _addValueToBuffer(value);
      numSuccessiveOutliers = 0;
      mean = _computeMean();
      return true;
    }
  }

  /// Increments outlier counter and clears the buffer if the threshold is exceeded.
  void incrementOutlierCount() {
    numSuccessiveOutliers += 1;
    if (numSuccessiveOutliers > maxNumSuccessiveOutliers) {
      clear();
    }
  }

  double _get(int index) {
    assert(index < size);
    return _values[(_indexZero + index) % maxSize];
  }

  void _addValueToBuffer(double value) {
    if (maxSize == 0) return;

    final index = (_indexZero + size) % maxSize;
    _values[index] = value;
    final newSize = size + 1;
    if (newSize == maxSize + 1) {
      size = maxSize;
      _indexZero = (_indexZero + 1) % maxSize;
    } else {
      size = newSize;
    }
  }

  double _computeMean() {
    assert(size > 0);
    var sum = 0.0;
    for (var i = 0; i < size; i++) {
      sum += _get(i);
    }
    return sum / size;
  }

  /// Computes the relative deviation of [value] from the current [mean].
  double computeDeviation(double value) {
    if (size == 0) {
      return 0.0;
    }
    return (value - mean).abs() / mean.abs();
  }
}

/// Multi-buffer online smoother that filters out sudden outliers while maintaining rapid convergence.
class OutlierRemovingSmoother {
  /// Creates an [OutlierRemovingSmoother].
  OutlierRemovingSmoother({
    required this.size,
    required double minValue,
    required double maxValue,
    double relativeDeviationToBeAnOutlier = 0.1,
    int maxNumSuccessiveOutliers = 1,
    int minNumValuesForValidMean = 2,
    int numBuffers = 3,
  }) : minNumValuesForValidMean = math.min(minNumValuesForValidMean, size),
       buffers = List.generate(
         numBuffers,
         (_) => OutlierRemovingSmoothingBuffer(
           maxSize: size,
           minValue: minValue,
           maxValue: maxValue,
           maxRelativeDeviation: relativeDeviationToBeAnOutlier,
           maxNumSuccessiveOutliers: maxNumSuccessiveOutliers,
         ),
       );

  /// Target buffer capacity for mean computation.
  final int size;

  /// Minimum values required in a buffer to produce a valid smoothed mean.
  final int minNumValuesForValidMean;

  /// Parallel candidate buffers.
  final List<OutlierRemovingSmoothingBuffer> buffers;

  /// Last valid smoothed value, or 0.0 if uninitialized.
  double smoothedValue = 0.0;

  /// Adds [value] to the smoother and returns the updated smoothed mean.
  ///
  /// Returns 0.0 if [value] is an outlier or if the active buffer has not yet reached
  /// [minNumValuesForValidMean]. In that case, [smoothedValue] preserves the last valid state.
  double call(double value) {
    var valueAppendedSuccessfully = false;

    // Append value to the first available buffer; subsequent buffers record an outlier
    for (final buffer in buffers) {
      if (valueAppendedSuccessfully) {
        buffer.incrementOutlierCount();
      } else {
        valueAppendedSuccessfully = buffer.append(value);
      }
    }

    if (buffers[0].size < minNumValuesForValidMean) {
      buffers.sort((a, b) => b.size.compareTo(a.size));
    }

    if (buffers[0].numSuccessiveOutliers == 0 &&
        buffers[0].size >= minNumValuesForValidMean) {
      smoothedValue = buffers[0].mean;
      return smoothedValue;
    } else {
      return 0.0;
    }
  }

  /// Resets all internal buffers and state.
  void reset() {
    for (final buffer in buffers) {
      buffer.clear();
    }
    smoothedValue = 0.0;
  }
}
