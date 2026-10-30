import '../models/musical_note.dart';
import '../tuning/musical_scale_frequencies.dart';
import 'rational_number.dart';
import 'temperament_circle_of_fifths.dart';

/// Abstract domain interface and base class for all musical temperaments and tuning systems.
///
/// Encapsulates cent values, frequency ratios, rational interval numbers,
/// circle-of-fifths configurations, and note-name sequences across one octave.
abstract class Temperament {
  const Temperament({
    required this.name,
    required this.abbreviation,
    required this.description,
    required this.stableId,
    required this.rootNote,
  });

  /// Full human-readable name of the temperament.
  final String name;

  /// Short abbreviation (e.g., "12-EDO", "Werck. III", "1/4-Meantone").
  final String abbreviation;

  /// Detailed historical or structural description.
  final String description;

  /// Unique persistent identifier for serialization and preset lookup.
  final int stableId;

  /// Base root note on which the temperament begins (default C).
  final MusicalNote rootNote;

  /// Number of notes within one octave (e.g. 12 for standard Western tuning).
  int get size;

  /// Ascending cent values of the temperament over one octave.
  ///
  /// Length is strictly `size + 1`, starting at 0.0 cents and ending with
  /// the full octave span (normally 1200.0 cents).
  List<double> get cents;

  /// Ascending frequency multiplication ratios relative to [rootNote].
  ///
  /// Length is strictly `size + 1`, starting at 1.0 and ending at the octave ratio (2.0).
  List<double> get ratios;

  /// Exact rational frequency ratios if this temperament is derived from pure harmonics
  /// (e.g., Just Intonation or Pythagorean). Null for irrational scales like 12-EDO.
  List<RationalNumber>? get rationalNumbers;

  /// Circle of fifths configuration if this temperament is defined via fifth modifications.
  TemperamentCircleOfFifths? get circleOfFifths;

  /// Number of equal divisions of the octave (EDO) if applicable; null otherwise.
  int? get equalOctaveDivision;

  /// Ordered musical notes representing each scale degree within the octave.
  List<MusicalNote> get notes;

  /// Constructs a full-octave [MusicalScaleFrequencies] lookup table based on this temperament.
  MusicalScaleFrequencies toScaleFrequencies({
    double referenceFrequency = 440.0,
    double frequencyMin = 16.0,
    double frequencyMax = 20000.0,
    int? referenceIndexWithinOctave,
  }) {
    // If not specified, look for reference note A4 (or index 9 in standard 12-EDO starting at C)
    final refIdx =
        referenceIndexWithinOctave ?? _findReferenceIndexWithinOctave();

    return MusicalScaleFrequencies.create(
      cents: cents,
      referenceIndexWithinOctave: refIdx,
      referenceFrequency: referenceFrequency,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
    );
  }

  int _findReferenceIndexWithinOctave() {
    // Attempt to locate A in the scale notes
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].base == BaseNote.a &&
          notes[i].modifier == NoteModifier.none) {
        return i;
      }
    }
    // Fallback: 0
    return 0;
  }
}
