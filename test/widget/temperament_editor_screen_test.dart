import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/temperaments/custom_temperament.dart';
import 'package:tuner_flutter/ui/screens/temperament_editor_screen.dart';
import 'package:tuner_flutter/ui/temperaments/temperament_table_line.dart';

void main() {
  group('TemperamentTableLine Widget Tests', () {
    testWidgets('renders index, note name and cents', (tester) async {
      double? changedCents;
      String? changedNoteName;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemperamentTableLine(
              index: 4,
              noteName: 'E',
              cents: 400.0,
              onCentsChanged: (c) => changedCents = c,
              onNoteNameChanged: (n) => changedNoteName = n,
            ),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
      expect(find.text('400.00'), findsOneWidget);

      // Edit Note Name dialog
      await tester.tap(find.text('E'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Note #4 Name'), findsOneWidget);
      final dialogTextField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(dialogTextField, 'E-flat');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(changedNoteName, 'E-flat');

      // Change cents value in the table line
      final centsField = find.descendant(
        of: find.byType(TemperamentTableLine),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(centsField, '405.5');
      expect(changedCents, 405.5);
    });

    testWidgets('displays error message when non-monotonic', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemperamentTableLine(
              index: 2,
              noteName: 'D',
              cents: 150.0,
              errorMessage: 'Must be > 200.00 ¢',
              onCentsChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Must be > 200.00 ¢'), findsOneWidget);
    });
  });

  group('TemperamentEditorScreen Widget Tests', () {
    testWidgets('renders editor with fields, edits and saves', (tester) async {
      CustomTemperament? savedTemperament;

      await tester.pumpWidget(
        MaterialApp(
          home: TemperamentEditorScreen(onSave: (t) => savedTemperament = t),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Temperament Editor'), findsOneWidget);
      expect(find.text('Custom Temperament'), findsOneWidget);
      expect(find.text('12 steps per octave'), findsOneWidget);

      // Verify Save button
      final saveBtn = find.text('Save');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(savedTemperament, isNotNull);
      expect(savedTemperament!.name, 'Custom Temperament');
      expect(savedTemperament!.cents.length, 13);
    });
  });
}
