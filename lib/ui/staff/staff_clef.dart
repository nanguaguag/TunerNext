import '../../domain/models/musical_note.dart';

/// Clef configurations for musical staff notation.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.notes.StaffClef`.
enum StaffClef {
  /// Grand staff with both treble and bass staves (standard for piano).
  grand('Grand'),

  /// Single treble (G) clef staff.
  treble('Treble'),

  /// Single treble clef with 8vb octave transpose (for tenor voices/guitars).
  tenor('Tenor (8vb)'),

  /// Single bass (F) clef staff.
  bass('Bass');

  const StaffClef(this.label);
  final String label;
}

/// Diatonic positions on the musical staff.
/// C0 = 0, D0 = 1, E0 = 2, ..., C4 = 28.
class StaffPositions {
  StaffPositions._();

  static const int trebleBottomLine = 30; // E4
  static const int bassBottomLine = 18; // G2
  static const int middleC = 28; // C4

  /// Base note diatonic steps relative to C:
  /// C:0, D:1, E:2, F:3, G:4, A:5, B:6
  static int diatonicPosition(MusicalNote note) {
    const baseSteps = {
      BaseNote.c: 0,
      BaseNote.d: 1,
      BaseNote.e: 2,
      BaseNote.f: 3,
      BaseNote.g: 4,
      BaseNote.a: 5,
      BaseNote.b: 6,
    };
    final octaveStep = note.octave * 7;
    return octaveStep + (baseSteps[note.base] ?? 0);
  }
}
