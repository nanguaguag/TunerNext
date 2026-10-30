import 'dart:math' as math;
import 'dart:typed_data';
import 'tuning_math.dart';

/// Stores and queries the discrete frequencies of a musical scale across all octaves,
/// providing logarithmic interpolation and extrapolation for continuous pitch tracking.
class MusicalScaleFrequencies {
  MusicalScaleFrequencies(List<double> frequencies, this.indexOfReferenceNote)
    : _frequencies = Float64List.fromList(frequencies) {
    if (_frequencies.isEmpty) {
      throw ArgumentError('Frequencies list cannot be empty');
    }
  }

  final Float64List _frequencies;

  /// Index in the frequencies list corresponding to the reference note (offset 0).
  final int indexOfReferenceNote;

  /// Number of frequencies stored in the scale.
  int get length => _frequencies.length;

  /// First available relative frequency index (inclusive).
  int get indexStart => -indexOfReferenceNote;

  /// End relative frequency index (exclusive).
  int get indexEnd => indexStart + _frequencies.length;

  /// Returns the frequency at the given discrete note index.
  ///
  /// Index is relative to the reference note (index 0).
  /// If [index] is outside the range `[indexStart, indexEnd - 1]`, it is clamped
  /// to the lower or upper boundary frequency.
  double operator [](int index) {
    final clamped = (index + indexOfReferenceNote).clamp(
      0,
      _frequencies.length - 1,
    );
    return _frequencies[clamped];
  }

  /// Obtains the frequency for a continuous floating-point note index.
  ///
  /// If [index] is not an integer, values are interpolated logarithmically.
  /// If [index] is out of bounds, values are extrapolated geometrically using
  /// the step ratio of the nearest interval.
  double getInterpolated(double index) {
    final noteIndexLower = index.floor();
    if (noteIndexLower < indexStart) {
      final f0 = this[indexStart];
      final f1 = this[indexStart + 1];
      final ratio = f1 / f0;
      return f0 * math.pow(ratio, index - indexStart);
    } else if (noteIndexLower >= indexEnd - 1) {
      final fLast = this[indexEnd - 1];
      final fPrev = this[indexEnd - 2];
      final ratio = fLast / fPrev;
      return fLast * math.pow(ratio, index - (indexEnd - 1));
    } else {
      final fLower = this[noteIndexLower];
      final fUpper = this[noteIndexLower + 1];
      final ratio = fUpper / fLower;
      return fLower * math.pow(ratio, index - noteIndexLower);
    }
  }

  /// Calculates the continuous floating-point note index corresponding to [frequency].
  ///
  /// Fractional indices represent pitch deviations between notes on a logarithmic scale.
  double getFrequencyIndex(double frequency) {
    if (_frequencies.isEmpty || frequency.isNaN || frequency <= 0.0) {
      return getClosestFrequencyIndex(frequency).toDouble();
    }

    final closestIndex = getClosestFrequencyIndex(frequency);
    final closestFrequency = this[closestIndex];

    if (frequency == closestFrequency || _frequencies.length == 1) {
      return closestIndex.toDouble();
    } else if (closestIndex > indexStart &&
        (frequency < closestFrequency || closestIndex == indexEnd - 1)) {
      final fPrev = this[closestIndex - 1];
      return closestIndex -
          math.log(closestFrequency / frequency) /
              math.log(closestFrequency / fPrev);
    } else if (closestIndex < indexEnd - 1 &&
        (frequency > closestFrequency || closestIndex == indexStart)) {
      final fNext = this[closestIndex + 1];
      return closestIndex +
          math.log(closestFrequency / frequency) /
              math.log(closestFrequency / fNext);
    } else {
      return closestIndex.toDouble();
    }
  }

  /// Finds the discrete integer note index closest to the given [frequency]
  /// on a logarithmic scale.
  int getClosestFrequencyIndex(double frequency) {
    if (_frequencies.isEmpty) return 0;
    if (frequency.isNaN || frequency <= 0.0) return indexStart;

    final index = _binarySearch(_frequencies, frequency);
    if (index >= 0) {
      return index - indexOfReferenceNote;
    }

    final indexAfter = -index - 1;
    final indexBefore = indexAfter - 1;

    if (indexAfter <= 0) {
      return -indexOfReferenceNote;
    }
    if (indexAfter >= _frequencies.length) {
      return _frequencies.length - 1 - indexOfReferenceNote;
    }

    // Compare logarithmic distances between neighbor frequencies
    final distBefore = math.log(frequency / _frequencies[indexBefore]);
    final distAfter = math.log(_frequencies[indexAfter] / frequency);

    if (distBefore < distAfter) {
      return indexBefore - indexOfReferenceNote;
    } else {
      return indexAfter - indexOfReferenceNote;
    }
  }

