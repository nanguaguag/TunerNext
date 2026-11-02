import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/staff/note_staff.dart';
import 'package:tuner_flutter/ui/staff/staff_clef.dart';

void main() {
  group('NoteStaff Widget', () {
    testWidgets('renders musical staff with clef and note', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: const Scaffold(
            body: SizedBox(
              width: 360,
              height: 240,
              child: NoteStaff(
                note: MusicalNote(
                  base: BaseNote.f,
                  modifier: NoteModifier.sharp,
                  octave: 4,
                ),
                clef: StaffClef.treble,
                keySignature: 1,
                tuningState: TuningState.inTune,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Treble'), findsOneWidget);
      expect(find.text('Key: +1 ♯'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders bass clef and handles outOfTune state without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: const Scaffold(
            body: SizedBox(
              width: 360,
              height: 240,
              child: NoteStaff(
                note: MusicalNote(base: BaseNote.c, octave: 2),
                clef: StaffClef.bass,
                tuningState: TuningState.tooLow,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bass'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
