/// Core acoustic and digital signal processing constants for Tuner.
class AcousticConstants {
  AcousticConstants._();

  /// Default audio sampling rate in Hertz.
  static const int defaultSampleRate = 44100;

  /// Absolute silence threshold in root-mean-square amplitude (-80 dBFS).
  /// Signals below this threshold are immediately treated as silence,
  /// preventing spurious G1-D3 jumps caused by ambient 50Hz/60Hz AC mains hum.
  static const double silenceThresholdRms = 1e-4;

  /// Minimum autocorrelation zero-lag energy R_xx[0] required for periodic detection.
  static const double minZeroLagEnergy = 1e-9;

  /// Minimum normalized peak ratio in autocorrelation: peak >= 0.15 * R_xx[0].
  /// Non-periodic random white noise produces peaks below this ratio.
  static const double minNormalizedPeakRatio = 0.15;

  /// Minimum measurable pitch frequency in Hertz.
  static const double defaultFrequencyMin = 16.0;

  /// Maximum measurable pitch frequency in Hertz.
  static const double defaultFrequencyMax = 20000.0;

  /// Default reference pitch A4 frequency in Hertz.
  static const double defaultReferenceFrequency = 440.0;

  /// Default FFT window size exponent (2^12 = 4096 samples ~ 92.9 ms at 44.1 kHz).
  static const int defaultWindowSizeExponent = 12;

  /// Default window overlap ratio (75% overlap yields ~43.1 fps refresh rate).
  static const double defaultOverlap = 0.75;

  /// Default in-tune tolerance in cents.
  static const int defaultToleranceInCents = 5;

  /// Default moving average count for frequency smoother.
  static const int defaultMovingAverageCount = 5;

  /// Default pitch history duration in seconds.
  static const double defaultPitchHistoryDuration = 1.5;

  /// Default sensitivity value on 0-100 scale.
  static const int defaultSensitivity = 90;

  /// Default maximum allowable noise ratio (0.1 = 10%).
  static const double defaultMaxNoise = 0.1;

  /// Default minimum required harmonic energy ratio (0.1 = 10%).
  static const double defaultMinHarmonicEnergyContent = 0.1;

  /// Hysteresis threshold: minimum cent deviation before switching detected target note.
  static const double targetHysteresisMinCents = 20.0;

  /// Hysteresis ratio for switching target notes (0.5 = midpoint, 0.6 = biased).
  static const double targetHysteresisRatio = 0.6;
}
