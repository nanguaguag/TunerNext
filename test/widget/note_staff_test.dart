// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/staff/note_staff.dart';
import 'package:tuner_flutter/ui/staff/staff_models.dart';

void main() {
  Widget buildStaffHarness({
    required MusicalNote? note,
    TuningState tuningState = TuningState.unknown,
    StaffClef staffClef = StaffClef.grand,
    ValueChanged<StaffClef>? onStaffClefChanged,
    int keySignature = 0,
    ValueChanged<int>? onKeySignatureChanged,
  }) {
    return MaterialApp(
      theme: TunerTheme.light(),
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 250,
          child: NoteStaff(
            note: note,
            tuningState: tuningState,
            staffClef: staffClef,
            onStaffClefChanged: onStaffClefChanged,
            keySignature: keySignature,
            onKeySignatureChanged: onKeySignatureChanged,
          ),
        ),
      ),
    );
  }

  group('NoteStaff Widget Tests', () {
    testWidgets('Renders NoteStaff in Grand Staff mode with A4', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildStaffHarness(
          note: const MusicalNote(base: BaseNote.a, octave: 4),
          tuningState: TuningState.inTune,
          staffClef: StaffClef.grand,
        ),
      );

      expect(find.byType(NoteStaff), findsOneWidget);
    });

    testWidgets('Key signature buttons trigger increments and decrements', (
      tester,
    ) async {
      int recordedKey = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 400,
                  height: 250,
                  child: NoteStaff(
                    note: const MusicalNote(base: BaseNote.c, octave: 4),
                    keySignature: recordedKey,
                    onKeySignatureChanged: (newSig) {
                      setState(() {
                        recordedKey = newSig;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap sharp button to increment key signature
      final sharpButton = find.widgetWithText(IconButton, '♯');
      expect(sharpButton, findsOneWidget);
      await tester.tap(sharpButton);
      await tester.pump();
      expect(recordedKey, equals(1));

      // Tap flat button to decrement back to 0
      final flatButton = find.widgetWithText(IconButton, '♭');
      expect(flatButton, findsOneWidget);
      await tester.tap(flatButton);
      await tester.pump();
      expect(recordedKey, equals(0));
    });

    testWidgets('Clef selector menu allows changing to Bass clef', (
      tester,
    ) async {
      StaffClef selectedClef = StaffClef.grand;
      await tester.pumpWidget(
        buildStaffHarness(
          note: const MusicalNote(base: BaseNote.g, octave: 2),
          staffClef: selectedClef,
          onStaffClefChanged: (clef) => selectedClef = clef,
        ),
      );

      // Find clef selector button
      final clefButton = find.byType(PopupMenuButton<StaffClef>);
      expect(clefButton, findsOneWidget);
      await tester.tap(clefButton);
      await tester.pumpAndSettle();

      // Tap 'Bass Clef' menu option
      final bassOption = find.text('Bass Clef');
      expect(bassOption, findsOneWidget);
      await tester.tap(bassOption);
      await tester.pumpAndSettle();

      expect(selectedClef, equals(StaffClef.bass));
    });

    testWidgets('Renders across all four clef configurations without crash', (
      tester,
    ) async {
      for (final clef in StaffClef.values) {
        await tester.pumpWidget(
          buildStaffHarness(
            note: const MusicalNote(
              base: BaseNote.f,
              modifier: NoteModifier.sharp,
              octave: 4,
            ),
            tuningState: TuningState.tooHigh,
            staffClef: clef,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
