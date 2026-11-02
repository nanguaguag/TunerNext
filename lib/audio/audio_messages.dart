import 'dart:typed_data';

import '../domain/models/dsp_enums.dart';
import '../dsp/pipeline/tuner_dsp_pipeline.dart';

/// Sealed base class for messages sent from Main Isolate to Audio Worker Isolate.
sealed class MainToWorkerMessage {
  const MainToWorkerMessage();
}

/// Message carrying raw PCM Float32 audio samples to the worker isolate.
class AudioDataMessage extends MainToWorkerMessage {
  const AudioDataMessage(this.samples);

  final Float32List samples;
}

/// Message updating DSP configuration and analysis parameters.
class ConfigureDspMessage extends MainToWorkerMessage {
  const ConfigureDspMessage({
    this.algorithm,
    this.weightingMode,
    this.windowSize,
    this.stride,
    this.sampleRate,
    this.smootherOrder,
    this.includeWaveformSnapshot = true,
    this.snapshotSize = 1024,
    this.includeSpectrum = false,
  });

  final PitchAlgorithm? algorithm;
  final AcousticWeightingMode? weightingMode;
  final int? windowSize;
  final int? stride;
  final int? sampleRate;
  final int? smootherOrder;
  final bool includeWaveformSnapshot;
  final int snapshotSize;
  final bool includeSpectrum;
}

/// Message instructing worker isolate to reset internal buffers and filters.
class ResetDspMessage extends MainToWorkerMessage {
  const ResetDspMessage();
}

/// Message requesting worker isolate to gracefully terminate.
class DisposeWorkerMessage extends MainToWorkerMessage {
  const DisposeWorkerMessage();
}

/// Sealed base class for messages sent from Audio Worker Isolate back to Main Isolate.
sealed class WorkerToMainMessage {
  const WorkerToMainMessage();
}

/// Initial handshake message sent when worker isolate successfully spawns.
class WorkerReadyMessage extends WorkerToMainMessage {
  const WorkerReadyMessage();
}

/// Diagnostic or unrecoverable error message from worker isolate.
class WorkerErrorMessage extends WorkerToMainMessage {
  const WorkerErrorMessage(this.error, [this.stackTrace]);

  final String error;
  final String? stackTrace;

  @override
  String toString() => 'WorkerErrorMessage: $error\n$stackTrace';
}

/// Telemetry and detection result packet sent back to main isolate for UI rendering.
class AudioAnalysisResult extends WorkerToMainMessage {
  const AudioAnalysisResult({
    required this.rawFrequency,
    required this.smoothedFrequency,
    required this.confidence,
    required this.rms,
    required this.isSilence,
    required this.algorithm,
    required this.executionLatency,
    this.waveformSnapshot,
    this.spectrumAmplitudes,
    this.correlationValues,
    this.correlationTimes,
    this.correlationZeroPosition = 0.5,
    this.timestampMicros,
  });

  /// Factory creating an [AudioAnalysisResult] directly from [TunerPipelineResult].
  factory AudioAnalysisResult.fromPipelineResult(
    TunerPipelineResult pipelineResult, {
    Float32List? waveformSnapshot,
    Float32List? spectrumAmplitudes,
    Float32List? correlationValues,
    Float32List? correlationTimes,
    double correlationZeroPosition = 0.5,
    int? timestampMicros,
  }) {
    return AudioAnalysisResult(
      rawFrequency: pipelineResult.rawFrequency,
      smoothedFrequency: pipelineResult.smoothedFrequency,
      confidence: pipelineResult.confidence,
      rms: pipelineResult.rms,
      isSilence: pipelineResult.isSilence,
      algorithm: pipelineResult.algorithm,
      executionLatency: pipelineResult.executionTime,
      waveformSnapshot: waveformSnapshot,
      spectrumAmplitudes: spectrumAmplitudes,
      correlationValues: correlationValues,
      correlationTimes: correlationTimes,
      correlationZeroPosition: correlationZeroPosition,
      timestampMicros: timestampMicros,
    );
  }

  /// Raw detected frequency before smoothing.
  final double rawFrequency;

  /// Clean, smoothed frequency after median filtering and octave jump rejection.
  final double smoothedFrequency;

  /// Voicing clarity / periodicity confidence [0.0, 1.0].
  final double confidence;

  /// Time-domain RMS amplitude.
  final double rms;

  /// True if signal is below acoustic silence threshold.
  final bool isSilence;

  /// Detection engine algorithm applied.
  final PitchAlgorithm algorithm;

  /// Wall-clock latency taken by DSP pipeline on the worker thread.
  final Duration executionLatency;

  /// Recent time-domain waveform snapshot for oscilloscope rendering.
  final Float32List? waveformSnapshot;

  /// FFT magnitude spectrum for scientific frequency plot rendering.
  final Float32List? spectrumAmplitudes;

  /// Normalized autocorrelation values for scientific correlation plot rendering.
  final Float32List? correlationValues;

  /// Time shifts / lags corresponding to [correlationValues].
  final Float32List? correlationTimes;

  /// The normalized Y-position of 0.0 correlation baseline.
  final double correlationZeroPosition;

  /// Timestamp in microseconds when this frame was analyzed.
  final int? timestampMicros;

  /// Silent default result constant.
  static const silence = AudioAnalysisResult(
    rawFrequency: 0.0,
    smoothedFrequency: 0.0,
    confidence: 0.0,
    rms: 0.0,
    isSilence: true,
    algorithm: PitchAlgorithm.mpm,
    executionLatency: Duration.zero,
    correlationZeroPosition: 0.5,
  );
}
