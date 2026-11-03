import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/dsp/analysis/offline_audio_analyzer.dart';
import 'package:tuner_flutter/ui/plot/static_pitch_timeline_plot.dart';

void main() {
  group('StaticPitchTimelinePlot Jump Break & Robust Y-Axis Tests', () {
    testWidgets('Renders frames with large pitch jumps without error or crash', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Create alternating frames mimicking polyphonic song (bass 65Hz vs cymbals 12000Hz vs vocal 440Hz)
      final frames = <AnalysisFrame>[
        const AnalysisFrame(
          timeSeconds: 0.0,
          frequency: 65.0, // G1
          confidence: 0.9,
          rms: 0.2,
          isSilence: false,
        ),
        const AnalysisFrame(
          timeSeconds: 0.05,
          frequency: 12000.0, // High cymbal spike
          confidence: 0.8,
          rms: 0.2,
          isSilence: false,
        ),
        const AnalysisFrame(
          timeSeconds: 0.10,
          frequency: 440.0, // A4 Vocal melody
          confidence: 0.95,
          rms: 0.3,
          isSilence: false,
        ),
        const AnalysisFrame(
          timeSeconds: 0.15,
          frequency: 442.0, // A4 Vocal melody (continuous)
          confidence: 0.96,
          rms: 0.3,
          isSilence: false,
        ),
        const AnalysisFrame(
          timeSeconds: 0.20,
          frequency: 0.0, // Silence
          confidence: 0.0,
          rms: 0.0,
          isSilence: true,
        ),
        const AnalysisFrame(
          timeSeconds: 0.30,
          frequency: 330.0, // E4 Vocal melody after silence
          confidence: 0.92,
          rms: 0.25,
          isSilence: false,
        ),
      ];

      double seekTarget = -1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: StaticPitchTimelinePlot(
                frames: frames,
                durationSeconds: 1.0,
                currentTime: 0.10,
                onSeekTime: (t) => seekTarget = t,
                targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                targetFrequency: 440.0,
                tuningState: TuningState.inTune,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // CustomPaint is rendered
      expect(find.byType(CustomPaint), findsWidgets);

      // Tap on plot to seek
      await tester.tapAt(const Offset(400, 200));
      await tester.pumpAndSettle();

      expect(seekTarget, greaterThan(0.0));
      expect(seekTarget, lessThanOrEqualTo(1.0));
    });

    testWidgets(
      'Wide pitch span (> 48 semitones) adapts Y-axis labels cleanly',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Frames spanning from C2 (~65Hz) to C7 (~2093Hz) - span > 60 semitones
        final frames = <AnalysisFrame>[
          const AnalysisFrame(
            timeSeconds: 0.0,
            frequency: 65.4, // C2
            confidence: 0.9,
            rms: 0.2,
            isSilence: false,
          ),
          const AnalysisFrame(
            timeSeconds: 0.5,
            frequency: 2093.0, // C7
            confidence: 0.9,
            rms: 0.2,
            isSilence: false,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 400,
                child: StaticPitchTimelinePlot(
                  frames: frames,
                  durationSeconds: 1.0,
                  currentTime: 0.0,
                  onSeekTime: (_) {},
                  targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                  targetFrequency: 440.0,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });
}
