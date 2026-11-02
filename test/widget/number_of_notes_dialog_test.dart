import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/ui/temperaments/number_of_notes_dialog.dart';

void main() {
  group('NumberOfNotesDialog Widget Tests', () {
    testWidgets('populates initial notes and submits valid count', (
      tester,
    ) async {
      int? submittedNotes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: ctx,
                    builder: (_) => NumberOfNotesDialog(
                      initialNumberOfNotes: 19,
                      onDone: (n) => submittedNotes = n,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Number of Notes'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);

      // Change to 31
      await tester.enterText(find.byType(TextFormField), '31');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(submittedNotes, 31);
    });

    testWidgets('rejects out of range note count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: ctx,
                    builder: (_) => NumberOfNotesDialog(
                      initialNumberOfNotes: 12,
                      onDone: (_) {},
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '1');
      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(find.text('Must be between 2 and 200'), findsOneWidget);
    });
  });
}
