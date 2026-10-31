import 'dart:math' as math;
import '../tuning/tuning_math.dart';

/// Represents a stretch tuning curve (such as the Railsback curve for pianos),
/// mapping theoretical unstretched harmonic frequencies to stretched frequencies
/// to compensate for acoustic inharmonicity caused by string stiffness.
class StretchTuning {
  StretchTuning({
    this.name = 'No Stretch Tuning',
    this.description =
        'Theoretical unstretched tuning without Railsback dispersion.',
    List<double>? unstretchedFrequencies,
    List<double>? stretchInCents,
    List<int>? keys,
    this.stableId = noStableId,
  }) : unstretchedFrequencies = List.unmodifiable(
         unstretchedFrequencies ?? const [],
       ),
       stretchInCents = List.unmodifiable(stretchInCents ?? const []),
       keys = List.unmodifiable(
         keys ??
             List<int>.generate(unstretchedFrequencies?.length ?? 0, (i) => i),
       ) {
    if (this.unstretchedFrequencies.length != this.stretchInCents.length) {
      throw ArgumentError(
        'unstretchedFrequencies and stretchInCents must have equal lengths',
      );
    }
    if (this.unstretchedFrequencies.length != this.keys.length) {
      throw ArgumentError('keys list must have the same length as frequencies');
    }
  }

  static const int noKey = -1;
  static const int noStableId = 0x7fffffff;

  /// Display name of the stretch tuning.
  final String name;

  /// Detailed description.
  final String description;

  /// Ordered nominal frequencies (Hz) that define the control points of the curve.
  final List<double> unstretchedFrequencies;

  /// Signed cent deviation at each control point.
  final List<double> stretchInCents;

  /// Unique identifiers for each control point (used for UI table modifications).
  final List<int> keys;

  /// Stable persistent identifier.
  final int stableId;

  /// Number of control points defining the curve.
  int get size => unstretchedFrequencies.length;

  /// Whether the curve has no control points (identity curve).
  bool get isEmpty => unstretchedFrequencies.isEmpty;

  /// Absolute stretched frequencies corresponding to each control point.
  late final List<double> stretchedFrequencies = List.generate(size, (i) {
    return TuningMath.centsToFrequency(
      stretchInCents[i],
      unstretchedFrequencies[i],
    );
  });

  /// True if the stretched frequencies remain strictly monotonic increasing.
  late final bool isMonotonic = _checkIsMonotonic(stretchedFrequencies);

  static bool _checkIsMonotonic(List<double> values) {
    if (values.length <= 1) return true;
    for (int i = 1; i < values.length; i++) {
      if (values[i] <= values[i - 1]) return false;
    }
    return true;
  }

  /// Calculates the stretched frequency for an arbitrary [unstretchedFrequency],
  /// zero-referenced at [referenceFrequency] (e.g. 440.0 Hz).
  double getStretchedFrequency(
    double unstretchedFrequency,
    double referenceFrequency,
  ) {
    if (unstretchedFrequency <= 0.0 || unstretchedFrequency.isNaN) {
      return unstretchedFrequency;
    }
    final stretch = getStretchInCents(unstretchedFrequency, referenceFrequency);
    return TuningMath.centsToFrequency(stretch, unstretchedFrequency);
  }

  /// Evaluates the relative stretch in cents for [unstretchedFrequency]
  /// referenced against [referenceFrequency].
  double getStretchInCents(
    double unstretchedFrequency, [
    double referenceFrequency = 440.0,
  ]) {
    if (size <= 1) return 0.0;
    final refStretch = _interpolateStretch(referenceFrequency);
    final rawStretch = _interpolateStretch(unstretchedFrequency);
    return rawStretch - refStretch;
  }

  /// Performs logarithmic-scale linear interpolation / geometric extrapolation
  /// of the cent deviation at [frequency].
  double _interpolateStretch(double frequency) {
    if (size <= 1) return 0.0;
    if (frequency <= 0.0 || frequency.isNaN) return 0.0;

    final index = _binarySearch(unstretchedFrequencies, frequency);
    if (index >= 0) {
      return stretchInCents[index];
    }

    final insertionIndex = -index - 1;
    final i0 = (insertionIndex - 1).clamp(0, size - 2);
    final i1 = i0 + 1;

    final f0 = unstretchedFrequencies[i0];
    final f1 = unstretchedFrequencies[i1];
    final c0 = stretchInCents[i0];
    final c1 = stretchInCents[i1];

    // Log-scale interpolation: t = ln(f / f0) / ln(f1 / f0)
    final t = math.log(frequency / f0) / math.log(f1 / f0);
    return c0 + (c1 - c0) * t;
  }

  static int _binarySearch(List<double> list, double value) {
    int low = 0;
    int high = list.length - 1;
    while (low <= high) {
      final mid = (low + high) >>> 1;
      final midVal = list[mid];
      if (midVal < value) {
        low = mid + 1;
      } else if (midVal > value) {
        high = mid - 1;
      } else {
        return mid;
      }
    }
    return -(low + 1);
  }

  /// Returns a new [StretchTuning] with a control point added or overwritten.
  StretchTuning add(double frequency, double stretch) {
    final key = _generateUniqueKey();
    return _addInternal(frequency, stretch, key);
  }

  /// Returns a new [StretchTuning] with the control point matching [key] removed.
  StretchTuning remove(int key) {
    final pos = keys.indexOf(key);
    if (pos < 0) return this;

    final newFreqs = List<double>.from(unstretchedFrequencies)..removeAt(pos);
    final newCents = List<double>.from(stretchInCents)..removeAt(pos);
    final newKeys = List<int>.from(keys)..removeAt(pos);

    return StretchTuning(
      name: name,
      description: description,
      unstretchedFrequencies: newFreqs,
      stretchInCents: newCents,
      keys: newKeys,
      stableId: stableId,
    );
  }

  /// Returns a new [StretchTuning] with modified values for control point [key].
  StretchTuning modify(double frequency, double stretch, int key) {
    final pos = keys.indexOf(key);
    if (pos < 0) return this;

    if (unstretchedFrequencies[pos] == frequency) {
      final newCents = List<double>.from(stretchInCents);
      newCents[pos] = stretch;
      return StretchTuning(
        name: name,
        description: description,
        unstretchedFrequencies: unstretchedFrequencies,
        stretchInCents: newCents,
        keys: keys,
        stableId: stableId,
      );
    } else {
      return remove(key)._addInternal(frequency, stretch, key);
    }
  }

  StretchTuning _addInternal(double frequency, double stretch, int key) {
    final pos = _binarySearch(unstretchedFrequencies, frequency);
    if (pos >= 0) {
      return modify(frequency, stretch, keys[pos]);
    }

    final insertIndex = -pos - 1;
    final newFreqs = List<double>.from(unstretchedFrequencies)
      ..insert(insertIndex, frequency);
    final newCents = List<double>.from(stretchInCents)
      ..insert(insertIndex, stretch);
    final newKeys = List<int>.from(keys)..insert(insertIndex, key);

    return StretchTuning(
      name: name,
      description: description,
      unstretchedFrequencies: newFreqs,
      stretchInCents: newCents,
      keys: newKeys,
      stableId: stableId,
    );
  }

  int _generateUniqueKey() {
    int candidate = 0;
    while (keys.contains(candidate)) {
      candidate++;
    }
    return candidate;
  }
}
