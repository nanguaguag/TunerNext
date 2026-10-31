import '../models/musical_note.dart';
import '../scala/scala_scale.dart';
import '../tuning/tuning_math.dart';
import 'rational_number.dart';
import 'temperament.dart';
import 'temperament_circle_of_fifths.dart';

/// A custom, user-defined, or imported Scala temperament.
///
/// Can represent any microtonal, historical, or non-octave scale defined by
/// exact rational intervals, floating-point cents, or imported .scl files.
class CustomTemperament extends Temperament {
  CustomTemperament({
    required super.name,
    required super.abbreviation,
    required super.description,
    required super.stableId,
    required super.rootNote,
    required List<double> cents,
    List<RationalNumber>? rationalNumbers,
    List<MusicalNote>? notes,
  }) : _cents = List.unmodifiable(cents),
       _rationalNumbers = rationalNumbers != null
           ? List.unmodifiable(rationalNumbers)
           : null,
       _notes = notes != null ? List.unmodifiable(notes) : null,
       assert(cents.isNotEmpty, 'Cents array must not be empty');

  /// Factory constructing a [CustomTemperament] directly from a parsed [ScalaScale].
  factory CustomTemperament.fromScalaScale(
    ScalaScale scale, {
    int stableId = -1,
    MusicalNote? rootNote,
  }) {
    final effectiveRoot = rootNote ?? scale.rootNote;
    final scaleNotes = scale.noteNames;

    return CustomTemperament(
      name: scale.name,
      abbreviation: scale.abbreviation.isNotEmpty
          ? scale.abbreviation
          : scale.name.takeChars(6),
      description: scale.description.isNotEmpty
          ? scale.description
          : scale.name,
      stableId: stableId,
      rootNote: effectiveRoot,
      cents: scale.fullCents,
      rationalNumbers: scale.fullRationalNumbers,
      notes: scaleNotes,
    );
  }

  final List<double> _cents;
  final List<RationalNumber>? _rationalNumbers;
  final List<MusicalNote>? _notes;

  @override
  int get size => _cents.length - 1;

  @override
  List<double> get cents => _cents;

  @override
  List<double> get ratios =>
      _cents.map((c) => TuningMath.centsToRatio(c)).toList();

  @override
  List<RationalNumber>? get rationalNumbers => _rationalNumbers;

  @override
  TemperamentCircleOfFifths? get circleOfFifths => null;

  @override
  int? get equalOctaveDivision {
    // Check if cents are equally spaced
    if (size <= 0) return null;
    final step = _cents.last / size;
    for (int i = 1; i <= size; i++) {
      final expected = step * i;
      if ((_cents[i] - expected).abs() > 0.05) {
        return null;
      }
    }
    return size;
  }

  @override
  List<MusicalNote> get notes {
    final notes = _notes;
    if (notes != null && notes.length == size) {
      return notes;
    }

    // Default note sequence generator based on size
    return _generateDefaultNotes();
  }

  List<MusicalNote> _generateDefaultNotes() {
    if (size == 12) {
      // Standard chromatic scale starting on rootNote
      final standardPitchClasses = [
        BaseNote.c,
        BaseNote.c,
        BaseNote.d,
        BaseNote.d,
        BaseNote.e,
        BaseNote.f,
        BaseNote.f,
        BaseNote.g,
        BaseNote.g,
        BaseNote.a,
        BaseNote.a,
        BaseNote.b,
      ];
      final modifiers = [
        NoteModifier.none,
        NoteModifier.sharp,
        NoteModifier.none,
        NoteModifier.sharp,
        NoteModifier.none,
        NoteModifier.none,
        NoteModifier.sharp,
        NoteModifier.none,
        NoteModifier.sharp,
        NoteModifier.none,
        NoteModifier.sharp,
        NoteModifier.none,
      ];

      return List.generate(12, (i) {
        return MusicalNote(
          base: standardPitchClasses[i],
          modifier: modifiers[i],
          octave: rootNote.octave,
        );
      });
    }

    // Fallback for N-tone scales: produce generic degree notes
    return List.generate(size, (i) {
      return MusicalNote(
        base: BaseNote.c,
        modifier: NoteModifier.none,
        octave: rootNote.octave + (i ~/ 7),
      );
    });
  }

  /// Converts this [CustomTemperament] back into an exportable [ScalaScale].
  ScalaScale toScalaScale() {
    final intervals = <ScalaPitchInterval>[];
    final notes = _notes;
    final rationals = _rationalNumbers;

    for (int i = 1; i <= size; i++) {
      final noteForDeg = (notes != null && i - 1 < notes.length)
          ? notes[i - 1]
          : null;

      if (rationals != null && i < rationals.length) {
        intervals.add(
          ScalaPitchInterval(
            cents: _cents[i],
            rational: rationals[i],
            note: noteForDeg,
          ),
        );
      } else {
        intervals.add(ScalaPitchInterval(cents: _cents[i], note: noteForDeg));
      }
    }

    return ScalaScale(
      name: name,
      abbreviation: abbreviation,
      description: description,
      intervals: intervals,
      rootNote: rootNote,
    );
  }

  /// Returns a new [CustomTemperament] rotated to begin on [newRootNote].
  CustomTemperament copyWithRootNote(MusicalNote newRootNote) {
    return CustomTemperament(
      name: name,
      abbreviation: abbreviation,
      description: description,
      stableId: stableId,
      rootNote: newRootNote,
      cents: _cents,
      rationalNumbers: _rationalNumbers,
      notes: _notes,
    );
  }
}

extension _TakeChars on String {
  String takeChars(int n) => length <= n ? this : substring(0, n);
}
