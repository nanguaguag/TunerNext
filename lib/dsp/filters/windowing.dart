import 'dart:math' as math;
import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';

/// Utilities for generating time-domain analysis windows.
class Windowing {
  Windowing._();

  /// Generates a windowing array of length [size] for the given [type].
  static Float32List getWindow(WindowingFunction type, int size) {
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

  /// Returns the integral / average power factor of the given window function.
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
}
