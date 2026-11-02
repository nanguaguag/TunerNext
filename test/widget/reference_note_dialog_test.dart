import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/dialogs/reference_note_dialog.dart';

void main() {
  group('ReferenceNoteDialog Widget', () {
    testWidgets('renders initial note, frequency and presets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: ReferenceNoteDialog(
              initialNote: const MusicalNote(base: BaseNote.a, octave: 4),
              initialFrequency: 440.0,
              onConfirm: (note, freq) {},
            ),
          ),
        ),
      );

      expect(find.text('Reference Pitch'), findsOneWidget);
      expect(find.text('440.0'), findsOneWidget);
      expect(find.text('440 Hz (Concert)'), findsOneWidget);
      expect(find.text('432 Hz (Verdi)'), findsOneWidget);
    });

    testWidgets('preset tap updates frequency field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: ReferenceNoteDialog(
              initialNote: const MusicalNote(base: BaseNote.a, octave: 4),
              initialFrequency: 440.0,
              onConfirm: (note, freq) {},
            ),
          ),
        ),
      );

      // Tap 432 Hz preset
      await tester.tap(find.text('432 Hz (Verdi)'));
      await tester.pumpAndSettle();

      expect(find.text('432.0'), findsOneWidget);
    });

    testWidgets('validation prevents invalid or negative frequencies', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: ReferenceNoteDialog(
              initialNote: const MusicalNote(base: BaseNote.a, octave: 4),
              initialFrequency: 440.0,
              onConfirm: (note, freq) {},
            ),
          ),
        ),
      );

      // Enter negative frequency
      await tester.enterText(find.byType(TextField), '-100');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Frequency must be greater than zero'), findsOneWidget);
    });
  });
}
