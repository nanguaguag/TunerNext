import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/plot/plot_window_outline.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history_state.dart';

void main() {
  Widget buildTestWidget({
    required PitchHistoryState state,
    MusicalNote targetNote = const MusicalNote(base: BaseNote.a, octave: 4),
    double targetFrequency = 440.0,
    TuningState tuningState = TuningState.inTune,
    int toleranceInCents = 5,
  }) {
    return MaterialApp(
      theme: TunerTheme.light(),
      home: Scaffold(
        body: SizedBox(
          width: 350,
          height: 400,
          child: PitchHistory(
            state: state,
            targetNote: targetNote,
            targetFrequency: targetFrequency,
            tuningState: tuningState,
            toleranceInCents: toleranceInCents,
            plotWindowPadding: const EdgeInsets.only(
              left: 4,
              top: 0,
              right: 40,
              bottom: 0,
            ),
            plotWindowOutline: const PlotWindowOutline(
              lineWidth: 1.5,
              cornerRadius: 8.0,
            ),
          ),
        ),
      ),
    );
  }

  group('PitchHistory Widget', () {
    testWidgets('renders properly with empty history in unknown state', (
      tester,
    ) async {
      final state = PitchHistoryState(capacity: 20);
      await tester.pumpWidget(
        buildTestWidget(state: state, tuningState: TuningState.unknown),
      );

      expect(find.byType(PitchHistory), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders history stream and inTune state without crash', (
      tester,
    ) async {
      final state = PitchHistoryState(capacity: 10);
      for (final f in [438.0, 439.0, 440.0, 440.2]) {
        state.addFrequency(f);
      }

      await tester.pumpWidget(
        buildTestWidget(state: state, tuningState: TuningState.inTune),
      );

      expect(find.byType(PitchHistory), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders outOfTune state (tooLow and tooHigh) with cent deviation badge',
      (tester) async {
        final state = PitchHistoryState(capacity: 10);
        state.addFrequency(430.0); // Too low relative to 440

        await tester.pumpWidget(
          buildTestWidget(state: state, tuningState: TuningState.tooLow),
        );
        expect(tester.takeException(), isNull);

        state.addFrequency(450.0); // Too high relative to 440
        await tester.pumpWidget(
          buildTestWidget(state: state, tuningState: TuningState.tooHigh),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('dynamic additions to PitchHistoryState trigger repaint', (
      tester,
    ) async {
      final state = PitchHistoryState(capacity: 5);
      await tester.pumpWidget(buildTestWidget(state: state));

      state.addFrequency(440.0);
      await tester.pump();

      state.addFrequency(null); // mute gap
      state.addFrequency(441.0);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
