import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../core/constants/acoustic_constants.dart';
import '../data/preferences/app_preferences.dart';
import '../ui/plot/line_coordinates.dart';
import 'audio_messages.dart';
import 'audio_processing_isolate.dart';
import 'audio_ring_buffer.dart';
import 'audio_source_interface.dart';
import 'microphone_audio_source.dart';
import 'mock_audio_source.dart';
import 'wave_writer.dart';

/// Top-level coordinator tying together microphone input, the background DSP isolate,
/// real-time telemetry distribution, and WAV recording buffers.
class AudioPipelineCoordinator {
  AudioPipelineCoordinator({
    this.sampleRate = AcousticConstants.defaultSampleRate,
  }) : _waveRingBuffer = AudioRingBuffer(
         capacity: sampleRate * 10,
       ); // 10s ring buffer

  final int sampleRate;
  final AudioRingBuffer _waveRingBuffer;

  AudioProcessingIsolate? _isolate;
  AudioSource? _audioSource;
  StreamSubscription<Float32List>? _sampleSubscription;
  StreamSubscription<AudioAnalysisResult>? _resultSubscription;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  final StreamController<AudioAnalysisResult> _analysisStreamController =
      StreamController<AudioAnalysisResult>.broadcast();
  Stream<AudioAnalysisResult> get analysisStream =>
      _analysisStreamController.stream;

  /// Starts the end-to-end audio pipeline.
  ///
  /// Spawns the background Isolate, attempts to start platform microphone capture,
  /// and automatically falls back to [MockAudioSource] if hardware is unavailable.
  Future<void> start({
    required AppPreferences preferences,
    bool forceMock = false,
  }) async {
    if (_isRunning) return;

    try {
      final stride =
          (preferences.windowSize * (1.0 - preferences.overlapPercent / 100.0))
              .round()
              .clamp(128, preferences.windowSize);

      // 1. Spawn and initialize background DSP worker isolate
      _isolate = AudioProcessingIsolate();
      await _isolate!.start(
        sampleRate: sampleRate,
        windowSize: preferences.windowSize,
        stride: stride,
        algorithm: preferences.pitchAlgorithm,
        weightingMode: preferences.acousticWeighting,
        includeSpectrum: true,
        includeWaveformSnapshot: true,
        maxFps: 60,
      );

      // 2. Initialize Audio Source (Microphone with Mock fallback)
      if (forceMock) {
        _audioSource = MockAudioSource(
          sampleRate: sampleRate,
          initialSignal: MockHarmonicSignal(
            fundamentalFrequency: 440.0,
            harmonicAmplitudes: const [1.0, 0.5, 0.25],
            overallAmplitude: 0.8,
          ),
          isRealtime: true,
        );
        await _audioSource!.start();
      } else {
        try {
          final micSource = MicrophoneAudioSource(sampleRate: sampleRate);
          await micSource.start();
          _audioSource = micSource;
        } catch (_) {
          // Fallback to Mock source if microphone is unavailable or running in tests
          _audioSource = MockAudioSource(
            sampleRate: sampleRate,
            initialSignal: MockHarmonicSignal(
              fundamentalFrequency: 440.0,
              harmonicAmplitudes: const [1.0, 0.5, 0.25],
              overallAmplitude: 0.8,
            ),
            isRealtime: true,
          );
          await _audioSource!.start();
        }
      }

      // 3. Connect audio stream -> isolate & wave buffer
      _sampleSubscription = _audioSource!.sampleStream.listen(
        (Float32List chunk) {
          _waveRingBuffer.write(chunk);
          _isolate?.postSamples(chunk);
        },
        onError: (Object error) {
          debugPrint('Audio pipeline sample stream error: $error');
        },
      );

      // 4. Connect isolate results -> telemetry broadcast
      _resultSubscription = _isolate!.throttledResultStream.listen((
        AudioAnalysisResult result,
      ) {
        if (!_analysisStreamController.isClosed) {
          _analysisStreamController.add(result);
        }
      });

      _isRunning = true;
    } catch (e, st) {
      debugPrint('Failed to start audio pipeline coordinator: $e\n$st');
      await stop();
    }
  }

