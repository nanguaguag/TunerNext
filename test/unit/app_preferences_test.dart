import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferences Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with standard defaults', () {
      final pref = AppPreferences();
      expect(pref.themeMode, ThemeMode.system);
      expect(pref.keepScreenOn, isTrue);
      expect(pref.referenceFrequency, 440.0);
      expect(pref.temperamentName, 'EDO 12');
      expect(pref.toleranceInCents, 10);
      expect(pref.preferFlat, isFalse);
      expect(pref.pitchAlgorithm, PitchAlgorithm.mpm);
      expect(pref.acousticWeighting, AcousticWeightingMode.none);
      expect(pref.windowSize, 2048);
      expect(pref.windowSizeExponent, 11);
      expect(pref.windowingFunction, WindowingFunction.hanning);
      expect(pref.scientificMode, isFalse);
    });

    test('Save and load roundtrip', () async {
      final pref = AppPreferences();
      pref.toleranceInCents = 15;
      pref.pitchAlgorithm = PitchAlgorithm.twm;
      pref.scientificMode = true;
      pref.themeMode = ThemeMode.dark;
      await pref.save();

      final reloaded = AppPreferences();
      await reloaded.load();

      expect(reloaded.toleranceInCents, 15);
      expect(reloaded.pitchAlgorithm, PitchAlgorithm.twm);
      expect(reloaded.scientificMode, isTrue);
      expect(reloaded.themeMode, ThemeMode.dark);
    });

    test('resetToDefaults restores default values', () async {
      final pref = AppPreferences();
      pref.toleranceInCents = 20;
      pref.scientificMode = true;
      pref.pitchAlgorithm = PitchAlgorithm.classic;

      await pref.resetToDefaults();

      expect(pref.toleranceInCents, 10);
      expect(pref.scientificMode, isFalse);
      expect(pref.pitchAlgorithm, PitchAlgorithm.mpm);
    });
  });
}
