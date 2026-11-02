import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:record/record.dart';

import '../core/constants/acoustic_constants.dart';
import 'audio_source_interface.dart';

/// Converts raw 16-bit signed PCM little-endian byte chunks to normalized `Float32List` samples in `[-1.0, 1.0]`.
///
/// Defensively handles unaligned byte offsets and uneven buffer lengths.
Float32List pcm16BytesToFloat32(Uint8List chunk) {
  final sampleCount = chunk.lengthInBytes ~/ 2;
  if (sampleCount <= 0) return Float32List(0);

  final floatList = Float32List(sampleCount);
  const normFactor = 1.0 / 32768.0;

  if (chunk.offsetInBytes % 2 == 0) {
    final int16List = chunk.buffer.asInt16List(
      chunk.offsetInBytes,
      sampleCount,
    );
    for (var i = 0; i < sampleCount; i++) {
      floatList[i] = (int16List[i] * normFactor).clamp(-1.0, 1.0);
    }
  } else {
    final byteData = ByteData.sublistView(chunk);
    for (var i = 0; i < sampleCount; i++) {
      final sampleInt16 = byteData.getInt16(i * 2, Endian.little);
      floatList[i] = (sampleInt16 * normFactor).clamp(-1.0, 1.0);
    }
  }

  return floatList;
}

/// Abstract platform driver decoupling microphone hardware plugins from business logic.
abstract class MicrophoneDriver {
  /// Checks whether microphone recording permission has been granted.
  Future<bool> hasPermission();

  /// Starts streaming 16-bit mono PCM bytes from the microphone at [sampleRate].
  Future<Stream<Uint8List>> startStream(int sampleRate);

  /// Pauses the audio capture hardware.
  Future<void> pause();

  /// Resumes the audio capture hardware from a paused state.
  Future<void> resume();

  /// Stops streaming and releases active audio capture session.
  Future<void> stop();

  /// Permanently disposes native recording resources.
  Future<void> dispose();
}

/// Production implementation of [MicrophoneDriver] powered by the cross-platform `record` plugin.
class RecordPluginMicrophoneDriver implements MicrophoneDriver {
  RecordPluginMicrophoneDriver({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<Stream<Uint8List>> startStream(int sampleRate) async {
    return _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        // Crucial acoustic tuning settings: disable voice processing algorithms
        // so musical overtone resonances are not attenuated or classified as ambient noise.
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      ),
    );
  }

  @override
  Future<void> pause() => _recorder.pause();

  @override
  Future<void> resume() => _recorder.resume();

