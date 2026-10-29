import 'dart:typed_data';
import '../core/constants/acoustic_constants.dart';
import '../domain/models/dsp_enums.dart';
import 'filters/acoustic_weighting.dart';
import 'filters/pitch_temporal_filter.dart';
import 'pitch/classic_pitch_detector.dart';
import 'pitch/mcleod_pitch_method.dart';
import 'pitch/pitch_detector_interface.dart';
import 'pitch/two_way_mismatch.dart';
import 'post_processing/outlier_removing_smoother.dart';

/// Top-level DSP pipeline that coordinates pitch detection, temporal filtering,
/// and adaptive outlier smoothing across different algorithm choices.
class TunerDspPipeline {
  TunerDspPipeline({
    this.pitchAlgorithm = PitchAlgorithm.classic,
    AcousticWeightingMode weightingMode = AcousticWeightingMode.none,
    this.octaveJumpGateEnabled = true,
    this.medianFilterEnabled = true,
    int movingAverageCount = AcousticConstants.defaultMovingAverageCount,
    double frequencyMin = AcousticConstants.defaultFrequencyMin,
    double frequencyMax = AcousticConstants.defaultFrequencyMax,
  }) : _weightingMode = weightingMode,
       _octaveGate = octaveJumpGateEnabled ? OctaveJumpGate() : null,
       _medianFilter = medianFilterEnabled ? PitchMedianFilter() : null,
       _smoother = OutlierRemovingSmoother(
         size: movingAverageCount,
         minValue: frequencyMin,
         maxValue: frequencyMax,
       ) {
    _initDetector();
    _weighting = AcousticWeighting.fromMode(weightingMode);
  }

  PitchAlgorithm pitchAlgorithm;
  AcousticWeightingMode _weightingMode;
  late AcousticWeighting _weighting;
  final bool octaveJumpGateEnabled;
  final bool medianFilterEnabled;

  AcousticWeightingMode get weightingMode => _weightingMode;
  set weightingMode(AcousticWeightingMode mode) {
    _weightingMode = mode;
    _weighting = AcousticWeighting.fromMode(mode);
  }

  AcousticWeighting get weighting => _weighting;
  PitchDetector get detector => _detector;

  final OctaveJumpGate? _octaveGate;
  final PitchMedianFilter? _medianFilter;
  final OutlierRemovingSmoother _smoother;
  late PitchDetector _detector;

  void _initDetector() {
    switch (pitchAlgorithm) {
      case PitchAlgorithm.classic:
        _detector = ClassicPitchDetector(useJacobsen: false);
        break;
      case PitchAlgorithm.hybridJacobsen:
        _detector = ClassicPitchDetector(useJacobsen: true);
        break;
      case PitchAlgorithm.mpm:
      case PitchAlgorithm.pyin:
        _detector = McLeodPitchDetector();
        break;
      case PitchAlgorithm.twm:
        _detector = TwoWayMismatchDetector();
        break;
    }
  }

  /// Processes raw audio frame [samples] at [sampleRate] and returns the final smoothed frequency.
  PitchDetectionResult processFrame(
    Float32List samples, {
    required int sampleRate,
    double frequencyMin = AcousticConstants.defaultFrequencyMin,
    double frequencyMax = AcousticConstants.defaultFrequencyMax,
  }) {
    final rawResult = _detector.detectPitch(
      samples: samples,
      sampleRate: sampleRate,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
    );

    if (rawResult.isSilence || rawResult.frequency <= 0.0) {
      _octaveGate?.reset();
      _medianFilter?.reset();
      return PitchDetectionResult.silence;
    }

    var freq = rawResult.frequency;
    if (_octaveGate != null) {
      freq = _octaveGate.filter(freq);
    }
    if (_medianFilter != null) {
      freq = _medianFilter.filter(freq);
    }

    final smoothedFreq = _smoother.smooth(freq);
    return PitchDetectionResult(
      frequency: smoothedFreq > 0.0 ? smoothedFreq : freq,
      confidence: rawResult.confidence,
      periodSamples: rawResult.periodSamples,
      isSilence: false,
      noiseRatio: rawResult.noiseRatio,
      harmonicEnergy: rawResult.harmonicEnergy,
      inharmonicity: rawResult.inharmonicity,
    );
  }

  void reset() {
    _detector.reset();
    _octaveGate?.reset();
    _medianFilter?.reset();
    _smoother.reset();
  }
}
