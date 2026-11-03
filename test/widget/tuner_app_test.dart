import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/main.dart';
import 'package:tuner_flutter/ui/common/notation_icons.dart';
import 'package:tuner_flutter/ui/instruments/instruments_screen.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';
import 'package:tuner_flutter/ui/screens/scientific_tuner_screen.dart';
import 'package:tuner_flutter/ui/screens/stretch_tuning_overview_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TunerApp boots into InstrumentTunerScreen by default', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final prefs = AppPreferences();

    await tester.pumpWidget(
      ProviderScope(child: TunerApp(initialPreferences: prefs)),
    );
    await tester.pumpAndSettle();

    // Verify Instrument Tuner Screen is loaded
    expect(find.text('6-string guitar'), findsOneWidget);
    expect(find.text('Tuner'), findsOneWidget);
    expect(
      find.byIcon(Icons.analytics_outlined),
      findsOneWidget,
    ); // Switch to scientific mode button
  });

  testWidgets(
    'TunerApp switches between InstrumentTuner and ScientificTuner via App Bar',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = AppPreferences();

      await tester.pumpWidget(
        ProviderScope(child: TunerApp(initialPreferences: prefs)),
      );
      await tester.pumpAndSettle();

      // 1. Switch to Scientific Mode
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ScientificTunerScreen), findsOneWidget);
      expect(find.text('Scientific Tuner'), findsOneWidget);

      // 2. Switch back to Instrument Tuner
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('6-string guitar'), findsOneWidget);
      expect(find.text('Tuner'), findsOneWidget);
    },
  );

  testWidgets(
    'TunerApp navigates to PreferencesScreen, InstrumentsScreen, and StretchTunings',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = AppPreferences();

      await tester.pumpWidget(
        ProviderScope(child: TunerApp(initialPreferences: prefs)),
      );
      await tester.pumpAndSettle();

      // 1. Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(PreferencesScreen), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Pop back to tuner
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 2. Navigate to Instruments
      await tester.tap(find.text('6-string guitar'));
      await tester.pumpAndSettle();

      expect(find.byType(InstrumentsScreen), findsOneWidget);
      expect(find.text('Instruments'), findsOneWidget);

      // Pop back to tuner
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 3. Navigate to Stretch Tuning overview
      await tester.tap(find.byType(StretchTuningIconWidget));
      await tester.pumpAndSettle();

      expect(find.byType(StretchTuningOverviewScreen), findsOneWidget);
      expect(find.text('Stretch tuning'), findsOneWidget);
    },
  );
}
