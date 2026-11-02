import 'dart:math';
import 'package:flutter/foundation.dart';

/// State container managing the historical stream of detected pitch frequencies.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.tuning.PitchHistoryState`.
class PitchHistoryState extends ChangeNotifier {
  PitchHistoryState({required int capacity})
    : _capacity = capacity,
      _frequencies = [] {
    if (capacity <= 0) {
      throw ArgumentError.value(capacity, 'capacity', 'Must be positive');
    }
  }

  int _capacity;
  final List<double?> _frequencies;

  /// Maximum number of historical points stored.
  int get capacity => _capacity;

  /// Ordered list of pitch frequencies (null represents silence / invalid frame).
  List<double?> get frequencies => List.unmodifiable(_frequencies);

  /// Current number of stored values.
  int get size => _frequencies.length;

  /// The most recently added frequency, or null if silent/empty.
  double? get latestFrequency =>
      _frequencies.isNotEmpty ? _frequencies.last : null;

  /// Adds a new frequency sample to history.
  /// If [frequency] is non-positive or NaN, it is stored as `null` (mute break).
  void addFrequency(double? frequency) {
    final valid = frequency != null && frequency > 0.0 && !frequency.isNaN;
    final val = valid ? frequency : null;

    if (_frequencies.length >= _capacity) {
      _frequencies.removeAt(0);
    }
    _frequencies.add(val);
    notifyListeners();
  }

  /// Clears all historical samples.
  void clear() {
    _frequencies.clear();
    notifyListeners();
  }

  /// Resizes the buffer capacity, trimming oldest items if necessary.
  void resize(int newCapacity) {
    if (newCapacity <= 0) {
      throw ArgumentError.value(newCapacity, 'newCapacity', 'Must be positive');
    }
    _capacity = newCapacity;
    if (_frequencies.length > _capacity) {
      _frequencies.removeRange(0, _frequencies.length - _capacity);
    }
    notifyListeners();
  }

  /// Computes the required history buffer size given signal parameters.
  ///
  /// Matches Kotlin `PitchHistoryState.computePitchHistorySize`.
  static int computePitchHistorySize({
    required double durationSeconds,
    required int sampleRate,
    required int windowSize,
    required double overlap,
  }) {
    if (durationSeconds <= 0 || sampleRate <= 0 || windowSize <= 0) {
      return 100;
    }
    final stepSize = windowSize * (1.0 - overlap);
    if (stepSize <= 0) return 100;
    final hopDuration = stepSize / sampleRate;
    return max(2, (durationSeconds / hopDuration).round());
  }
}
