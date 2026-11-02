import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/stretch_tuning/stretch_tuning.dart';
import 'package:tuner_flutter/ui/stretchtuning/modify_stretch_tuning_line_dialog.dart';
import 'package:tuner_flutter/ui/stretchtuning/stretch_tuning_table.dart';

void main() {
  group('StretchTuningTable Widget Tests', () {
    final testTuning = StretchTuning(
      name: 'Test Stretch',
      unstretchedFrequencies: [220.0, 440.0, 880.0],
      stretchInCents: [-2.5, 0.0, 4.2],
      keys: [1, 2, 3],
    );

    testWidgets('renders headers and items', (tester) async {
      int? clickedKey;
      int? editKey;
      int? deleteKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 400,
              child: StretchTuningTable(
                stretchTuning: testTuning,
                selectedKey: 2,
                onLineClicked: (k) => clickedKey = k,
                onEditLineClicked: (k) => editKey = k,
                onDeleteLineClicked: (k) => deleteKey = k,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Stretch'), findsOneWidget);
      expect(find.text('440.00 Hz'), findsOneWidget);
      expect(find.text('+0.00 ¢'), findsOneWidget);
      expect(find.text('+4.20 ¢'), findsOneWidget);

      // Tap row
      await tester.tap(find.text('440.00 Hz'));
      expect(clickedKey, 2);

      // Tap edit
      final editButtons = find.byIcon(Icons.edit_outlined);
      expect(editButtons, findsNWidgets(3));
      await tester.tap(editButtons.at(0));
      expect(editKey, 1);

      // Tap delete
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(3));
      await tester.tap(deleteButtons.at(2));
      expect(deleteKey, 3);
    });

    testWidgets('renders empty placeholder when no points', (tester) async {
      final empty = StretchTuning();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: StretchTuningTable(stretchTuning: empty),
            ),
          ),
        ),
      );

      expect(find.textContaining('No stretch points'), findsOneWidget);
    });
  });

  group('ModifyStretchTuningLineDialog Widget Tests', () {
    testWidgets('populates initial values and confirms valid submission', (
      tester,
    ) async {
      double? confirmedF;
      double? confirmedS;
      int? confirmedK;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: ctx,
                    builder: (_) => ModifyStretchTuningLineDialog(
                      initialUnstretchedFrequency: 440.0,
                      initialStretchInCents: 2.5,
                      pointKey: 99,
                      onConfirmed: (f, s, k) {
                        confirmedF = f;
                        confirmedS = s;
                        confirmedK = k;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Stretch Point'), findsOneWidget);
      expect(find.text('440.00'), findsOneWidget);
      expect(find.text('2.50'), findsOneWidget);

      // Change frequency to 880.0
      await tester.enterText(
        find.widgetWithText(TextFormField, '440.00'),
        '880',
      );
      // Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmedF, 880.0);
      expect(confirmedS, 2.5);
      expect(confirmedK, 99);
    });

    testWidgets('validates negative or non-numeric frequency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: ctx,
                    builder: (_) => ModifyStretchTuningLineDialog(
                      initialUnstretchedFrequency: 440.0,
                      initialStretchInCents: 0.0,
                      pointKey: 1,
                      onConfirmed: (_, _, _) {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '440.00'),
        '-50',
      );
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(find.text('Must be a positive number'), findsOneWidget);
    });
  });
}
