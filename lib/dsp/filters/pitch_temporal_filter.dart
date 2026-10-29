/// 3-tap running median filter to eliminate isolated single-frame impulse noise.
class PitchMedianFilter {
  double _v0 = 0.0;
  double _v1 = 0.0;
  double _v2 = 0.0;
  int _count = 0;

  /// Filters [frequency]. Resets if frequency <= 0.
  double filter(double frequency) {
    if (frequency <= 0.0) {
      reset();
      return 0.0;
    }
    switch (_count) {
      case 0:
        _v0 = frequency;
        _count = 1;
        return frequency;
      case 1:
        _v1 = frequency;
        _count = 2;
        return 0.5 * (_v0 + _v1);
      default:
        _v2 = frequency;
        final a = _v0;
        final b = _v1;
        final c = _v2;
        // Shift window
        _v0 = _v1;
        _v1 = _v2;
        // Fast 3-element median calculation
        if ((a <= b && b <= c) || (c <= b && b <= a)) {
          return b;
        } else if ((b <= a && a <= c) || (c <= a && a <= b)) {
          return a;
        } else {
          return c;
        }
    }
  }

  void reset() {
    _v0 = 0.0;
    _v1 = 0.0;
    _v2 = 0.0;
    _count = 0;
  }
}

/// Gate to suppress momentary octave jumps caused by transient friction noise in bowed instruments.
class OctaveJumpGate {
  OctaveJumpGate({this.tolerance = 0.08, this.requiredSustainedFrames = 2});

  /// Relative tolerance to identify an integer harmonic multiple (default 8%).
  final double tolerance;

  /// Number of consecutive frames needed to confirm a legitimate octave transition.
  final int requiredSustainedFrames;

  double _lastConfirmedFrequency = 0.0;
  double _candidateJumpFrequency = 0.0;
  int _candidateJumpCount = 0;

  /// Filters [frequency] against sudden octave jumps.
  double filter(double frequency) {
    if (frequency <= 0.0) {
      reset();
      return 0.0;
    }

    if (_lastConfirmedFrequency <= 0.0) {
      _lastConfirmedFrequency = frequency;
      return frequency;
    }

    final ratio = frequency / _lastConfirmedFrequency;

    // Check if frequency jumped up to an upper harmonic (2x, 3x, 4x)
    if (ratio > 1.8) {
      final roundRatio = ratio.round();
      if (roundRatio >= 2 &&
          roundRatio <= 4 &&
          (ratio - roundRatio).abs() / roundRatio <= tolerance) {
        if (_isSameJumpCandidate(frequency)) {
          _candidateJumpCount++;
          if (_candidateJumpCount >= requiredSustainedFrames) {
            _lastConfirmedFrequency = frequency;
            _resetCandidate();
            return frequency;
          }
        } else {
          _candidateJumpFrequency = frequency;
          _candidateJumpCount = 1;
        }
        // During transient phase, fold back to base fundamental
        return frequency / roundRatio;
      }
    } else if (ratio < 0.55) {
      // Check if frequency jumped down to a sub-octave (1/2, 1/3, 1/4)
      final invRatio = 1.0 / ratio;
      final roundInvRatio = invRatio.round();
      if (roundInvRatio >= 2 &&
          roundInvRatio <= 4 &&
          (invRatio - roundInvRatio).abs() / roundInvRatio <= tolerance) {
        if (_isSameJumpCandidate(frequency)) {
          _candidateJumpCount++;
          if (_candidateJumpCount >= requiredSustainedFrames) {
            _lastConfirmedFrequency = frequency;
            _resetCandidate();
            return frequency;
          }
        } else {
          _candidateJumpFrequency = frequency;
          _candidateJumpCount = 1;
        }
        return frequency * roundInvRatio;
      }
    }

    // Legitimate continuous transition
    _lastConfirmedFrequency = frequency;
    _resetCandidate();
    return frequency;
  }

  bool _isSameJumpCandidate(double freq) {
    if (_candidateJumpFrequency <= 0.0) return false;
    return (freq - _candidateJumpFrequency).abs() / _candidateJumpFrequency <=
        tolerance;
  }

  void _resetCandidate() {
    _candidateJumpFrequency = 0.0;
    _candidateJumpCount = 0;
  }

  void reset() {
    _lastConfirmedFrequency = 0.0;
    _resetCandidate();
  }
}
