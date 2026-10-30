import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/domain/tuning/frequency_to_note_converter.dart';
import 'package:tuner_flutter/domain/tuning/musical_scale_frequencies.dart';
import 'package:tuner_flutter/domain/tuning/tuning_math.dart';

void main() {
  group('TuningMath Unit Tests', () {
    test('ratioToCents and centsToRatio are exact mathematical inverses', () {
      expect(TuningMath.ratioToCents(1.0), closeTo(0.0, 1e-9));
      expect(TuningMath.ratioToCents(2.0), closeTo(1200.0, 1e-9));
      expect(TuningMath.ratioToCents(0.5), closeTo(-1200.0, 1e-9));

      const semitoneRatio = 1.0594630943592953; // 2^(1/12)
      expect(TuningMath.ratioToCents(semitoneRatio), closeTo(100.0, 1e-7));

      expect(TuningMath.centsToRatio(0.0), closeTo(1.0, 1e-9));
      expect(TuningMath.centsToRatio(1200.0), closeTo(2.0, 1e-9));
      expect(TuningMath.centsToRatio(-1200.0), closeTo(0.5, 1e-9));
      expect(TuningMath.centsToRatio(100.0), closeTo(semitoneRatio, 1e-7));

      for (double cents = -2400.0; cents <= 2400.0; cents += 137.5) {
        final ratio = TuningMath.centsToRatio(cents);
        final invertedCents = TuningMath.ratioToCents(ratio);
        expect(invertedCents, closeTo(cents, 1e-7));
      }
    });

    test('centsToFrequency and frequencyToCents roundtrip accurately', () {
      const ref = 440.0;
      expect(TuningMath.centsToFrequency(0.0, ref), closeTo(440.0, 1e-9));
      expect(TuningMath.centsToFrequency(1200.0, ref), closeTo(880.0, 1e-9));
      expect(TuningMath.centsToFrequency(-1200.0, ref), closeTo(220.0, 1e-9));

      expect(TuningMath.frequencyToCents(440.0, ref), closeTo(0.0, 1e-9));
      expect(TuningMath.frequencyToCents(880.0, ref), closeTo(1200.0, 1e-9));
      expect(TuningMath.frequencyToCents(220.0, ref), closeTo(-1200.0, 1e-9));

      expect(TuningMath.centsDeviation(442.54, 440.0), closeTo(9.98, 0.05));
    });

    test('Robust handling of non-positive, zero, and NaN inputs', () {
      expect(TuningMath.ratioToCents(0.0), equals(double.negativeInfinity));
      expect(TuningMath.ratioToCents(-1.0), equals(double.negativeInfinity));
      expect(TuningMath.ratioToCents(double.nan).isNaN, isTrue);

      expect(TuningMath.centsToRatio(double.nan).isNaN, isTrue);
      expect(TuningMath.centsToFrequency(100.0, 0.0), equals(0.0));
      expect(
        TuningMath.frequencyToCents(-440.0, 440.0),
        equals(double.negativeInfinity),
      );
      expect(
        TuningMath.frequencyToCents(440.0, 0.0),
        equals(double.negativeInfinity),
      );
    });
  });

  group('MusicalScaleFrequencies Unit Tests (Parity with Kotlin Baseline)', () {
    test('12-EDO scale construction and octave doubling/halving', () {
      final cents = List<double>.generate(13, (i) => i * 100.0);
      const referenceFrequency = 440.0;
      const frequencyMin = 10.0;
      const frequencyMax = 16000.0;

      final frequencies = MusicalScaleFrequencies.create(
        cents: cents,
        referenceIndexWithinOctave: 0,
        referenceFrequency: referenceFrequency,
        frequencyMin: frequencyMin,
        frequencyMax: frequencyMax,
      );

      // Check reference and octave doubles/halves
      expect(frequencies[0], closeTo(referenceFrequency, 1e-5));
      expect(frequencies[12], closeTo(2 * referenceFrequency, 1e-4));
      expect(frequencies[-12], closeTo(referenceFrequency / 2, 1e-4));

      // Frequency boundary constraints
      expect(
        frequencies[frequencies.indexStart],
        greaterThanOrEqualTo(frequencyMin),
      );
      expect(
        frequencies[frequencies.indexEnd - 1],
        lessThanOrEqualTo(frequencyMax),
      );

      // Step check: each step must be strictly 100 cents
      for (int i = frequencies.indexStart + 1; i < frequencies.indexEnd; i++) {
        final prev = frequencies[i - 1];
        final curr = frequencies[i];
        final stepExpected = TuningMath.centsToFrequency(100.0, prev);
        expect(curr, closeTo(stepExpected, 1e-3));
      }

      // Discrete closest frequency search
      expect(
        frequencies.getClosestFrequencyIndex(referenceFrequency),
        equals(0),
      );
      expect(
        frequencies.getClosestFrequencyIndex(frequencyMin),
        equals(frequencies.indexStart),
      );
      expect(
        frequencies.getClosestFrequencyIndex(frequencyMax),
        equals(frequencies.indexEnd - 1),
      );
      expect(
        frequencies.getClosestFrequencyIndex(2 * referenceFrequency),
        equals(12),
      );

      // Continuous frequency index as float
      expect(
        frequencies.getFrequencyIndex(referenceFrequency),
        closeTo(0.0, 1e-5),
      );
      expect(frequencies.getFrequencyIndex(frequencies[1]), closeTo(1.0, 1e-5));
      expect(
        frequencies.getFrequencyIndex(frequencies[-1]),
        closeTo(-1.0, 1e-5),
      );

      // Fractional logarithmic offsets (30 cents -> 0.3, 70 cents -> 0.7)
      final freq03 = TuningMath.centsToFrequency(30.0, referenceFrequency);
      expect(frequencies.getFrequencyIndex(freq03), closeTo(0.3, 1e-4));

      final freq07 = TuningMath.centsToFrequency(70.0, referenceFrequency);
      expect(frequencies.getFrequencyIndex(freq07), closeTo(0.7, 1e-4));

      // Continuous logarithmic extrapolation outside bounds
      final maxFreq = frequencies[frequencies.indexEnd - 1];
      final freqBeyondMax = TuningMath.centsToFrequency(500.0, maxFreq);
      expect(
        frequencies.getFrequencyIndex(freqBeyondMax),
        closeTo(frequencies.indexEnd - 1 + 5.0, 1e-3),
      );

      final minFreq = frequencies[frequencies.indexStart];
      final freqBelowMin = TuningMath.centsToFrequency(-500.0, minFreq);
      expect(
        frequencies.getFrequencyIndex(freqBelowMin),
        closeTo(frequencies.indexStart - 5.0, 1e-3),
      );
    });

    test('Scale handles reference pitch placed outside min/max range', () {
      final cents = List<double>.generate(13, (i) => i * 100.0);
      const referenceFrequency = 440.0;
      const frequencyMin = 500.0;
      const frequencyMax = 16000.0;

      final frequencies = MusicalScaleFrequencies.create(
        cents: cents,
        referenceIndexWithinOctave: 0,
        referenceFrequency: referenceFrequency,
        frequencyMin: frequencyMin,
        frequencyMax: frequencyMax,
      );

      expect(frequencies.indexStart, greaterThan(0));
      expect(
        frequencies[frequencies.indexStart],
        greaterThanOrEqualTo(frequencyMin),
      );
    });
  });

  group('MusicalNote MIDI Conversion Tests', () {
    test('Standard note to MIDI mappings', () {
      const a4 = MusicalNote(base: BaseNote.a, octave: 4);
      expect(a4.midiNumber, equals(69));

      const c4 = MusicalNote(base: BaseNote.c, octave: 4);
      expect(c4.midiNumber, equals(60));

      const c0 = MusicalNote(base: BaseNote.c, octave: 0);
      expect(c0.midiNumber, equals(12));

      const a0 = MusicalNote(base: BaseNote.a, octave: 0);
      expect(a0.midiNumber, equals(21));

      const c8 = MusicalNote(base: BaseNote.c, octave: 8);
      expect(c8.midiNumber, equals(108));
    });

    test(
      'MIDI to MusicalNote factory produces accurate names and accidentals',
      () {
        final a4 = MusicalNote.fromMidiNumber(69);
        expect(a4.base, equals(BaseNote.a));
        expect(a4.octave, equals(4));
        expect(a4.modifier, equals(NoteModifier.none));

        final cSharp4 = MusicalNote.fromMidiNumber(61, preferSharp: true);
        expect(cSharp4.base, equals(BaseNote.c));
        expect(cSharp4.modifier, equals(NoteModifier.sharp));
        expect(cSharp4.name, equals('C♯4'));
        expect(cSharp4.enharmonicBase, equals(BaseNote.d));
        expect(cSharp4.enharmonicModifier, equals(NoteModifier.flat));

        final dFlat4 = MusicalNote.fromMidiNumber(61, preferSharp: false);
        expect(dFlat4.base, equals(BaseNote.d));
        expect(dFlat4.modifier, equals(NoteModifier.flat));
        expect(dFlat4.name, equals('D♭4'));
        expect(cSharp4.matches(dFlat4), isTrue);
      },
    );
  });

  group('FrequencyToNoteConverter Core Functionality Tests', () {
    final converter = FrequencyToNoteConverter(
      referenceFrequency: 440.0,
      toleranceInCents: 3.0,
    );

    test('A440 concert pitch exact mapping', () {
      expect(converter.frequencyToMidi(440.0), closeTo(69.0, 1e-9));
      expect(converter.midiToFrequency(69.0), closeTo(440.0, 1e-9));

      final note = converter.frequencyToNote(440.0);
      expect(note.name, equals('A4'));
      expect(converter.noteToFrequency(note), closeTo(440.0, 1e-9));
    });

    test('Open guitar strings detection parity', () {
      // E2: ~82.41 Hz (MIDI 40)
      final e2Note = converter.frequencyToNote(82.41);
      expect(e2Note.name, equals('E2'));
      expect(converter.noteToFrequency(e2Note), closeTo(82.4069, 1e-2));

      // A2: 110.0 Hz (MIDI 45)
      final a2Note = converter.frequencyToNote(110.0);
      expect(a2Note.name, equals('A2'));

      // D3: ~146.83 Hz (MIDI 50)
      final d3Note = converter.frequencyToNote(146.83);
      expect(d3Note.name, equals('D3'));

      // G3: ~196.00 Hz (MIDI 55)
      final g3Note = converter.frequencyToNote(196.00);
      expect(g3Note.name, equals('G3'));

      // B3: ~246.94 Hz (MIDI 59)
      final b3Note = converter.frequencyToNote(246.94);
      expect(b3Note.name, equals('B3'));

      // E4: ~329.63 Hz (MIDI 64)
      final e4Note = converter.frequencyToNote(329.63);
      expect(e4Note.name, equals('E4'));
    });

    test('Adjustable A4 reference pitch (415 Hz Baroque, 442 Hz Symphony)', () {
      final baroqueConverter = FrequencyToNoteConverter(
        referenceFrequency: 415.0,
      );
      expect(
        baroqueConverter.noteToFrequency(
          const MusicalNote(base: BaseNote.a, octave: 4),
        ),
        closeTo(415.0, 1e-5),
      );
      expect(baroqueConverter.frequencyToNote(415.0).name, equals('A4'));

      final orchestraConverter = FrequencyToNoteConverter(
        referenceFrequency: 442.0,
      );
      expect(
        orchestraConverter.noteToFrequency(
          const MusicalNote(base: BaseNote.a, octave: 4),
        ),
        closeTo(442.0, 1e-5),
      );
      expect(orchestraConverter.frequencyToNote(442.0).name, equals('A4'));
    });

    test('Cent deviation and tuning state evaluation', () {
      expect(converter.determineTuningState(0.0), equals(TuningState.inTune));
      expect(converter.determineTuningState(2.9), equals(TuningState.inTune));
      expect(converter.determineTuningState(-2.9), equals(TuningState.inTune));

      expect(converter.determineTuningState(3.1), equals(TuningState.tooHigh));
      expect(converter.determineTuningState(-3.1), equals(TuningState.tooLow));

      expect(
        converter.determineTuningState(double.nan),
        equals(TuningState.unknown),
      );
    });

    test('Hysteresis stabilization prevents jitter at pitch borders', () {
      // Middle C4 is MIDI 60 (261.6256 Hz). C#4 is MIDI 61 (277.1826 Hz).
      // Exact midpoint is 269.29 Hz (+50 cents from C4).
      const c4 = MusicalNote(base: BaseNote.c, octave: 4);

      // 1. Without previousTarget, 270.0 Hz (+55 cents) selects C#4
      final unbiasedTarget = converter.detectTarget(270.0);
      expect(unbiasedTarget.note.name, equals('C♯4'));

      // 2. With previousTarget set to C4, 270.0 Hz (+55 cents) is held at C4 due to 0.6 hysteresis
      final stabilizedTarget = converter.detectTarget(
        270.0,
        previousTarget: c4,
      );
      expect(stabilizedTarget.note.name, equals('C4'));

      // 3. When frequency moves past the hysteresis barrier (e.g. 273.5 Hz, ~+77 cents), it unlocks to C#4
      final releasedTarget = converter.detectTarget(273.5, previousTarget: c4);
      expect(releasedTarget.note.name, equals('C♯4'));
    });

    test('Comprehensive evaluatePitch returns integrated PitchAssessment', () {
      final assessment = converter.evaluatePitch(440.5);
      expect(assessment.target.note.name, equals('A4'));
      expect(assessment.centsDeviation, closeTo(1.96, 0.05));
      expect(assessment.tuningState, equals(TuningState.inTune));
      expect(assessment.isInTune, isTrue);

      final flatAssessment = converter.evaluatePitch(435.0);
      expect(flatAssessment.target.note.name, equals('A4'));
      expect(flatAssessment.centsDeviation, lessThan(-3.0));
      expect(flatAssessment.tuningState, equals(TuningState.tooLow));
      expect(flatAssessment.isInTune, isFalse);

      final silentAssessment = converter.evaluatePitch(0.0);
      expect(silentAssessment.tuningState, equals(TuningState.unknown));
    });
  });
}
