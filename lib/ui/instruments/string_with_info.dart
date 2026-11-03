import 'dart:math';
import 'package:equatable/equatable.dart';
import '../../domain/models/musical_note.dart';

/// Position of the strings sidebar relative to the string fretboard/lines.
enum StringsSidebarPosition {
  /// Sidebar is before (to the left of) the strings lines.
  start,

  /// Sidebar is behind (to the right of) the strings lines.
  end,

  /// No extra sidebar buttons (for compact sidebar column mode).
  none,
}

/// Scroll mode for the strings view.
enum StringsScrollMode {
  /// User is manually dragging or scrolling the string list.
  manual,

  /// View automatically centers on the detected target string.
  automatic,
}

/// Represents an instrument string with its musical pitch and unique tracking key.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.instruments.StringWithInfo`.
class StringWithInfo extends Equatable {
  const StringWithInfo({required this.note, required this.key});

  /// The musical note of the string.
  final MusicalNote note;

  /// Unique key for tracking selection and list identity.
  final int key;

  @override
  List<Object?> get props => [note, key];

  /// Generates a unique key that does not conflict with existing string items.
  static int generateKey(List<StringWithInfo> existingList) {
    final random = Random();
    while (true) {
      final k = random.nextInt(0x7FFFFFFF - 1);
      if (!existingList.any((e) => e.key == k)) {
        return k;
      }
    }
  }
}

/// Computes the visual line thickness of a string.
/// Lower notes (smaller indices) are rendered thicker; higher notes are rendered thinner.
double computeStringLineWidth({
  required int index,
  required int minIndex,
  required int maxIndex,
  double minLineWidth = 1.0,
  double maxLineWidth = 4.0,
}) {
  if (maxIndex <= minIndex || index == 0x7FFFFFFF) {
    return (minLineWidth + maxLineWidth) / 2.0;
  }
  final clampedIndex = index.clamp(minIndex, maxIndex);
  final relativeWidth = (clampedIndex - minIndex) / (maxIndex - minIndex);
  return (maxLineWidth - minLineWidth) * (1.0 - relativeWidth) + minLineWidth;
}
