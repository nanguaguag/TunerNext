import 'package:equatable/equatable.dart';

/// Represents a Huygens-Fokker Scala Keyboard Mapping (.kbm) configuration.
///
/// A keyboard mapping defines how scale degrees are mapped to physical MIDI keys,
/// specifying the anchor reference frequency, middle note, and scale step periodicities.
class KeyboardMapping extends Equatable {
  const KeyboardMapping({
    this.mapSize = 12,
    this.firstMidiNote = 0,
    this.lastMidiNote = 127,
    this.middleMidiNote = 60,
    this.referenceMidiNote = 69,
    this.referenceFrequency = 440.0,
    this.scaleDegreeForOctave = 12,
    this.keyPattern = const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  });

  /// Factory for standard default 1:1 mapping for an N-tone scale.
  factory KeyboardMapping.standardForScale(
    int scaleSize, {
    int middleMidiNote = 60,
    int referenceMidiNote = 69,
    double referenceFrequency = 440.0,
  }) {
    final pattern = List<int>.generate(scaleSize, (i) => i);
    return KeyboardMapping(
      mapSize: scaleSize,
      firstMidiNote: 0,
      lastMidiNote: 127,
      middleMidiNote: middleMidiNote,
      referenceMidiNote: referenceMidiNote,
      referenceFrequency: referenceFrequency,
      scaleDegreeForOctave: scaleSize,
      keyPattern: pattern,
    );
  }

  /// Number of keys in the repeating mapping pattern.
  final int mapSize;

  /// Lower bound MIDI key number to retune (usually 0).
  final int firstMidiNote;

  /// Upper bound MIDI key number to retune (usually 127).
  final int lastMidiNote;

  /// Middle note where degree 0 (1/1 unison) of the scale is placed (usually 60 = C4).
  final int middleMidiNote;

  /// Key note number where [referenceFrequency] is applied (usually 69 = A4).
  final int referenceMidiNote;

  /// Reference pitch in Hz (usually 440.0).
  final double referenceFrequency;

  /// Scale degree corresponding to the formal octave/period interval (usually scale count).
  final int scaleDegreeForOctave;

  /// Key assignment pattern of length [mapSize].
  ///
  /// Each element represents the scale degree index (0-based) for that key,
  /// or -1 if the key is unmapped ('x' in .kbm specification).
  final List<int> keyPattern;

  @override
  List<Object?> get props => [
    mapSize,
    firstMidiNote,
    lastMidiNote,
    middleMidiNote,
    referenceMidiNote,
    referenceFrequency,
    scaleDegreeForOctave,
    keyPattern,
  ];
}
