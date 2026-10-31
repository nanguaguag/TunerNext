import 'dart:typed_data';

/// Life-cycle states of the audio input source.
enum AudioSourceState { idle, recording, paused, error, disposed }

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
  String toString() => 'MicrophoneUnavailableError(${message ?? ''})';
}

/// The hardware failed with an unrecoverable low-level read error code.
class AudioReadFailedError extends AudioSourceError {
  const AudioReadFailedError(this.code);
  final int code;

  @override
  String toString() => 'AudioReadFailedError(code: $code)';
}

/// Audio buffer overflow error when consumer falls behind producer.
class AudioBufferOverflowError extends AudioSourceError {
  const AudioBufferOverflowError([this.message]);
  final String? message;

  @override
  String toString() => 'AudioBufferOverflowError(${message ?? ''})';
}

/// Audio source is already closed or disposed.
class AudioSourceClosedError extends AudioSourceError {
  const AudioSourceClosedError([this.message]);
  final String? message;

  @override
  String toString() => 'AudioSourceClosedError(${message ?? ''})';
}

/// Abstraction layer decouples Flutter UI & DSP from concrete audio hardware plugins.
abstract class AudioSource {
  /// Stream of raw PCM single-channel audio frames normalized to [-1.0, 1.0].
  Stream<Float32List> get sampleStream;

  /// Stream of state changes for reactive UI and controller observation.
  Stream<AudioSourceState> get stateStream;

  /// Current lifecycle state of the audio capture source.
  AudioSourceState get state;

  /// The most recent error encountered by the audio source, if any.
  AudioSourceError? get lastError;

  /// Audio sampling rate in Hertz (typically 44100 Hz).
  int get sampleRate;

  /// Number of channels (typically 1 for mono).
  int get channelCount;

  /// Starts or resumes recording/streaming.
  Future<void> start();

  /// Pauses recording/streaming.
  Future<void> pause();

  /// Resumes recording/streaming from paused state.
  Future<void> resume();

  /// Stops recording/streaming and resets to idle.
  Future<void> stop();

  /// Releases hardware and underlying stream controllers.
  Future<void> dispose();
}
