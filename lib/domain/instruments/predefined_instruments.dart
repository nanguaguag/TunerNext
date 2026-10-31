import '../models/musical_note.dart';
import 'instrument.dart';
import 'instrument_icon.dart';

/// Comprehensive repository of built-in instruments and tunings.
class PredefinedInstruments {
  PredefinedInstruments._();

  /// Default chromatic instrument (all 12 semitones active without fixed strings).
  static const Instrument chromatic = Instrument(
    name: 'Chromatic',
    nameResourceKey: 'chromatic',
    strings: [],
    icon: InstrumentIcon.piano,
    stableId: -1,
    isChromatic: true,
  );

  /// 6-string acoustic/electric guitar in Standard EADGBE tuning.
  static const Instrument guitarStandard = Instrument(
    name: '6-string guitar',
    nameResourceKey: 'guitar_eadgbe',
    strings: [
      MusicalNote(base: BaseNote.e, octave: 2),
      MusicalNote(base: BaseNote.a, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.b, octave: 3),
      MusicalNote(base: BaseNote.e, octave: 4),
    ],
    icon: InstrumentIcon.guitar,
    stableId: -2,
  );

  /// 6-string guitar in Drop D tuning (DADGBE).
  static const Instrument guitarDropD = Instrument(
    name: '6-string guitar (Drop D)',
    nameResourceKey: 'guitar_drop_d',
    strings: [
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.a, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.b, octave: 3),
      MusicalNote(base: BaseNote.e, octave: 4),
    ],
    icon: InstrumentIcon.guitar,
    stableId: -3,
  );

  /// 6-string guitar in DADGAD (Celtic) tuning.
  static const Instrument guitarDadgad = Instrument(
    name: '6-string guitar (DADGAD)',
    nameResourceKey: 'guitar_dadgad',
    strings: [
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.a, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.a, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
    ],
    icon: InstrumentIcon.guitar,
    stableId: -4,
  );

  /// 6-string guitar in Open D tuning (DADF#AD).
  static const Instrument guitarOpenD = Instrument(
    name: '6-string guitar (Open D)',
    nameResourceKey: 'guitar_open_d',
    strings: [
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.a, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.f, modifier: NoteModifier.sharp, octave: 3),
      MusicalNote(base: BaseNote.a, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
    ],
    icon: InstrumentIcon.guitar,
    stableId: -5,
  );

  /// 6-string guitar in Open G tuning (DGDGBD).
  static const Instrument guitarOpenG = Instrument(
    name: '6-string guitar (Open G)',
    nameResourceKey: 'guitar_open_g',
    strings: [
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.b, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
    ],
    icon: InstrumentIcon.guitar,
    stableId: -6,
  );

  /// 4-string electric bass in standard EADG tuning.
  static const Instrument bass4String = Instrument(
    name: '4-string bass',
    nameResourceKey: 'bass_eadg',
    strings: [
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
    ],
    icon: InstrumentIcon.bass,
    stableId: -7,
  );

  /// 5-string electric bass in standard BEADG tuning.
  static const Instrument bass5String = Instrument(
    name: '5-string bass',
    nameResourceKey: 'bass_beadg',
    strings: [
      MusicalNote(base: BaseNote.b, octave: 0),
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
    ],
    icon: InstrumentIcon.bass,
    stableId: -8,
  );

  /// 6-string electric bass in standard BEADGC tuning.
  static const Instrument bass6String = Instrument(
    name: '6-string bass',
    nameResourceKey: 'bass_beadgc',
    strings: [
      MusicalNote(base: BaseNote.b, octave: 0),
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
      MusicalNote(base: BaseNote.c, octave: 3),
    ],
    icon: InstrumentIcon.bass,
    stableId: -9,
  );

  /// Standard Soprano/Concert/Tenor Ukulele in re-entrant C6 tuning (G4, C4, E4, A4).
  static const Instrument ukuleleGcea = Instrument(
    name: 'Ukulele',
    nameResourceKey: 'ukulele_gcea',
    strings: [
      MusicalNote(base: BaseNote.g, octave: 4),
      MusicalNote(base: BaseNote.c, octave: 4),
      MusicalNote(base: BaseNote.e, octave: 4),
      MusicalNote(base: BaseNote.a, octave: 4),
    ],
    icon: InstrumentIcon.ukulele,
    stableId: -10,
  );

  /// Baritone Ukulele in DGBE tuning.
  static const Instrument ukuleleBaritone = Instrument(
    name: 'Baritone Ukulele',
    nameResourceKey: 'ukulele_dgbe',
    strings: [
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.b, octave: 3),
      MusicalNote(base: BaseNote.e, octave: 4),
    ],
    icon: InstrumentIcon.ukulele,
    stableId: -11,
  );

  /// Violin in standard fifths tuning (G3, D4, A4, E5).
  static const Instrument violin = Instrument(
    name: 'Violin',
    nameResourceKey: 'violin_gdae',
    strings: [
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
      MusicalNote(base: BaseNote.a, octave: 4),
      MusicalNote(base: BaseNote.e, octave: 5),
    ],
    icon: InstrumentIcon.violin,
    stableId: -12,
  );

  /// Viola in standard fifths tuning (C3, G3, D4, A4).
  static const Instrument viola = Instrument(
    name: 'Viola',
    nameResourceKey: 'viola_cgda',
    strings: [
      MusicalNote(base: BaseNote.c, octave: 3),
      MusicalNote(base: BaseNote.g, octave: 3),
      MusicalNote(base: BaseNote.d, octave: 4),
      MusicalNote(base: BaseNote.a, octave: 4),
    ],
    icon: InstrumentIcon.violin,
    stableId: -13,
  );

  /// Cello (Violoncello) in standard fifths tuning (C2, G2, D3, A3).
  static const Instrument cello = Instrument(
    name: 'Cello',
    nameResourceKey: 'cello_cgda',
    strings: [
      MusicalNote(base: BaseNote.c, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
      MusicalNote(base: BaseNote.d, octave: 3),
      MusicalNote(base: BaseNote.a, octave: 3),
    ],
    icon: InstrumentIcon.cello,
    stableId: -14,
  );

  /// Double bass (Contrabass) in standard fourths tuning (E1, A1, D2, G2).
  static const Instrument doubleBass = Instrument(
    name: 'Double bass',
    nameResourceKey: 'double_bass_eadg',
    strings: [
      MusicalNote(base: BaseNote.e, octave: 1),
      MusicalNote(base: BaseNote.a, octave: 1),
      MusicalNote(base: BaseNote.d, octave: 2),
      MusicalNote(base: BaseNote.g, octave: 2),
    ],
    icon: InstrumentIcon.doubleBass,
    stableId: -15,
  );

  /// Complete list of all predefined instruments.
  static const List<Instrument> all = [
    chromatic,
    guitarStandard,
    guitarDropD,
    guitarDadgad,
    guitarOpenD,
    guitarOpenG,
    bass4String,
    bass5String,
    bass6String,
    ukuleleGcea,
    ukuleleBaritone,
    violin,
    viola,
    cello,
    doubleBass,
  ];
}
