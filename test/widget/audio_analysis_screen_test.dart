import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_file_loader.dart';
import 'package:tuner_flutter/domain/instruments/predefined_instruments.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/analysis/offline_audio_analyzer.dart';
import 'package:tuner_flutter/ui/instruments/instruments_screen.dart';
import 'package:tuner_flutter/ui/screens/audio_analysis_screen.dart';

void main() {
  group('AudioAnalysisScreen Widget Tests', () {
    late OfflineAnalysisResult mockResult;
    late DecodedAudio mockDecodedAudio;

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

      // 4096 samples at 44100Hz (~0.09s of sine wave)
      final dummySamples = Float32List(4096);
      mockDecodedAudio = DecodedAudio(
        samples: dummySamples,
        sampleRate: 44100,
        duration: const Duration(milliseconds: 93),
      );
    });

    testWidgets(
      'Renders top banner, strings, timeline plot, scrubber controls, and mute toggle',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: AudioAnalysisScreen(
              analysisResult: mockResult,
              fileName: 'test_music.wav',
              decodedAudio: mockDecodedAudio,
              audioPath: 'assets/audio/test_music.wav',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Audio Pitch Analysis'), findsOneWidget);
        expect(find.text('test_music.wav'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        // Verify time text
        expect(find.text('0.0s'), findsOneWidget);
        expect(find.text('2.0s'), findsOneWidget);

        // Tap play button
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();
        expect(find.byIcon(Icons.pause), findsOneWidget);

        // Tap mute button
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pump();
        expect(find.byIcon(Icons.volume_off), findsOneWidget);

        // Tap unmute
        await tester.tap(find.byIcon(Icons.volume_off));
        await tester.pump();
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        // Tap pause button
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pump();
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        // Drag slider to 1.0s
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Tapping instrument button opens InstrumentsScreen and allows selection',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: AudioAnalysisScreen(
              analysisResult: mockResult,
              fileName: 'test_music.wav',
              initialInstrument: PredefinedInstruments.guitarStandard,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find instrument button in TuningIndicatorBanner
        final instrumentBtn = find.text('6-string guitar');
        expect(instrumentBtn, findsOneWidget);

        await tester.tap(instrumentBtn);
        await tester.pumpAndSettle();

        // Verify InstrumentsScreen is opened
        expect(find.byType(InstrumentsScreen), findsOneWidget);
        expect(find.text('4-string bass'), findsWidgets);

        // Select '4-string bass'
        await tester.tap(find.text('4-string bass').first);
        await tester.pumpAndSettle();

        // Should return to AudioAnalysisScreen with 4-string bass active
        expect(find.byType(InstrumentsScreen), findsNothing);
        expect(find.text('4-string bass'), findsOneWidget);
      },
    );

    testWidgets(
      'Re-analyze config dialog updates algorithm and triggers analysis',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        PitchAlgorithm? reanalyzedAlgo;
        AcousticWeightingMode? reanalyzedWeight;

        await tester.pumpWidget(
          MaterialApp(
            home: AudioAnalysisScreen(
              analysisResult: mockResult,
              fileName: 'test_music.wav',
              decodedAudio: mockDecodedAudio,
              onReanalyzeWithConfig: (algo, weight) {
                reanalyzedAlgo = algo;
                reanalyzedWeight = weight;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap tune/config action button in AppBar
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();

        // Verify dialog is visible
        expect(find.text('Re-analyze Audio'), findsOneWidget);
        expect(find.text('Pitch Algorithm:'), findsOneWidget);
        expect(find.text('Acoustic Weighting:'), findsOneWidget);

        // Tap Analyze button in dialog
        await tester.tap(find.text('Analyze'));
        await tester.pumpAndSettle();

        expect(find.text('Re-analyze Audio'), findsNothing);
        expect(reanalyzedAlgo, PitchAlgorithm.mpm);
        expect(reanalyzedWeight, AcousticWeightingMode.none);
      },
    );
  });
}