  @override
  Future<void> stop() async {
    try {
      await _recorder.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (_) {}
  }
}

/// Real-time platform microphone audio source implementing [AudioSource].
///
/// Features:
/// - 16-bit PCM streaming converted to normalized `Float32List` single-channel frames.
/// - Automatic app lifecycle management via [WidgetsBindingObserver] (suspends recording
///   in background to extinguish privacy indicators and save battery; resumes on foreground).
/// - Dynamic permission check and structured error propagation.
/// - Injectable [MicrophoneDriver] for deterministic unit and integration testing.
class MicrophoneAudioSource with WidgetsBindingObserver implements AudioSource {
  MicrophoneAudioSource({
    MicrophoneDriver? driver,
    this.sampleRate = AcousticConstants.defaultSampleRate,
    this.channelCount = 1,
    this.handleLifecycleEvents = true,
  }) : _driver = driver ?? RecordPluginMicrophoneDriver(),
       assert(sampleRate > 0, 'Sample rate must be positive'),
       assert(channelCount == 1, 'Only mono audio is currently supported') {
    if (handleLifecycleEvents) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  final MicrophoneDriver _driver;

  @override
  final int sampleRate;

  @override
  final int channelCount;

  /// Whether this source automatically attaches to [WidgetsBinding] lifecycle changes.
  final bool handleLifecycleEvents;

  final StreamController<Float32List> _sampleController =
      StreamController<Float32List>.broadcast();
  final StreamController<AudioSourceState> _stateController =
      StreamController<AudioSourceState>.broadcast();

  AudioSourceState _state = AudioSourceState.idle;
  AudioSourceError? _lastError;
  StreamSubscription<Uint8List>? _streamSubscription;
  bool _wasRecordingBeforeSleep = false;
  bool _isDisposed = false;
  int? _leftoverByte;

  @override
  Stream<Float32List> get sampleStream => _sampleController.stream;

  @override
  Stream<AudioSourceState> get stateStream => _stateController.stream;

  @override
  AudioSourceState get state => _state;

  @override
  AudioSourceError? get lastError => _lastError;

  void _changeState(AudioSourceState newState) {
    if (_state != newState) {
      _state = newState;
      if (!_stateController.isClosed) {
        _stateController.add(newState);
      }
    }
  }

  void _checkNotDisposed() {
    if (_isDisposed) {
      throw const AudioSourceClosedError(
        'MicrophoneAudioSource is already disposed',
      );
    }
  }

  @override
  Future<void> start() async {
    _checkNotDisposed();
    if (_state == AudioSourceState.recording) return;

    try {
      final hasPermission = await _driver.hasPermission();
      if (!hasPermission) {
        const error = PermissionDeniedError(isPermanentlyDenied: false);
        _lastError = error;
        _changeState(AudioSourceState.error);
        if (!_sampleController.isClosed) {
          _sampleController.addError(error);
        }
        return;
      }

      await _streamSubscription?.cancel();
      final byteStream = await _driver.startStream(sampleRate);

      _lastError = null;
      _leftoverByte = null;
      _changeState(AudioSourceState.recording);

      _streamSubscription = byteStream.listen(
        (chunk) {
          Uint8List alignedChunk;
          if (_leftoverByte != null) {
            alignedChunk = Uint8List(chunk.length + 1);
            alignedChunk[0] = _leftoverByte!;
            alignedChunk.setRange(1, alignedChunk.length, chunk);
            _leftoverByte = null;
          } else {
            alignedChunk = chunk;
          }

          if (alignedChunk.length % 2 != 0) {
            _leftoverByte = alignedChunk.last;
            alignedChunk = Uint8List.sublistView(
              alignedChunk,
              0,
              alignedChunk.length - 1,
            );
          }

          final floatSamples = pcm16BytesToFloat32(alignedChunk);
          if (floatSamples.isNotEmpty && !_sampleController.isClosed) {
            _sampleController.add(floatSamples);
          }
        },
        onError: (Object error) {
          final sourceError = MicrophoneUnavailableError(error.toString());
          _lastError = sourceError;
          _changeState(AudioSourceState.error);
          if (!_sampleController.isClosed) {
            _sampleController.addError(sourceError);
          }
        },
        onDone: () {
          if (_state == AudioSourceState.recording) {
            _changeState(AudioSourceState.idle);
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      final sourceError = MicrophoneUnavailableError(e.toString());
      _lastError = sourceError;
      _changeState(AudioSourceState.error);
      if (!_sampleController.isClosed) {
        _sampleController.addError(sourceError);
      }
    }
  }

  @override
  Future<void> pause() async {
    _checkNotDisposed();
    if (_state != AudioSourceState.recording) return;

    _changeState(AudioSourceState.paused);
    try {
      await _driver.pause();
    } catch (_) {}
  }

  @override
  Future<void> resume() async {
    _checkNotDisposed();
    if (_state == AudioSourceState.recording) return;

    if (_state == AudioSourceState.paused) {
      _changeState(AudioSourceState.recording);
      try {
        await _driver.resume();
      } catch (e) {
        // If resume fails on some platform drivers, fall back to clean start
        await start();
      }
    } else {
      await start();
    }
  }

  @override
  Future<void> stop() async {
    _checkNotDisposed();
    if (_state == AudioSourceState.idle) return;

    _changeState(AudioSourceState.idle);

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    try {
      await _driver.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _changeState(AudioSourceState.disposed);

    if (handleLifecycleEvents) {
      try {
        WidgetsBinding.instance.removeObserver(this);
      } catch (_) {}
    }

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    try {
      await _driver.stop();
      await _driver.dispose();
    } catch (_) {}

    await _sampleController.close();
    await _stateController.close();
  }

  /// Handles AppLifecycleState transitions to preserve privacy and battery.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    handleAppLifecycleChange(lifecycleState);
  }

  /// Explicitly processes app lifecycle changes (callable during testing without binding).
  Future<void> handleAppLifecycleChange(
    AppLifecycleState lifecycleState,
  ) async {
    if (_isDisposed) return;

    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (_state == AudioSourceState.recording) {
          _wasRecordingBeforeSleep = true;
          await pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (_wasRecordingBeforeSleep) {
          _wasRecordingBeforeSleep = false;
          await resume();
        }
        break;
      case AppLifecycleState.detached:
        await dispose();
        break;
    }
  }
}
