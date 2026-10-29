/// Supported pitch detection and estimation algorithms.
enum PitchAlgorithm {
  /// Baseline algorithm using FFT-based autocorrelation and phase vocoder.
  classic,

  /// Classic algorithm enhanced with 3-bin complex Jacobsen interpolation.
  hybridJacobsen,

  /// McLeod Pitch Method utilizing Normalized Square Difference Function (NSDF)
  /// with first-peak thresholding to eliminate octave-doubling.
  mpm,

  /// Two-Way Mismatch evaluating harmonic spectral peak mismatch and inharmonicity.
  twm,

  /// Probabilistic continuity tracking with multi-candidate state evaluation.
  pyin,
}

/// Supported acoustic frequency weighting curves.
enum AcousticWeightingMode {
  /// IEC 61672-1 A-weighting curve mimicking human ear equal-loudness contour.
  aWeighting,

  /// C-weighting curve for high-SPL or wide-band acoustic signals.
  cWeighting,

  /// Flat / zero weighting curve across all frequencies.
  none,
}

/// Time-domain windowing functions applied prior to FFT.
enum WindowingFunction {
  /// Rectangular / flat window with narrowest main lobe but higher side lobes.
  tophat,

  /// Hanning window: smooth cosine taper with -31 dB side-lobe attenuation.
  hanning,

  /// Hamming window: optimized cosine taper with -42 dB first side lobe.
  hamming,
}
