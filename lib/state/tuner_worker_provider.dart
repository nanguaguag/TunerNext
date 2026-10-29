// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_source_interface.dart';
import '../audio/audio_stream_controller.dart';
import '../audio/record_audio_source.dart';
import '../audio/wave_writer.dart';
import '../domain/tuning/tuning_target_computer.dart';
import '../dsp/tuner_isolate_worker.dart';
import '../dsp/tuner_pipeline_runner.dart';
import '../dsp/tuner_worker_protocol.dart';

/// Provider for DSP configuration state.
final tunerDspConfigProvider =
    NotifierProvider<TunerDspConfigNotifier, TunerDspConfig>(
      TunerDspConfigNotifier.new,
    );

class TunerDspConfigNotifier extends Notifier<TunerDspConfig> {
  @override
  TunerDspConfig build() => const TunerDspConfig();

  void update(TunerDspConfig Function(TunerDspConfig prev) updater) {
    state = updater(state);
  }

  void setConfig(TunerDspConfig newConfig) {
    state = newConfig;
  }
}

/// Provider for the audio input hardware source.
final audioSourceProvider = Provider<AudioSource>((ref) {
  final source = RecordAudioSource();
  ref.onDispose(source.dispose);
  return source;
});

/// Provider for the pipeline runner (defaults to Isolate-backed worker).
final tunerPipelineRunnerProvider = Provider<TunerPipelineRunner>((ref) {
  final config = ref.watch(tunerDspConfigProvider);
  final runner = TunerIsolateWorker(initialConfig: config);
  ref.onDispose(runner.dispose);
  return runner;
});

/// Provider for the circular wave recording buffer.
final waveWriterProvider = Provider<WaveWriter>((ref) {
  final config = ref.watch(tunerDspConfigProvider);
  return WaveWriter(sampleRate: config.sampleRate);
});

/// Central controller coordinating audio capture, window slicing, and DSP runner.
final audioStreamControllerProvider = Provider<AudioStreamController>((ref) {
  final source = ref.watch(audioSourceProvider);
  final runner = ref.watch(tunerPipelineRunnerProvider);
  final config = ref.watch(tunerDspConfigProvider);
  final waveWriter = ref.watch(waveWriterProvider);

  final controller = AudioStreamController(
    audioSource: source,
    pipelineRunner: runner,
    config: config,
    waveWriter: waveWriter,
  );

  // Sync config updates to running controller
  ref.listen<TunerDspConfig>(tunerDspConfigProvider, (_, nextConfig) {
    controller.updateConfig(nextConfig);
  });

  ref.onDispose(controller.dispose);
  return controller;
});

/// Stream of evaluated real-time tuning events.
final tunerWorkerResultStreamProvider = StreamProvider<TunerWorkerResult>((
  ref,
) {
  final controller = ref.watch(audioStreamControllerProvider);
  return controller.results;
});

/// Latest tuning evaluation status, or null if no frames processed yet.
final currentTuningEvaluationProvider = Provider<TuningEvaluation?>((ref) {
  final asyncResult = ref.watch(tunerWorkerResultStreamProvider);
  return asyncResult.value?.evaluation;
});
