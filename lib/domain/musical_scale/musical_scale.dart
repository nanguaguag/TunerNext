import '../models/musical_note.dart';
import '../stretchtuning/stretch_tuning.dart';
import '../temperaments/predefined_temperaments.dart';
import '../temperaments/temperament_models.dart';
import 'musical_scale_frequencies.dart';

/// Complete musical scale combining temperament, reference pitch, and stretch tuning.
class MusicalScale {
  MusicalScale({
    Temperament? temperament,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.referenceFrequency = 440.0,
    this.frequencyMin = 16.0,
    this.frequencyMax = 20000.0,
    StretchTuning? stretchTuning,
  }) : temperament = temperament ?? PredefinedTemperaments.edo12(),
       stretchTuning = stretchTuning ?? PredefinedStretchTunings.none() {
    _initFrequencies();
  }

  final Temperament temperament;
  final MusicalNote referenceNote;
  final double referenceFrequency;
  final double frequencyMin;
  final double frequencyMax;
  final StretchTuning stretchTuning;

  late final MusicalScaleFrequencies _frequencies;

  MusicalScaleFrequencies get frequencies => _frequencies;
  int get noteIndexBegin => _frequencies.indexStart;
  int get noteIndexEnd => _frequencies.indexEnd;

  void _initFrequencies() {
    // For standard 12-tone scales, reference A is note index 9 within C=0..B=11 octave
    final refIndexWithinOctave = (temperament.size == 12) ? 9 : 0;

    _frequencies = MusicalScaleFrequencies.create(
      cents: temperament.cents(),
      referenceIndexWithinOctave: refIndexWithinOctave,
      referenceFrequency: referenceFrequency,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
      stretchTuning: stretchTuning,
    );
  }

  /// Returns [MusicalNote] representation for [noteIndex] relative to reference note.
  MusicalNote getNote(int noteIndex) {
    if (temperament.size == 12) {
      // Reference is A4 (semitone 9 in octave 4, middle C4 is index -9)
      const a4Semitone = 9 + 4 * 12; // 57
      final semitone = a4Semitone + noteIndex;
      final octave = semitone ~/ 12;
      final noteInOctave = semitone % 12;

      const chromaticNotes = [
        (BaseNote.c, NoteModifier.none, null, null),
        (BaseNote.c, NoteModifier.sharp, BaseNote.d, NoteModifier.flat),
        (BaseNote.d, NoteModifier.none, null, null),
        (BaseNote.d, NoteModifier.sharp, BaseNote.e, NoteModifier.flat),
        (BaseNote.e, NoteModifier.none, null, null),
        (BaseNote.f, NoteModifier.none, null, null),
        (BaseNote.f, NoteModifier.sharp, BaseNote.g, NoteModifier.flat),
        (BaseNote.g, NoteModifier.none, null, null),
        (BaseNote.g, NoteModifier.sharp, BaseNote.a, NoteModifier.flat),
        (BaseNote.a, NoteModifier.none, null, null),
        (BaseNote.a, NoteModifier.sharp, BaseNote.b, NoteModifier.flat),
        (BaseNote.b, NoteModifier.none, null, null),
      ];

      final entry = chromaticNotes[noteInOctave];
      return MusicalNote(
        base: entry.$1,
        modifier: entry.$2,
        octave: octave,
        enharmonicBase: entry.$3,
        enharmonicModifier: entry.$4,
      );
    }

    // Generic EDO fallback
    final octave = referenceNote.octave + (noteIndex ~/ temperament.size);
    return MusicalNote(
      base: BaseNote.a,
      modifier: NoteModifier.none,
      octave: octave,
    );
  }

  /// Returns target frequency for note index.
  double getNoteFrequency(int noteIndex) => _frequencies[noteIndex];

  /// Returns fractional note index for given [frequency].
  double getNoteIndex(double frequency) =>
      _frequencies.getFrequencyIndex(frequency);

  /// Returns closest note index for given [frequency].
  int getClosestNoteIndex(double frequency) =>
      _frequencies.getClosestFrequencyIndex(frequency);

  /// Returns deviation in cents of [frequency] relative to closest scale note.
  double centDeviation(double frequency) {
    if (frequency <= 0.0) return 0.0;
    final closestIdx = getClosestNoteIndex(frequency);
    final targetFreq = getNoteFrequency(closestIdx);
    if (targetFreq <= 0.0) return 0.0;
    return frequencyToCents(frequency, targetFreq);
  }

  static MusicalScale defaultEdo12() => MusicalScale(
    temperament: PredefinedTemperaments.edo12(),
    referenceNote: const MusicalNote(base: BaseNote.a, octave: 4),
    referenceFrequency: 440.0,
  );
}
