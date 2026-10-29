// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import '../dsp/tuner_pipeline_runner.dart';
import '../dsp/tuner_worker_protocol.dart';
import 'audio_source_interface.dart';
import 'circular_audio_buffer.dart';
import 'wave_writer.dart';

/// Central orchestrator connecting raw audio capture, circular windowing buffer,
/// lossless wave recording, and the DSP processing pipeline runner.
class AudioStreamController {
  AudioStreamController({
    required this.audioSource,
    required this.pipelineRunner,
    TunerDspConfig config = const TunerDspConfig(),
    WaveWriter? waveWriter,
  }) : _config = config,
       _waveWriter = waveWriter ?? WaveWriter(sampleRate: config.sampleRate) {
    _buffer = CircularAudioBuffer(
      windowSize: config.windowSize,
      overlap: config.overlap,
    );
  }

  final AudioSource audioSource;
  final TunerPipelineRunner pipelineRunner;
  final WaveWriter _waveWriter;
  late CircularAudioBuffer _buffer;
  TunerDspConfig _config;

  StreamSubscription<Uint8List>? _pcmSubscription;
  StreamSubscription<AudioSourceError>? _errorSubscription;
  final _errorController = StreamController<AudioSourceError>.broadcast();

  bool _isRunning = false;

  WaveWriter get waveWriter => _waveWriter;
  CircularAudioBuffer get buffer => _buffer;
  TunerDspConfig get config => _config;
  bool get isRunning => _isRunning;

  Stream<TunerWorkerResult> get results => pipelineRunner.results;
  Stream<AudioSourceError> get errors => _errorController.stream;

  /// Starts audio capture and real-time DSP analysis.
  Future<void> start() async {
    if (_isRunning) return;

    _buffer.reset();
    pipelineRunner.reset();

    _pcmSubscription = audioSource.pcmByteStream.listen(_onPcmChunk);
    _errorSubscription = audioSource.errorStream.listen((err) {
      if (!_errorController.isClosed) {
        _errorController.add(err);
      }
    });

    try {
      await audioSource.start(sampleRate: _config.sampleRate);
      _isRunning = true;
    } catch (e) {
      _isRunning = false;
      await _pcmSubscription?.cancel();
      await _errorSubscription?.cancel();
      rethrow;
    }
  }

  void _onPcmChunk(Uint8List chunk) {
    // 1. Append to WaveWriter if enabled
    if (_waveWriter.isEnabled) {
      _waveWriter.appendPcm16Bytes(chunk);
    }

    // 2. Ingest into Circular Audio Window Buffer
    _buffer.writePcm16Bytes(chunk);

    // 3. Extract and dispatch all completed overlapping windows
    while (_buffer.hasNextWindow()) {
      final framePosition = _buffer.currentWindowFramePosition;
      final window = _buffer.readNextWindow();
      if (window != null) {
        pipelineRunner.processFrame(window, framePosition);
      }
    }
  }

  /// Ingests normalized float samples directly (used in testing or simulation).
  void ingestFloatSamples(Float32List samples) {
    if (_waveWriter.isEnabled) {
      _waveWriter.appendSamples(samples);
    }
    _buffer.writeSamples(samples);

    while (_buffer.hasNextWindow()) {
      final framePosition = _buffer.currentWindowFramePosition;
      final window = _buffer.readNextWindow();
      if (window != null) {
        pipelineRunner.processFrame(window, framePosition);
      }
    }
  }

  /// Reconfigures DSP parameters or buffer window sizes on-the-fly.
  void updateConfig(TunerDspConfig config) {
    final windowSizeChanged = config.windowSize != _config.windowSize;
    final overlapChanged = config.overlap != _config.overlap;

    _config = config;

    if (windowSizeChanged || overlapChanged) {
      _buffer.reconfigure(
        windowSize: config.windowSize,
        overlap: config.overlap,
      );
    }

    pipelineRunner.updateConfig(config);
  }

  /// Stops audio streaming and clears buffers.
  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;

    await _pcmSubscription?.cancel();
    _pcmSubscription = null;
    await _errorSubscription?.cancel();
    _errorSubscription = null;

    await audioSource.stop();
    _buffer.reset();
    pipelineRunner.reset();
  }

  /// Releases all resources.
  Future<void> dispose() async {
    await stop();
    await audioSource.dispose();
    await pipelineRunner.dispose();
    await _errorController.close();
  }
}
