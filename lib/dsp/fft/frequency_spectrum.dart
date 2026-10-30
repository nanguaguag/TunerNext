import 'dart:typed_data';

/// Encapsulates frequency-domain spectral data for pitch detection and spectrum visualization.
///
/// Holds the complex Fourier coefficients `[re0, im0, re1, im1, ...]`, frequency grid,
/// squared amplitude spectrum, and normalized values for UI plotting.
class FrequencySpectrum {
  /// Creates a [FrequencySpectrum] with [size] frequency bins and resolution [df].
  ///
  /// [size] is typically `numTimeSamples ~/ 2 + 1` for real-valued FFTs.
  FrequencySpectrum(this.size, this.df)
    : frequencies = Float32List(size),
      spectrum = Float32List(2 * size),
      amplitudeSpectrumSquared = Float32List(size),
      plottingSpectrumNormalized = Float32List(size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'Size must be positive.');
    }
    for (var i = 0; i < size; i++) {
      frequencies[i] = df * i;
    }
  }

  /// Number of distinct frequency bins ($N/2 + 1$).
  final int size;

  /// Frequency resolution between adjacent bins in Hertz ($f_s / N$).
  final double df;

  /// Frequency array mapping bin index to physical frequency in Hertz.
  final Float32List frequencies;

  /// Complex spectrum buffer where `2 * i` is real and `2 * i + 1` is imaginary.
  final Float32List spectrum;

  /// Squared magnitude spectrum: $(re^2 + im^2) / \text{norm}$.
  final Float32List amplitudeSpectrumSquared;

  /// Normalized spectrum values scaled to `[0.0, 1.0]` for plotting.
  final Float32List plottingSpectrumNormalized;

  /// Returns the real component of the spectrum at bin [index].
  double real(int index) => spectrum[2 * index];

  /// Returns the imaginary component of the spectrum at bin [index].
  double imag(int index) => spectrum[2 * index + 1];

  /// Computes the squared amplitude spectrum from the complex spectrum.
  ///
  /// [normalizationFactor] is typically $1.0 / (N \cdot \text{windowIntegralFactor})^2$.
  void computeAmplitudeSpectrumSquared([double normalizationFactor = 1.0]) {
    for (var i = 0; i < size; i++) {
      final re = spectrum[2 * i];
      final im = spectrum[2 * i + 1];
      amplitudeSpectrumSquared[i] = normalizationFactor * (re * re + im * im);
    }
  }

  /// Recalculates [plottingSpectrumNormalized] to normalize the squared amplitudes to `[0.0, 1.0]`.
  void updatePlotNormalized() {
    var minVal = double.infinity;
    var maxVal = double.negativeInfinity;

    for (var i = 0; i < size; i++) {
      final v = amplitudeSpectrumSquared[i];
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    final range = maxVal - minVal;
    if (range > 1e-12) {
      for (var i = 0; i < size; i++) {
        plottingSpectrumNormalized[i] =
            (amplitudeSpectrumSquared[i] - minVal) / range;
      }
    } else {
      plottingSpectrumNormalized.fillRange(0, size, 0.0);
    }
  }
}
