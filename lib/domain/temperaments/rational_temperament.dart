import '../models/musical_note.dart';
import '../tuning/tuning_math.dart';
import 'rational_number.dart';
import 'temperament.dart';
import 'temperament_circle_of_fifths.dart';

/// Temperament defined explicitly by integer harmonic ratios (Rational Numbers),
/// commonly used for Just Intonation and harmonic monochord scales.
class RationalTemperament extends Temperament {
  RationalTemperament({
    required super.name,
    required super.abbreviation,
    required super.description,
    required super.stableId,
    required super.rootNote,
    required List<RationalNumber> rationalNumbers,
    this.uniqueIdentifier = '',
  }) : _rationalNumbers = List.unmodifiable(rationalNumbers),
       super() {
    if (rationalNumbers.length < 2) {
      throw ArgumentError(
        'Rational numbers list must have at least 2 entries (including octave)',
      );
    }
  }

  final List<RationalNumber> _rationalNumbers;
  final String uniqueIdentifier;

  @override
  int get size => _rationalNumbers.length - 1;

  @override
  int? get equalOctaveDivision => null;

  @override
  List<RationalNumber> get rationalNumbers => _rationalNumbers;

  @override
  TemperamentCircleOfFifths? get circleOfFifths => null;

  @override
  late final List<double> ratios = _rationalNumbers
      .map((r) => r.toDouble())
      .toList();

  @override
  late final List<double> cents = ratios.map(TuningMath.ratioToCents).toList();

  @override
  late final List<MusicalNote> notes = _generateNotes();

  List<MusicalNote> _generateNotes() {
    final rootMidi = rootNote.midiNumber;
    return List<MusicalNote>.generate(size, (i) {
      if (size == 12) {
        return MusicalNote.fromMidiNumber(rootMidi + i);
      }
      final semitoneEstimate = (cents[i] / 100.0).round();
      return MusicalNote.fromMidiNumber(rootMidi + semitoneEstimate);
    });
  }
}
