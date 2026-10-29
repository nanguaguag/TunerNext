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
}

/// The microphone could not be acquired or is being used by another application.
class MicrophoneUnavailableError extends AudioSourceError {
  const MicrophoneUnavailableError([this.message]);
  final String? message;
}

/// The hardware failed with an unrecoverable low-level read error code.
class AudioReadFailedError extends AudioSourceError {
  const AudioReadFailedError(this.code);
  final int code;
}

/// Abstraction layer decouples Flutter UI & DSP from concrete audio hardware plugins.
abstract class AudioSource {
  /// Stream of raw PCM single-channel audio frames.
  Stream<Float32List> get sampleStream;

  /// Current lifecycle state of the audio capture hardware.
  AudioSourceState get state;

  /// Starts or resumes microphone recording.
  Future<void> start();

  /// Pauses or stops microphone recording.
  Future<void> stop();

  /// Releases hardware and underlying stream controllers.
  Future<void> dispose();
}
