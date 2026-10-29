// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/l10n/app_localizations.dart';
import 'package:tuner_flutter/state/preferences_state.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';
import 'package:tuner_flutter/ui/widgets/settings_dialogs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createPreferencesScreen({
    SharedPreferences? prefs,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        theme: TunerTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PreferencesScreen(),
      ),
    );
  }

  group('PreferencesScreen Widget Tests', () {
    testWidgets('Renders all four M3 sections with correct titles', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('BASIC'), findsOneWidget);
      expect(find.text('ADVANCED ACOUSTIC DSP'), findsOneWidget);
      expect(find.text('EXPERT'), findsOneWidget);
      expect(find.text('OTHERS'), findsOneWidget);
    });

    testWidgets('Appearance dialog opens and allows switching theme mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      // Tap on Appearance
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.byType(AppearanceDialog), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(find.byType(AppearanceDialog), findsNothing);
      expect(prefs.getString('appearance_mode'), 'dark');
    });

    testWidgets('Language dialog opens and displays supported languages', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      // Tap on Language
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageDialog), findsOneWidget);
      expect(find.text('Simplified Chinese'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);

      // Select German
      await tester.tap(find.text('German'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageDialog), findsNothing);
      expect(prefs.getString('app_locale'), 'de');
    });

    testWidgets('Pitch algorithm dialog opens and selects MPM', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pitch Detection Engine'));
      await tester.pumpAndSettle();

      expect(find.byType(PitchAlgorithmDialog), findsOneWidget);
      expect(find.text(PitchAlgorithm.mpm.displayName), findsOneWidget);

      // Select MPM
      await tester.tap(find.text(PitchAlgorithm.mpm.displayName));
      await tester.pumpAndSettle();

      expect(find.byType(PitchAlgorithmDialog), findsNothing);
      expect(prefs.getString('pitch_algorithm'), 'mpm');
    });

    testWidgets('Acoustic weighting dialog opens and selects C-weighting', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acoustic Weighting'));
      await tester.pumpAndSettle();

      expect(find.byType(AcousticWeightingDialog), findsOneWidget);

      await tester.tap(find.text(AcousticWeightingMode.cWeighting.displayName));
      await tester.pumpAndSettle();

      expect(find.byType(AcousticWeightingDialog), findsNothing);
      expect(prefs.getString('acoustic_weighting_mode_enum'), 'cWeighting');
    });

    testWidgets('Keep screen on switch toggles wakelock state', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      final switchFinder = find.widgetWithText(
        SwitchListTile,
        'Keep screen on',
      );
      expect(switchFinder, findsOneWidget);

      // Initially false
      expect(tester.widget<SwitchListTile>(switchFinder).value, false);

      // Toggle switch
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(switchFinder).value, true);
      expect(prefs.getBool('screenon'), true);
    });

    testWidgets('Reset all settings confirmation dialog restores defaults', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({
        'screenon': true,
        'reference_frequency': 432.0,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Reset all settings'), findsOneWidget);
      await tester.tap(find.text('Reset all settings'));
      await tester.pumpAndSettle();

      expect(find.byType(ResetSettingsDialog), findsOneWidget);

      // Confirm reset
      await tester.tap(find.text('Reset All'));
      await tester.pumpAndSettle();

      expect(find.byType(ResetSettingsDialog), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('All settings restored to factory defaults'),
        findsOneWidget,
      );
      expect(prefs.getBool('screenon'), isNull);
    });

    testWidgets('About dialog presents GPL-3.0 and Gonville Font attribution', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createPreferencesScreen(prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutTunerDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AboutTunerDialog),
          matching: find.textContaining('GPLv3'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AboutTunerDialog),
          matching: find.textContaining('Simon Tatham'),
        ),
        findsWidgets,
      );

      // Dismiss dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutTunerDialog), findsNothing);
    });
  });
}
