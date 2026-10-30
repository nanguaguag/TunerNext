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

  /// Semitone offsets of diatonic base notes relative to C.
  static const Map<BaseNote, int> _baseSemitones = {
    BaseNote.c: 0,
    BaseNote.d: 2,
    BaseNote.e: 4,
    BaseNote.f: 5,
    BaseNote.g: 7,
    BaseNote.a: 9,
    BaseNote.b: 11,
  };

  /// Constructs a [MusicalNote] from a MIDI note number (where 60 is C4 and 69 is A4).
  factory MusicalNote.fromMidiNumber(
    int midiNumber, {
    bool preferSharp = true,
  }) {
    final octave = (midiNumber / 12.0).floor() - 1;
    final pitchClass = midiNumber % 12;

    switch (pitchClass) {
      case 0:
        return MusicalNote(base: BaseNote.c, octave: octave);
      case 1:
        return preferSharp
            ? MusicalNote(
                base: BaseNote.c,
                modifier: NoteModifier.sharp,
                octave: octave,
                enharmonicBase: BaseNote.d,
                enharmonicModifier: NoteModifier.flat,
              )
            : MusicalNote(
                base: BaseNote.d,
                modifier: NoteModifier.flat,
                octave: octave,
                enharmonicBase: BaseNote.c,
                enharmonicModifier: NoteModifier.sharp,
              );
      case 2:
        return MusicalNote(base: BaseNote.d, octave: octave);
      case 3:
        return preferSharp
            ? MusicalNote(
                base: BaseNote.d,
                modifier: NoteModifier.sharp,
                octave: octave,
                enharmonicBase: BaseNote.e,
                enharmonicModifier: NoteModifier.flat,
              )
            : MusicalNote(
                base: BaseNote.e,
                modifier: NoteModifier.flat,
                octave: octave,
                enharmonicBase: BaseNote.d,
                enharmonicModifier: NoteModifier.sharp,
              );
      case 4:
        return MusicalNote(base: BaseNote.e, octave: octave);
      case 5:
        return MusicalNote(base: BaseNote.f, octave: octave);
      case 6:
        return preferSharp
            ? MusicalNote(
                base: BaseNote.f,
                modifier: NoteModifier.sharp,
                octave: octave,
                enharmonicBase: BaseNote.g,
                enharmonicModifier: NoteModifier.flat,
              )
            : MusicalNote(
                base: BaseNote.g,
                modifier: NoteModifier.flat,
                octave: octave,
                enharmonicBase: BaseNote.f,
                enharmonicModifier: NoteModifier.sharp,
              );
      case 7:
        return MusicalNote(base: BaseNote.g, octave: octave);
      case 8:
        return preferSharp
            ? MusicalNote(
                base: BaseNote.g,
                modifier: NoteModifier.sharp,
                octave: octave,
                enharmonicBase: BaseNote.a,
                enharmonicModifier: NoteModifier.flat,
              )
            : MusicalNote(
                base: BaseNote.a,
                modifier: NoteModifier.flat,
                octave: octave,
                enharmonicBase: BaseNote.g,
                enharmonicModifier: NoteModifier.sharp,
              );
      case 9:
        return MusicalNote(base: BaseNote.a, octave: octave);
      case 10:
        return preferSharp
            ? MusicalNote(
                base: BaseNote.a,
                modifier: NoteModifier.sharp,
                octave: octave,
                enharmonicBase: BaseNote.b,
                enharmonicModifier: NoteModifier.flat,
              )
            : MusicalNote(
                base: BaseNote.b,
                modifier: NoteModifier.flat,
                octave: octave,
                enharmonicBase: BaseNote.a,
                enharmonicModifier: NoteModifier.sharp,
              );
      case 11:
        return MusicalNote(base: BaseNote.b, octave: octave);
      default:
        return MusicalNote(base: BaseNote.c, octave: octave);
    }
  }

  /// The standard MIDI note number corresponding to this note (C4 = 60, A4 = 69).
  int get midiNumber {
    final baseOffset = _baseSemitones[base]!;
    return (octave + 1) * 12 + baseOffset + modifier.semitoneOffset;
  }

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
