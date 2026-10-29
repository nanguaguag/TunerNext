// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

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
  pyin;

  String get displayName {
    switch (this) {
      case PitchAlgorithm.classic:
        return 'Classic (Autocorrelation + Vocoder)';
      case PitchAlgorithm.hybridJacobsen:
        return 'Hybrid Jacobsen (Interpolated Vocoder)';
      case PitchAlgorithm.mpm:
        return 'MPM (McLeod Pitch Method)';
      case PitchAlgorithm.twm:
        return 'TWM (Two-Way Mismatch)';
      case PitchAlgorithm.pyin:
        return 'pYIN (Probabilistic Continuity)';
    }
  }

  String get description {
    switch (this) {
      case PitchAlgorithm.classic:
        return 'Baseline algorithm combining time-domain autocorrelation and FFT phase vocoder.';
      case PitchAlgorithm.hybridJacobsen:
        return '3-bin complex FFT interpolation preventing integer bin phase jumps on high notes.';
      case PitchAlgorithm.mpm:
        return 'Normalized Square Difference Function (NSDF) with first-peak selection to eliminate octave errors.';
      case PitchAlgorithm.twm:
        return 'Bidirectional harmonic matching with inharmonicity compensation. Excels at missing fundamentals.';
      case PitchAlgorithm.pyin:
        return 'Probabilistic multi-candidate pitch tracking with temporal continuity smoothing.';
    }
  }
}

/// Supported acoustic frequency weighting curves.
enum AcousticWeightingMode {
  /// IEC 61672-1 A-weighting curve mimicking human ear equal-loudness contour.
  aWeighting,

  /// C-weighting curve for high-SPL or wide-band acoustic signals.
  cWeighting,

  /// Flat / zero weighting curve across all frequencies.
  none;

  String get displayName {
    switch (this) {
      case AcousticWeightingMode.aWeighting:
        return 'A-Weighting (Human hearing, attenuates hum)';
      case AcousticWeightingMode.cWeighting:
        return 'C-Weighting (High sound pressure levels)';
      case AcousticWeightingMode.none:
        return 'Flat (No acoustic weighting)';
    }
  }

  String get description {
    switch (this) {
      case AcousticWeightingMode.aWeighting:
        return 'IEC 61672 A-weighting curve; attenuates 50/60 Hz mains hum and HVAC room noise.';
      case AcousticWeightingMode.cWeighting:
        return 'Standard C-weighting curve for high sound pressure levels and transient signals.';
      case AcousticWeightingMode.none:
        return 'Linear frequency response with no filtering.';
    }
  }
}

/// Time-domain windowing functions applied prior to FFT.
enum WindowingFunction {
  /// Rectangular / flat window with narrowest main lobe but higher side lobes.
  tophat,

  /// Hanning window: smooth cosine taper with -31 dB side-lobe attenuation.
  hanning,

  /// Hamming window: optimized cosine taper with -42 dB first side lobe.
  hamming;

  String get displayName {
    switch (this) {
      case WindowingFunction.tophat:
        return 'Top-Hat (Rectangular)';
      case WindowingFunction.hanning:
        return 'Hann Window';
      case WindowingFunction.hamming:
        return 'Hamming Window';
    }
  }

  String get description {
    switch (this) {
      case WindowingFunction.tophat:
        return 'Uniform rectangular weighting without attenuation at boundaries.';
      case WindowingFunction.hanning:
        return 'Cosine taper reaching zero at edges; -31 dB side-lobe rejection.';
      case WindowingFunction.hamming:
        return 'Optimized cosine taper with non-zero edge; -42 dB first side lobe.';
    }
  }
}
