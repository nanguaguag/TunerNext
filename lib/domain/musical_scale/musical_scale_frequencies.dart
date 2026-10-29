import 'dart:math' as math;
import '../stretchtuning/stretch_tuning.dart';
import '../temperaments/temperament_models.dart';

/// Precomputed frequencies of a musical scale across all audible octaves.
class MusicalScaleFrequencies {
  MusicalScaleFrequencies({
    required this.frequencies,
    required this.indexOfReferenceNote,
  });

  final List<double> frequencies;
  final int indexOfReferenceNote;

  int get indexStart => -indexOfReferenceNote;
  int get indexEnd => indexStart + frequencies.length;

  /// Returns note frequency at integer index relative to reference note.
  double operator [](int index) {
    if (frequencies.isEmpty) return 0.0;
    final clamped = (index + indexOfReferenceNote).clamp(
      0,
      frequencies.length - 1,
    );
    return frequencies[clamped];
  }

  /// Returns interpolated frequency at fractional note index.
  double getAtFractionalIndex(double index) {
    if (frequencies.isEmpty) return 0.0;
    final noteIndexLower = index.floor();
    if (noteIndexLower < indexStart) {
      final f0 = this[indexStart];
      final f1 = this[indexStart + 1];
      if (f0 <= 0.0) return 0.0;
      return f0 * math.pow(f1 / f0, index - indexStart);
    }
    if (noteIndexLower >= indexEnd - 1) {
      final f0 = this[indexEnd - 2];
      final f1 = this[indexEnd - 1];
      if (f0 <= 0.0) return 0.0;
      return f1 * math.pow(f1 / f0, index - (indexEnd - 1));
    }
    final f0 = this[noteIndexLower];
    final f1 = this[noteIndexLower + 1];
    if (f0 <= 0.0) return 0.0;
    return f0 * math.pow(f1 / f0, index - noteIndexLower);
  }

  /// Finds integer note index closest to [frequency].
  int getClosestFrequencyIndex(double frequency) {
    if (frequencies.isEmpty || frequency <= 0.0) return 0;
    var low = 0;
    var high = frequencies.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midVal = frequencies[mid];
      if (midVal == frequency) {
        return mid - indexOfReferenceNote;
      } else if (midVal < frequency) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    final idxAfter = low.clamp(0, frequencies.length - 1);
    final idxBefore = (low - 1).clamp(0, frequencies.length - 1);

    final ratioBefore = (frequency / frequencies[idxBefore]).abs();
    final ratioAfter = (frequencies[idxAfter] / frequency).abs();

    if (ratioBefore <= ratioAfter) {
      return idxBefore - indexOfReferenceNote;
    } else {
      return idxAfter - indexOfReferenceNote;
    }
  }

  /// Calculates continuous fractional note index for [frequency].
  double getFrequencyIndex(double frequency) {
    if (frequencies.isEmpty || frequency.isNaN || frequency <= 0.0) {
      return getClosestFrequencyIndex(frequency).toDouble();
    }
    final closestIndex = getClosestFrequencyIndex(frequency);
    final closestFreq = this[closestIndex];
    if (closestFreq <= 0.0) return closestIndex.toDouble();

    if (frequency > closestFreq) {
      final nextFreq = this[closestIndex + 1];
      if (nextFreq <= closestFreq) return closestIndex.toDouble();
      final diffOctave = math.log(frequency / closestFreq) / math.ln2;
      final stepOctave = math.log(nextFreq / closestFreq) / math.ln2;
      if (stepOctave <= 0.0) return closestIndex.toDouble();
      return closestIndex + (diffOctave / stepOctave);
    } else if (frequency < closestFreq) {
      final prevFreq = this[closestIndex - 1];
      if (closestFreq <= prevFreq) return closestIndex.toDouble();
      final diffOctave = math.log(closestFreq / frequency) / math.ln2;
      final stepOctave = math.log(closestFreq / prevFreq) / math.ln2;
      if (stepOctave <= 0.0) return closestIndex.toDouble();
      return closestIndex - (diffOctave / stepOctave);
    } else {
      return closestIndex.toDouble();
    }
  }