  /// Standard binary search implementation adhering to Java/Kotlin conventions:
  /// returns non-negative index if found; otherwise `-(insertionPoint + 1)`.
  static int _binarySearch(Float64List list, double value) {
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

  /// Factory to construct a complete multi-octave [MusicalScaleFrequencies] table.
  ///
  /// - [cents]: Pitch values of the scale within one octave, including octave bounds
  ///   (e.g., `[0, 100, 200, ..., 1200]` for 12-EDO).
  /// - [referenceIndexWithinOctave]: Index in [cents] where the reference pitch sits (e.g. 9 or 10).
  /// - [referenceFrequency]: The nominal frequency in Hz of the reference note (e.g. 440.0 Hz).
  /// - [frequencyMin]: Lower frequency cut-off (Hz).
  /// - [frequencyMax]: Upper frequency cut-off (Hz).
  /// - [stretchFunction]: Optional function mapping unstretched frequency to stretched frequency.
  static MusicalScaleFrequencies create({
    required List<double> cents,
    required int referenceIndexWithinOctave,
    required double referenceFrequency,
    required double frequencyMin,
    required double frequencyMax,
    double Function(double unstretchedFrequency)? stretchFunction,
  }) {
    if (cents.length < 2) {
      throw ArgumentError(
        'Cents array must contain at least 2 entries (octave bounds)',
      );
    }
    if (referenceIndexWithinOctave < 0 ||
        referenceIndexWithinOctave >= cents.length - 1) {
      throw RangeError.range(
        referenceIndexWithinOctave,
        0,
        cents.length - 2,
        'referenceIndexWithinOctave',
      );
    }

    final numberOfNotesPerOctave = cents.length - 1;
    final centsReference = cents[referenceIndexWithinOctave];
    final octaveSpanCents = cents.last - cents.first;

    double applyStretch(double f) {
      if (stretchFunction != null) {
        return stretchFunction(f);
      }
      return f;
    }

    // 1. Collect frequencies from reference up to frequencyMax
    var octaveWiseCentCounter = 0.0;
    var indexWithinOctave = referenceIndexWithinOctave;
    final higherFrequencies = <double>[];
    var globalIndexOfReferenceHigh = 0;

    var currentFrequency = applyStretch(referenceFrequency);
    while (currentFrequency < frequencyMax) {
      if (currentFrequency > frequencyMin) {
        higherFrequencies.add(currentFrequency);
      } else {
        globalIndexOfReferenceHigh--;
      }

      indexWithinOctave++;
      if (indexWithinOctave == numberOfNotesPerOctave) {
        indexWithinOctave = 0;
        octaveWiseCentCounter += octaveSpanCents;
      }

      final centsNext =
          octaveWiseCentCounter + cents[indexWithinOctave] - centsReference;
      final rawFreq = TuningMath.centsToFrequency(
        centsNext,
        referenceFrequency,
      );
      currentFrequency = applyStretch(rawFreq);
    }

    // 2. Collect frequencies from reference down to frequencyMin
    octaveWiseCentCounter = 0.0;
    indexWithinOctave = referenceIndexWithinOctave;
    final lowerFrequencies = <double>[];
    var globalIndexOfReferenceLow = 0;

    currentFrequency = applyStretch(referenceFrequency);
    while (currentFrequency > frequencyMin) {
      if (currentFrequency < frequencyMax) {
        lowerFrequencies.add(currentFrequency);
      } else {
        globalIndexOfReferenceLow--;
      }

      indexWithinOctave--;
      if (indexWithinOctave < 0) {
        indexWithinOctave = numberOfNotesPerOctave - 1;
        octaveWiseCentCounter -= octaveSpanCents;
      }

      final centsNext =
          octaveWiseCentCounter + cents[indexWithinOctave] - centsReference;
      final rawFreq = TuningMath.centsToFrequency(
        centsNext,
        referenceFrequency,
      );
      currentFrequency = applyStretch(rawFreq);
    }

    // 3. Merge into unified ascending array and establish reference index
    final List<double> mergedFrequencies;
    final int refIndex;

    if (higherFrequencies.isEmpty) {
      mergedFrequencies = lowerFrequencies.reversed.toList();
      refIndex = lowerFrequencies.length - 1 - globalIndexOfReferenceLow;
    } else if (lowerFrequencies.isEmpty) {
      mergedFrequencies = higherFrequencies;
      refIndex = globalIndexOfReferenceHigh;
    } else {
      mergedFrequencies = List<double>.filled(
        lowerFrequencies.length + higherFrequencies.length - 1,
        0.0,
      );
      for (int i = 0; i < lowerFrequencies.length; i++) {
        mergedFrequencies[lowerFrequencies.length - 1 - i] =
            lowerFrequencies[i];
      }
      for (int i = 1; i < higherFrequencies.length; i++) {
        mergedFrequencies[lowerFrequencies.length - 1 + i] =
            higherFrequencies[i];
      }
      refIndex = lowerFrequencies.length - 1;
    }

    // Enforce exact reference frequency at the reference index
    if (refIndex >= 0 && refIndex < mergedFrequencies.length) {
      mergedFrequencies[refIndex] = referenceFrequency;
    }

    return MusicalScaleFrequencies(mergedFrequencies, refIndex);
  }
}
