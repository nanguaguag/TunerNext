import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/instruments/instrument.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/ui/instruments/instrument_editor_screen.dart';

void main() {
  group('InstrumentEditorScreen Widget', () {
    testWidgets(
      'renders initial instrument data and allows editing name and strings',
      (tester) async {
        Instrument? savedResult;

        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: InstrumentEditorScreen(
              initialInstrument: PredefinedInstruments.guitarStandard,
              onSaveInstrument: (inst) => savedResult = inst,
            ),
          ),
        );

        expect(find.text('Edit Instrument'), findsOneWidget);
        expect(find.text('6-string guitar'), findsOneWidget);

        // Add a string
        await tester.tap(find.text('Add String'));
        await tester.pumpAndSettle();

        expect(find.text('Strings Preview (7 Strings)'), findsOneWidget);

        // Delete string
        await tester.tap(find.text('Delete String'));
        await tester.pumpAndSettle();

        expect(find.text('Strings Preview (6 Strings)'), findsOneWidget);

        // Change name and save
        await tester.enterText(find.byType(TextField).first, 'Custom Guitar');
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(savedResult, isNotNull);
        expect(savedResult?.name, equals('Custom Guitar'));
      },
    );
  });
}
