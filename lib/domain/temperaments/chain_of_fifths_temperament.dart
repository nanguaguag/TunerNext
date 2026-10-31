import '../models/musical_note.dart';
import '../tuning/tuning_math.dart';
import 'chain_of_fifths.dart';
import 'fifth_modification.dart';
import 'rational_number.dart';
import 'temperament.dart';
import 'temperament_circle_of_fifths.dart';

/// Temperament derived from an explicit sequence of fifth intervals (chain of fifths).
class ChainOfFifthsTemperament extends Temperament {
  ChainOfFifthsTemperament({
    required super.name,
    required super.abbreviation,
    required super.description,
    required super.stableId,
    required super.rootNote,
    required List<FifthModification> fifths,
    required int rootIndex,
    this.uniqueIdentifier = '',
  }) : _chain = ChainOfFifths(fifths, rootIndex),
       super();

  final ChainOfFifths _chain;
  final String uniqueIdentifier;

  @override
  int get size => _chain.size;

  @override
  int? get equalOctaveDivision => null;

  @override
  List<RationalNumber>? get rationalNumbers => null;

  @override
  TemperamentCircleOfFifths? get circleOfFifths => null;

  @override
  late final List<double> ratios = [..._chain.getSortedRatios(), 2.0];

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
      // Generalized mapping for extended scales (e.g. 15-note extended meantone)
      final semitoneEstimate = (cents[i] / 100.0).round();
      return MusicalNote.fromMidiNumber(rootMidi + semitoneEstimate);
    });
  }

  /// Underlying fifths chain configuration.
  ChainOfFifths get chain => _chain;
}
