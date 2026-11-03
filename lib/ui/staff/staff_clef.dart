import '../../domain/models/musical_note.dart';
import 'staff_models.dart';

export 'staff_models.dart';

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
    return staffPosition(note);
  }
}
