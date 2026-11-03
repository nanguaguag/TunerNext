// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/dsp/pipeline/tuner_dsp_pipeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DSP Algorithm Parameters in AppPreferences', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads correct default values for DSP and Staff parameters', () {
      final prefs = AppPreferences();

      expect(prefs.mpmCutoffClarity, 0.45);
      expect(prefs.mpmPeakThresholdRatio, 0.85);
      expect(prefs.twmMaxHarmonics, 10);
      expect(prefs.twmInharmonicity, 0.0);
      expect(prefs.twmMaxMismatchError, 0.40);
      expect(prefs.showStaffTargetNote, isTrue);
      expect(prefs.showStaffCurrentNote, isTrue);
    });

    test(
      'Setters update values, notify listeners, and persist to SharedPreferences',
      () async {
        final prefs = AppPreferences();
        var notificationCount = 0;
        prefs.addListener(() => notificationCount++);

        prefs.setMpmCutoffClarity(0.60);
        expect(prefs.mpmCutoffClarity, 0.60);
        expect(notificationCount, 1);

        prefs.setMpmPeakThresholdRatio(0.90);
        expect(prefs.mpmPeakThresholdRatio, 0.90);
        expect(notificationCount, 2);

        prefs.setTwmMaxHarmonics(16);
        expect(prefs.twmMaxHarmonics, 16);
        expect(notificationCount, 3);

        prefs.setTwmInharmonicity(0.002);
        expect(prefs.twmInharmonicity, 0.002);
        expect(notificationCount, 4);

        prefs.setTwmMaxMismatchError(0.25);
        expect(prefs.twmMaxMismatchError, 0.25);
        expect(notificationCount, 5);

        prefs.setShowStaffTargetNote(false);
        expect(prefs.showStaffTargetNote, isFalse);
        expect(notificationCount, 6);

        prefs.setShowStaffCurrentNote(false);
        expect(prefs.showStaffCurrentNote, isFalse);
        expect(notificationCount, 7);

        // Verify persistence by loading into fresh instance
        await prefs.save();
        final freshPrefs = AppPreferences();
        await freshPrefs.load();

        expect(freshPrefs.mpmCutoffClarity, 0.60);
        expect(freshPrefs.mpmPeakThresholdRatio, 0.90);
        expect(freshPrefs.twmMaxHarmonics, 16);
        expect(freshPrefs.twmInharmonicity, 0.002);
        expect(freshPrefs.twmMaxMismatchError, 0.25);
        expect(freshPrefs.showStaffTargetNote, isFalse);
        expect(freshPrefs.showStaffCurrentNote, isFalse);
      },
    );
  });

  group('TunerDspPipeline Parameter Hot-Reconfiguration', () {
    test('Configures MPM parameters and updates detector', () {
      final pipeline = TunerDspPipeline(
        mpmCutoffClarity: 0.50,
        mpmPeakThresholdRatio: 0.80,
      );

      expect(pipeline.mpmDetector.cutoffClarity, 0.50);
      expect(pipeline.mpmDetector.peakThresholdRatio, 0.80);

      pipeline.setMpmParameters(cutoffClarity: 0.70, peakThresholdRatio: 0.95);
      expect(pipeline.mpmDetector.cutoffClarity, 0.70);
      expect(pipeline.mpmDetector.peakThresholdRatio, 0.95);
    });

    test('Configures TWM parameters and updates detector', () {
      final pipeline = TunerDspPipeline(
        twmMaxHarmonics: 8,
        twmInharmonicity: 0.001,
        twmMaxMismatchError: 0.35,
      );

      expect(pipeline.twmDetector.maxHarmonics, 8);
      expect(pipeline.twmDetector.inharmonicity, 0.001);
      expect(pipeline.twmDetector.maxMismatchError, 0.35);

      pipeline.setTwmParameters(
        maxHarmonics: 15,
        inharmonicity: 0.003,
        maxMismatchError: 0.50,
      );
      expect(pipeline.twmDetector.maxHarmonics, 15);
      expect(pipeline.twmDetector.inharmonicity, 0.003);
      expect(pipeline.twmDetector.maxMismatchError, 0.50);
    });

    test('Configures filter switches at runtime', () {
      final pipeline = TunerDspPipeline(
        useMedianFilter: true,
        useOctaveJumpGate: true,
        useSmoother: true,
      );

      expect(pipeline.useMedianFilter, isTrue);
      expect(pipeline.useOctaveJumpGate, isTrue);
      expect(pipeline.useSmoother, isTrue);

      pipeline.setFilterSwitches(
        useMedianFilter: false,
        useOctaveJumpGate: false,
        useSmoother: false,
      );

      expect(pipeline.useMedianFilter, isFalse);
      expect(pipeline.useOctaveJumpGate, isFalse);
      expect(pipeline.useSmoother, isFalse);
    });
  });
}
