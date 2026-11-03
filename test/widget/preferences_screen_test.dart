import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/ui/preferences/preference_dialogs.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';

void main() {
  group('PreferencesScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders all preference categories and toggles switches', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pref = AppPreferences();
      var changedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: PreferencesScreen(
            preferences: pref,
            onPreferencesChanged: () => changedCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check section headers
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('BASIC'), findsOneWidget);
      expect(find.text('ADVANCED ACOUSTIC DSP'), findsOneWidget);
      expect(find.text('EXPERT / SCIENTIFIC MODE'), findsOneWidget);
      expect(find.text('OTHERS'), findsOneWidget);

      // Verify Keep Screen On switch
      final keepScreenSwitch = find.widgetWithText(
        SwitchListTile,
        'Keep Screen On',
      );
      expect(keepScreenSwitch, findsOneWidget);
      await tester.tap(keepScreenSwitch);
      await tester.pumpAndSettle();
      expect(pref.keepScreenOn, isFalse);

      // Verify Pitch Algorithm Dialog
      final pitchAlgoItem = find.text('Pitch Algorithm');
      expect(pitchAlgoItem, findsOneWidget);
      await tester.tap(pitchAlgoItem);
      await tester.pumpAndSettle();

      expect(find.byType(PitchAlgorithmDialog), findsOneWidget);
      expect(find.text('Two-Way Mismatch (TWM)'), findsOneWidget);
      await tester.tap(find.text('Two-Way Mismatch (TWM)'));
      await tester.pumpAndSettle();

      expect(pref.pitchAlgorithm, PitchAlgorithm.twm);

      // Verify About Dialog
      final aboutItem = find.text('About');
      expect(aboutItem, findsOneWidget);
      await tester.tap(aboutItem);
      await tester.pumpAndSettle();

      expect(find.byType(AboutTunerDialog), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });
  });
}