  /// Hot-reconfigures the DSP pipeline with updated preferences.
  void reconfigure(AppPreferences preferences) {
    if (_isolate == null || !_isRunning) return;

    final stride =
        (preferences.windowSize * (1.0 - preferences.overlapPercent / 100.0))
            .round()
            .clamp(128, preferences.windowSize);

    _isolate!.configure(
      algorithm: preferences.pitchAlgorithm,
      weightingMode: preferences.acousticWeighting,
      windowSize: preferences.windowSize,
      stride: stride,
      includeSpectrum: true,
      includeWaveformSnapshot: true,
    );
  }

  /// Converts spectrum amplitudes from an analysis result into [LineCoordinates].
  static LineCoordinates? convertSpectrumToLineCoordinates(
    Float32List? spectrum, {
    int sampleRate = AcousticConstants.defaultSampleRate,
    int windowSize = 2048,
    double maxFrequency = 3000.0,
  }) {
    if (spectrum == null || spectrum.isEmpty) return null;

    final points = <Offset>[];
    final numBins = spectrum.length;
    final binWidth = sampleRate / windowSize;

    double maxVal = 0.0001;
    for (var i = 0; i < numBins; i++) {
      if (spectrum[i] > maxVal) maxVal = spectrum[i];
    }

    // Step to avoid excessive drawing overhead (aim for ~100-200 points)
    final step = math.max<int>(1, (numBins / 150).floor());

    for (var i = 0; i < numBins; i += step) {
      final freq = i * binWidth;
      if (freq > maxFrequency) break;
      final normalizedAmp = (spectrum[i] / maxVal).clamp(0.0, 1.0);
      points.add(Offset(freq, normalizedAmp));
    }

    return points.isNotEmpty ? LineCoordinates(points) : null;
  }

  /// Converts time-domain waveform snapshot into [LineCoordinates].
  static LineCoordinates? convertWaveformToLineCoordinates(
    Float32List? snapshot, {
    int sampleRate = AcousticConstants.defaultSampleRate,
  }) {
    if (snapshot == null || snapshot.isEmpty) return null;

    final points = <Offset>[];
    final len = snapshot.length;
    final step = math.max<int>(1, (len / 200).floor());

    for (var i = 0; i < len; i += step) {
      final t = i / sampleRate;
      final y = (0.5 + 0.5 * snapshot[i]).clamp(0.0, 1.0);
      points.add(Offset(t, y));
    }

    return points.isNotEmpty ? LineCoordinates(points) : null;
  }

  /// Exports the latest [durationSeconds] of audio from the ring buffer as a WAV file.
  Uint8List? exportWavSnapshot({int durationSeconds = 1}) {
    if (durationSeconds <= 0) return null;
    final sampleCount = sampleRate * durationSeconds;
    final samples = _waveRingBuffer.getLatestSnapshot(sampleCount);
    if (samples.isEmpty) return null;

    return WaveWriter.encodeWavBytes(data: samples, sampleRate: sampleRate);
  }

  /// Gracefully stops audio capture and processing.
  Future<void> stop() async {
    _isRunning = false;

    await _sampleSubscription?.cancel();
    _sampleSubscription = null;

    await _resultSubscription?.cancel();
    _resultSubscription = null;

    try {
      await _audioSource?.stop();
      await _audioSource?.dispose();
    } catch (_) {}
    _audioSource = null;

    try {
      await _isolate?.dispose();
    } catch (_) {}
    _isolate = null;
  }

  /// Permanently disposes all resources.
  Future<void> dispose() async {
    await stop();
    await _analysisStreamController.close();
  }
}
