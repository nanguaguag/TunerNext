// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Life-cycle states of the audio input source.
enum AudioSourceState { idle, recording, paused, error }

/// Standardized error classification for audio hardware capture failures.
sealed class AudioSourceError {
  const AudioSourceError();
}

/// The user permanently or temporarily denied microphone permission.
class PermissionDeniedError extends AudioSourceError {
  const PermissionDeniedError({this.isPermanentlyDenied = false});
  final bool isPermanentlyDenied;

  @override
  String toString() =>
      'PermissionDeniedError(isPermanentlyDenied: $isPermanentlyDenied)';
}

/// The microphone could not be acquired or is being used by another application.
class MicrophoneUnavailableError extends AudioSourceError {
  const MicrophoneUnavailableError([this.message]);
  final String? message;

  @override
  String toString() => 'MicrophoneUnavailableError($message)';
}

/// The hardware failed with an unrecoverable low-level read error code.
class AudioReadFailedError extends AudioSourceError {
  const AudioReadFailedError(this.code);
  final int code;

  @override
  String toString() => 'AudioReadFailedError(code: $code)';
}

/// Abstraction layer decoupling Flutter UI & DSP from concrete audio hardware plugins.
abstract class AudioSource {
  /// Stream of raw PCM 16-bit mono little-endian byte chunks.
  Stream<Uint8List> get pcmByteStream;

  /// Stream of hardware or lifecycle error events.
  Stream<AudioSourceError> get errorStream;

  /// Current lifecycle state of the audio capture hardware.
  AudioSourceState get state;

  /// Starts or resumes audio capture at [sampleRate].
  Future<void> start({int sampleRate = 44100});

  /// Pauses or stops audio capture.
  Future<void> stop();

  /// Releases hardware and underlying stream controllers.
  Future<void> dispose();
}
