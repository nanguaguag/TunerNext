import 'package:equatable/equatable.dart';

/// Diatonic base note names.
enum BaseNote { c, d, e, f, g, a, b }

/// Accidentals / note modifiers.
enum NoteModifier {
  none(0, ''),
  sharp(1, '♯'),
  flat(-1, '♭'),
  doubleSharp(2, '𝄪'),
  doubleFlat(-2, '𝄫');

  const NoteModifier(this.semitoneOffset, this.symbol);
  final int semitoneOffset;
  final String symbol;
}

/// A representation of a musical note including its accidental, octave, and enharmonics.
class MusicalNote extends Equatable {
  const MusicalNote({
    required this.base,
    this.modifier = NoteModifier.none,
    required this.octave,
    this.enharmonicBase,
    this.enharmonicModifier,
  });

  final BaseNote base;
  final NoteModifier modifier;
  final int octave;
  final BaseNote? enharmonicBase;
  final NoteModifier? enharmonicModifier;

  /// Returns standard scientific pitch representation, e.g., "A4" or "C♯3".
  String get name => '${base.name.toUpperCase()}${modifier.symbol}$octave';

  /// Returns pitch class name without octave, e.g., "A" or "C♯".
  String get pitchClassName => '${base.name.toUpperCase()}${modifier.symbol}';

  /// Returns whether this note represents the same pitch class and octave as [other],
  /// taking enharmonic spelling into consideration if [matchEnharmonic] is true.
  bool matches(
    MusicalNote other, {
    bool matchEnharmonic = true,
    bool ignoreOctave = false,
  }) {
    if (!ignoreOctave && octave != other.octave) return false;
    if (base == other.base && modifier == other.modifier) return true;
    if (matchEnharmonic) {
      if (enharmonicBase != null &&
          enharmonicBase == other.base &&
          enharmonicModifier == other.modifier) {
        return true;
      }
      if (other.enharmonicBase != null &&
          base == other.enharmonicBase &&
          modifier == other.enharmonicModifier) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Object?> get props => [
    base,
    modifier,
    octave,
    enharmonicBase,
    enharmonicModifier,
  ];
}
