import 'dart:math' as math;
import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';

/// Utilities for generating time-domain analysis windows and integral compensation.
class Windowing {
  Windowing._();

  /// Generates a windowing coefficient vector of length [size] for the given [type].
  ///
  /// - [WindowingFunction.tophat]: Rectangular window ($w[n] = 1.0$).
  /// - [WindowingFunction.hamming]: Hamming window ($w[n] = 0.54 - 0.46 \cos(2\pi n / N)$).
  /// - [WindowingFunction.hanning]: Hann window ($w[n] = 0.5 \cdot (1.0 - \cos(2\pi n / N))$).
  static Float32List getWindow(WindowingFunction type, int size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'Window size must be positive.');
    }

    final window = Float32List(size);
    switch (type) {
      case WindowingFunction.tophat:
        window.fillRange(0, size, 1.0);
        break;

      case WindowingFunction.hamming:
        for (var i = 0; i < size; i++) {
          window[i] = 0.54 - 0.46 * math.cos(2.0 * math.pi * i / size);
        }
        break;

      case WindowingFunction.hanning:
        for (var i = 0; i < size; i++) {
          window[i] = 0.5 * (1.0 - math.cos(2.0 * math.pi * i / size));
        }
        break;
    }
    return window;
  }

  /// Returns the analytical integral (average window height) $\int_0^1 w(t) dt$.
  ///
  /// - Tophat: 1.0
  /// - Hamming: 0.54
  /// - Hanning: 0.5
  static double getWindowIntegral(WindowingFunction type) {
    switch (type) {
      case WindowingFunction.tophat:
        return 1.0;
      case WindowingFunction.hamming:
        return 0.54;
      case WindowingFunction.hanning:
        return 0.5;
    }
  }

  /// Returns the amplitude compensation factor $K = \frac{2}{N \cdot \int_0^1 w(t) dt}$.
  ///
  /// Ensures that spectral peak amplitudes of sine waves remain identical before and after windowing.
  static double getWindowCompensationFactor(WindowingFunction type, int size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'Window size must be positive.');
    }
    return 2.0 / (size * getWindowIntegral(type));
  }
}
