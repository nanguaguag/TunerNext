// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_source_interface.dart';
import 'package:tuner_flutter/audio/audio_stream_controller.dart';
import 'package:tuner_flutter/audio/mock_audio_source.dart';
import 'package:tuner_flutter/audio/wave_writer.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/dsp/tuner_pipeline_runner.dart';
import 'package:tuner_flutter/dsp/tuner_worker_protocol.dart';

void main() {
  group('AudioStreamController Tests', () {
    test(
      'End-to-end audio streaming, window extraction, and DSP pitch evaluation',
      () async {
        final mockSource = MockAudioSource();
        final runner = TunerSyncPipelineRunner(
          config: const TunerDspConfig(
            pitchAlgorithm: PitchAlgorithm.classic,
            sampleRate: 44100,
            windowSize: 2048,
            overlap: 0.5,
          ),
        );
        final waveWriter = WaveWriter(sampleRate: 44100, durationSeconds: 1);

        final controller = AudioStreamController(
          audioSource: mockSource,
          pipelineRunner: runner,
          config: const TunerDspConfig(
            pitchAlgorithm: PitchAlgorithm.classic,
            sampleRate: 44100,
            windowSize: 2048,
            overlap: 0.5,
          ),
          waveWriter: waveWriter,
        );

        final results = <TunerWorkerResult>[];
        final sub = controller.results.listen(results.add);

        expect(controller.isRunning, isFalse);
        await controller.start();
        expect(controller.isRunning, isTrue);

        // Push 4096 samples of 440 Hz sine wave (generates multiple overlapping windows)
        mockSource.pushSineChunk(
          frequency: 440.0,
          numSamples: 4096,
          amplitude: 0.8,
          sampleRate: 44100,
        );

        await Future<void>.delayed(const Duration(milliseconds: 20));

        // With windowSize=2048, overlap=0.5 (step=1024), 4096 samples produce multiple windows:
        // window 0: [0..2048]
        // window 1: [1024..3072]
        // window 2: [2048..4096]
        expect(results.length, greaterThanOrEqualTo(2));
        final lastResult = results.last;
        expect(lastResult.isSilence, isFalse);
        expect(lastResult.frequency, closeTo(440.0, 0.5));
        expect(lastResult.target.note.pitchClassName, 'A');
        expect(lastResult.target.note.octave, 4);
        expect(lastResult.state, TuningState.inTune);

        // Verify WaveWriter captured the raw audio samples
        expect(waveWriter.numStoredValues, 4096);
        final snapshot = waveWriter.storeSnapshot();
        expect(snapshot.length, 4096);

        // Stop controller
        await controller.stop();
        expect(controller.isRunning, isFalse);

        await sub.cancel();
        await controller.dispose();
      },
    );

    test(
      'Audio capture errors propagate through controller errorStream',
      () async {
        final mockSource = MockAudioSource();
        final runner = TunerSyncPipelineRunner();
        final controller = AudioStreamController(
          audioSource: mockSource,
          pipelineRunner: runner,
        );

        final errors = <AudioSourceError>[];
        final sub = controller.errors.listen(errors.add);

        await controller.start();

        mockSource.emitError(const MicrophoneUnavailableError('Hardware busy'));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(errors.length, 1);
        expect(errors.first, isA<MicrophoneUnavailableError>());

        await sub.cancel();
        await controller.dispose();
      },
    );
  });
}
