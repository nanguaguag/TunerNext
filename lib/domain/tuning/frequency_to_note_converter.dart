import 'dart:math' as math;
import '../models/musical_note.dart';
import '../models/tuning_state.dart';
import '../models/tuning_target.dart';
import 'musical_scale_frequencies.dart';
import 'tuning_math.dart';

/// Comprehensive evaluation result of an acoustic pitch against a target note.
class PitchAssessment {
  const PitchAssessment({
    required this.target,
    required this.actualFrequency,
    required this.centsDeviation,
    required this.tuningState,
  });

  /// The target note and its nominal tuning frequency.
  final TuningTarget target;

  /// The measured acoustic frequency in Hertz.
  final double actualFrequency;

  /// The signed cent deviation relative to the target note.
  final double centsDeviation;

  /// Discrete tuning status (inTune, tooLow, tooHigh, or unknown).
  final TuningState tuningState;

  /// Whether the current pitch is considered successfully in-tune.
  bool get isInTune => tuningState == TuningState.inTune;

  @override
  String toString() =>
      'PitchAssessment(${target.note.name}, dev: ${centsDeviation.toStringAsFixed(1)}c, state: ${tuningState.name})';
}

/// Bidirectional converter between continuous acoustic frequencies and musical notes,
/// featuring customizable reference pitch (A4), 12-EDO logarithmic mapping,
/// cent deviation metrics, and hysteresis note stabilization.
class FrequencyToNoteConverter {
  FrequencyToNoteConverter({
    this.referenceFrequency = 440.0,
    this.referenceMidi = 69, // A4
    this.toleranceInCents = 3.0,
    this.frequencyMin = 16.0,
    this.frequencyMax = 20000.0,
    this.hysteresisRatio = 0.6,
    this.minimumHysteresisCents = 20.0,
  }) {
    if (referenceFrequency <= 0.0) {
      throw ArgumentError('Reference frequency must be positive');
    }
    _rebuildScale();
  }

  /// Reference pitch standard (default 440.0 Hz for concert A4).
  final double referenceFrequency;

  /// Reference MIDI note number (default 69 for A4).
  final int referenceMidi;

  /// Cent tolerance for classifying a pitch as in-tune (typically 3.0 to 5.0 cents).
  final double toleranceInCents;

  /// Measurable lower frequency bound in Hertz.
  final double frequencyMin;

  /// Measurable upper frequency bound in Hertz.
  final double frequencyMax;

  /// Hysteresis ratio (0.5 = neutral, 0.6 = biased towards previous note).
  final double hysteresisRatio;

  /// Minimum cent boundary required before abandoning a previously locked target.
  final double minimumHysteresisCents;

  late MusicalScaleFrequencies _scaleFrequencies;

  void _rebuildScale() {
    // 12-EDO equal temperament cents: [0, 100, 200, ..., 1200]
    final cents = List<double>.generate(13, (i) => i * 100.0);
    // In standard 12-EDO octave starting at C (0), A is at index 9.
    const referenceIndexWithinOctave = 9;

    _scaleFrequencies = MusicalScaleFrequencies.create(
      cents: cents,
      referenceIndexWithinOctave: referenceIndexWithinOctave,
      referenceFrequency: referenceFrequency,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
    );
  }

  /// Converts a frequency in Hz to a continuous MIDI note number.
  ///
  /// Formula: `referenceMidi + 12 * log2(frequency / referenceFrequency)`
  double frequencyToMidi(double frequency) {
    if (frequency <= 0.0 || frequency.isNaN) return double.nan;
    return referenceMidi +
        (12.0 * math.log(frequency / referenceFrequency) / TuningMath.ln2);
  }

  /// Converts a continuous MIDI note number to its exact frequency in Hz.
  ///
  /// Formula: `referenceFrequency * 2^((midiNumber - referenceMidi) / 12)`
  double midiToFrequency(double midiNumber) {
    if (midiNumber.isNaN) return double.nan;
    return referenceFrequency *
        math.pow(2.0, (midiNumber - referenceMidi) / 12.0);
  }

  /// Converts a [MusicalNote] to its nominal frequency in Hz.
  double noteToFrequency(MusicalNote note) {
    return midiToFrequency(note.midiNumber.toDouble());
  }

  /// Converts a frequency to the closest discrete [MusicalNote] (unbiased, without hysteresis).
  MusicalNote frequencyToNote(double frequency, {bool preferSharp = true}) {
    if (frequency <= 0.0 || frequency.isNaN) {
      return MusicalNote.fromMidiNumber(
        referenceMidi,
        preferSharp: preferSharp,
      );
    }
    final midi = frequencyToMidi(frequency);
    final roundedMidi = midi.round();
    return MusicalNote.fromMidiNumber(roundedMidi, preferSharp: preferSharp);
  }

