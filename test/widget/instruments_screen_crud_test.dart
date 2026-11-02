import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/instruments/instrument.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/instruments/instruments_screen.dart';

void main() {
  testWidgets(
    'InstrumentsScreen supports copying predefined instrument and editing/deleting custom instruments',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Instrument? addedInst;
      Instrument? deletedInst;

      final initialCustom = [
        const Instrument(
          name: 'My Custom Guitar',
          strings: [
            MusicalNote(base: BaseNote.e, octave: 2),
            MusicalNote(base: BaseNote.a, octave: 2),
          ],
          stableId: 8888,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: InstrumentsScreen(
            selectedInstrument: PredefinedInstruments.guitarStandard,
            customInstruments: initialCustom,
            onSelectInstrument: (_) {},
            onAddCustomInstrument: (inst) => addedInst = inst,
            onDeleteCustomInstrument: (inst) => deletedInst = inst,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Custom Guitar'), findsOneWidget);
      expect(find.text('6-string guitar'), findsOneWidget);

      // 1. Delete button on custom instrument
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsOneWidget);

      await tester.tap(deleteButtons);
      await tester.pumpAndSettle();

      expect(find.text('Delete Instrument'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete "My Custom Guitar"?'),
        findsOneWidget,
      );

      // Confirm deletion
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(deletedInst?.name, 'My Custom Guitar');
      expect(find.text('My Custom Guitar'), findsNothing);

      // 2. Predefined instruments have "Copy to customize" button
      final copyButtons = find.byIcon(Icons.copy_outlined);
      expect(copyButtons, findsWidgets);

      // Tap copy on first predefined instrument
      await tester.tap(copyButtons.first);
      await tester.pumpAndSettle();

      // Opens InstrumentEditorScreen with prefilled name
      expect(find.text('Edit Instrument'), findsOneWidget);
      expect(find.text('6-string guitar (Custom)'), findsOneWidget);

      // Tap Save button in AppBar
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(addedInst?.name, '6-string guitar (Custom)');
    },
  );
}
