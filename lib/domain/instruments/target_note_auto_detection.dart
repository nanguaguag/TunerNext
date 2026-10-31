import 'dart:math' as math;

import '../models/musical_note.dart';
import '../tuning/musical_scale_frequencies.dart';
import '../tuning/tuning_math.dart';
import 'instrument.dart';
import 'instrument_icon.dart';
import 'sorted_and_distinct_instrument_strings.dart';

/// Intelligent target note and string selector with hysteresis stabilization against jitter.
///
/// Dispatches incoming acoustic frequencies to the closest string on an [instrument]
/// or the closest chromatic semitone, applying hysteresis bounds when a [previousNote]
/// is already tracked.
class TargetNoteAutoDetection {
  TargetNoteAutoDetection({
    required this.scaleFrequencies,
    Instrument? instrument,
    this.toleranceInCents = 5.0,
    this.referenceMidi = 69,
    this.relativeDeviationForChangingTarget = 0.6,
    this.minimumCentDeviationBeforeChangingTarget = 20.0,
  }) : instrument =
           instrument ??
           const Instrument(
             name: '',
             strings: [],
             icon: InstrumentIcon.piano,
             stableId: 0,
             isChromatic: true,
           ),
       sortedStrings = SortedAndDistinctInstrumentStrings(
         instrument:
             instrument ??
             const Instrument(
               name: '',
               strings: [],
               icon: InstrumentIcon.piano,
               stableId: 0,
               isChromatic: true,
             ),
         referenceMidi: referenceMidi,
       );

  final MusicalScaleFrequencies scaleFrequencies;
  final Instrument instrument;
  final double toleranceInCents;
  final int referenceMidi;

  /// Fraction of distance between adjacent targets where switching occurs (default 0.6).
  final double relativeDeviationForChangingTarget;

  /// Minimum cent boundary deviation before triggering a note change (default 20.0 cents).
  final double minimumCentDeviationBeforeChangingTarget;

  final SortedAndDistinctInstrumentStrings sortedStrings;

  List<int> get _sortedIndices => sortedStrings.sortedAndDistinctNoteIndices;
  int get _numDifferentNotes => sortedStrings.numDifferentNotes;

  /// Detects the target note based on acoustic [frequency] and optional [previousNote].
  ///
  /// Returns null for non-positive frequencies or when an instrument has no strings
  /// that exist in the active scale.
  MusicalNote? detect(double frequency, [MusicalNote? previousNote]) {
    if (frequency <= 0.0 ||
        frequency.isNaN ||
        (!instrument.isChromatic && _numDifferentNotes == 0)) {
      return null;
    }

    // 1. Check if previous note should be preserved via hysteresis
    if (previousNote != null &&
        sortedStrings.isNotePartOfInstrument(
          previousNote,
          referenceMidi: referenceMidi,
        )) {
      final bounds = _getFrequencyBoundsForNote(previousNote);
      if (frequency >= bounds[0] && frequency <= bounds[1]) {
        return previousNote;
      }
    }

    // 2. Unbiased closest target selection
    if (instrument.isChromatic) {
      final closestIndex = scaleFrequencies.getClosestFrequencyIndex(frequency);
      return _scaleIndexToNote(closestIndex);
    }

    if (_numDifferentNotes == 1) {
      return _scaleIndexToNote(_sortedIndices[0]);
    }

    final continuousIndex = scaleFrequencies.getFrequencyIndex(frequency);
    return _findClosestInstrumentString(continuousIndex);
  }

  MusicalNote _scaleIndexToNote(int scaleIndex) {
    final midiNumber = referenceMidi + scaleIndex;
    return MusicalNote.fromMidiNumber(midiNumber);
  }

  MusicalNote _findClosestInstrumentString(double continuousIndex) {
    int low = 0;
    int high = _numDifferentNotes - 1;

    // Binary search for insertion point
    while (low <= high) {
      final mid = (low + high) >> 1;
      final val = _sortedIndices[mid].toDouble();
      if (val < continuousIndex) {
        low = mid + 1;
      } else if (val > continuousIndex) {
        high = mid - 1;
      } else {
        return _scaleIndexToNote(_sortedIndices[mid]);
      }
    }

    // Determine whether low - 1 or low is closer
    final bestIdx = _chooseClosestIndex(continuousIndex, low);
    return _scaleIndexToNote(_sortedIndices[bestIdx]);
  }

  int _chooseClosestIndex(double targetIndex, int insertionPoint) {
    if (insertionPoint <= 0) return 0;
    if (insertionPoint >= _numDifferentNotes) return _numDifferentNotes - 1;

    final distPrev = (targetIndex - _sortedIndices[insertionPoint - 1]).abs();
    final distNext = (_sortedIndices[insertionPoint] - targetIndex).abs();

    return distPrev < distNext ? insertionPoint - 1 : insertionPoint;
  }

