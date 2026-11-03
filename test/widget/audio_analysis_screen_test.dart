import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/analysis/offline_audio_analyzer.dart';
import 'package:tuner_flutter/ui/screens/audio_analysis_screen.dart';

void main() {
  group('AudioAnalysisScreen Widget Tests', () {
    late OfflineAnalysisResult mockResult;

    setUp(() {
      final frames = <AnalysisFrame>[
        const AnalysisFrame(
          timeSeconds: 0.0,
          frequency: 440.0,
          confidence: 0.95,
          rms: 0.1,
          isSilence: false,
        ),
        const AnalysisFrame(
          timeSeconds: 1.0,
          frequency: 880.0,
          confidence: 0.98,
          rms: 0.12,
          isSilence: false,
        ),
        const AnalysisFrame(
          timeSeconds: 2.0,
          frequency: 0.0,
          confidence: 0.0,
          rms: 0.0,
          isSilence: true,
        ),
      ];

      mockResult = OfflineAnalysisResult(
        frames: frames,
        durationSeconds: 2.0,
        sampleRate: 44100,
        algorithm: PitchAlgorithm.mpm,
        weightingMode: AcousticWeightingMode.none,
      );
    });

    testWidgets(
      'Renders top banner, strings, timeline plot and scrubber controls',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: AudioAnalysisScreen(
              analysisResult: mockResult,
              fileName: 'test_music.m4a',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Audio Pitch Analysis'), findsOneWidget);
        expect(find.text('test_music.m4a'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        // Verify time text
        expect(find.text('0.0s'), findsOneWidget);
        expect(find.text('2.0s'), findsOneWidget);

        // Tap play button
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Drag slider to 1.0s
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();
      },
    );
  });
}
