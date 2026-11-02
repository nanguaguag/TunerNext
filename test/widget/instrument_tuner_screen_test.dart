import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/ui/common/quick_settings_bar.dart';
import 'package:tuner_flutter/ui/instruments/instrument_button.dart';
import 'package:tuner_flutter/ui/instruments/strings.dart';
import 'package:tuner_flutter/ui/screens/instrument_tuner_screen.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history.dart';

void main() {
  group('InstrumentTunerScreen Widget', () {
    testWidgets(
      'renders all major components: button, strings, plot, and quickbar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: const InstrumentTunerScreen(
              initialInstrument: PredefinedInstruments.guitarStandard,
            ),
          ),
        );

        // Verify InstrumentButton
        expect(find.byType(InstrumentButton), findsOneWidget);
        expect(find.text('6-string guitar'), findsOneWidget);

        // Verify Strings fretboard
        expect(find.byType(Strings), findsOneWidget);

        // Verify PitchHistory canvas
        expect(find.byType(PitchHistory), findsOneWidget);

        // Verify QuickSettingsBar
        expect(find.byType(QuickSettingsBar), findsOneWidget);
        expect(find.text('A4'), findsOneWidget);
        expect(find.text('440.0 Hz'), findsOneWidget);
      },
    );

    testWidgets('tap on string locks target note', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: const InstrumentTunerScreen(
            initialInstrument: PredefinedInstruments.guitarStandard,
          ),
        ),
      );

      // Tap on D3 string
      await tester.tap(find.text('D3'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('opening reference note dialog from quick bar works', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: const InstrumentTunerScreen(
            initialInstrument: PredefinedInstruments.guitarStandard,
          ),
        ),
      );

      // Tap on A4 cell in bottom bar
      await tester.tap(find.text('A4'));
      await tester.pumpAndSettle();

      expect(find.text('Reference Pitch'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Reference Pitch'), findsNothing);
    });
  });
}
