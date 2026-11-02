import '../models/musical_note.dart';
import 'chain_of_fifths_temperament.dart';
import 'equal_temperament.dart';
import 'fifth_modification.dart';
import 'rational_number.dart';
import 'rational_temperament.dart';
import 'temperament.dart';

/// Catalog of all 19 predefined standard and historical European temperaments,
/// precisely matching the Kotlin reference implementations.
class PredefinedTemperaments {
  PredefinedTemperaments._();

  static const _defaultRoot = MusicalNote(base: BaseNote.c, octave: 4);

  /// 1. Twelve-Tone Equal Temperament (12-EDO)
  static Temperament edo12({MusicalNote? rootNote, int stableId = 1}) {
    return EqualTemperament.edo12(
      rootNote: rootNote ?? _defaultRoot,
      stableId: stableId,
    );
  }

  /// 2. Pythagorean Tuning
  static Temperament pythagorean({MusicalNote? rootNote, int stableId = 2}) {
    return ChainOfFifthsTemperament(
      name: 'Pythagorean Tuning',
      abbreviation: 'Pythagorean',
      description:
          'Historical scale based exclusively on pure fifth intervals (3:2).',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: List.generate(11, (_) => FifthModification()),
      rootIndex: 5,
      uniqueIdentifier: 'pythagorean',
    );
  }