  /// Factory creating frequency tables across all octaves from temperament cents.
  static MusicalScaleFrequencies create({
    required List<double> cents,
    required int referenceIndexWithinOctave,
    required double referenceFrequency,
    required double frequencyMin,
    required double frequencyMax,
    required StretchTuning stretchTuning,
  }) {
    final numberOfNotesPerOctave = cents.length - 1;
    final centsReference = cents[referenceIndexWithinOctave];

    // 1. Collect higher frequencies starting from reference up to frequencyMax
    var octaveWiseCentCounter = 0.0;
    var indexWithinOctave = referenceIndexWithinOctave;
    final higherFrequencies = <double>[];
    var globalIndexOfRefHigh = 0;

    var currentFreq = stretchTuning.getStretchedFrequency(
      referenceFrequency,
      referenceFrequency,
    );

    while (currentFreq < frequencyMax) {
      if (currentFreq > frequencyMin) {
        higherFrequencies.add(currentFreq);
      } else {
        globalIndexOfRefHigh--;
      }
      indexWithinOctave++;
      if (indexWithinOctave == numberOfNotesPerOctave) {
        indexWithinOctave = 0;
        octaveWiseCentCounter += cents.last - cents.first;
      }
      final centsNext =
          octaveWiseCentCounter + cents[indexWithinOctave] - centsReference;
      final unstretched = centsToFrequency(centsNext, referenceFrequency);
      currentFreq = stretchTuning.getStretchedFrequency(
        unstretched,
        referenceFrequency,
      );
    }

    // 2. Collect lower frequencies starting from reference down to frequencyMin
    octaveWiseCentCounter = 0.0;
    indexWithinOctave = referenceIndexWithinOctave;
    final lowerFrequencies = <double>[];
    var globalIndexOfRefLow = 0;

    currentFreq = stretchTuning.getStretchedFrequency(
      referenceFrequency,
      referenceFrequency,
    );

    while (currentFreq > frequencyMin) {
      if (currentFreq < frequencyMax) {
        lowerFrequencies.add(currentFreq);
      } else {
        globalIndexOfRefLow--;
      }
      indexWithinOctave--;
      if (indexWithinOctave < 0) {
        indexWithinOctave = numberOfNotesPerOctave - 1;
        octaveWiseCentCounter -= cents.last - cents.first;
      }
      final centsNext =
          octaveWiseCentCounter + cents[indexWithinOctave] - centsReference;
      final unstretched = centsToFrequency(centsNext, referenceFrequency);
      currentFreq = stretchTuning.getStretchedFrequency(
        unstretched,
        referenceFrequency,
      );
    }

    // 3. Assemble combined array
    if (higherFrequencies.isEmpty) {
      return MusicalScaleFrequencies(
        frequencies: lowerFrequencies.reversed.toList(),
        indexOfReferenceNote: lowerFrequencies.length - 1 - globalIndexOfRefLow,
      );
    } else if (lowerFrequencies.isEmpty) {
      return MusicalScaleFrequencies(
        frequencies: higherFrequencies,
        indexOfReferenceNote: globalIndexOfRefHigh,
      );
    } else {
      final combined = List<double>.filled(
        lowerFrequencies.length + higherFrequencies.length - 1,
        0.0,
      );
      for (var i = 0; i < lowerFrequencies.length; i++) {
        combined[lowerFrequencies.length - i - 1] = lowerFrequencies[i];
      }
      for (var i = 0; i < higherFrequencies.length; i++) {
        combined[lowerFrequencies.length - 1 + i] = higherFrequencies[i];
      }
      final refIndex = lowerFrequencies.length - 1;
      if (refIndex >= 0 && refIndex < combined.length) {
        combined[refIndex] = referenceFrequency;
      }
      return MusicalScaleFrequencies(
        frequencies: combined,
        indexOfReferenceNote: refIndex,
      );
    }
  }
}
