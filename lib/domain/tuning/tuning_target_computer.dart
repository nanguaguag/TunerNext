import '../models/musical_note.dart';
import '../models/tuning_state.dart';
import '../models/tuning_target.dart';
import '../musical_scale/musical_scale.dart';
import '../temperaments/temperament_models.dart';

/// Evaluated tuning status containing target, cent deviation, and in-tune verdict.
class TuningEvaluation {
  const TuningEvaluation({
    required this.target,
    required this.deviationCents,
    required this.state,
    required this.measuredFrequency,
  });

  final TuningTarget target;
  final double deviationCents;
  final TuningState state;
  final double measuredFrequency;
}

/// Evaluates real-time detected frequency against musical scale, instrument strings, and tolerance.
class TuningTargetComputer {
  const TuningTargetComputer({
    required this.scale,
    this.instrumentStrings = const [],
    this.inTuneToleranceCents = 5.0,
  });

  final MusicalScale scale;
  final List<MusicalNote> instrumentStrings;
  final double inTuneToleranceCents;

  /// Resolves target note and frequency for measured [frequency].
  TuningTarget computeTarget({
    required double frequency,
    MusicalNote? manualTargetNote,
  }) {
    // 1. If signal is silent or frequency invalid, default to scale reference note
    if (frequency <= 0.0 || frequency.isNaN) {
      return TuningTarget(
        note: scale.referenceNote,
        frequency: scale.referenceFrequency,
        isPartOfInstrument:
            instrumentStrings.isEmpty ||
            instrumentStrings.any((s) => s.matches(scale.referenceNote)),
        instrumentHasNoStrings: instrumentStrings.isEmpty,
      );
    }

    // 2. Manual user override
    if (manualTargetNote != null) {
      final closestIdx = scale.getClosestNoteIndex(frequency);
      final closestNote = scale.getNote(closestIdx);
      final noteFreq = closestNote.matches(manualTargetNote)
          ? scale.getNoteFrequency(closestIdx)
          : scale.referenceFrequency;

      return TuningTarget(
        note: manualTargetNote,
        frequency: noteFreq,
        isPartOfInstrument: instrumentStrings.any(
          (s) => s.matches(manualTargetNote),
        ),
        instrumentHasNoStrings: instrumentStrings.isEmpty,
      );
    }

    // 3. Instrument string lock
    if (instrumentStrings.isNotEmpty) {
      MusicalNote? bestString;
      var bestDiffCents = double.infinity;
      var bestStringFreq = 0.0;

      for (final stringNote in instrumentStrings) {
        // Find matching scale index for string
        for (var i = scale.noteIndexBegin; i < scale.noteIndexEnd; i++) {
          if (scale.getNote(i).matches(stringNote)) {
            final fString = scale.getNoteFrequency(i);
            final diff = (frequencyToCents(frequency, fString)).abs();
            if (diff < bestDiffCents) {
              bestDiffCents = diff;
              bestString = stringNote;
              bestStringFreq = fString;
            }
          }
        }
      }

      if (bestString != null && bestDiffCents < 150.0) {
        return TuningTarget(
          note: bestString,
          frequency: bestStringFreq,
          isPartOfInstrument: true,
          instrumentHasNoStrings: false,
        );
      }
    }

    // 4. Chromatic fallback to closest scale note
    final closestIdx = scale.getClosestNoteIndex(frequency);
    final targetNote = scale.getNote(closestIdx);
    final targetFreq = scale.getNoteFrequency(closestIdx);

    return TuningTarget(
      note: targetNote,
      frequency: targetFreq,
      isPartOfInstrument:
          instrumentStrings.isNotEmpty &&
          instrumentStrings.any((s) => s.matches(targetNote)),
      instrumentHasNoStrings: instrumentStrings.isEmpty,
    );
  }

  /// Evaluates in-tune / sharp / flat status of [frequency] against target.
  TuningEvaluation evaluate({
    required double frequency,
    MusicalNote? manualTargetNote,
  }) {
    if (frequency <= 0.0 || frequency.isNaN) {
      final target = computeTarget(frequency: 0.0);
      return TuningEvaluation(
        target: target,
        deviationCents: 0.0,
        state: TuningState.unknown,
        measuredFrequency: frequency,
      );
    }

    final target = computeTarget(
      frequency: frequency,
      manualTargetNote: manualTargetNote,
    );

    final deviation = frequencyToCents(frequency, target.frequency);
    final TuningState state;
    if (deviation.abs() <= inTuneToleranceCents) {
      state = TuningState.inTune;
    } else if (deviation < -inTuneToleranceCents) {
      state = TuningState.tooLow;
    } else {
      state = TuningState.tooHigh;
    }

    return TuningEvaluation(
      target: target,
      deviationCents: deviation,
      state: state,
      measuredFrequency: frequency,
    );
  }
}