  List<double> _getFrequencyBoundsForNote(MusicalNote note) {
    final scaleIndex = _noteToScaleIndex(note);
    if (scaleIndex == null) {
      return [double.infinity, double.negativeInfinity];
    }

    if (instrument.isChromatic) {
      return _getChromaticBounds(scaleIndex);
    }

    if (_numDifferentNotes <= 1) {
      return [double.negativeInfinity, double.infinity];
    }

    final stringIndex = _sortedIndices.indexOf(scaleIndex);
    if (stringIndex < 0 ||
        _sortedIndices[stringIndex] ==
            SortedAndDistinctInstrumentStrings.sentinelIndex) {
      return [double.infinity, double.negativeInfinity];
    }

    return _getInstrumentStringBounds(stringIndex);
  }

  int? _noteToScaleIndex(MusicalNote note) {
    // Non-standard modifiers do not map to discrete 12-EDO scale
    if (note.modifier != NoteModifier.none &&
        note.modifier != NoteModifier.sharp &&
        note.modifier != NoteModifier.flat &&
        note.modifier != NoteModifier.doubleSharp &&
        note.modifier != NoteModifier.doubleFlat) {
      return null;
    }
    return note.midiNumber - referenceMidi;
  }

  List<double> _getChromaticBounds(int targetIndex) {
    final centerFreq = scaleFrequencies.getInterpolated(targetIndex.toDouble());

    final lowerFreqDev = scaleFrequencies.getInterpolated(
      targetIndex - relativeDeviationForChangingTarget,
    );
    final upperFreqDev = scaleFrequencies.getInterpolated(
      targetIndex + relativeDeviationForChangingTarget,
    );

    final freqLowerTarget = scaleFrequencies.getInterpolated(targetIndex - 1.0);
    final freqUpperTarget = scaleFrequencies.getInterpolated(targetIndex + 1.0);

    final centsToLowerBound =
        TuningMath.ratioToCents(centerFreq / freqLowerTarget) -
        toleranceInCents;
    final centsToUpperBound =
        TuningMath.ratioToCents(freqUpperTarget / centerFreq) -
        toleranceInCents;

    final lowerFreqCent =
        centerFreq /
        TuningMath.centsToRatio(
          math.min(minimumCentDeviationBeforeChangingTarget, centsToLowerBound),
        );
    final upperFreqCent =
        centerFreq *
        TuningMath.centsToRatio(
          math.min(minimumCentDeviationBeforeChangingTarget, centsToUpperBound),
        );

    return [
      math.min(lowerFreqDev, lowerFreqCent),
      math.max(upperFreqDev, upperFreqCent),
    ];
  }

  List<double> _getInstrumentStringBounds(int stringIndex) {
    final centerIdx = _sortedIndices[stringIndex];
    final centerFreq = scaleFrequencies.getInterpolated(centerIdx.toDouble());

    // Lower bound: lowest string has unbounded negative infinite range
    double lowerBound;
    if (stringIndex == 0) {
      lowerBound = double.negativeInfinity;
    } else {
      final prevIdx = _sortedIndices[stringIndex - 1];
      final lowerDevIdx =
          (1.0 - relativeDeviationForChangingTarget) * centerIdx +
          relativeDeviationForChangingTarget * prevIdx;
      final lowerFreqDev = scaleFrequencies.getInterpolated(lowerDevIdx);

      final freqLowerTarget = scaleFrequencies.getInterpolated(
        prevIdx.toDouble(),
      );
      final centsToLowerBound =
          TuningMath.ratioToCents(centerFreq / freqLowerTarget) -
          toleranceInCents;

      final lowerFreqCent =
          centerFreq /
          TuningMath.centsToRatio(
            math.min(
              minimumCentDeviationBeforeChangingTarget,
              centsToLowerBound,
            ),
          );

      lowerBound = math.min(lowerFreqDev, lowerFreqCent);
    }

    // Upper bound: highest string has unbounded positive infinite range
    double upperBound;
    if (stringIndex == _numDifferentNotes - 1) {
      upperBound = double.infinity;
    } else {
      final nextIdx = _sortedIndices[stringIndex + 1];
      final upperDevIdx =
          (1.0 - relativeDeviationForChangingTarget) * centerIdx +
          relativeDeviationForChangingTarget * nextIdx;
      final upperFreqDev = scaleFrequencies.getInterpolated(upperDevIdx);

      final freqUpperTarget = scaleFrequencies.getInterpolated(
        nextIdx.toDouble(),
      );
      final centsToUpperBound =
          TuningMath.ratioToCents(freqUpperTarget / centerFreq) -
          toleranceInCents;

      final upperFreqCent =
          centerFreq *
          TuningMath.centsToRatio(
            math.min(
              minimumCentDeviationBeforeChangingTarget,
              centsToUpperBound,
            ),
          );

      upperBound = math.max(upperFreqDev, upperFreqCent);
    }

    return [lowerBound, upperBound];
  }
}
