// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/staff/note_staff.dart';
import 'package:tuner_flutter/ui/staff/note_staff_painter.dart';
import 'package:tuner_flutter/ui/staff/staff_models.dart';

void main() {
  Widget buildTestStaff({
    MusicalNote? targetNote,
    MusicalNote? currentNote,
    double centsDeviation = 0.0,
    TuningState tuningState = TuningState.inTune,
    bool showTargetNote = true,
    bool showCurrentNote = true,
    bool isChromatic = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 250,
            child: NoteStaff(
              targetNote: targetNote,
              currentNote: currentNote,
              centsDeviation: centsDeviation,
              tuningState: tuningState,
              showTargetNote: showTargetNote,
              showCurrentNote: showCurrentNote,
              isChromatic: isChromatic,
              staffClef: StaffClef.treble,
            ),
          ),
        ),
      ),
    );
  }

  group('NoteStaff Dual Notes & Dynamics Widget Tests', () {
    testWidgets('Renders both Target Note (left) and Current Note (right)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestStaff(
          targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
          currentNote: const MusicalNote(
            base: BaseNote.a,
            modifier: NoteModifier.sharp,
            octave: 4,
          ),
          centsDeviation: 4.5,
          tuningState: TuningState.inTune,
        ),
      );

      final customPaintFinder = find.descendant(
        of: find.byType(NoteStaff),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);

      final painter =
          tester.widget<CustomPaint>(customPaintFinder).painter
              as NoteStaffPainter;
      expect(painter.targetNote?.name, 'A4');
      expect(painter.currentNote?.name, 'A♯4');
      expect(painter.centsDeviation, 4.5);
      expect(painter.currentNoteColor, isNotNull);
    });

    testWidgets('Chromatic instrument mode hides target note on the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestStaff(
          targetNote: const MusicalNote(base: BaseNote.e, octave: 4),
          currentNote: const MusicalNote(base: BaseNote.g, octave: 4),
          isChromatic: true,
        ),
      );

      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(NoteStaff),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter
              as NoteStaffPainter;
      expect(painter.isChromatic, isTrue);
      expect(painter.currentNote?.name, 'G4');
    });

    testWidgets('Setting showTargetNote=false hides target note', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestStaff(
          targetNote: const MusicalNote(base: BaseNote.c, octave: 4),
          currentNote: const MusicalNote(base: BaseNote.d, octave: 4),
          showTargetNote: false,
          showCurrentNote: true,
        ),
      );

      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(NoteStaff),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter
              as NoteStaffPainter;
      expect(painter.showTargetNote, isFalse);
      expect(painter.showCurrentNote, isTrue);
    });

    testWidgets('Setting showCurrentNote=false hides current note', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestStaff(
          targetNote: const MusicalNote(base: BaseNote.c, octave: 4),
          currentNote: const MusicalNote(base: BaseNote.d, octave: 4),
          showTargetNote: true,
          showCurrentNote: false,
        ),
      );

      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(NoteStaff),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter
              as NoteStaffPainter;
      expect(painter.showTargetNote, isTrue);
      expect(painter.showCurrentNote, isFalse);
    });

    testWidgets('Dynamic ledger lines union calculation for high and low notes', (
      tester,
    ) async {
      // C6 (position 42) is high above treble staff (requires 2 ledger lines: A5=40, C6=42)
      // C4 (Middle C, position 28) is below treble staff (requires 1 ledger line: C4=28)
      final highLedgers = ledgerLinePositions(42, StaffClef.treble);
      final lowLedgers = ledgerLinePositions(28, StaffClef.treble);

      expect(highLedgers, containsAll([40, 42]));
      expect(lowLedgers, contains(28));

      final unionLedgers = <int>{...highLedgers, ...lowLedgers}.toList()
        ..sort();
      expect(unionLedgers, equals([28, 40, 42]));
    });

    testWidgets('TuningState colors correctly apply to currentNoteColor', (
      tester,
    ) async {
      final painterInTune = NoteStaffPainter(
        currentNote: const MusicalNote(base: BaseNote.a, octave: 4),
        tuningState: TuningState.inTune,
        staffClef: StaffClef.treble,
        staffColor: Colors.black,
        inTuneColor: Colors.green,
        outOfTuneColor: Colors.red,
        unknownTuningColor: Colors.grey,
        borderColor: Colors.black26,
      );
      expect(painterInTune.currentNoteColor, Colors.green);

      final painterTooLow = NoteStaffPainter(
        currentNote: const MusicalNote(base: BaseNote.a, octave: 4),
        tuningState: TuningState.tooLow,
        staffClef: StaffClef.treble,
        staffColor: Colors.black,
        inTuneColor: Colors.green,
        outOfTuneColor: Colors.red,
        unknownTuningColor: Colors.grey,
        borderColor: Colors.black26,
      );
      expect(painterTooLow.currentNoteColor, Colors.red);

      final painterUnknown = NoteStaffPainter(
        currentNote: const MusicalNote(base: BaseNote.a, octave: 4),
        tuningState: TuningState.unknown,
        staffClef: StaffClef.treble,
        staffColor: Colors.black,
        inTuneColor: Colors.green,
        outOfTuneColor: Colors.red,
        unknownTuningColor: Colors.grey,
        borderColor: Colors.black26,
      );
      expect(painterUnknown.currentNoteColor, Colors.grey);
    });
  });
}
