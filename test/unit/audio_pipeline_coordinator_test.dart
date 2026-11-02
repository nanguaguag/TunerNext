import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_pipeline_coordinator.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPipelineCoordinator Tests', () {
    test(
      'converts spectrum amplitudes to LineCoordinates with normalized height',
      () {
        final spectrum = Float32List.fromList([0.0, 10.0, 50.0, 100.0, 20.0]);
        final coords =
            AudioPipelineCoordinator.convertSpectrumToLineCoordinates(
              spectrum,
              sampleRate: 44100,
              windowSize: 2048,
              maxFrequency: 5000.0,
            );

        expect(coords, isNotNull);
        expect(coords!.coordinates.length, spectrum.length);
        // Peak value is 100.0, so 100.0 / 100.0 = 1.0
        expect(coords.coordinates[3].dy, 1.0);
      },
    );

    test('converts waveform snapshot to LineCoordinates clamped in [0, 1]', () {
      final snapshot = Float32List.fromList([-1.0, -0.5, 0.0, 0.5, 1.0]);
      final coords = AudioPipelineCoordinator.convertWaveformToLineCoordinates(
        snapshot,
        sampleRate: 44100,
      );

      expect(coords, isNotNull);
      expect(coords!.coordinates.length, snapshot.length);
      // -1.0 maps to 0.5 + 0.5 * (-1.0) = 0.0
      expect(coords.coordinates[0].dy, 0.0);
      // 0.0 maps to 0.5
      expect(coords.coordinates[2].dy, 0.5);
      // 1.0 maps to 1.0
      expect(coords.coordinates[4].dy, 1.0);
    });

    test('can start with MockAudioSource and stop cleanly', () async {
      final coordinator = AudioPipelineCoordinator(sampleRate: 44100);
      final prefs = AppPreferences();

      await coordinator.start(preferences: prefs, forceMock: true);
      expect(coordinator.isRunning, isTrue);

      coordinator.reconfigure(prefs);

      await coordinator.stop();
      expect(coordinator.isRunning, isFalse);
    });
  });
}
