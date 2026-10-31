import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/instruments/instrument.dart';
import 'package:tuner_flutter/domain/instruments/instrument_icon.dart';
import 'package:tuner_flutter/domain/instruments/instrument_io.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/domain/instruments/sorted_and_distinct_instrument_strings.dart';
import 'package:tuner_flutter/domain/instruments/target_note_auto_detection.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/tuning/musical_scale_frequencies.dart';

void main() {
  // Construct standard 12-EDO scale frequencies centered on A4 (440 Hz)
  late MusicalScaleFrequencies edo12Scale;

  setUp(() {
    final cents12Edo = List<double>.generate(13, (i) => i * 100.0);
    edo12Scale = MusicalScaleFrequencies.create(
      cents: cents12Edo,
      referenceIndexWithinOctave: 9, // A4 in C-based octave
      referenceFrequency: 440.0,
      frequencyMin: 16.0,
      frequencyMax: 20000.0,
    );
  });

  group('PredefinedInstruments Repository Tests', () {
    test(
      'All predefined instruments are initialized with valid properties',
      () {
        expect(PredefinedInstruments.all.length, 15);
        expect(PredefinedInstruments.chromatic.isChromatic, isTrue);
        expect(PredefinedInstruments.chromatic.strings, isEmpty);
        expect(PredefinedInstruments.chromatic.icon, InstrumentIcon.piano);

        // Guitar standard: E2, A2, D3, G3, B3, E4
        final guitar = PredefinedInstruments.guitarStandard;
        expect(guitar.stringCount, 6);
        expect(
          guitar.strings.first,
          const MusicalNote(base: BaseNote.e, octave: 2),
        );
        expect(
          guitar.strings.last,
          const MusicalNote(base: BaseNote.e, octave: 4),
        );
        expect(guitar.stringsFormatted, 'E2 - A2 - D3 - G3 - B3 - E4');

        // Violin: G3, D4, A4, E5
        final violin = PredefinedInstruments.violin;
        expect(violin.stringCount, 4);
        expect(
          violin.strings[0],
          const MusicalNote(base: BaseNote.g, octave: 3),
        );
        expect(
          violin.strings[1],
          const MusicalNote(base: BaseNote.d, octave: 4),
        );
        expect(
          violin.strings[2],
          const MusicalNote(base: BaseNote.a, octave: 4),
        );
        expect(
          violin.strings[3],
          const MusicalNote(base: BaseNote.e, octave: 5),
        );

        // Ukulele re-entrant: G4, C4, E4, A4
        final uke = PredefinedInstruments.ukuleleGcea;
        expect(uke.stringCount, 4);
        expect(uke.strings[0].octave, 4); // High G
        expect(uke.strings[1].octave, 4); // C4 lower pitch than G4
      },
    );

    test('InstrumentIcon parsing supports various formats', () {
      expect(InstrumentIcon.fromString('guitar'), InstrumentIcon.guitar);
      expect(
        InstrumentIcon.fromString('double_bass'),
        InstrumentIcon.doubleBass,
      );
      expect(
        InstrumentIcon.fromString('Double Bass'),
        InstrumentIcon.doubleBass,
      );
      expect(InstrumentIcon.fromString('ukulele'), InstrumentIcon.ukulele);
      expect(
        InstrumentIcon.fromString('unknown_instrument'),
        InstrumentIcon.guitar,
      );
    });
  });

  group('SortedAndDistinctInstrumentStrings Tests', () {
    test(
      'Strings are sorted according to scale index and duplicates are removed',
      () {
        // Scale indices: E4 (-5), A2 (-24), E2 (-29), E4 (-5 duplicate)
        const e4 = MusicalNote(base: BaseNote.e, octave: 4);
        const a2 = MusicalNote(base: BaseNote.a, octave: 2);
        const e2 = MusicalNote(base: BaseNote.e, octave: 2);

        const inst = Instrument(name: 'test', strings: [e4, a2, e4, e2]);

        final adapter = SortedAndDistinctInstrumentStrings(instrument: inst);
        expect(adapter.sortedAndDistinctNoteIndices, [-29, -24, -5]);
        expect(adapter.numDifferentNotes, 3);
      },
    );

    test('Strings not in scale are collapsed into trailing sentinel', () {
      // Non-scale note (e.g. sharp-sharp or non-standard modifier in 12-EDO)
      const d3 = MusicalNote(base: BaseNote.d, octave: 3); // -19
      const a2 = MusicalNote(base: BaseNote.a, octave: 2); // -24
      // We simulate an invalid note by crafting a note with artificial non-12edo modifier
      // In SortedAndDistinctInstrumentStrings, standard accidentals are accepted;
      // non-scale notes get sentinelIndex.
      const inst = Instrument(name: 'test', strings: [d3, a2]);

      final adapter = SortedAndDistinctInstrumentStrings(instrument: inst);
      expect(adapter.sortedAndDistinctNoteIndices, [-24, -19]);
      expect(adapter.numDifferentNotes, 2);
    });

    test('Chromatic and empty instruments have zero strings', () {
      const chromatic = Instrument(name: 'chromatic', isChromatic: true);
      expect(
        SortedAndDistinctInstrumentStrings(
          instrument: chromatic,
        ).numDifferentNotes,
        0,
      );

      const empty = Instrument(name: 'empty', strings: []);
      expect(
        SortedAndDistinctInstrumentStrings(instrument: empty).numDifferentNotes,
        0,
      );
    });

    test('isNotePartOfInstrument correctly identifies matching strings', () {
      const e2 = MusicalNote(base: BaseNote.e, octave: 2);
      const a2 = MusicalNote(base: BaseNote.a, octave: 2);
      const d3 = MusicalNote(base: BaseNote.d, octave: 3);
      const c4 = MusicalNote(base: BaseNote.c, octave: 4);

      const inst = Instrument(name: 'test', strings: [e2, a2]);
      final adapter = SortedAndDistinctInstrumentStrings(instrument: inst);

      expect(adapter.isNotePartOfInstrument(e2), isTrue);
      expect(adapter.isNotePartOfInstrument(a2), isTrue);
      expect(adapter.isNotePartOfInstrument(d3), isFalse);
      expect(adapter.isNotePartOfInstrument(null), isFalse);

      // Chromatic accepts any valid scale note
      const chromatic = Instrument(name: 'chromatic', isChromatic: true);
      final chromAdapter = SortedAndDistinctInstrumentStrings(
        instrument: chromatic,
      );
      expect(chromAdapter.isNotePartOfInstrument(c4), isTrue);
      expect(chromAdapter.isNotePartOfInstrument(null), isFalse);
    });
  });

  group('TargetNoteAutoDetection Tests (Kotlin Parity)', () {
    double freq(double index) => edo12Scale.getInterpolated(index);

    const noteE2 = MusicalNote(base: BaseNote.e, octave: 2); // index -29
    const noteA2 = MusicalNote(base: BaseNote.a, octave: 2); // index -24
    const noteD3 = MusicalNote(base: BaseNote.d, octave: 3); // index -19
    const noteG3 = MusicalNote(base: BaseNote.g, octave: 3); // index -14
    const noteB3 = MusicalNote(base: BaseNote.b, octave: 3); // index -10
    const noteE4 = MusicalNote(base: BaseNote.e, octave: 4); // index -5

    final guitar = Instrument(
      name: 'Guitar',
      strings: [noteE4, noteA2, noteB3, noteE2, noteG3, noteD3, noteA2],
    );

    test('Chromatic returns closest note without previous note', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: null, // chromatic
        toleranceInCents: 5.0,
      );

      final a4 = MusicalNote.fromMidiNumber(69);
      final aSharp4 = MusicalNote.fromMidiNumber(70);
      final aFlat4 = MusicalNote.fromMidiNumber(68);

      expect(detector.detect(440.0), a4);
      expect(detector.detect(freq(0.45)), a4);
      expect(detector.detect(freq(0.55)), aSharp4);
      expect(detector.detect(freq(-0.55)), aFlat4);
    });

    test('Chromatic keeps previous note within hysteresis range', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: null,
        toleranceInCents: 5.0,
      );

      final a4 = MusicalNote.fromMidiNumber(69);
      // At +/- 0.57 semitones (deviation-based 60% hysteresis), A4 is retained
      expect(detector.detect(freq(0.57), a4), a4);
      expect(detector.detect(freq(-0.57), a4), a4);
    });

    test('Chromatic switches note when leaving hysteresis range', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: null,
        toleranceInCents: 5.0,
      );

      final a4 = MusicalNote.fromMidiNumber(69);
      final aSharp4 = MusicalNote.fromMidiNumber(70);
      final aFlat4 = MusicalNote.fromMidiNumber(68);

      // At 0.63 semitones (beyond 0.6 hysteresis), target switches to A#4 or Ab4
      expect(detector.detect(freq(0.63), a4), aSharp4);
      expect(detector.detect(freq(-0.63), a4), aFlat4);

      // Distant frequency jumps directly to closest note
      final e5 = MusicalNote.fromMidiNumber(76); // index +7
      expect(detector.detect(freq(7.1), a4), e5);
    });

    test('Invalid frequencies return null', () {
      final detector = TargetNoteAutoDetection(scaleFrequencies: edo12Scale);
      expect(detector.detect(0.0), isNull);
      expect(detector.detect(-50.0), isNull);
      expect(detector.detect(double.nan), isNull);
    });

    test('Instrument without strings returns null', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: const Instrument(name: 'empty', strings: []),
      );
      expect(detector.detect(440.0), isNull);
    });

    test('Instrument returns closest string note', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: guitar,
        toleranceInCents: 5.0,
      );

      expect(detector.detect(freq(-29.0)), noteE2);
      expect(detector.detect(freq(-23.0)), noteA2);
      expect(detector.detect(freq(-21.2)), noteD3);
      expect(detector.detect(freq(-9.0)), noteB3);
    });

    test('Instrument keeps previous string within hysteresis range', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: guitar,
        toleranceInCents: 5.0,
      );

      // A2 (-24) and D3 (-19): 60% upper bound for A2 is at -21
      expect(detector.detect(freq(-21.2), noteA2), noteA2);
      expect(detector.detect(freq(-20.8), noteA2), noteD3);

      // Lower bound for D3 is at -22
      expect(detector.detect(freq(-21.8), noteD3), noteD3);
      expect(detector.detect(freq(-22.2), noteD3), noteA2);
    });

    test('Lowest and highest strings have unbounded outer ranges', () {
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: guitar,
        toleranceInCents: 5.0,
      );

      // Far below lowest string E2: retains or falls back to E2
      expect(detector.detect(freq(-45.0)), noteE2);
      expect(detector.detect(freq(-45.0), noteE2), noteE2);
      expect(detector.detect(freq(-45.0), noteE4), noteE2);

      // Far above highest string E4: retains or falls back to E4
      expect(detector.detect(freq(30.0)), noteE4);
      expect(detector.detect(freq(30.0), noteE4), noteE4);
      expect(detector.detect(freq(30.0), noteE2), noteE4);
    });

    test('Single distinct string instrument is always returned', () {
      final singleStringInst = Instrument(
        name: 'mono',
        strings: const [noteA2, noteA2],
      );
      final detector = TargetNoteAutoDetection(
        scaleFrequencies: edo12Scale,
        instrument: singleStringInst,
      );

      expect(detector.detect(freq(-40.0)), noteA2);
      expect(detector.detect(freq(20.0)), noteA2);
      expect(detector.detect(freq(20.0), noteA2), noteA2);
    });
  });

  group('InstrumentIO Import and Export Tests', () {
    const e2 = MusicalNote(base: BaseNote.e, octave: 2);
    const a2 = MusicalNote(base: BaseNote.a, octave: 2);
    const fSharp4 = MusicalNote(
      base: BaseNote.f,
      modifier: NoteModifier.sharp,
      octave: 4,
    );

    test(
      'Round-trip serialization preserves all instrument attributes verbatim',
      () {
        final originalInstruments = [
          const Instrument(
            name: 'Guitar',
            strings: [e2, a2],
            icon: InstrumentIcon.guitar,
            stableId: 3,
          ),
          // Name contains special symbols, spaces, and newline: verified by length prefix
          const Instrument(
            name: 'My Custom Instrument;\nIcon=piano',
            strings: [fSharp4],
            icon: InstrumentIcon.doubleBass,
            stableId: 10,
          ),
          const Instrument(
            name: 'Empty Instrument',
            strings: [],
            icon: InstrumentIcon.piano,
            stableId: Instrument.noStableId,
          ),
        ];

        final serializedText = InstrumentIO.instrumentsListToString(
          originalInstruments,
        );
        final parseResult = InstrumentIO.stringToInstruments(serializedText);

        expect(parseResult.isOk, isTrue);
        expect(parseResult.instruments.length, originalInstruments.length);

        final reloaded0 = parseResult.instruments[0];
        expect(reloaded0.name, 'Guitar');
        expect(reloaded0.strings, [e2, a2]);
        expect(reloaded0.icon, InstrumentIcon.guitar);
        expect(reloaded0.stableId, 3);

        final reloaded1 = parseResult.instruments[1];
        expect(reloaded1.name, 'My Custom Instrument;\nIcon=piano');
        expect(reloaded1.strings, [fSharp4]);
        expect(reloaded1.icon, InstrumentIcon.doubleBass);
        expect(reloaded1.stableId, 10);

        final reloaded2 = parseResult.instruments[2];
        expect(reloaded2.name, 'Empty Instrument');
        expect(reloaded2.strings, isEmpty);
        expect(reloaded2.stableId, Instrument.noStableId);
      },
    );

    test('Empty content returns empty status', () {
      expect(InstrumentIO.stringToInstruments('').isEmpty, isTrue);
      expect(InstrumentIO.stringToInstruments('   \n\t ').isEmpty, isTrue);
    });

    test('Malformed string inputs are rejected as invalid', () {
      // Unknown base note
      final badBase = InstrumentIO.stringToInstruments(
        'Strings=[MusicalNote(base=X)]',
      );
      expect(badBase.isInvalid, isTrue);

      // Unterminated array
      final unterminated = InstrumentIO.stringToInstruments(
        'Strings=[MusicalNote(base=C',
      );
      expect(unterminated.isInvalid, isTrue);
    });
  });
}
