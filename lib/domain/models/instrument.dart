// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'musical_note.dart';

/// Representation of a musical instrument with its string tuning definitions.
class Instrument extends Equatable {
  const Instrument({
    required this.name,
    this.strings = const [],
    required this.stableId,
    this.isChromatic = false,
  });

  /// Name of the instrument.
  final String name;

  /// Tuning of physical instrument strings from lowest to highest pitch.
  final List<MusicalNote> strings;

  /// Stable identifier for persistence and selection.
  final int stableId;

  /// Whether the instrument is chromatic (all notes enabled, no fixed strings).
  final bool isChromatic;

  /// Returns the strings ordered from highest pitch to lowest pitch,
  /// matching the standard physical string order on sidebars.
  List<MusicalNote> get stringsHighToLow => strings.reversed.toList();

  /// Returns strings ordered from lowest pitch to highest pitch.
  List<MusicalNote> get stringsLowToHigh => List.unmodifiable(strings);

  Instrument copyWith({
    String? name,
    List<MusicalNote>? strings,
    int? stableId,
    bool? isChromatic,
  }) {
    return Instrument(
      name: name ?? this.name,
      strings: strings ?? this.strings,
      stableId: stableId ?? this.stableId,
      isChromatic: isChromatic ?? this.isChromatic,
    );
  }

  @override
  List<Object?> get props => [name, strings, stableId, isChromatic];
}

/// Predefined standard acoustic instruments matching Kotlin Instrument.kt.
class PredefinedInstruments {
  static const chromatic = Instrument(
    name: 'Chromatic',
    strings: [],
    stableId: -1,
    isChromatic: true,
  );

  static const guitar6String = Instrument(
    name: '6-string guitar',
    strings: [
      MusicalNote(base: BaseNote.e, octave: 2),
      MusicalNote(base: BaseNote.a, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.b, octave: 3),
      MusicalNote(base: BaseNote.e, octave: 4),
    ],
    stableId: -2,
  );

  static const bass4String = Instrument(
    name: '4-string bass',
    strings: [
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
    ],
    stableId: -3,
  );

  static const bass5String = Instrument(
    name: '5-string bass',
    strings: [
      MusicalNote(base: BaseNote.b, octave: 0),
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
    ],
    stableId: -4,
  );

  static const ukulele = Instrument(
    name: 'Ukulele',
    strings: [
      MusicalNote(base: BaseNote.g, octave: 4),
      MusicalNote(base: BaseNote.c, octave: 4),
      MusicalNote(base: BaseNote.e, octave: 4),
      MusicalNote(base: BaseNote.a, octave: 4),
    ],
    stableId: -5,
  );

  static const violin = Instrument(
    name: 'Violin',
    strings: [
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
      MusicalNote(base: BaseNote.a, octave: 4),
      MusicalNote(base: BaseNote.e, octave: 5),
    ],
    stableId: -6,
  );

  static const viola = Instrument(
    name: 'Viola',
    strings: [
      MusicalNote(base: BaseNote.c, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
      MusicalNote(base: BaseNote.a, octave: 4),
    ],
    stableId: -7,
  );

  static const cello = Instrument(
    name: 'Cello',
    strings: [
      MusicalNote(base: BaseNote.c, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.a, octave: 3),
    ],
    stableId: -8,
  );

  static const doubleBass = Instrument(
    name: 'Double bass',
    strings: [
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
    ],
    stableId: -9,
  );

  static List<Instrument> getAll() => const [
    chromatic,
    guitar6String,
    bass4String,
    bass5String,
    ukulele,
    violin,
    viola,
    cello,
    doubleBass,
  ];
}
