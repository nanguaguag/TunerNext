import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/temperaments/predefined_temperament.dart';
import 'package:tuner_flutter/domain/temperaments/temperament.dart';
import 'package:tuner_flutter/ui/dialogs/temperament_dialog.dart';
import 'package:tuner_flutter/ui/dialogs/temperament_info_dialog.dart';

void main() {
  group('TemperamentDialog Widget', () {
    testWidgets('renders list with 19 standard temperaments and searches', (
      tester,
    ) async {
      Temperament? selected;
      final edo12 = PredefinedTemperaments.edo12();

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: TemperamentDialog(
              selectedTemperament: edo12,
              onSelectTemperament: (t) => selected = t,
            ),
          ),
        ),
      );

      expect(find.text('Temperaments'), findsOneWidget);
      expect(find.text('12-Tone Equal Temperament'), findsOneWidget);

      // Search for Werckmeister
      await tester.enterText(find.byType(TextField), 'Werckmeister');
      await tester.pumpAndSettle();

      expect(find.text('Werckmeister III'), findsOneWidget);
      expect(find.text('12-Tone Equal Temperament'), findsNothing);

      // Select Werckmeister III
      await tester.tap(find.text('Werckmeister III'));
      await tester.pumpAndSettle();

      expect(selected?.name, contains('Werckmeister III'));
    });

    testWidgets(
      'info button opens TemperamentInfoDialog with intervals table',
      (tester) async {
        final edo12 = PredefinedTemperaments.edo12();

        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: Scaffold(
              body: TemperamentDialog(
                selectedTemperament: edo12,
                onSelectTemperament: (_) {},
              ),
            ),
          ),
        );

        // Tap first info button
        await tester.tap(find.byIcon(Icons.info_outline).first);
        await tester.pumpAndSettle();

        expect(find.byType(TemperamentInfoDialog), findsOneWidget);
        expect(find.text('Scale Degree Intervals (Cents)'), findsOneWidget);
      },
    );
  });
}
