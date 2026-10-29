import '../models/chain_of_fifths.dart';
import '../models/fifth_modification.dart';
import '../models/rational_number.dart';
import 'temperament_models.dart';

/// Catalog of 19 standard and historical musical temperaments.
class PredefinedTemperaments {
  static List<Temperament> getAll() {
    return [
      edo12(),
      pythagorean(),
      justIntonation(),
      quarterCommaMeantone(),
      extendedQuarterCommaMeantone(),
      thirdCommaMeantone(),
      fifthCommaMeantone(),
      werckmeisterIII(),
      werckmeisterIV(),
      werckmeisterV(),
      werckmeisterVI(),
      kirnbergerI(),
      kirnbergerII(),
      kirnbergerIII(),
      neidhardtI(),
      neidhardtII(),
      neidhardtIII(),
      vallotti(),
      youngII(),
    ];
  }

  static TemperamentEDO edo12() => const TemperamentEDO(
    notesPerOctave: 12,
    stableId: -1,
    customName: 'Equal Temperament (12-EDO)',
    customAbbr: '12-EDO',
  );

  static TemperamentChainOfFifths pythagorean() => TemperamentChainOfFifths(
    name: 'Pythagorean Tuning',
    abbreviation: 'Pythagorean',
    description: 'Tuning based on pure 3:2 fifths without comma narrowing.',
    fifthsChain: ChainOfFifths(
      fifths: List.generate(11, (_) => FifthModification()),
      rootIndex: 5,
    ),
    stableId: -2,
    uniqueIdentifier: 'pythagorean',
  );

