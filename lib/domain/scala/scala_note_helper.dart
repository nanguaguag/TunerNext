import '../models/musical_note.dart';

/// Helper utilities for parsing and formatting note strings within Scala (.scl) files.
class ScalaNoteHelper {
  ScalaNoteHelper._();

  static const String notePrefix = 'note=';

  /// Parses a note assignment string, which can be in forms like:
  /// - "note=D"
  /// - "note=C#"
  /// - "note=Eb"
  /// - "note=F#+1"
  /// - "note=C#/Db"
  /// - "note=-/C"
  static MusicalNote? parseNoteAssignment(String string) {
    final trimmed = string.trim();
    if (!trimmed.startsWith(notePrefix)) return null;

    final noteBody = trimmed.substring(notePrefix.length).trim();
    return parseNoteString(noteBody);
  }

  /// Parses an isolated note specification (e.g. "C#", "Eb", "C#/Db", "A4").
  static MusicalNote? parseNoteString(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    String primaryPart = trimmed;
    String? enharmonicPart;

    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      primaryPart = parts[0].trim();
      if (parts.length > 1) {
        enharmonicPart = parts[1].trim();
      }
    }

    final primary = primaryPart != '-' && primaryPart.isNotEmpty
        ? _parseSingleNote(primaryPart)
        : null;

    final enharmonic =
        enharmonicPart != null &&
            enharmonicPart != '-' &&
            enharmonicPart.isNotEmpty
        ? _parseSingleNote(enharmonicPart)
        : null;

    if (primary == null && enharmonic == null) return null;

    if (primary != null) {
      return MusicalNote(
        base: primary.base,
        modifier: primary.modifier,
        octave: primary.octave,
        enharmonicBase: enharmonic?.base,
        enharmonicModifier: enharmonic?.modifier,
      );
    } else {
      // Only enharmonic was specified (e.g. "-/C")
      return MusicalNote(
        base: enharmonic!.base,
        modifier: enharmonic.modifier,
        octave: enharmonic.octave,
      );
    }
  }

  static MusicalNote? _parseSingleNote(String string) {
    if (string.isEmpty) return null;

    // Match base note
    final firstChar = string[0].toUpperCase();
    final base = _charToBaseNote(firstChar);
    if (base == null) return null;

    var rest = string.substring(1).trim();

    // Match modifier
    NoteModifier modifier = NoteModifier.none;
    if (rest.startsWith('##') || rest.startsWith('𝄪')) {
      modifier = NoteModifier.doubleSharp;
      rest = rest.startsWith('##') ? rest.substring(2) : rest.substring(1);
    } else if (rest.startsWith('bb') || rest.startsWith('𝄫')) {
      modifier = NoteModifier.doubleFlat;
      rest = rest.startsWith('bb') ? rest.substring(2) : rest.substring(1);
    } else if (rest.startsWith('#') || rest.startsWith('♯')) {
      modifier = NoteModifier.sharp;
      rest = rest.substring(1);
    } else if (rest.startsWith('b') || rest.startsWith('♭')) {
      modifier = NoteModifier.flat;
      rest = rest.substring(1);
    }

    // Match octave or octave offset (e.g., "4", "+1", "-1")
    int octave = 4;
    final octaveMatch = RegExp(r'^([+-]?\d+)').firstMatch(rest);
    if (octaveMatch != null) {
      final parsed = int.tryParse(octaveMatch.group(1)!);
      if (parsed != null) {
        octave = parsed;
      }
    }

    return MusicalNote(base: base, modifier: modifier, octave: octave);
  }

  static BaseNote? _charToBaseNote(String char) {
    switch (char) {
      case 'C':
        return BaseNote.c;
      case 'D':
        return BaseNote.d;
      case 'E':
        return BaseNote.e;
      case 'F':
        return BaseNote.f;
      case 'G':
        return BaseNote.g;
      case 'A':
        return BaseNote.a;
      case 'B':
        return BaseNote.b;
      default:
        return null;
    }
  }

  /// Formats a [MusicalNote] for inclusion in a Scala file line (e.g. "C#", "C#/Db").
  static String formatNoteForScala(
    MusicalNote note, {
    bool includeOctave = false,
  }) {
    final buffer = StringBuffer();
    buffer.write(note.base.name.toUpperCase());
    buffer.write(_modifierToString(note.modifier));
    if (includeOctave) {
      buffer.write(note.octave);
    }

    if (note.enharmonicBase != null) {
      buffer.write('/');
      buffer.write(note.enharmonicBase!.name.toUpperCase());
      buffer.write(
        _modifierToString(note.enharmonicModifier ?? NoteModifier.none),
      );
      if (includeOctave) {
        buffer.write(note.octave);
      }
    }

    return buffer.toString();
  }

  static String _modifierToString(NoteModifier modifier) {
    switch (modifier) {
      case NoteModifier.sharp:
        return '#';
      case NoteModifier.flat:
        return 'b';
      case NoteModifier.doubleSharp:
        return '##';
      case NoteModifier.doubleFlat:
        return 'bb';
      case NoteModifier.none:
        return '';
    }
  }
}
