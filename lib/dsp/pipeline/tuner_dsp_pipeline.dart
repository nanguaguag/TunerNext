import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/models/dsp_enums.dart';
import '../filters/acoustic_weighting.dart';
import '../filters/outlier_removing_smoother.dart';
import '../filters/pitch_temporal_filter.dart';
import '../pitch/classic_pitch_detector.dart';
import '../pitch/mcleod_pitch_method.dart';
import '../pitch/pitch_detector_interface.dart';
import '../pitch/two_way_mismatch.dart';

/// Encapsulates the output of a single analysis frame processed by [TunerDspPipeline].
class TunerPipelineResult {
  const TunerPipelineResult({
    required this.rawFrequency,
    required this.smoothedFrequency,
    required this.confidence,
    required this.rms,
    required this.isSilence,
    required this.algorithm,
    required this.executionTime,
  });

  /// Raw instantaneous frequency in Hertz detected by the underlying engine.
  final double rawFrequency;

  /// Post-processed frequency in Hertz after median filtering, octave gate, and smoothing.
  final double smoothedFrequency;

  /// Detection clarity / confidence metric in `[0.0, 1.0]`.
  final double confidence;

  /// Time-domain root-mean-square amplitude.
  final double rms;

  /// True if frame is below silence threshold or contains no voiced tone.
  final bool isSilence;

  /// Pitch detection algorithm applied.
  final PitchAlgorithm algorithm;

  /// Wall-clock execution latency for processing the frame.
  final Duration executionTime;

  /// Silent / unvoiced result constant.
  static const silence = TunerPipelineResult(
    rawFrequency: 0.0,
    smoothedFrequency: 0.0,
    confidence: 0.0,
    rms: 0.0,
    isSilence: true,
    algorithm: PitchAlgorithm.mpm,
    executionTime: Duration.zero,
  );
}

/// Facade coordinating the full DSP analysis chain:
///
/// ```
/// Input PCM Samples
///        │
///        ▼
/// [RMS Silence Check] ──(silent)──> Return Silence
///        │
///        ▼
/// [Acoustic Weighting] (A-Weighting / C-Weighting / Flat)
///        │
///        ▼
/// [Pitch Engine Dispatcher] (MPM / TWM / Classic / HybridJacobsen)
///        │
///        ▼
/// [Octave Jump Gate] (Suppresses transient 2x/3x bow attacks)
///        │
///        ▼
/// [Pitch Median Filter] (3-tap single-sample spike suppressor)
///        │
///        ▼
/// [Outlier-Removing Smoother] (Multi-buffer online averager)
///        │
///        ▼
/// Output: TunerPipelineResult
/// ```
class TunerDspPipeline {
  /// Creates a configured [TunerDspPipeline].
  TunerDspPipeline({
    this.frameSize = 2048,
    this.algorithm = PitchAlgorithm.mpm,
    AcousticWeightingMode weightingMode = AcousticWeightingMode.none,
    this.useMedianFilter = true,
    this.useOctaveJumpGate = true,
    this.useSmoother = true,
    int smootherOrder = 3,
    this.frequencyMin = 16.0,
    this.frequencyMax = 20000.0,
    this.silenceThresholdRms = 1e-4,
  }) : _weightingMode = weightingMode,
       _weighting = AcousticWeighting.fromMode(weightingMode),
       _smootherOrder = smootherOrder,
       _classicDetector = ClassicPitchDetector(frameSize: frameSize),
       _mpmDetector = McLeodPitchDetector(),
       _twmDetector = TwoWayMismatchDetector(),
       _medianFilter = PitchMedianFilter(),
       _octaveJumpGate = OctaveJumpGate(),
       _smoother = OutlierRemovingSmoother(
         size: smootherOrder,
         minValue: frequencyMin,
         maxValue: frequencyMax,
       );

  /// Number of PCM samples required per analysis frame.
  final int frameSize;

  /// Active pitch detection algorithm.
  PitchAlgorithm algorithm;

  /// Active frequency weighting mode.
  AcousticWeightingMode _weightingMode;
  AcousticWeighting _weighting;

  /// Whether 3-tap median filtering is enabled.
  bool useMedianFilter;

  /// Whether octave jump fold-back gate is enabled.
  bool useOctaveJumpGate;

  /// Whether multi-buffer outlier-removing smoothing is enabled.
  bool useSmoother;

  /// Number of taps in the smoothing buffer.
  int _smootherOrder;

  /// Minimum allowable frequency in Hertz.
  final double frequencyMin;

  /// Maximum allowable frequency in Hertz.
  final double frequencyMax;

