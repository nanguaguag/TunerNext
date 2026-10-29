// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import '../domain/musical_scale/musical_scale.dart';
import '../domain/tuning/tuning_target_computer.dart';
import 'tuner_dsp_pipeline.dart';
import 'tuner_worker_protocol.dart';

/// Common interface for executing the DSP analysis pipeline either in the
/// current thread or in a background Isolate.
abstract class TunerPipelineRunner {
  /// Stream of calculated pitch, deviation, and tuning evaluations.
  Stream<TunerWorkerResult> get results;

  /// Stream of non-fatal calculation errors or warnings.
  Stream<String> get errors;

  /// Whether the pipeline is initialized and ready to accept audio frames.
  bool get isReady;

  /// Ingests a window of [samples] at [frameIndex] for pitch detection and tuning.
  void processFrame(Float32List samples, int frameIndex);

  /// Dynamically updates DSP, temperament, or instrument configuration.
  void updateConfig(TunerDspConfig config);

  /// Resets internal filters, smoothens, and octave jump gate history.
  void reset();

  /// Shuts down pipeline and closes all stream controllers.
  Future<void> dispose();
}

/// Synchronous in-isolate implementation of [TunerPipelineRunner].
///
/// Ideal for deterministic unit tests, headless benchmarks, and immediate execution.
class TunerSyncPipelineRunner implements TunerPipelineRunner {
  TunerSyncPipelineRunner({this._config = const TunerDspConfig()}) {
    _initPipeline();
  }

  TunerDspConfig _config;
  late TunerDspPipeline _dspPipeline;
  late MusicalScale _scale;
  late TuningTargetComputer _targetComputer;

  final _resultController = StreamController<TunerWorkerResult>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  bool _isDisposed = false;

  @override
  Stream<TunerWorkerResult> get results => _resultController.stream;

  @override
  Stream<String> get errors => _errorController.stream;

  @override
  bool get isReady => !_isDisposed;

  void _initPipeline() {
    _dspPipeline = TunerDspPipeline(
      pitchAlgorithm: _config.pitchAlgorithm,
      weightingMode: _config.weightingMode,
      octaveJumpGateEnabled: _config.octaveJumpGateEnabled,
      medianFilterEnabled: _config.medianFilterEnabled,
      movingAverageCount: _config.movingAverageCount,
      frequencyMin: _config.frequencyMin,
      frequencyMax: _config.frequencyMax,
    );

    _scale = MusicalScale(
      temperament: _config.temperament,
      referenceFrequency: _config.referenceFrequency,
      referenceNote: _config.referenceNote,
    );

    _targetComputer = TuningTargetComputer(
      scale: _scale,
      instrumentStrings: _config.instrumentStrings,
      inTuneToleranceCents: _config.inTuneToleranceCents,
    );
  }

  @override
  void updateConfig(TunerDspConfig config) {
    if (_isDisposed) return;
    _config = config;
    _initPipeline();
  }

  @override
  void processFrame(Float32List samples, int frameIndex) {
    if (_isDisposed) return;

    try {
      final pitchResult = _dspPipeline.processFrame(
        samples,
        sampleRate: _config.sampleRate,
        frequencyMin: _config.frequencyMin,
        frequencyMax: _config.frequencyMax,
        framePosition: frameIndex,
      );

      final evaluation = _targetComputer.evaluate(
        frequency: pitchResult.frequency,
        manualTargetNote: _config.manualTargetNote,
      );

      final timestampUs = DateTime.now().microsecondsSinceEpoch;

      final result = TunerWorkerResult(
        evaluation: evaluation,
        pitchResult: pitchResult,
        frameIndex: frameIndex,
        timestampUs: timestampUs,
      );

      if (!_resultController.isClosed) {
        _resultController.add(result);
      }
    } catch (e, stack) {
      if (!_errorController.isClosed) {
        _errorController.add('DSP Error at frame $frameIndex: $e\n$stack');
      }
    }
  }

  @override
  void reset() {
    if (_isDisposed) return;
    _dspPipeline.reset();
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await _resultController.close();
    await _errorController.close();
  }
}