  /// 3. Just Intonation / Pure Tuning
  static Temperament pure({MusicalNote? rootNote, int stableId = 3}) {
    return RationalTemperament(
      name: 'Pure Tuning (Just Intonation)',
      abbreviation: 'Just Intonation',
      description: 'Tuning based on pure harmonic integer frequency ratios.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      rationalNumbers: [
        RationalNumber(1, 1),
        RationalNumber(16, 15),
        RationalNumber(9, 8),
        RationalNumber(6, 5),
        RationalNumber(5, 4),
        RationalNumber(4, 3),
        RationalNumber(45, 32),
        RationalNumber(3, 2),
        RationalNumber(8, 5),
        RationalNumber(5, 3),
        RationalNumber(9, 5),
        RationalNumber(15, 8),
        RationalNumber(2, 1),
      ],
      uniqueIdentifier: 'pure',
    );
  }

  /// 4. Quarter-comma Meantone
  static Temperament quarterCommaMeantone({
    MusicalNote? rootNote,
    int stableId = 4,
  }) {
    return ChainOfFifthsTemperament(
      name: '1/4-Comma Meantone',
      abbreviation: '1/4-Meantone',
      description:
          'Classic Renaissance tuning yielding pure major thirds (5:4).',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: List.generate(
        11,
        (_) => FifthModification(syntonicComma: RationalNumber(-1, 4)),
      ),
      rootIndex: 3,
      uniqueIdentifier: 'quarter comma mean tone',
    );
  }

  /// 5. Extended Quarter-comma Meantone (15-note scale)
  static Temperament extendedQuarterCommaMeantone({
    MusicalNote? rootNote,
    int stableId = 5,
  }) {
    return ChainOfFifthsTemperament(
      name: 'Extended 1/4-Comma Meantone',
      abbreviation: 'Ext. 1/4-Meantone',
      description:
          'Meantone scale extended to 15 notes to reduce wolf intervals.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: List.generate(
        14,
        (_) => FifthModification(syntonicComma: RationalNumber(-1, 4)),
      ),
      rootIndex: 4,
      uniqueIdentifier: 'extended quarter comma mean tone',
    );
  }

  /// 6. Third-comma Meantone
  static Temperament thirdCommaMeantone({
    MusicalNote? rootNote,
    int stableId = 6,
  }) {
    return ChainOfFifthsTemperament(
      name: '1/3-Comma Meantone',
      abbreviation: '1/3-Meantone',
      description: 'Meantone tuning yielding pure minor thirds (6:5).',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: List.generate(
        11,
        (_) => FifthModification(syntonicComma: RationalNumber(-1, 3)),
      ),
      rootIndex: 3,
      uniqueIdentifier: 'third comma mean tone',
    );
  }

  /// 7. Fifth-comma Meantone
  static Temperament fifthCommaMeantone({
    MusicalNote? rootNote,
    int stableId = 7,
  }) {
    return ChainOfFifthsTemperament(
      name: '1/5-Comma Meantone',
      abbreviation: '1/5-Meantone',
      description:
          'Compromise meantone temperament between 1/4-comma and equal temperament.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: List.generate(
        11,
        (_) => FifthModification(syntonicComma: RationalNumber(-1, 5)),
      ),
      rootIndex: 3,
      uniqueIdentifier: 'fifth comma mean tone',
    );
  }

  /// 8. Werckmeister III
  static Temperament werckmeisterIII({
    MusicalNote? rootNote,
    int stableId = 8,
  }) {
    final fifths = List.generate(11, (_) => FifthModification());
    final negQuarterPC = FifthModification(
      pythagoreanComma: RationalNumber(-1, 4),
    );
    fifths[0] = negQuarterPC; // C-G
    fifths[1] = negQuarterPC; // G-D
    fifths[2] = negQuarterPC; // D-A
    fifths[5] = negQuarterPC; // B-F#

    return ChainOfFifthsTemperament(
      name: 'Werckmeister III',
      abbreviation: 'Werckmeister III',
      description:
          'Renowned well-temperament designed by Andreas Werckmeister in 1691.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'werckmeister iii',
    );
  }

  /// 9. Werckmeister IV
  static Temperament werckmeisterIV({MusicalNote? rootNote, int stableId = 9}) {
    final negThirdPC = FifthModification(
      pythagoreanComma: RationalNumber(-1, 3),
    );
    final posThirdPC = FifthModification(
      pythagoreanComma: RationalNumber(1, 3),
    );
    final empty = FifthModification();

    final fifths = [
      negThirdPC, // CG
      empty, // GD
      negThirdPC, // DA
      empty, // AE
      negThirdPC, // EB
      empty, // BF#
      negThirdPC, // F#C#
      empty, // C#G#
      posThirdPC, // G#Eb
      posThirdPC, // EbBb
      negThirdPC, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Werckmeister IV',
      abbreviation: 'Werckmeister IV',
      description:
          'Septenarius well-temperament dividing the ditonic comma into thirds.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'werckmeister iv',
    );
  }

  /// 10. Werckmeister V
  static Temperament werckmeisterV({MusicalNote? rootNote, int stableId = 10}) {
    final negQuarterPC = FifthModification(
      pythagoreanComma: RationalNumber(-1, 4),
    );
    final posQuarterPC = FifthModification(
      pythagoreanComma: RationalNumber(1, 4),
    );
    final empty = FifthModification();

    final fifths = [
      empty, // CG
      empty, // GD
      negQuarterPC, // DA
      negQuarterPC, // AE
      empty, // EB
      empty, // BF#
      negQuarterPC, // F#C#
      negQuarterPC, // C#G#
      posQuarterPC, // G#Eb
      empty, // EbBb
      empty, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Werckmeister V',
      abbreviation: 'Werckmeister V',
      description: 'Well-temperament favoring keys with flats.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'werckmeister v',
    );
  }

  /// 11. Werckmeister VI
  static Temperament werckmeisterVI({
    MusicalNote? rootNote,
    int stableId = 11,
  }) {
    return RationalTemperament(
      name: 'Werckmeister VI',
      abbreviation: 'Werckmeister VI',
      description:
          'Werckmeister monochord tuning based on strict integer string lengths.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      rationalNumbers: [
        RationalNumber(1, 1),
        RationalNumber(196, 186),
        RationalNumber(196, 175),
        RationalNumber(196, 165),
        RationalNumber(196, 156),
        RationalNumber(196, 147),
        RationalNumber(196, 139),
        RationalNumber(196, 131),
        RationalNumber(196, 124),
        RationalNumber(196, 117),
        RationalNumber(196, 110),
        RationalNumber(196, 104),
        RationalNumber(2, 1),
      ],
      uniqueIdentifier: 'werckmeister vi',
    );
  }

  /// 12. Kirnberger I
  static Temperament kirnberger1({MusicalNote? rootNote, int stableId = 12}) {
    final fifths = List.generate(11, (_) => FifthModification());
    fifths[2] = FifthModification(syntonicComma: RationalNumber(-1, 1)); // DA
    fifths[6] = FifthModification(schisma: RationalNumber(-1, 1)); // F#C#

    return ChainOfFifthsTemperament(
      name: 'Kirnberger I',
      abbreviation: 'Kirnberger I',
      description:
          'Johann Philipp Kirnberger’s first temperament with 4 pure major thirds.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'kirnberger 1',
    );
  }

  /// 13. Kirnberger II
  static Temperament kirnberger2({MusicalNote? rootNote, int stableId = 13}) {
    final fifths = List.generate(11, (_) => FifthModification());
    final halfSC = FifthModification(syntonicComma: RationalNumber(-1, 2));
    fifths[2] = halfSC; // DA
    fifths[3] = halfSC; // AE
    fifths[6] = FifthModification(schisma: RationalNumber(-1, 1)); // F#C#

    return ChainOfFifthsTemperament(
      name: 'Kirnberger II',
      abbreviation: 'Kirnberger II',
      description:
          'Johann Philipp Kirnberger’s second tuning halving the syntonic comma across D-A and A-E.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'kirnberger 2',
    );
  }

  /// 14. Kirnberger III
  static Temperament kirnberger3({MusicalNote? rootNote, int stableId = 14}) {
    final fifths = List.generate(11, (_) => FifthModification());
    final quarterSC = FifthModification(syntonicComma: RationalNumber(-1, 4));
    fifths[0] = quarterSC; // CG
    fifths[1] = quarterSC; // GD
    fifths[2] = quarterSC; // DA
    fifths[3] = quarterSC; // AE
    fifths[6] = FifthModification(schisma: RationalNumber(-1, 1)); // F#C#

    return ChainOfFifthsTemperament(
      name: 'Kirnberger III',
      abbreviation: 'Kirnberger III',
      description:
          'Johann Philipp Kirnberger’s famous well-temperament (1779) dividing the syntonic comma into quarters.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'kirnberger 3',
    );
  }

  /// 15. Neidhardt I (1732, "Für ein Dorf")
  static Temperament neidhardt1({MusicalNote? rootNote, int stableId = 15}) {
    final m1_12 = FifthModification(pythagoreanComma: RationalNumber(-1, 12));
    final m1_6 = FifthModification(pythagoreanComma: RationalNumber(-1, 6));
    final m1_4 = FifthModification(pythagoreanComma: RationalNumber(-1, 4));
    final empty = FifthModification();

    final fifths = [
      m1_12, // CG
      m1_6, // GD
      m1_4, // DA
      m1_4, // AE
      empty, // EB
      m1_12, // BF#
      empty, // F#C#
      m1_12, // C#G#
      empty, // G#Eb
      empty, // EbBb
      m1_12, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Neidhardt I',
      abbreviation: 'Neidhardt I',
      description:
          'Johann Georg Neidhardt 1732 rural well-temperament ("Für ein Dorf").',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'neidhardt 1',
    );
  }

  /// 16. Neidhardt II (1724 / 1732, "Für eine kleine Stadt")
  static Temperament neidhardt2({MusicalNote? rootNote, int stableId = 16}) {
    final m1_6 = FifthModification(pythagoreanComma: RationalNumber(-1, 6));
    final m1_12 = FifthModification(pythagoreanComma: RationalNumber(-1, 12));
    final empty = FifthModification();

    final fifths = [
      m1_6, // CG
      m1_6, // GD
      m1_6, // DA
      m1_6, // AE
      m1_12, // EB
      m1_12, // BF#
      empty, // F#C#
      empty, // C#G#
      m1_12, // G#Eb
      m1_12, // EbBb
      empty, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Neidhardt II',
      abbreviation: 'Neidhardt II',
      description:
          'Johann Georg Neidhardt tuning for small towns ("Für eine kleine Stadt").',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'neidhardt 2',
    );
  }

  /// 17. Neidhardt III (1724, "Für eine große Stadt")
  static Temperament neidhardt3({MusicalNote? rootNote, int stableId = 17}) {
    final m1_6 = FifthModification(pythagoreanComma: RationalNumber(-1, 6));
    final m1_12 = FifthModification(pythagoreanComma: RationalNumber(-1, 12));
    final empty = FifthModification();

    final fifths = [
      m1_6, // CG
      m1_6, // GD
      m1_6, // DA
      m1_12, // AE
      empty, // EB
      m1_12, // BF#
      m1_12, // F#C#
      m1_12, // C#G#
      empty, // G#Eb
      empty, // EbBb
      m1_12, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Neidhardt III',
      abbreviation: 'Neidhardt III',
      description:
          'Johann Georg Neidhardt tuning for large cathedral cities ("Für eine große Stadt").',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'neidhardt 3',
    );
  }

  /// 18. Vallotti
  static Temperament valotti({MusicalNote? rootNote, int stableId = 18}) {
    final m1_6 = FifthModification(pythagoreanComma: RationalNumber(-1, 6));
    final empty = FifthModification();

    final fifths = [
      m1_6, // CG
      m1_6, // GD
      m1_6, // DA
      m1_6, // AE
      m1_6, // EB
      empty, // BF#
      empty, // F#C#
      empty, // C#G#
      empty, // G#Eb
      empty, // EbBb
      empty, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Vallotti',
      abbreviation: 'Vallotti',
      description:
          'Francesco Antonio Vallotti’s 1779 Italian circular well-temperament.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'valotti',
    );
  }

  /// 19. Young II
  static Temperament young2({MusicalNote? rootNote, int stableId = 19}) {
    final m1_6 = FifthModification(pythagoreanComma: RationalNumber(-1, 6));
    final empty = FifthModification();

    final fifths = [
      m1_6, // CG
      m1_6, // GD
      m1_6, // DA
      m1_6, // AE
      m1_6, // EB
      m1_6, // BF#
      empty, // F#C#
      empty, // C#G#
      empty, // G#Eb
      empty, // EbBb
      empty, // BbF
    ];

    return ChainOfFifthsTemperament(
      name: 'Young II',
      abbreviation: 'Young II',
      description:
          'Thomas Young’s 1800 tuning with six consecutive fifths tempered by 1/6 Pythagorean comma.',
      stableId: stableId,
      rootNote: rootNote ?? _defaultRoot,
      fifths: fifths,
      rootIndex: 0,
      uniqueIdentifier: 'young 2',
    );
  }

  /// Returns the other 18 historical & non-EDO temperaments (excluding 12-EDO).
  static List<Temperament> getHistoricalTemperaments({MusicalNote? rootNote}) {
    return [
      pythagorean(rootNote: rootNote),
      pure(rootNote: rootNote),
      quarterCommaMeantone(rootNote: rootNote),
      extendedQuarterCommaMeantone(rootNote: rootNote),
      thirdCommaMeantone(rootNote: rootNote),
      fifthCommaMeantone(rootNote: rootNote),
      werckmeisterIII(rootNote: rootNote),
      werckmeisterIV(rootNote: rootNote),
      werckmeisterV(rootNote: rootNote),
      werckmeisterVI(rootNote: rootNote),
      kirnberger1(rootNote: rootNote),
      kirnberger2(rootNote: rootNote),
      kirnberger3(rootNote: rootNote),
      neidhardt1(rootNote: rootNote),
      neidhardt2(rootNote: rootNote),
      neidhardt3(rootNote: rootNote),
      valotti(rootNote: rootNote),
      young2(rootNote: rootNote),
    ];
  }

  /// Returns all 68 predefined EDO temperaments from 5-EDO to 72-EDO (matching Kotlin `edoTemperaments`).
  static List<Temperament> getEdoTemperaments({MusicalNote? rootNote}) {
    return List<Temperament>.generate(72 - 5 + 1, (i) {
      final edo = 5 + i;
      return EqualTemperament.edo(
        edo,
        rootNote: rootNote,
        stableId: (edo == 12) ? 1 : (1000 + edo),
      );
    });
  }

  /// Returns the classical list of 19 standard and historical temperaments.
  static List<Temperament> getHistorical19({MusicalNote? rootNote}) {
    return [
      edo12(rootNote: rootNote),
      ...getHistoricalTemperaments(rootNote: rootNote),
    ];
  }

  /// Returns the complete comprehensive list of all predefined temperaments (86 distinct temperaments:
  /// 12-EDO, 18 historical temperaments, and all 5-72 EDO systems).
  static List<Temperament> getAll({MusicalNote? rootNote}) {
    final edos = getEdoTemperaments(rootNote: rootNote);
    final historical = getHistoricalTemperaments(rootNote: rootNote);
    return [
      edo12(rootNote: rootNote),
      ...historical,
      ...edos.where((t) => t.equalOctaveDivision != 12),
    ];
  }
}
