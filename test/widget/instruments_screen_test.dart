import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/instruments/instrument.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/ui/instruments/instruments_screen.dart';

void main() {
  group('InstrumentsScreen Widget', () {
    testWidgets('renders predefined instruments and searches by keyword', (
      tester,
    ) async {
      Instrument? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: InstrumentsScreen(
            selectedInstrument: PredefinedInstruments.guitarStandard,
            onSelectInstrument: (inst) => selected = inst,
          ),
        ),
      );

      expect(find.text('Instruments'), findsOneWidget);
      expect(find.text('6-string guitar'), findsOneWidget);
      expect(find.text('Chromatic'), findsOneWidget);

      // Search for "Violin"
      await tester.enterText(find.byType(TextField), 'Violin');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Violin'), findsOneWidget);
      expect(find.widgetWithText(ListTile, '6-string guitar'), findsNothing);

      // Select Violin
      await tester.tap(find.widgetWithText(ListTile, 'Violin'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected?.name, equals('Violin'));
    });
  });
}
