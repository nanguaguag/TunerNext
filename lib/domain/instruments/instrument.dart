import 'package:equatable/equatable.dart';

import '../models/musical_note.dart';
import 'instrument_icon.dart';

/// Represents an instrument with a fixed set of strings/tunings or a chromatic mode.
class Instrument extends Equatable {
  const Instrument({
    required this.name,
    this.nameResourceKey,
    this.strings = const [],
    this.icon = InstrumentIcon.guitar,
    this.stableId = noStableId,
    this.isChromatic = false,
  });

  /// Human-readable name (or fallback for user-defined instruments).
  final String name;

  /// String localization key for predefined instruments (e.g. 'guitar_eadgbe'),
  /// or null if this is a custom user-defined instrument.
  final String? nameResourceKey;

  /// Ordered notes corresponding to strings of the instrument.
  ///
  /// Usually ordered from lowest sounding string to highest (e.g. E2 to E4 for standard guitar),
  /// except for re-entrant tunings like Soprano Ukulele (G4, C4, E4, A4).
  final List<MusicalNote> strings;

  /// Visual icon for the instrument.
  final InstrumentIcon icon;

  /// Unique stable identifier for list management, selection, and persistence.
  final int stableId;

  /// Whether this instrument represents global chromatic tuning (no fixed strings).
  final bool isChromatic;

  /// Special sentinel stable ID indicating an unassigned or new instrument.
  static const int noStableId = 0x7FFFFFFFFFFFFFFF;

  /// Whether this instrument is one of the built-in system presets.
  bool get isPredefined => nameResourceKey != null;

  /// Number of strings defined for this instrument.
  int get stringCount => strings.length;

  /// Formatted string representing the tuning pitches (e.g., "E2 - A2 - D3 - G3 - B3 - E4").
  String get stringsFormatted {
    if (isChromatic) {
      return 'Chromatic';
    }
    if (strings.isEmpty) {
      return '';
    }
    return strings.map((s) => s.name).join(' - ');
  }

  /// Creates a copy of this [Instrument] with specified fields replaced.
  Instrument copyWith({
    String? name,
    String? nameResourceKey,
    List<MusicalNote>? strings,
    InstrumentIcon? icon,
    int? stableId,
    bool? isChromatic,
  }) {
    return Instrument(
      name: name ?? this.name,
      nameResourceKey: nameResourceKey ?? this.nameResourceKey,
      strings: strings ?? this.strings,
      icon: icon ?? this.icon,
      stableId: stableId ?? this.stableId,
      isChromatic: isChromatic ?? this.isChromatic,
    );
  }

  @override
  List<Object?> get props => [
    name,
    nameResourceKey,
    strings,
    icon,
    stableId,
    isChromatic,
  ];

  @override
  String toString() =>
      'Instrument($name, strings=$stringCount, icon=${icon.name}, stableId=$stableId)';
}
