import 'dart:math' as math;

/// Single smoothing buffer tracking a running mean while filtering out relative deviations.
class OutlierRemovingSmoothingBuffer {
  OutlierRemovingSmoothingBuffer({
    required this.maxSize,
    required this.minValue,
    required this.maxValue,
    required this.maxRelativeDeviation,
    required this.maxNumSuccessiveOutliers,
  }) : _values = List<double>.filled(maxSize > 0 ? maxSize : 1, 0.0);

  final int maxSize;
  final double minValue;
  final double maxValue;
  final double maxRelativeDeviation;
  final int maxNumSuccessiveOutliers;

  final List<double> _values;
  int _indexZero = 0;
  int numSuccessiveOutliers = 0;
  int size = 0;
  double mean = 0.0;

  void clear() {
    _indexZero = 0;
    size = 0;
    mean = 0.0;
    numSuccessiveOutliers = 0;
  }

  /// Appends [value] if within limits and acceptable relative deviation.
  bool append(double value) {
    if (maxSize == 0) return false;

    if (value < minValue ||
        value > maxValue ||
        _computeDeviation(value) > maxRelativeDeviation) {
      incrementOutlierCount();
      return false;
    } else {
      _addValueToBuffer(value);
      numSuccessiveOutliers = 0;
      mean = _computeMean();
      return true;
    }
  }

  void incrementOutlierCount() {
    numSuccessiveOutliers++;
    if (numSuccessiveOutliers > maxNumSuccessiveOutliers) {
      clear();
    }
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
    if (size == 0) return 0.0;
    var sum = 0.0;
    for (var i = 0; i < size; i++) {
      sum += _values[(_indexZero + i) % maxSize];
    }
    return sum / size;
  }

  double _computeDeviation(double value) {
    if (size == 0 || mean == 0.0) return 0.0;
    return (value - mean).abs() / mean.abs();
  }
}

/// Adaptive multi-buffer online frequency smoother with outlier rejection.
class OutlierRemovingSmoother {
  OutlierRemovingSmoother({
    required this.size,
    required this.minValue,
    required this.maxValue,
    this.relativeDeviationToBeAnOutlier = 0.1,
    this.maxNumSuccessiveOutliers = 3,
    int minNumValuesForValidMean = 2,
    int numBuffers = 3,
  }) : minNumValuesForValidMean = math.min(minNumValuesForValidMean, size),
       _buffers = List.generate(
         numBuffers,
         (_) => OutlierRemovingSmoothingBuffer(
           maxSize: size,
           minValue: minValue,
           maxValue: maxValue,
           maxRelativeDeviation: relativeDeviationToBeAnOutlier,
           maxNumSuccessiveOutliers: maxNumSuccessiveOutliers,
         ),
       );

  final int size;
  final double minValue;
  final double maxValue;
  final double relativeDeviationToBeAnOutlier;
  final int maxNumSuccessiveOutliers;
  final int minNumValuesForValidMean;
  final List<OutlierRemovingSmoothingBuffer> _buffers;

  double smoothedValue = 0.0;

  /// Feeds a new detected [value] into the multi-buffer pipeline.
  /// Returns the smoothed mean, or 0.0 if in an unconfirmed outlier phase.
  double smooth(double value) {
    if (value <= 0.0) {
      for (final buf in _buffers) {
        buf.incrementOutlierCount();
      }
      return 0.0;
    }

    var valueAppended = false;
    for (final buffer in _buffers) {
      if (valueAppended) {
        buffer.incrementOutlierCount();
      } else {
        valueAppended = buffer.append(value);
      }
    }

    if (_buffers[0].size < minNumValuesForValidMean) {
      _buffers.sort((a, b) => b.size.compareTo(a.size));
    }

    if (_buffers[0].numSuccessiveOutliers == 0 &&
        _buffers[0].size >= minNumValuesForValidMean) {
      smoothedValue = _buffers[0].mean;
      return smoothedValue;
    } else {
      return 0.0;
    }
  }

  void reset() {
    smoothedValue = 0.0;
    for (final b in _buffers) {
      b.clear();
    }
  }
}
