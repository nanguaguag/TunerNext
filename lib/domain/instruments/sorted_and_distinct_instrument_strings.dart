import '../models/musical_note.dart';
import 'instrument.dart';

/// Adapter that extracts unique, sorted scale note indices for an instrument's strings.
///
/// Strings not found in the scale are collapsed into a trailing sentinel [sentinelIndex].
class SortedAndDistinctInstrumentStrings {
  SortedAndDistinctInstrumentStrings({
    required this.instrument,
    int referenceMidi = 69, // A4 = 440 Hz
    int notesPerOctave = 12,
  }) : sortedAndDistinctNoteIndices = _extractSortedAndDistinctIndices(
         instrument,
         referenceMidi,
         notesPerOctave,
       );

  /// Trailing sentinel index used when one or more strings are not part of the active scale.
  static const int sentinelIndex = 0x7FFFFFFF;

  final Instrument instrument;

  /// Sorted, unique note indices corresponding to the instrument's strings.
  ///
  /// Relative to reference note (index 0). If any strings do not exist in the scale,
  /// the list ends with [sentinelIndex].
  final List<int> sortedAndDistinctNoteIndices;

  /// Number of distinct valid strings that exist within the musical scale.
  int get numDifferentNotes {
    if (sortedAndDistinctNoteIndices.isEmpty) return 0;
    if (sortedAndDistinctNoteIndices.last == sentinelIndex) {
      return sortedAndDistinctNoteIndices.length - 1;
    }
    return sortedAndDistinctNoteIndices.length;
  }

  /// Whether [note] is a string on this instrument or within scale for chromatic mode.
  bool isNotePartOfInstrument(
    MusicalNote? note, {
    int referenceMidi = 69,
    int notesPerOctave = 12,
  }) {
    if (note == null) return false;

    // Check if the note can exist on standard 12-EDO scale
    final noteIndex = _noteToScaleIndex(note, referenceMidi, notesPerOctave);
    if (noteIndex == null) return false;

    if (instrument.isChromatic) {
      return true;
    }

    if (numDifferentNotes == 0) return false;

    return _binarySearch(sortedAndDistinctNoteIndices, noteIndex) >= 0;
  }

  static int? _noteToScaleIndex(
    MusicalNote note,
    int referenceMidi,
    int notesPerOctave,
  ) {
    // Only standard accidentals exist in standard 12-EDO
    if (note.modifier != NoteModifier.none &&
        note.modifier != NoteModifier.sharp &&
        note.modifier != NoteModifier.flat &&
        note.modifier != NoteModifier.doubleSharp &&
        note.modifier != NoteModifier.doubleFlat) {
      return null;
    }
    return note.midiNumber - referenceMidi;
  }

  static List<int> _extractSortedAndDistinctIndices(
    Instrument instrument,
    int referenceMidi,
    int notesPerOctave,
  ) {
    if (instrument.isChromatic || instrument.strings.isEmpty) {
      return const [];
    }

    final collected = <int>[];
    for (final note in instrument.strings) {
      final index = _noteToScaleIndex(note, referenceMidi, notesPerOctave);
      if (index == null) {
        collected.add(sentinelIndex);
      } else {
        collected.add(index);
      }
    }

    if (collected.isEmpty) return const [];

    collected.sort();

    final result = <int>[collected[0]];
    for (int i = 1; i < collected.length; i++) {
      if (collected[i] != collected[i - 1]) {
        result.add(collected[i]);
      }
    }

    return List.unmodifiable(result);
  }

  static int _binarySearch(List<int> list, int value) {
    int min = 0;
    int max = list.length - 1;
    while (min <= max) {
      final mid = (min + max) >> 1;
      final element = list[mid];
      if (element == value) return mid;
      if (element < value) {
        min = mid + 1;
      } else {
        max = mid - 1;
      }
    }
    return -1;
  }
}
