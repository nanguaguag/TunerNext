import 'package:equatable/equatable.dart';
import 'musical_note.dart';

/// Target pitch note and frequency towards which the instrument is being tuned.
class TuningTarget extends Equatable {
  const TuningTarget({
    required this.note,
    required this.frequency,
    this.isPartOfInstrument = true,
    this.instrumentHasNoStrings = false,
  });

  /// The target musical note representation.
  final MusicalNote note;

  /// The nominal frequency of the target note in Hertz.
  final double frequency;

  /// True if the note is a defined string in the currently selected instrument.
  final bool isPartOfInstrument;

  /// True if the selected instrument has no explicit strings (e.g., chromatic).
  final bool instrumentHasNoStrings;

  @override
  List<Object?> get props => [
    note,
    frequency,
    isPartOfInstrument,
    instrumentHasNoStrings,
  ];
}
