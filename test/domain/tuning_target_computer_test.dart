import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/domain/musical_scale/musical_scale.dart';
import 'package:tuner_flutter/domain/tuning/tuning_target_computer.dart';

void main() {
  group('TuningTargetComputer Tests', () {
    final scale = MusicalScale.defaultEdo12();

    test('Zero or silent frequency returns reference note A4', () {
      final computer = TuningTargetComputer(scale: scale);
      final target = computer.computeTarget(frequency: 0.0);
      expect(target.note.base, BaseNote.a);
      expect(target.note.octave, 4);
      expect(target.frequency, closeTo(440.0, 1e-4));
    });

    test(
      'Chromatic frequency 440 Hz evaluates to inTune with 0 cents deviation',
      () {
        final computer = TuningTargetComputer(
          scale: scale,
          inTuneToleranceCents: 5.0,
        );
        final eval = computer.evaluate(frequency: 440.0);
        expect(eval.target.note.base, BaseNote.a);
        expect(eval.target.note.octave, 4);
        expect(eval.deviationCents, closeTo(0.0, 1e-3));
        expect(eval.state, TuningState.inTune);
      },
    );

    test('Sharp pitch (442 Hz) evaluates to tooHigh', () {
      final computer = TuningTargetComputer(
        scale: scale,
        inTuneToleranceCents: 3.0,
      );
      final eval = computer.evaluate(frequency: 442.0);
      expect(eval.target.note.name, 'A4');
      expect(eval.deviationCents, greaterThan(3.0));
      expect(eval.state, TuningState.tooHigh);
    });

    test('Flat pitch (438 Hz) evaluates to tooLow', () {
      final computer = TuningTargetComputer(
        scale: scale,
        inTuneToleranceCents: 3.0,
      );
      final eval = computer.evaluate(frequency: 438.0);
      expect(eval.target.note.name, 'A4');
      expect(eval.deviationCents, lessThan(-3.0));
      expect(eval.state, TuningState.tooLow);
    });

    test('Instrument string lock detects closest string note', () {
      const guitarStrings = [
        MusicalNote(base: BaseNote.e, octave: 2), // 82.41 Hz
        MusicalNote(base: BaseNote.a, octave: 2), // 110.0 Hz
        MusicalNote(base: BaseNote.d, octave: 3), // 146.83 Hz
        MusicalNote(base: BaseNote.g, octave: 3), // 196.0 Hz
        MusicalNote(base: BaseNote.b, octave: 3), // 246.94 Hz
        MusicalNote(base: BaseNote.e, octave: 4), // 329.63 Hz
      ];

      final computer = TuningTargetComputer(
        scale: scale,
        instrumentStrings: guitarStrings,
      );

      final evalA2 = computer.evaluate(frequency: 109.5);
      expect(evalA2.target.note.base, BaseNote.a);
      expect(evalA2.target.note.octave, 2);
      expect(evalA2.target.isPartOfInstrument, isTrue);

      final evalE4 = computer.evaluate(frequency: 331.0);
      expect(evalE4.target.note.base, BaseNote.e);
      expect(evalE4.target.note.octave, 4);
      expect(evalE4.target.isPartOfInstrument, isTrue);
    });
  });
}