  /// Calculates the signed cent deviation of [actualFrequency] relative to [targetFrequency].
  double centsDeviation(double actualFrequency, double targetFrequency) {
    return TuningMath.centsDeviation(actualFrequency, targetFrequency);
  }

  /// Evaluates the discrete [TuningState] for a given [centsDeviation] and optional [tolerance].
  TuningState determineTuningState(double centsDeviation, {double? tolerance}) {
    if (centsDeviation.isNaN || centsDeviation.isInfinite) {
      return TuningState.unknown;
    }
    final tol = tolerance ?? toleranceInCents;
    if (centsDeviation.abs() <= tol) {
      return TuningState.inTune;
    } else if (centsDeviation < -tol) {
      return TuningState.tooLow;
    } else {
      return TuningState.tooHigh;
    }
  }

  /// Detects the target note with hysteresis stabilization against pitch jitter.
  ///
  /// If [previousTarget] is provided, the converter prioritizes maintaining [previousTarget]
  /// unless the frequency departs significantly past the halfway mark (controlled by [hysteresisRatio]).
  TuningTarget detectTarget(
    double frequency, {
    MusicalNote? previousTarget,
    double? customTolerance,
  }) {
    if (frequency <= 0.0 || frequency.isNaN) {
      final defaultNote = MusicalNote.fromMidiNumber(referenceMidi);
      return TuningTarget(note: defaultNote, frequency: referenceFrequency);
    }

    if (previousTarget != null) {
      final prevMidi = previousTarget.midiNumber;
      final prevFreq = midiToFrequency(prevMidi.toDouble());
      final lowerTargetFreq = midiToFrequency(prevMidi - 1.0);
      final upperTargetFreq = midiToFrequency(prevMidi + 1.0);

      final tol = customTolerance ?? toleranceInCents;

      // Deviation-based boundaries: hysteresisRatio (e.g. 0.6) into adjacent semitone
      final lowerFreqDev = midiToFrequency(prevMidi - hysteresisRatio);
      final upperFreqDev = midiToFrequency(prevMidi + hysteresisRatio);

      // Cent-based boundaries (guarded by tolerance to prevent overlapping)
      final centsToLowerBound =
          TuningMath.ratioToCents(prevFreq / lowerTargetFreq) - tol;
      final centsToUpperBound =
          TuningMath.ratioToCents(upperTargetFreq / prevFreq) - tol;

      final lowerFreqCent =
          prevFreq /
          TuningMath.centsToRatio(
            math.min(minimumHysteresisCents, centsToLowerBound),
          );
      final upperFreqCent =
          prevFreq *
          TuningMath.centsToRatio(
            math.min(minimumHysteresisCents, centsToUpperBound),
          );

      final minAllowedFreq = math.min(lowerFreqDev, lowerFreqCent);
      final maxAllowedFreq = math.max(upperFreqDev, upperFreqCent);

      if (frequency >= minAllowedFreq && frequency <= maxAllowedFreq) {
        return TuningTarget(note: previousTarget, frequency: prevFreq);
      }
    }

    // Unbiased nearest note selection
    final targetNote = frequencyToNote(frequency);
    final targetFreq = noteToFrequency(targetNote);
    return TuningTarget(note: targetNote, frequency: targetFreq);
  }

  /// Evaluates an input [frequency] fully into a [PitchAssessment].
  PitchAssessment evaluatePitch(
    double frequency, {
    MusicalNote? previousTarget,
    double? customTolerance,
  }) {
    if (frequency <= 0.0 || frequency.isNaN) {
      final fallbackTarget = detectTarget(referenceFrequency);
      return PitchAssessment(
        target: fallbackTarget,
        actualFrequency: 0.0,
        centsDeviation: double.nan,
        tuningState: TuningState.unknown,
      );
    }

    final target = detectTarget(
      frequency,
      previousTarget: previousTarget,
      customTolerance: customTolerance,
    );

    final deviation = centsDeviation(frequency, target.frequency);
    final state = determineTuningState(deviation, tolerance: customTolerance);

    return PitchAssessment(
      target: target,
      actualFrequency: frequency,
      centsDeviation: deviation,
      tuningState: state,
    );
  }

  /// Underlying discrete frequency scale table.
  MusicalScaleFrequencies get scaleFrequencies => _scaleFrequencies;
}
