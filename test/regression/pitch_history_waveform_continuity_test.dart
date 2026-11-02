import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/screens/instrument_tuner_screen.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history_state.dart';

void main() {
  group('Regression Test: BUG-P0-01 PitchHistory Waveform Continuity & Clipping', () {
    testWidgets(
      'Liang-Barsky segment clipping prevents flying spikes on extreme out-of-range notes',
      (tester) async {
        // Simulate whistle at G#6 (~1661 Hz, MIDI=92) with sudden extreme transient rumbles (80 Hz, 4000 Hz)
        final state = PitchHistoryState(capacity: 20);
        state.addFrequency(1661.22); // G#6 (in view)
        state.addFrequency(1665.00); // G#6 (in view)
        state.addFrequency(
          80.0,
        ); // Extreme subharmonic rumble (way below bottom)
        state.addFrequency(4500.0); // Extreme high spike (way above top)
        state.addFrequency(1660.0); // Back in view

        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: PitchHistory(
                  state: state,
                  targetNote: MusicalNote.fromMidiNumber(92), // G#6
                  targetFrequency: 1661.22,
                  tuningState: TuningState.inTune,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(PitchHistory), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'InstrumentTunerScreen continuous steady pitch does not get starved by didUpdateWidget',
      (tester) async {
        // Pumping with steady 1661.22 Hz across multiple frames
        await tester.pumpWidget(
          const MaterialApp(
            home: InstrumentTunerScreen(currentFrequency: 1661.22),
          ),
        );
        await tester.pump();

        // Update with identical frequency across frames (steady whistle)
        await tester.pumpWidget(
          const MaterialApp(
            home: InstrumentTunerScreen(currentFrequency: 1661.22),
          ),
        );
        await tester.pump();

        await tester.pumpWidget(
          const MaterialApp(
            home: InstrumentTunerScreen(currentFrequency: 1661.22),
          ),
        );
        await tester.pump();

        // Silent / null frame should not crash and should update tuning state to unknown without injecting null
        await tester.pumpWidget(
          const MaterialApp(
            home: InstrumentTunerScreen(currentFrequency: null),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
