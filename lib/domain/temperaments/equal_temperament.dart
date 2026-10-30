import 'dart:math' as math;
import '../models/musical_note.dart';
import 'rational_number.dart';
import 'temperament.dart';
import 'temperament_circle_of_fifths.dart';

/// Implements Equal Division of the Octave (EDO) temperaments, specifically 12-EDO
/// (standard twelve-tone equal temperament) with support for arbitrary division counts (5 to 72).
class EqualTemperament extends Temperament {
  EqualTemperament({
    required super.name,
    required super.abbreviation,
    required super.description,
    required super.stableId,
    required super.rootNote,
    this.notesPerOctave = 12,
  }) : super();

  /// Standard factory for 12-Tone Equal Temperament (12-EDO).
  factory EqualTemperament.edo12({MusicalNote? rootNote, int stableId = 1}) {
    final root = rootNote ?? const MusicalNote(base: BaseNote.c, octave: 4);
    return EqualTemperament(
      name: '12-Tone Equal Temperament',
      abbreviation: '12-EDO',
      description:
          'Standard modern Western tuning dividing the octave into 12 semitones of exactly 100 cents each.',
      stableId: stableId,
      rootNote: root,
      notesPerOctave: 12,
    );
  }

  /// Number of equal divisions dividing the octave.
  final int notesPerOctave;

  @override
  int get size => notesPerOctave;

  @override
  int? get equalOctaveDivision => notesPerOctave;

  @override
  List<RationalNumber>? get rationalNumbers => null;

  @override
  TemperamentCircleOfFifths? get circleOfFifths =>
      notesPerOctave == 12 ? TemperamentCircleOfFifths.edo12 : null;

  @override
  late final List<double> cents = List<double>.generate(
    notesPerOctave + 1,
    (i) => i * (1200.0 / notesPerOctave),
  );

  @override
  late final List<double> ratios = List<double>.generate(
    notesPerOctave + 1,
    (i) => math.pow(2.0, i / notesPerOctave).toDouble(),
  );

  @override
  late final List<MusicalNote> notes = _generateNotes();

  List<MusicalNote> _generateNotes() {
    if (notesPerOctave == 12) {
      final rootMidi = rootNote.midiNumber;
      return List<MusicalNote>.generate(12, (i) {
        return MusicalNote.fromMidiNumber(rootMidi + i);
      });
    }

    // Generic EDO fallback: produce notes from root
    final rootMidi = rootNote.midiNumber;
    return List<MusicalNote>.generate(notesPerOctave, (i) {
      final approxMidi = rootMidi + (i * 12.0 / notesPerOctave).round();
      return MusicalNote.fromMidiNumber(approxMidi);
    });
  }
}
