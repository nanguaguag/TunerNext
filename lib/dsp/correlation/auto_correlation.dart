import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';
import '../fft/fft.dart';
import '../filters/windowing.dart';

/// Data structure holding the autocorrelation sequence of an audio frame.
class AutoCorrelationData {
  AutoCorrelationData({required this.size, required this.dt})
    : times = Float32List(size),
      values = Float32List(size),
      plotValuesNormalized = Float32List(size) {
    for (var i = 0; i < size; i++) {
      times[i] = i * dt;
    }
  }

  final int size;
  final double dt;
  final Float32List times;
  final Float32List values;
  final Float32List plotValuesNormalized;
  double plotValuesNormalizedZero = 0.0;

  double operator [](int index) => values[index];
}

/// Computes the autocorrelation sequence of a time series via zero-padded FFT.
class CorrelationComputer {
  CorrelationComputer(this.size, {this.windowType = WindowingFunction.tophat})
    : _fft = FFT(2 * size),
      _paddedBuffer = Float32List(2 * size + 2),
      _spectrumPower = Float32List(2 * size + 2),
      _window = Windowing.getWindow(windowType, size);

  final int size;
  final WindowingFunction windowType;
  final FFT _fft;
  final Float32List _paddedBuffer;
  final Float32List _spectrumPower;
  final Float32List _window;

  /// Correlates [input] of length [size] and stores the result in [autoCorr.values].
  /// Optionally outputs the complex spectrum in [spectrumOut] (length 2*size + 2).
  void compute(
    Float32List input,
    AutoCorrelationData autoCorr, {
    Float32List? spectrumOut,
    bool disableWindow = false,
  }) {
    if (input.length < size) {
      throw ArgumentError(
        'Input length (${input.length}) must be at least size ($size).',
      );
    }

    final targetSpectrum = spectrumOut ?? _paddedBuffer;
    targetSpectrum.fillRange(0, 2 * size + 2, 0.0);

    // 1. Windowing and zero-padding to 2*size with bit-reversal
    final applyWin = windowType != WindowingFunction.tophat && !disableWindow;
    if (!applyWin) {
      for (var i = 0; i < size; i++) {
        final ir2 = 2 * _fft.bitReverseTable[i];
        final i2 = 2 * i;
        if (i2 >= ir2) {
          targetSpectrum[i2] = ir2 < size ? input[ir2] : 0.0;
          targetSpectrum[i2 + 1] = (ir2 + 1) < size ? input[ir2 + 1] : 0.0;
          targetSpectrum[ir2] = i2 < size ? input[i2] : 0.0;
          targetSpectrum[ir2 + 1] = (i2 + 1) < size ? input[i2 + 1] : 0.0;
        }
      }
    } else {
      for (var i = 0; i < size; i++) {
        final ir2 = 2 * _fft.bitReverseTable[i];
        final i2 = 2 * i;
        if (i2 >= ir2) {
          targetSpectrum[i2] = ir2 < size ? _window[ir2] * input[ir2] : 0.0;
          targetSpectrum[i2 + 1] = (ir2 + 1) < size
              ? _window[ir2 + 1] * input[ir2 + 1]
              : 0.0;
          targetSpectrum[ir2] = i2 < size ? _window[i2] * input[i2] : 0.0;
          targetSpectrum[ir2 + 1] = (i2 + 1) < size
              ? _window[i2 + 1] * input[i2 + 1]
              : 0.0;
        }
      }
    }

    // Run forward real FFT
    _fft.fftBitReversed(targetSpectrum);
    _fft.combineFFTResultForRealFFT(targetSpectrum);

    // 2. Power spectrum: |X[k]|^2
    for (var i = 0; i <= size; i++) {
      final re = targetSpectrum[2 * i];
      final im = targetSpectrum[2 * i + 1];
      _spectrumPower[2 * i] = re * re + im * im;
      _spectrumPower[2 * i + 1] = 0.0;
    }

    // 3. Inverse real FFT yields un-normalized autocorrelation
    _fft.ifftReal(_spectrumPower, _paddedBuffer);

    // 4. Copy first 'size' samples to output
    for (var i = 0; i < size; i++) {
      autoCorr.values[i] = _paddedBuffer[i];
    }

    // 5. Compute normalized plot values
    final r0 = autoCorr.values[0];
    if (r0 > 1e-9) {
      var minVal = double.infinity;
      var maxVal = double.negativeInfinity;
      for (var i = 0; i < size; i++) {
        final v = autoCorr.values[i];
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
      }
      final range = maxVal - minVal;
      if (range > 1e-9) {
        for (var i = 0; i < size; i++) {
          autoCorr.plotValuesNormalized[i] =
              (autoCorr.values[i] - minVal) / range;
        }
        autoCorr.plotValuesNormalizedZero = (0.0 - minVal) / range;
      } else {
        autoCorr.plotValuesNormalized.fillRange(0, size, 0.5);
        autoCorr.plotValuesNormalizedZero = 0.5;
      }
    } else {
      autoCorr.plotValuesNormalized.fillRange(0, size, 0.0);
      autoCorr.plotValuesNormalizedZero = 0.0;
    }
  }
}
