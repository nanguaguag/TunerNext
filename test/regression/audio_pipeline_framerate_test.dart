import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_messages.dart';
import 'package:tuner_flutter/audio/audio_pipeline_coordinator.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';

void main() {
  group('Regression Test: BUG-P1-02 Audio Pipeline Framerate & Window Delivery', () {
    test(
      'AudioPipelineCoordinator receives all sliding windows without burst drop',
      () async {
        final coordinator = AudioPipelineCoordinator(sampleRate: 44100);
        final preferences = AppPreferences();
        preferences.windowSizeExponent = 11; // 2^11 = 2048
        preferences.overlapPercent = 75; // stride = 512

        final received = <AudioAnalysisResult>[];
        final sub = coordinator.analysisStream.listen(received.add);

        await coordinator.start(preferences: preferences, forceMock: true);

        // Allow mock audio source to generate several blocks
        await Future<void>.delayed(const Duration(milliseconds: 250));

        await coordinator.stop();
        await sub.cancel();

        // With 44100 Hz, stride 512 -> ~86 frames/sec. In 250ms we should get around 15~25 frames.
        // Previously with 60 FPS throttle discarding bursts, it would receive less than 5 frames.
        expect(received.length, greaterThanOrEqualTo(10));
        for (final res in received) {
          expect(res.smoothedFrequency, greaterThan(0));
        }
      },
    );
  });
}