  /// RMS threshold below which signals are deemed silent.
  final double silenceThresholdRms;

  final ClassicPitchDetector _classicDetector;
  final McLeodPitchDetector _mpmDetector;
  final TwoWayMismatchDetector _twmDetector;
  final PitchMedianFilter _medianFilter;
  final OctaveJumpGate _octaveJumpGate;
  OutlierRemovingSmoother _smoother;

  AcousticWeightingMode get weightingMode => _weightingMode;
  AcousticWeighting get acousticWeighting => _weighting;
  int get smootherOrder => _smootherOrder;

  /// Switches the active pitch algorithm at runtime.
  void setAlgorithm(PitchAlgorithm newAlgorithm) {
    if (algorithm != newAlgorithm) {
      algorithm = newAlgorithm;
      reset();
    }
  }

  /// Updates the acoustic weighting mode.
  void setWeightingMode(AcousticWeightingMode mode) {
    if (_weightingMode != mode) {
      _weightingMode = mode;
      _weighting = AcousticWeighting.fromMode(mode);
    }
  }

  /// Updates the smoothing buffer order.
  void setSmootherOrder(int order) {
    if (_smootherOrder != order) {
      _smootherOrder = order;
      _smoother = OutlierRemovingSmoother(
        size: _smootherOrder,
        minValue: frequencyMin,
        maxValue: frequencyMax,
      );
    }
  }

  /// Selects the underlying [PitchDetector] matching [_algorithm].
  PitchDetector get _activeDetector {
    switch (algorithm) {
      case PitchAlgorithm.mpm:
        return _mpmDetector;
      case PitchAlgorithm.twm:
        return _twmDetector;
      case PitchAlgorithm.classic:
      case PitchAlgorithm.hybridJacobsen:
        return _classicDetector;
      case PitchAlgorithm.pyin:
        // pYIN falls back to MPM until slice 3.8
        return _mpmDetector;
    }
  }

  /// Processes an audio frame and returns complete analysis telemetry.
  TunerPipelineResult process(Float32List samples, {required int sampleRate}) {
    final stopwatch = Stopwatch()..start();

    if (samples.length < frameSize || sampleRate <= 0) {
      return TunerPipelineResult.silence;
    }

    // Step 1: RMS Energy check
    var sumSq = 0.0;
    for (var i = 0; i < frameSize; i++) {
      final s = samples[i];
      sumSq += s * s;
    }
    final rms = math.sqrt(sumSq / frameSize);

    if (rms < silenceThresholdRms) {
      _medianFilter.reset();
      _octaveJumpGate.reset();
      _smoother.reset();
      return TunerPipelineResult(
        rawFrequency: 0.0,
        smoothedFrequency: 0.0,
        confidence: 0.0,
        rms: rms,
        isSilence: true,
        algorithm: algorithm,
        executionTime: stopwatch.elapsed,
      );
    }

    // Step 2: Pitch Detection Engine Dispatch
    final detection = _activeDetector.detectPitch(
      samples: samples,
      sampleRate: sampleRate,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
    );

    if (detection.isSilence || detection.frequency <= 0.0) {
      _medianFilter.reset();
      _octaveJumpGate.reset();
      _smoother.reset();
      return TunerPipelineResult(
        rawFrequency: 0.0,
        smoothedFrequency: 0.0,
        confidence: detection.confidence,
        rms: rms,
        isSilence: true,
        algorithm: algorithm,
        executionTime: stopwatch.elapsed,
      );
    }

    // Step 3: Post-processing filtering chain
    var freq = detection.frequency;

    // 3a: Octave Jump Gate
    if (useOctaveJumpGate) {
      freq = _octaveJumpGate.filter(freq);
    }

    // 3b: Pitch Median Filter
    if (useMedianFilter) {
      freq = _medianFilter.filter(freq);
    }

    // 3c: Outlier-Removing Smoother
    var smoothed = freq;
    if (useSmoother) {
      final s = _smoother(freq);
      smoothed = (s > 0.0)
          ? s
          : (_smoother.smoothedValue > 0.0 ? _smoother.smoothedValue : freq);
    }

    return TunerPipelineResult(
      rawFrequency: detection.frequency,
      smoothedFrequency: smoothed,
      confidence: detection.confidence,
      rms: rms,
      isSilence: false,
      algorithm: algorithm,
      executionTime: stopwatch.elapsed,
    );
  }

  /// Resets all internal detector states, filters, and smoothing buffers.
  void reset() {
    _classicDetector.reset();
    _mpmDetector.reset();
    _twmDetector.reset();
    _medianFilter.reset();
    _octaveJumpGate.reset();
    _smoother.reset();
  }
}
