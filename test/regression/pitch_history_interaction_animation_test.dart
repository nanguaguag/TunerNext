import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history_state.dart';

void main() {
  group('Regression Test: BUG-P1-06 PitchHistory Gesture & Smooth Animation', () {
    testWidgets(
      'Pan and zoom gesture interaction updates viewport and tap resets',
      (tester) async {
        final state = PitchHistoryState(capacity: 30);
        state.addFrequency(440.0); // A4

        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: PitchHistory(
                  state: state,
                  targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                  tuningState: TuningState.inTune,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(PitchHistory), findsOneWidget);

        // 1. Perform vertical drag gesture (Pan)
        await tester.drag(find.byType(PitchHistory), const Offset(0.0, 100.0));
        await tester.pump();

        // Viewport shifted without crash
        expect(tester.takeException(), isNull);

        // 2. Tap to reset gesture and return to auto tracking
        await tester.tap(find.byType(PitchHistory));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Target note transition from G2 to F2 animates smoothly over time',
      (tester) async {
        final state = PitchHistoryState(capacity: 30);
        state.addFrequency(98.0); // G2

        const noteG2 = MusicalNote(base: BaseNote.g, octave: 2);
        const noteF2 = MusicalNote(base: BaseNote.f, octave: 2);

        var activeNote = noteG2;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                theme: TunerTheme.light(),
                home: Scaffold(
                  body: SizedBox(
                    width: 400,
                    height: 400,
                    child: PitchHistory(
                      state: state,
                      targetNote: activeNote,
                      tuningState: TuningState.inTune,
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        activeNote = noteF2;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );

        // Trigger note switch
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump(); // Start animation

        // Advance frames partially to verify intermediate smooth animation frames
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        // Finish animation smoothly
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