  static TemperamentRational justIntonation() => TemperamentRational(
    name: 'Just Intonation (Pure)',
    abbreviation: 'Just',
    description: 'Pure harmonic ratios based on prime factors 2, 3, and 5.',
    ratios: [
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
    stableId: -3,
    uniqueIdentifier: 'pure',
  );

  static TemperamentChainOfFifths
  quarterCommaMeantone() => TemperamentChainOfFifths(
    name: 'Quarter-comma Meantone',
    abbreviation: '1/4c Meantone',
    description:
        'Fifths narrowed by 1/4 syntonic comma producing pure major thirds.',
    fifthsChain: ChainOfFifths(
      fifths: List.generate(
        11,
        (_) => FifthModification(syntonicComma: RationalNumber(-1, 4)),
      ),
      rootIndex: 3,
    ),
    stableId: -4,
    uniqueIdentifier: 'quarter comma mean tone',
  );

  static TemperamentChainOfFifths extendedQuarterCommaMeantone() =>
      TemperamentChainOfFifths(
        name: 'Extended Quarter-comma Meantone',
        abbreviation: 'Ext 1/4c Meantone',
        description:
            '14-note quarter-comma meantone chain with extra accidentals.',
        fifthsChain: ChainOfFifths(
          fifths: List.generate(
            14,
            (_) => FifthModification(syntonicComma: RationalNumber(-1, 4)),
          ),
          rootIndex: 4,
        ),
        stableId: -5,
        uniqueIdentifier: 'extended quarter comma mean tone',
      );

  static TemperamentChainOfFifths
  thirdCommaMeantone() => TemperamentChainOfFifths(
    name: 'Third-comma Meantone',
    abbreviation: '1/3c Meantone',
    description:
        'Fifths narrowed by 1/3 syntonic comma producing pure minor thirds.',
    fifthsChain: ChainOfFifths(
      fifths: List.generate(
        11,
        (_) => FifthModification(syntonicComma: RationalNumber(-1, 3)),
      ),
      rootIndex: 3,
    ),
    stableId: -6,
    uniqueIdentifier: 'third comma mean tone',
  );

  static TemperamentChainOfFifths fifthCommaMeantone() =>
      TemperamentChainOfFifths(
        name: 'Fifth-comma Meantone',
        abbreviation: '1/5c Meantone',
        description: 'Fifths narrowed by 1/5 syntonic comma.',
        fifthsChain: ChainOfFifths(
          fifths: List.generate(
            11,
            (_) => FifthModification(syntonicComma: RationalNumber(-1, 5)),
          ),
          rootIndex: 3,
        ),
        stableId: -7,
        uniqueIdentifier: 'fifth comma mean tone',
      );

  static TemperamentChainOfFifths werckmeisterIII() => TemperamentChainOfFifths(
    name: 'Werckmeister III',
    abbreviation: 'Werckmeister III',
    description:
        'Famous baroque circulating temperament with 4 quarter-comma fifths.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // C-G
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // D-A
        FifthModification(), // A-E
        FifthModification(), // E-B
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // B-F#
        FifthModification(), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(), // G#-D#
        FifthModification(), // D#-A#
        FifthModification(), // A#-F
      ],
      rootIndex: 0,
    ),
    stableId: -8,
    uniqueIdentifier: 'werckmeister iii',
  );

  static TemperamentChainOfFifths werckmeisterIV() => TemperamentChainOfFifths(
    name: 'Werckmeister IV',
    abbreviation: 'Werckmeister IV',
    description: 'Werckmeister septenarian circulating tuning.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 3)), // C-G
        FifthModification(), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 3)), // D-A
        FifthModification(), // A-E
        FifthModification(pythagoreanComma: RationalNumber(-1, 3)), // E-B
        FifthModification(), // B-F#
        FifthModification(pythagoreanComma: RationalNumber(-1, 3)), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(pythagoreanComma: RationalNumber(1, 3)), // G#-D#
        FifthModification(pythagoreanComma: RationalNumber(1, 3)), // D#-A#
        FifthModification(pythagoreanComma: RationalNumber(-1, 3)), // A#-F
      ],
      rootIndex: 0,
    ),
    stableId: -9,
    uniqueIdentifier: 'werckmeister iv',
  );

  static TemperamentChainOfFifths werckmeisterV() => TemperamentChainOfFifths(
    name: 'Werckmeister V',
    abbreviation: 'Werckmeister V',
    description: 'Circulating temperament with 5 quarter-comma modifications.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(), // C-G
        FifthModification(), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // D-A
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // A-E
        FifthModification(), // E-B
        FifthModification(), // B-F#
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // F#-C#
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // C#-G#
        FifthModification(pythagoreanComma: RationalNumber(1, 4)), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -10,
    uniqueIdentifier: 'werckmeister v',
  );

  static TemperamentRational werckmeisterVI() => TemperamentRational(
    name: 'Werckmeister VI',
    abbreviation: 'Werckmeister VI',
    description: 'Septenarius tuning based on geometric string divisions.',
    ratios: [
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
    stableId: -11,
    uniqueIdentifier: 'werckmeister vi',
  );

  static TemperamentChainOfFifths kirnbergerI() => TemperamentChainOfFifths(
    name: 'Kirnberger I',
    abbreviation: 'Kirnberger I',
    description:
        'D-A narrowed by one syntonic comma, F#-C# narrowed by one schisma.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(), // C-G
        FifthModification(), // G-D
        FifthModification(syntonicComma: RationalNumber(-1, 1)), // D-A
        FifthModification(), // A-E
        FifthModification(), // E-B
        FifthModification(), // B-F#
        FifthModification(schisma: RationalNumber(-1, 1)), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -12,
    uniqueIdentifier: 'kirnberger 1',
  );

  static TemperamentChainOfFifths kirnbergerII() => TemperamentChainOfFifths(
    name: 'Kirnberger II',
    abbreviation: 'Kirnberger II',
    description:
        'D-A and A-E narrowed by 1/2 syntonic comma, F#-C# by 1 schisma.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(), // C-G
        FifthModification(), // G-D
        FifthModification(syntonicComma: RationalNumber(-1, 2)), // D-A
        FifthModification(syntonicComma: RationalNumber(-1, 2)), // A-E
        FifthModification(), // E-B
        FifthModification(), // B-F#
        FifthModification(schisma: RationalNumber(-1, 1)), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -13,
    uniqueIdentifier: 'kirnberger 2',
  );

  static TemperamentChainOfFifths kirnbergerIII() => TemperamentChainOfFifths(
    name: 'Kirnberger III',
    abbreviation: 'Kirnberger III',
    description:
        'Four consecutive fifths (C-E) narrowed by 1/4 syntonic comma.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(syntonicComma: RationalNumber(-1, 4)), // C-G
        FifthModification(syntonicComma: RationalNumber(-1, 4)), // G-D
        FifthModification(syntonicComma: RationalNumber(-1, 4)), // D-A
        FifthModification(syntonicComma: RationalNumber(-1, 4)), // A-E
        FifthModification(), // E-B
        FifthModification(), // B-F#
        FifthModification(schisma: RationalNumber(-1, 1)), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -14,
    uniqueIdentifier: 'kirnberger 3',
  );

  static TemperamentChainOfFifths neidhardtI() => TemperamentChainOfFifths(
    name: 'Neidhardt I (Village, 1732)',
    abbreviation: 'Neidhardt I',
    description:
        'Circulating temperament optimized for smaller village organs.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // C-G
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // D-A
        FifthModification(pythagoreanComma: RationalNumber(-1, 4)), // A-E
        FifthModification(), // E-B
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // B-F#
        FifthModification(), // F#-C#
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -15,
    uniqueIdentifier: 'neidhardt 1',
  );

  static TemperamentChainOfFifths neidhardtII() => TemperamentChainOfFifths(
    name: 'Neidhardt II (Small City, 1732)',
    abbreviation: 'Neidhardt II',
    description: 'Circulating temperament for small towns with key modulation.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // C-G
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // D-A
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // A-E
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // E-B
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // B-F#
        FifthModification(), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // G#-Eb
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -16,
    uniqueIdentifier: 'neidhardt 2',
  );

  static TemperamentChainOfFifths neidhardtIII() => TemperamentChainOfFifths(
    name: 'Neidhardt III (Large City, 1732)',
    abbreviation: 'Neidhardt III',
    description: 'Advanced circulating temperament enabling all 24 keys.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // C-G
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // D-A
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // A-E
        FifthModification(), // E-B
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // B-F#
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // F#-C#
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(pythagoreanComma: RationalNumber(-1, 12)), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -17,
    uniqueIdentifier: 'neidhardt 3',
  );

  static TemperamentChainOfFifths vallotti() => TemperamentChainOfFifths(
    name: 'Vallotti',
    abbreviation: 'Vallotti',
    description:
        'Six consecutive fifths (F-B) narrowed by 1/6 pythagorean comma.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // C-G
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // D-A
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // A-E
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // E-B
        FifthModification(), // B-F#
        FifthModification(), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -18,
    uniqueIdentifier: 'valotti',
  );

  static TemperamentChainOfFifths youngII() => TemperamentChainOfFifths(
    name: 'Young II',
    abbreviation: 'Young II',
    description: 'Thomas Young 1799 circulating temperament.',
    fifthsChain: ChainOfFifths(
      fifths: [
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // C-G
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // G-D
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // D-A
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // A-E
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // E-B
        FifthModification(pythagoreanComma: RationalNumber(-1, 6)), // B-F#
        FifthModification(), // F#-C#
        FifthModification(), // C#-G#
        FifthModification(), // G#-Eb
        FifthModification(), // Eb-Bb
        FifthModification(), // Bb-F
      ],
      rootIndex: 0,
    ),
    stableId: -19,
    uniqueIdentifier: 'young 2',
  );
}
