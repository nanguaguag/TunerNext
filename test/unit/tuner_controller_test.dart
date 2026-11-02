import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/domain/instruments/instrument.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/domain/stretch_tuning/predefined_stretch_tunings.dart';
import 'package:tuner_flutter/domain/temperaments/predefined_temperament.dart';
import 'package:tuner_flutter/state/tuner_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TunerController & TunerAppState Tests', () {
    test('initial state has standard defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(tunerControllerProvider);

      expect(state.currentInstrument.name, '6-string guitar');
      expect(state.currentTemperament.name, '12-Tone Equal Temperament');
      expect(state.currentStretchTuning.name, 'No Stretch Tuning');
      expect(state.referenceFrequency, 440.0);
      expect(
        state.referenceNote,
        const MusicalNote(base: BaseNote.a, octave: 4),
      );
      expect(state.preferFlat, false);
      expect(state.preferences.scientificMode, false);
    });

    test('toggling scientific mode and preferFlat', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tunerControllerProvider.notifier);

      notifier.setScientificMode(true);
      expect(
        container.read(tunerControllerProvider).preferences.scientificMode,
        true,
      );

      notifier.togglePreferFlat();
      expect(container.read(tunerControllerProvider).preferFlat, true);

      notifier.setThemeMode(ThemeMode.dark);
      expect(
        container.read(tunerControllerProvider).preferences.themeMode,
        ThemeMode.dark,
      );
    });

    test('updating reference frequency and reference note', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tunerControllerProvider.notifier);

      notifier.setReferenceFrequency(442.0);
      expect(container.read(tunerControllerProvider).referenceFrequency, 442.0);

      notifier.setReferenceNote(const MusicalNote(base: BaseNote.c, octave: 4));
      expect(
        container.read(tunerControllerProvider).referenceNote,
        const MusicalNote(base: BaseNote.c, octave: 4),
      );
    });

    test('custom instruments addition, update and deletion', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tunerControllerProvider.notifier);

      const customInst = Instrument(
        name: 'Custom Banjo',
        strings: [
          MusicalNote(base: BaseNote.g, octave: 4),
          MusicalNote(base: BaseNote.d, octave: 4),
        ],
        stableId: 9999,
      );

      notifier.addCustomInstrument(customInst);
      var state = container.read(tunerControllerProvider);
      expect(state.customInstruments.length, 1);
      expect(state.currentInstrument.name, 'Custom Banjo');

      const updatedInst = Instrument(
        name: 'Custom Banjo 5-string',
        strings: [
          MusicalNote(base: BaseNote.g, octave: 4),
          MusicalNote(base: BaseNote.c, octave: 4),
        ],
        stableId: 9999,
      );

      notifier.updateCustomInstrument(updatedInst);
      state = container.read(tunerControllerProvider);
      expect(state.currentInstrument.name, 'Custom Banjo 5-string');

      notifier.deleteCustomInstrument(updatedInst);
      state = container.read(tunerControllerProvider);
      expect(state.customInstruments, isEmpty);
    });

    test('feedPitch and acoustics updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tunerControllerProvider.notifier);

      notifier.feedPitch(440.0, TuningState.inTune);
      var state = container.read(tunerControllerProvider);
      expect(state.currentFrequency, 440.0);
      expect(state.tuningState, TuningState.inTune);

      notifier.feedPitch(null);
      state = container.read(tunerControllerProvider);
      expect(state.currentFrequency, isNull);
    });

    test('temperament and stretch tuning selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tunerControllerProvider.notifier);
      final pyth = PredefinedTemperaments.pythagorean();
      final railsback = PredefinedStretchTunings.railsback();

      notifier.setCurrentTemperament(pyth);
      expect(
        container.read(tunerControllerProvider).currentTemperament.name,
        pyth.name,
      );

      notifier.setCurrentStretchTuning(railsback);
      expect(
        container.read(tunerControllerProvider).currentStretchTuning.name,
        railsback.name,
      );
    });
  });
}
