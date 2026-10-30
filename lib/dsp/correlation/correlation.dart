import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';
import '../fft/fft.dart';
import '../windowing/windowing.dart';
import 'auto_correlation.dart';

/// Computes the autocorrelation sequence of a time-domain signal via zero-padded real FFT.
///
/// Implements the Wiener-Khinchin theorem:
/// $$R_{xx}[\tau] = \mathcal{F}^{-1}\left\{ |\mathcal{F}\{x_{\text{padded}}\}|^2 \right\}$$
/// Using zero-padding up to $2N$ avoids circular correlation distortion at larger lags.
class Correlation {
  /// Creates a [Correlation] processor for input frames of [size] samples.
  ///
  /// [size] must be a positive power of 2.
  Correlation(this.size, {this.windowType = WindowingFunction.tophat})
    : _fft = FFT(2 * size),
      _inputBitReversed = Float32List(2 * size + 2),
      _window = Windowing.getWindow(windowType, size) {
    if (size <= 0 || (size & (size - 1)) != 0) {
      throw ArgumentError.value(
        size,
        'size',
        'Correlation size must be a positive power of 2, but $size was given.',
      );
    }
  }

  /// Number of input samples in each analysis frame.
  final int size;

  /// Windowing function applied prior to FFT.
  final WindowingFunction windowType;

  final FFT _fft;
  final Float32List _inputBitReversed;
  final Float32List _window;

  /// Internal window coefficient table.
  Float32List get window => _window;

  /// Computes the autocorrelation of [input] and stores the result into [output].
  ///
  /// - [input]: Float array of length >= [size].
  /// - [output]: Float array of length >= [size] to store autocorrelation values.
  /// - [disableWindow]: If true, forces rectangular/tophat windowing regardless of [windowType].
  /// - [spectrum]: Optional buffer of length >= `2 * size + 2` to receive the complex spectrum
  ///   of the zero-padded input.
  void correlate(
    Float32List input,
    Float32List output, {
    bool disableWindow = false,
    Float32List? spectrum,
  }) {
    if (input.length < size) {
      throw ArgumentError(
        'Input length (${input.length}) must be at least correlation size ($size).',
      );
    }
    if (output.length < size) {
      throw ArgumentError(
        'Output length (${output.length}) must be at least correlation size ($size).',
      );
    }
    if (spectrum != null && spectrum.length < 2 * size + 2) {
      throw ArgumentError(
        'Spectrum buffer length (${spectrum.length}) must be at least ${2 * size + 2}.',
      );
    }

    final spectrumStorage = spectrum ?? _inputBitReversed;
    final applyWin = windowType != WindowingFunction.tophat && !disableWindow;

    // 1. Bit-reversed permutation into zero-padded FFT buffer
    if (!applyWin) {
      for (var i = 0; i < size; i++) {
        final ir2 = 2 * _fft.bitReverseTable[i];
        final i2 = 2 * i;
        if (i2 >= ir2) {
          spectrumStorage[i2] = ir2 < size ? input[ir2] : 0.0;
          spectrumStorage[i2 + 1] = (ir2 + 1) < size ? input[ir2 + 1] : 0.0;
          spectrumStorage[ir2] = i2 < size ? input[i2] : 0.0;
          spectrumStorage[ir2 + 1] = (i2 + 1) < size ? input[i2 + 1] : 0.0;
        }
      }
    } else {
      for (var i = 0; i < size; i++) {
        final ir2 = 2 * _fft.bitReverseTable[i];
        final i2 = 2 * i;
        if (i2 >= ir2) {
          spectrumStorage[i2] = ir2 < size ? _window[ir2] * input[ir2] : 0.0;
          spectrumStorage[i2 + 1] = (ir2 + 1) < size
              ? _window[ir2 + 1] * input[ir2 + 1]
              : 0.0;
          spectrumStorage[ir2] = i2 < size ? _window[i2] * input[i2] : 0.0;
          spectrumStorage[ir2 + 1] = (i2 + 1) < size
              ? _window[i2 + 1] * input[i2 + 1]
              : 0.0;
        }
      }
    }

    // 2. Compute forward real FFT
    _fft.fftBitReversed(spectrumStorage);
    _fft.combineFFTResultForRealFFT(spectrumStorage);

    // 3. Compute power spectrum |X[k]|^2
    for (var i = 0; i <= size; i++) {
      final re = spectrumStorage[2 * i];
      final im = spectrumStorage[2 * i + 1];
      _inputBitReversed[2 * i] = re * re + im * im;
      _inputBitReversed[2 * i + 1] = 0.0;
    }

    // 4. Inverse real FFT yields raw un-normalized autocorrelation sequence
    _fft.ifftReal(_inputBitReversed, _inputBitReversed);

    // 5. Copy first 'size' lags to output
    for (var i = 0; i < size; i++) {
      output[i] = _inputBitReversed[i];
    }
  }

  /// Convenience method to compute autocorrelation and automatically update [autoCorr].
  void correlateToData(
    Float32List input,
    AutoCorrelationData autoCorr, {
    bool disableWindow = false,
    Float32List? spectrum,
  }) {
    correlate(
      input,
      autoCorr.values,
      disableWindow: disableWindow,
      spectrum: spectrum,
    );
    autoCorr.updatePlotNormalized();
  }
}
