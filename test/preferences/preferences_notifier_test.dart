// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/domain/preferences/preferences_models.dart';
import 'package:tuner_flutter/state/preferences_state.dart';
import 'package:tuner_flutter/state/tuner_worker_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesNotifier Tests', () {
    test(
      'Initial state loads defaults when SharedPreferences is empty',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final state = container.read(preferencesProvider);
        expect(state.themeMode, AppThemeMode.system);
        expect(state.localeCode, isNull);
        expect(state.screenAlwaysOn, false);
        expect(state.referenceFrequency, 440.0);
        expect(state.toleranceInCents, 5);
        expect(state.pitchAlgorithm, PitchAlgorithm.classic);
        expect(state.acousticWeightingMode, AcousticWeightingMode.aWeighting);
        expect(state.windowSizeExponent, 12); // 4096
        expect(state.windowSize, 4096);
        expect(state.overlapPercent, 75);
        expect(state.octaveJumpGate, true);
        expect(state.medianFilter, true);
      },
    );

    test(
      'Initial state correctly deserializes persisted preferences',
      () async {
        SharedPreferences.setMockInitialValues({
          'appearance_mode': 'dark',
          'app_locale': 'de',
          'screenon': true,
          'reference_frequency': 442.0,
          'tolerance_in_cents': 3,
          'prefer_flat': true,
          'pitch_algorithm': 'mpm',
          'acoustic_weighting_mode_enum': 'cWeighting',
          'window_size_exponent': 13, // 8192
          'overlap': 50,
          'sensitivity': 85,
          'octave_jump_gate': false,
          'median_filter': false,
        });

        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final state = container.read(preferencesProvider);
        expect(state.themeMode, AppThemeMode.dark);
        expect(state.localeCode, 'de');
        expect(state.screenAlwaysOn, true);
        expect(state.referenceFrequency, 442.0);
        expect(state.toleranceInCents, 3);
        expect(state.preferFlat, true);
        expect(state.pitchAlgorithm, PitchAlgorithm.mpm);
        expect(state.acousticWeightingMode, AcousticWeightingMode.cWeighting);
        expect(state.windowSizeExponent, 13);
        expect(state.windowSize, 8192);
        expect(state.overlapPercent, 50);
        expect(state.sensitivity, 85);
        expect(state.octaveJumpGate, false);
        expect(state.medianFilter, false);
      },
    );

    test(
      'update persists changes to SharedPreferences and syncs with DSP config',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(preferencesProvider.notifier);

        notifier.update(
          (s) => s.copyWith(
            referenceFrequency: 432.0,
            toleranceInCents: 2,
            pitchAlgorithm: PitchAlgorithm.hybridJacobsen,
            acousticWeightingMode: AcousticWeightingMode.none,
            overlapPercent: 80,
            screenAlwaysOn: true,
            themeMode: AppThemeMode.light,
            localeCode: () => 'zh',
          ),
        );

        final updatedState = container.read(preferencesProvider);
        expect(updatedState.referenceFrequency, 432.0);
        expect(updatedState.toleranceInCents, 2);
        expect(updatedState.pitchAlgorithm, PitchAlgorithm.hybridJacobsen);
        expect(updatedState.acousticWeightingMode, AcousticWeightingMode.none);
        expect(updatedState.overlapPercent, 80);
        expect(updatedState.screenAlwaysOn, true);
        expect(updatedState.themeMode, AppThemeMode.light);
        expect(updatedState.localeCode, 'zh');

        // Verify persisted to SharedPreferences
        expect(prefs.getDouble('reference_frequency'), 432.0);
        expect(prefs.getInt('tolerance_in_cents'), 2);
        expect(prefs.getString('pitch_algorithm'), 'hybridJacobsen');
        expect(prefs.getString('acoustic_weighting_mode_enum'), 'none');
        expect(prefs.getInt('overlap'), 80);
        expect(prefs.getBool('screenon'), true);
        expect(prefs.getString('appearance_mode'), 'light');
        expect(prefs.getString('app_locale'), 'zh');

        // Verify bi-directional sync with TunerDspConfigProvider
        final dspConfig = container.read(tunerDspConfigProvider);
        expect(dspConfig.referenceFrequency, 432.0);
        expect(dspConfig.inTuneToleranceCents, 2.0);
        expect(dspConfig.pitchAlgorithm, PitchAlgorithm.hybridJacobsen);
        expect(dspConfig.weightingMode, AcousticWeightingMode.none);
        expect(dspConfig.overlap, 0.80);
      },
    );

    test(
      'resetAllSettings restores all defaults and clears persisted storage',
      () async {
        SharedPreferences.setMockInitialValues({
          'reference_frequency': 415.0,
          'tolerance_in_cents': 1,
          'pitch_algorithm': 'twm',
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(preferencesProvider.notifier);
        expect(container.read(preferencesProvider).referenceFrequency, 415.0);

        // Perform factory reset
        notifier.resetAllSettings();

        final resetState = container.read(preferencesProvider);
        expect(resetState.referenceFrequency, 440.0);
        expect(resetState.toleranceInCents, 5);
        expect(resetState.pitchAlgorithm, PitchAlgorithm.classic);
        expect(resetState.themeMode, AppThemeMode.system);
        expect(resetState.screenAlwaysOn, false);

        // Verify SharedPreferences is cleared
        expect(prefs.getKeys().isEmpty, true);

        // Verify DSP config restored
        final dspConfig = container.read(tunerDspConfigProvider);
        expect(dspConfig.referenceFrequency, 440.0);
        expect(dspConfig.inTuneToleranceCents, 5.0);
        expect(dspConfig.pitchAlgorithm, PitchAlgorithm.classic);
      },
    );
  });
}
