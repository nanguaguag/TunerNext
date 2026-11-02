import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/dialogs/reference_note_dialog.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';

void main() {
  group('Reference Note & Frequency Parity Tests', () {
    testWidgets('Preferences screen displays G4 without duplicate octave G44', (
      tester,
    ) async {
      final prefs = AppPreferences();
      prefs.setReferenceNote(const MusicalNote(base: BaseNote.g, octave: 4));
      prefs.setReferenceFrequency(440.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PreferencesScreen(preferences: prefs)),
        ),
      );
      await tester.pumpAndSettle();

      // Must display 'G4 = 440.0 Hz' and must NEVER contain 'G44'
      expect(find.text('G4 = 440.0 Hz'), findsOneWidget);
      expect(find.textContaining('G44'), findsNothing);
    });

    testWidgets(
      'ReferenceNoteDialog fills detected frequency from microphone',
      (tester) async {
        MusicalNote? submittedNote;
        double? submittedFreq;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReferenceNoteDialog(
                initialNote: const MusicalNote(base: BaseNote.a, octave: 4),
                initialFrequency: 440.0,
                detectedFrequency: 443.25,
                onConfirm: (n, f) {
                  submittedNote = n;
                  submittedFreq = f;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the live pitch fill button
        final livePitchFinder = find.textContaining('443.25 Hz');
        expect(livePitchFinder, findsOneWidget);

        // Tap on live pitch button to fill
        await tester.tap(livePitchFinder);
        await tester.pumpAndSettle();

        // Confirm dialog
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(submittedNote?.name, equals('A4'));
        expect(submittedFreq, closeTo(443.25, 0.01));
      },
    );

    testWidgets(
      'ReferenceNoteDialog selects chromatic notes and resets to default',
      (tester) async {
        MusicalNote? submittedNote;
        double? submittedFreq;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReferenceNoteDialog(
                initialNote: const MusicalNote(base: BaseNote.c, octave: 4),
                initialFrequency: 523.25,
                onConfirm: (n, f) {
                  submittedNote = n;
                  submittedFreq = f;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap 'Set to Default'
        await tester.tap(find.textContaining('Set to Default'));
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(submittedNote?.name, equals('A4'));
        expect(submittedFreq, equals(440.0));
      },
    );
  });
}
