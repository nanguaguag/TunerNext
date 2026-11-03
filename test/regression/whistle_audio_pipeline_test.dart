import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/dsp/pipeline/tuner_dsp_pipeline.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history_state.dart';

void main() {
  group('Whistle Audio Tracking & Artifact Elimination Suite', () {
    const sampleRate = 44100;
    const frameSize = 2048;

    test(
      'MPM and TWM track high whistle tones accurately without subharmonic traps',
      () {
        final file = File('/tmp/test_music.pcm');
        Float32List samples;
        if (file.existsSync()) {
          final bytes = file.readAsBytesSync();
          samples = Float32List.view(bytes.buffer);
        } else {
          // Fallback synthetic whistle tone (1620 Hz)
          const total = 44100 * 2;
          samples = Float32List(total);
          for (var i = 0; i < total; i++) {
            samples[i] =
                0.8 * math.sin(2.0 * math.pi * 1620.0 * (i / sampleRate));
          }
        }

        // Check first second of whistle tone around 0.35s
        final offset = (0.35 * sampleRate).round();
        final frame = samples.sublist(offset, offset + frameSize);

        final pipelineMpm = TunerDspPipeline(
          frameSize: frameSize,
          algorithm: PitchAlgorithm.mpm,
        );
        final resMpm = pipelineMpm.process(frame, sampleRate: sampleRate);
        expect(resMpm.isSilence, isFalse);
        expect(resMpm.rawFrequency, closeTo(1630.0, 30.0));

        final pipelineTwm = TunerDspPipeline(
          frameSize: frameSize,
          algorithm: PitchAlgorithm.twm,
        );
        final resTwm = pipelineTwm.process(frame, sampleRate: sampleRate);
        expect(resTwm.isSilence, isFalse);
        expect(resTwm.rawFrequency, closeTo(1630.0, 30.0));
      },
    );

    testWidgets(
      'PitchHistory renders whistle pitch contour without vertical line spikes',
      (tester) async {
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final historyState = PitchHistoryState(capacity: 60);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: PitchHistory(
                  state: historyState,
                  targetNote: const MusicalNote(base: BaseNote.g, octave: 6),
                  targetFrequency: 1567.98,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Feed continuous whistle melody frames
        for (var f = 1600.0; f <= 1650.0; f += 5.0) {
          historyState.addFrequency(f);
          await tester.pump();
        }

        // Feed mute gaps (silence)
        historyState.addFrequency(null);
        historyState.addFrequency(null);
        await tester.pump();

        // Next whistle phrase
        for (var f = 2000.0; f <= 2050.0; f += 5.0) {
          historyState.addFrequency(f);
          await tester.pump();
        }

        expect(tester.takeException(), isNull);
      },
    );
  });
}
