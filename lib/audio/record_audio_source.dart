// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'audio_source_interface.dart';

/// Real-time microphone audio input using the cross-platform record plugin.
///
/// Streams raw 16-bit linear PCM little-endian single-channel audio frames.
class RecordAudioSource implements AudioSource {
  RecordAudioSource({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final _pcmController = StreamController<Uint8List>.broadcast();
  final _errorController = StreamController<AudioSourceError>.broadcast();
  StreamSubscription<Uint8List>? _recordSubscription;
  AudioSourceState _state = AudioSourceState.idle;
  bool _isDisposed = false;

  @override
  Stream<Uint8List> get pcmByteStream => _pcmController.stream;

  @override
  Stream<AudioSourceError> get errorStream => _errorController.stream;

  @override
  AudioSourceState get state => _state;

  @override
  Future<void> start({int sampleRate = 44100}) async {
    if (_isDisposed || _state == AudioSourceState.recording) return;

    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _state = AudioSourceState.error;
        _errorController.add(const PermissionDeniedError());
        return;
      }

      final stream = await _recorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: sampleRate,
          numChannels: 1,
        ),
      );

      _state = AudioSourceState.recording;
      _recordSubscription = stream.listen(
        (chunk) {
          if (!_pcmController.isClosed) {
            _pcmController.add(chunk);
          }
        },
        onError: (e) {
          _state = AudioSourceState.error;
          if (!_errorController.isClosed) {
            _errorController.add(MicrophoneUnavailableError(e.toString()));
          }
        },
        onDone: () {
          if (_state == AudioSourceState.recording) {
            _state = AudioSourceState.idle;
          }
        },
      );
    } catch (e) {
      _state = AudioSourceState.error;
      if (!_errorController.isClosed) {
        _errorController.add(MicrophoneUnavailableError(e.toString()));
      }
    }
  }

  @override
  Future<void> stop() async {
    if (_state != AudioSourceState.recording) return;
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    _state = AudioSourceState.idle;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await stop();

    try {
      await _recorder.dispose();
    } catch (_) {
      // Ignore if recorder was not created or already disposed on the native platform channel
    }

    if (!_pcmController.isClosed) {
      await _pcmController.close();
    }
    if (!_errorController.isClosed) {
      await _errorController.close();
    }
  }
}
