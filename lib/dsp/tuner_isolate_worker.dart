// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import '../domain/musical_scale/musical_scale.dart';
import '../domain/tuning/tuning_target_computer.dart';
import 'tuner_dsp_pipeline.dart';
import 'tuner_pipeline_runner.dart';
import 'tuner_worker_protocol.dart';

/// Background Isolate worker executing real-time DSP pitch detection,
/// harmonic extraction, and musical scale evaluation without blocking the UI thread.
class TunerIsolateWorker implements TunerPipelineRunner {
  TunerIsolateWorker({TunerDspConfig initialConfig = const TunerDspConfig()})
    : _config = initialConfig {
    _spawnWorker();
  }

  TunerDspConfig _config;
  Isolate? _isolate;
  ReceivePort? _mainReceivePort;
  SendPort? _workerSendPort;

  final _resultController = StreamController<TunerWorkerResult>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _readyCompleter = Completer<void>();
  bool _isDisposed = false;

  @override
  Stream<TunerWorkerResult> get results => _resultController.stream;

  @override
  Stream<String> get errors => _errorController.stream;

  @override
  bool get isReady => _readyCompleter.isCompleted && !_isDisposed;

  /// Future that completes when the background isolate has initialized.
  Future<void> get waitUntilReady => _readyCompleter.future;

  Future<void> _spawnWorker() async {
    _mainReceivePort = ReceivePort();

    _mainReceivePort!.listen((message) {
      if (message is SendPort) {
        _workerSendPort = message;
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.complete();
        }
      } else if (message is TunerWorkerResult) {
        if (!_resultController.isClosed) {
          _resultController.add(message);
        }
      } else if (message is String) {
        if (!_errorController.isClosed) {
          _errorController.add(message);
        }
      }
    });

    try {
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _IsolateInitParams(
          sendPort: _mainReceivePort!.sendPort,
          config: _config,
        ),
      );
    } catch (e, stack) {
      if (!_errorController.isClosed) {
        _errorController.add('Failed to spawn DSP Isolate: $e\n$stack');
      }
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.completeError(e);
      }
    }
  }

  @override
  void processFrame(Float32List samples, int frameIndex) {
    if (!isReady || _workerSendPort == null || _isDisposed) return;
    _workerSendPort!.send(
      TunerCommandProcessFrame(samples: samples, frameIndex: frameIndex),
    );
  }

  @override
  void updateConfig(TunerDspConfig config) {
    _config = config;
    if (_workerSendPort != null && !_isDisposed) {
      _workerSendPort!.send(TunerCommandUpdateConfig(config));
    }
  }

  @override
  void reset() {
    if (_workerSendPort != null && !_isDisposed) {
      _workerSendPort!.send(const TunerCommandReset());
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      _workerSendPort?.send(const TunerCommandDispose());
    } catch (_) {}

    _mainReceivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    await _resultController.close();
    await _errorController.close();
  }

  /// Entry point for the background Isolate thread.
  static void _isolateEntryPoint(_IsolateInitParams params) {
    final workerReceivePort = ReceivePort();
    // 1. Handshake: send worker's command port back to main isolate
    params.sendPort.send(workerReceivePort.sendPort);

    var config = params.config;

    late TunerDspPipeline dspPipeline;
    late MusicalScale scale;
    late TuningTargetComputer targetComputer;

    void initPipeline() {
      dspPipeline = TunerDspPipeline(
        pitchAlgorithm: config.pitchAlgorithm,
        weightingMode: config.weightingMode,
        octaveJumpGateEnabled: config.octaveJumpGateEnabled,
        medianFilterEnabled: config.medianFilterEnabled,
        movingAverageCount: config.movingAverageCount,
        frequencyMin: config.frequencyMin,
        frequencyMax: config.frequencyMax,
      );

      scale = MusicalScale(
        temperament: config.temperament,
        referenceFrequency: config.referenceFrequency,
        referenceNote: config.referenceNote,
      );

      targetComputer = TuningTargetComputer(
        scale: scale,
        instrumentStrings: config.instrumentStrings,
        inTuneToleranceCents: config.inTuneToleranceCents,
      );
    }

    initPipeline();

    // 2. Command processing loop
    workerReceivePort.listen((command) {
      if (command is TunerCommandProcessFrame) {
        try {
          final pitchResult = dspPipeline.processFrame(
            command.samples,
            sampleRate: config.sampleRate,
            frequencyMin: config.frequencyMin,
            frequencyMax: config.frequencyMax,
            framePosition: command.frameIndex,
          );

          final evaluation = targetComputer.evaluate(
            frequency: pitchResult.frequency,
            manualTargetNote: config.manualTargetNote,
          );

          final timestampUs = DateTime.now().microsecondsSinceEpoch;

          final result = TunerWorkerResult(
            evaluation: evaluation,
            pitchResult: pitchResult,
            frameIndex: command.frameIndex,
            timestampUs: timestampUs,
          );

          params.sendPort.send(result);
        } catch (e, stack) {
          params.sendPort.send(
            'Isolate DSP Error at frame ${command.frameIndex}: $e\n$stack',
          );
        }
      } else if (command is TunerCommandUpdateConfig) {
        config = command.config;
        initPipeline();
      } else if (command is TunerCommandReset) {
        dspPipeline.reset();
      } else if (command is TunerCommandDispose) {
        workerReceivePort.close();
      }
    });
  }
}

class _IsolateInitParams {
  const _IsolateInitParams({required this.sendPort, required this.config});
  final SendPort sendPort;
  final TunerDspConfig config;
}
