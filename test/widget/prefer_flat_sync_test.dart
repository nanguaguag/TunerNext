// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/state/tuner_controller.dart';
import 'package:tuner_flutter/ui/common/notation_icons.dart';
import 'package:tuner_flutter/ui/screens/instrument_tuner_screen.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Prefer Flat (# / b) Bidirectional Synchronization Tests', () {
    testWidgets(
      'Tapping #/b in InstrumentTunerScreen triggers onTogglePreferFlat',
      (tester) async {
        var toggleCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: InstrumentTunerScreen(
              initialInstrument: PredefinedInstruments.guitarStandard,
              initialPreferFlat: false,
              onTogglePreferFlat: () {
                toggleCalled = true;
              },
            ),
          ),
        );

        // Find the PreferFlatIconWidget in QuickSettingsBar
        final sharpFlatFinder = find.byType(PreferFlatIconWidget);
        expect(sharpFlatFinder, findsOneWidget);

        await tester.tap(sharpFlatFinder);
        await tester.pumpAndSettle();

        expect(toggleCalled, isTrue);
      },
    );

    testWidgets(
      'Toggling preferFlat in PreferencesScreen updates AppPreferences',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final prefs = AppPreferences();
        expect(prefs.preferFlat, isFalse);

        await tester.pumpWidget(
          MaterialApp(home: PreferencesScreen(preferences: prefs)),
        );
        await tester.pumpAndSettle();

        // Find the Prefer Flat switch
        final switchFinder = find.widgetWithText(
          SwitchListTile,
          'Prefer Flat (♭)',
        );
        expect(switchFinder, findsOneWidget);

        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(prefs.preferFlat, isTrue);
      },
    );

    testWidgets(
      'TunerController togglePreferFlat coordinates state and preferences',
      (tester) async {
        final prefs = AppPreferences();
        final container = ProviderContainer();
        final notifier = container.read(tunerControllerProvider.notifier);
        notifier.initializeWithPreferences(prefs, startAudio: false);

        expect(container.read(tunerControllerProvider).preferFlat, isFalse);
        expect(prefs.preferFlat, isFalse);

        notifier.togglePreferFlat();

        expect(container.read(tunerControllerProvider).preferFlat, isTrue);
        expect(prefs.preferFlat, isTrue);

        notifier.togglePreferFlat();

        expect(container.read(tunerControllerProvider).preferFlat, isFalse);
        expect(prefs.preferFlat, isFalse);
      },
    );
  });
}
