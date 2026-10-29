// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/dsp/tuner_isolate_worker.dart';
import 'package:tuner_flutter/dsp/tuner_pipeline_runner.dart';
import 'package:tuner_flutter/dsp/tuner_worker_protocol.dart';

Float32List generateSineWindow({
  required double frequency,
  int windowSize = 4096,
  int sampleRate = 44100,
  double amplitude = 0.8,
}) {
  final out = Float32List(windowSize);
  for (var i = 0; i < windowSize; i++) {
    out[i] = amplitude * math.sin(2.0 * math.pi * frequency * i / sampleRate);
  }
  return out;
}

void main() {
  group('TunerSyncPipelineRunner Tests', () {
    test('A4 (440.0 Hz) sine window evaluates to in-tune A4 target', () async {
      final runner = TunerSyncPipelineRunner(
        config: const TunerDspConfig(
          pitchAlgorithm: PitchAlgorithm.classic,
          sampleRate: 44100,
          windowSize: 4096,
        ),
      );

      final sine = generateSineWindow(frequency: 440.0);
      final results = <TunerWorkerResult>[];
      final sub = runner.results.listen(results.add);

      runner.processFrame(sine, 0);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(results.length, 1);
      final r = results.first;
      expect(r.isSilence, isFalse);
      expect(r.frequency, closeTo(440.0, 0.5));
      expect(r.target.note.pitchClassName, 'A');
      expect(r.target.note.octave, 4);
      expect(r.deviationCents.abs(), lessThan(1.0));
      expect(r.state, TuningState.inTune);

      await sub.cancel();
      await runner.dispose();
    });

    test('Digital silence evaluates to silence with 0 Hz', () async {
      final runner = TunerSyncPipelineRunner();
      final silence = Float32List(4096);
      final results = <TunerWorkerResult>[];
      final sub = runner.results.listen(results.add);

      runner.processFrame(silence, 100);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(results.length, 1);
      final r = results.first;
      expect(r.isSilence, isTrue);
      expect(r.frequency, 0.0);

      await sub.cancel();
      await runner.dispose();
    });
  });

  group('TunerIsolateWorker Concurrency Tests', () {
    test(
      'Isolate spawns, processes audio window in background, and emits result',
      () async {
        final worker = TunerIsolateWorker(
          initialConfig: const TunerDspConfig(
            pitchAlgorithm: PitchAlgorithm.classic,
            sampleRate: 44100,
            windowSize: 4096,
          ),
        );

        await worker.waitUntilReady;
        expect(worker.isReady, isTrue);

        final results = <TunerWorkerResult>[];
        final sub = worker.results.listen(results.add);

        final sine = generateSineWindow(frequency: 440.0);
        worker.processFrame(sine, 1);

        // Await isolate message delivery
        for (var i = 0; i < 50 && results.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }

        expect(results.isNotEmpty, isTrue);
        final r = results.first;
        expect(r.isSilence, isFalse);
        expect(r.frequency, closeTo(440.0, 0.5));
        expect(r.target.note.pitchClassName, 'A');
        expect(r.target.note.octave, 4);
        expect(r.frameIndex, 1);

        await sub.cancel();
        await worker.dispose();
      },
    );
  });
}
