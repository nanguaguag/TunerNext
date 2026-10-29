import 'dart:typed_data';

/// Common data packet representing the raw output of pitch detection prior to smoothing.
class PitchDetectionResult {
  const PitchDetectionResult({
    required this.frequency,
    required this.confidence,
    required this.periodSamples,
    required this.isSilence,
    this.noiseRatio = 0.0,
    this.harmonicEnergy = 0.0,
    this.inharmonicity = 0.0,
  });

  /// Detected fundamental frequency in Hertz, or 0.0 if unvoiced / silent.
  final double frequency;

  /// Detection clarity or confidence metric normalized to [0.0, 1.0].
  final double confidence;

  /// Period lag in samples ($f_0 = f_s / \tau$).
  final double periodSamples;

  /// True if signal level is below silence threshold or lacks periodicity.
  final bool isSilence;

  /// Non-periodic noise ratio [0.0, 1.0].
  final double noiseRatio;

  /// Absolute harmonic energy in the signal.
  final double harmonicEnergy;

  /// Estimated string inharmonicity factor B.
  final double inharmonicity;

  /// Unvoiced / silent result constant.
  static const silence = PitchDetectionResult(
    frequency: 0.0,
    confidence: 0.0,
    periodSamples: 0.0,
    isSilence: true,
    noiseRatio: 1.0,
  );
}

/// Abstract contract for all modular pitch detection engines.
abstract class PitchDetector {
  /// Evaluates the input time-domain PCM samples [samples] and returns the detected pitch.
  PitchDetectionResult detectPitch({
    required Float32List samples,
    required int sampleRate,
    double frequencyMin = 16.0,
    double frequencyMax = 20000.0,
    int? framePosition,
  });

  /// Resets internal state (buffers, filters, history).
  void reset();
}
