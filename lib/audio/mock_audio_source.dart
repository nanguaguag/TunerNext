// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'audio_source_interface.dart';

/// Mock audio capture source for deterministic testing and synthetic tone injection.
class MockAudioSource implements AudioSource {
  MockAudioSource({this.autoPlayPeriodic = false});

  final bool autoPlayPeriodic;
  final _pcmController = StreamController<Uint8List>.broadcast();
  final _errorController = StreamController<AudioSourceError>.broadcast();
  AudioSourceState _state = AudioSourceState.idle;
  Timer? _periodicTimer;
  int _currentSampleRate = 44100;
  int _phaseIndex = 0;

  double syntheticFrequency = 440.0;
  double syntheticAmplitude = 0.8;
  bool emitSilence = false;

  @override
  Stream<Uint8List> get pcmByteStream => _pcmController.stream;

  @override
  Stream<AudioSourceError> get errorStream => _errorController.stream;

  @override
  AudioSourceState get state => _state;

  @override
  Future<void> start({int sampleRate = 44100}) async {
    _currentSampleRate = sampleRate;
    _state = AudioSourceState.recording;

    if (autoPlayPeriodic) {
      _periodicTimer?.cancel();
      // Generate chunks every 25ms (e.g. 1102 samples @ 44.1kHz)
      const intervalMs = 25;
      final chunkSize = (sampleRate * (intervalMs / 1000.0)).round();

      _periodicTimer = Timer.periodic(
        const Duration(milliseconds: intervalMs),
        (_) {
          if (_state == AudioSourceState.recording) {
            pushSineChunk(
              frequency: syntheticFrequency,
              numSamples: chunkSize,
              amplitude: emitSilence ? 0.0 : syntheticAmplitude,
              sampleRate: _currentSampleRate,
            );
          }
        },
      );
    }
  }

  /// Injects a chunk of synthetic sine wave samples as 16-bit PCM bytes.
  void pushSineChunk({
    required double frequency,
    required int numSamples,
    double amplitude = 0.8,
    int? sampleRate,
  }) {
    final sr = sampleRate ?? _currentSampleRate;
    final byteData = ByteData(numSamples * 2);

    for (var i = 0; i < numSamples; i++) {
      final t = (_phaseIndex + i) / sr;
      final sampleVal = amplitude * math.sin(2.0 * math.pi * frequency * t);
      final clamped = sampleVal.clamp(-1.0, 1.0);
      final shortVal = (clamped * 32767.0).round().clamp(-32768, 32767);
      byteData.setInt16(i * 2, shortVal, Endian.little);
    }
    _phaseIndex += numSamples;

    if (!_pcmController.isClosed) {
      _pcmController.add(byteData.buffer.asUint8List());
    }
  }

  /// Directly injects raw PCM bytes.
  void pushBytes(Uint8List bytes) {
    if (!_pcmController.isClosed) {
      _pcmController.add(bytes);
    }
  }

  /// Simulates a capture error.
  void emitError(AudioSourceError error) {
    _state = AudioSourceState.error;
    if (!_errorController.isClosed) {
      _errorController.add(error);
    }
  }

  @override
  Future<void> stop() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _state = AudioSourceState.idle;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _pcmController.close();
    await _errorController.close();
  }
}
