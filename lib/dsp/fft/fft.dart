import 'dart:math' as math;
import 'dart:typed_data';

/// Reverses the bits of [value] within [numBits] bit-width.
int bitReverse(int value, int numBits) {
  var myValue = value;
  var rev = 0;
  for (var i = 0; i < numBits; i++) {
    rev = (rev << 1) | (myValue & 1);
    myValue >>= 1;
  }
  return rev;
}

/// Fast Fourier Transform implementation supporting both complex and real-valued signals.
class FFT {
  FFT(this.size) {
    nBits = (math.log(size) / math.ln2).round();
    final sizeCheck = 1 << nBits;
    if (size != sizeCheck) {
      throw ArgumentError('FFT size must be a power of 2, but $size given.');
    }

    final halfSize = size ~/ 2;
    cosTable = Float32List(halfSize);
    sinTable = Float32List(halfSize);
    cosTableH = Float32List(halfSize);
    sinTableH = Float32List(halfSize);
    bitReverseTable = Int32List(halfSize);

    final fac = -2.0 * math.pi / size;
    for (var i = 0; i < halfSize; i++) {
      sinTable[i] = math.sin(2 * i * fac);
      cosTable[i] = math.cos(2 * i * fac);
      sinTableH[i] = math.sin(i * fac);
      cosTableH[i] = math.cos(i * fac);
      bitReverseTable[i] = bitReverse(i, nBits - 1);
    }
  }

  /// Number of floating point values of input signal.
  final int size;

  late final int nBits;
  late final Float32List cosTable;
  late final Float32List sinTable;
  late final Float32List cosTableH;
  late final Float32List sinTableH;
  late final Int32List bitReverseTable;

  /// Number of frequencies returned by a real FFT of length [size].
  static int numFrequenciesReal(int size) => size ~/ 2 + 1;

  /// Number of frequencies returned by a complex FFT of length [size].
  static int numFrequenciesComplex(int size) => size ~/ 2;

  /// Frequency in Hertz for a specific bin index computed by real FFT.
  static double getFrequencyReal(int idx, int size, double dt) =>
      idx / (dt * size);

  /// Frequency in Hertz for a specific complex index computed by FFT.
  static double getFrequencyComplex(int idx, int size, double dt) {
    final numValues = size ~/ 2;
    final half = numValues ~/ 2;
    return idx < half
        ? idx / (dt * numValues)
        : (idx - numValues) / (dt * numValues);
  }

  /// Forward Fast Fourier Transform for complex numbers stored interleaved [re, im, re, im, ...].
  void fft(Float32List input, Float32List output) {
    if (input.length != size || output.length != size) {
      throw ArgumentError('FFT input/output length must equal size ($size).');
    }
    _bitReverse(input, output);
    fftBitReversed(output);
  }

  /// Inverse Fast Fourier Transform for complex numbers.
  void ifft(Float32List input, Float32List output) {
    if (input.length != size || output.length != size) {
      throw ArgumentError('FFT input/output length must equal size ($size).');
    }
    _bitReverse(input, output);
    ifftBitReversed(output);
  }

  /// Forward Fast Fourier Transform for real-valued numbers.
  /// [input] has length [size].
  /// [output] has length [size + 2] to store [size/2 + 1] complex frequency bins.
  void fftReal(Float32List input, Float32List output) {
    if (input.length < size || output.length < size + 2) {
      throw ArgumentError(
        'fftReal requires input.length >= $size and output.length >= ${size + 2}.',
      );
    }
    _bitReverse(input, output);
    fftBitReversed(output);
    combineFFTResultForRealFFT(output);
  }

  /// Inverse Fast Fourier Transform yielding real-valued output.
  /// [input] has length [size + 2] (positive frequency bins).
  /// [output] has length [size].
  void ifftReal(Float32List input, Float32List output) {
    if (input.length < size + 2 || output.length < size) {
      throw ArgumentError(
        'ifftReal requires input.length >= ${size + 2} and output.length >= $size.',
      );
    }
    _prepareDataForInverseRealFFT(input, output);
    _bitReverseInPlace(output);
    ifftBitReversed(output);
  }

  /// Transforms already bit-reversed interleaved complex data in-place.
  void fftBitReversed(Float32List output) {
    final halfSize = size ~/ 2;
    var numInner = 1;
    var wStep = halfSize ~/ 2;

    for (var s = 0; s < nBits - 1; s++) {
      var idx1 = 0;
      var idx2 = halfSize ~/ 2;

      for (var i = 0; i < numInner; i++) {
        final cos1 = cosTable[idx1];
        final sin1 = sinTable[idx1];
        final cos2 = cosTable[idx2];
        final sin2 = sinTable[idx2];

        var k1re = 2 * i;

        for (var k = 0; k < wStep; k++) {
          final k1im = k1re + 1;
          final k2re = k1re + 2 * numInner;
          final k2im = k2re + 1;

          final tmp2Re = output[k2re];
          final tmp2Im = output[k2im];

          output[k2re] = output[k1re] + cos2 * tmp2Re - sin2 * tmp2Im;
          output[k2im] = output[k1im] + cos2 * tmp2Im + sin2 * tmp2Re;
          output[k1re] += cos1 * tmp2Re - sin1 * tmp2Im;
          output[k1im] += cos1 * tmp2Im + sin1 * tmp2Re;

          k1re += 4 * numInner;
        }
        idx1 += wStep;
        idx2 += wStep;
      }
      numInner *= 2;
      wStep ~/= 2;
    }
  }

  /// Inverse transforms already bit-reversed interleaved complex data in-place.
  void ifftBitReversed(Float32List output) {
    final halfSize = size ~/ 2;
    var numInner = 1;
    var wStep = halfSize ~/ 2;

    for (var s = 0; s < nBits - 1; s++) {
      var idx1 = 0;
      var idx2 = halfSize ~/ 2;

      for (var i = 0; i < numInner; i++) {
        final cos1 = cosTable[idx1];
        final sin1 = sinTable[idx1];
        final cos2 = cosTable[idx2];
        final sin2 = sinTable[idx2];

        var k1re = 2 * i;

        for (var k = 0; k < wStep; k++) {
          final k1im = k1re + 1;
          final k2re = k1re + 2 * numInner;
          final k2im = k2re + 1;

          final tmp2Re = output[k2re];
          final tmp2Im = output[k2im];

          output[k2re] = output[k1re] + cos2 * tmp2Re + sin2 * tmp2Im;
          output[k2im] = output[k1im] + cos2 * tmp2Im - sin2 * tmp2Re;
          output[k1re] += cos1 * tmp2Re + sin1 * tmp2Im;
          output[k1im] += cos1 * tmp2Im - sin1 * tmp2Re;

          k1re += 4 * numInner;
        }
        idx1 += wStep;
        idx2 += wStep;
      }
      numInner *= 2;
      wStep ~/= 2;
    }
  }

  void _bitReverse(Float32List input, Float32List output) {
    final halfSize = size ~/ 2;
    for (var i = 0; i < halfSize; i++) {
      final ir2 = 2 * bitReverseTable[i];
      final i2 = 2 * i;
      if (i2 >= ir2) {
        final tmp1 = input[i2];
        output[i2] = input[ir2];
        output[ir2] = tmp1;
        final tmp2 = input[i2 + 1];
        output[i2 + 1] = input[ir2 + 1];
        output[ir2 + 1] = tmp2;
      }
    }
  }

  void _bitReverseInPlace(Float32List data) {
    _bitReverse(data, data);
  }

  /// Unpacks an N/2 complex FFT into an N-point real FFT spectrum.
  /// Resolves the in-place overwrite conflict at i = halfSize/2 (FORK-NEW-02 fix).
  void combineFFTResultForRealFFT(Float32List output) {
    final halfSize = size ~/ 2;
    var k1re = 0;
    var k1im = 1;
    var k2re = 2 * halfSize;
    var k2im = k2re + 1;

    for (var i = 1; i <= halfSize ~/ 2; i++) {
      k1re += 2;
      k1im += 2;
      k2re -= 2;
      k2im -= 2;

      final cos1 = cosTableH[i];
      final sin1 = sinTableH[i];
      final cos2 = cosTableH[halfSize - i];
      final sin2 = sinTableH[halfSize - i];

      final frRe = 0.5 * (output[k1re] + output[k2re]);
      final frIm = 0.5 * (output[k1im] - output[k2im]);
      final grRe = 0.5 * (output[k1im] + output[k2im]);
      final grIm = 0.5 * (output[k2re] - output[k1re]);

      final outK1Re = frRe + cos1 * grRe - sin1 * grIm;
      final outK1Im = frIm + sin1 * grRe + cos1 * grIm;
      final outK2Re = frRe + cos2 * grRe + sin2 * grIm;
      final outK2Im = -frIm + sin2 * grRe - cos2 * grIm;

      output[k1re] = outK1Re;
      output[k1im] = outK1Im;
      output[k2re] = outK2Re;
      output[k2im] = outK2Im;
    }

    output[size] = output[0] - output[1];
    output[0] = output[0] + output[1];
    output[1] = 0.0;
    output[size + 1] = 0.0;
  }

  void _prepareDataForInverseRealFFT(Float32List input, Float32List output) {
    final halfSize = size ~/ 2;
    var k1re = 0;
    var k1im = 1;
    var k2re = 2 * halfSize;
    var k2im = k2re + 1;

    for (var i = 1; i <= halfSize ~/ 2; i++) {
      k1re += 2;
      k1im += 2;
      k2re -= 2;
      k2im -= 2;

      final cos1 = cosTableH[i];
      final sin1 = sinTableH[i];
      final cos2 = cosTableH[halfSize - i];
      final sin2 = sinTableH[halfSize - i];

      final frRe = 0.5 * (input[k1re] + input[k2re]);
      final frIm = 0.5 * (input[k1im] - input[k2im]);
      final grRe = 0.5 * (input[k1im] + input[k2im]);
      final grIm = 0.5 * (input[k2re] - input[k1re]);

      final outK1Re = frRe - cos1 * grRe - sin1 * grIm;
      final outK1Im = frIm + sin1 * grRe - cos1 * grIm;
      final outK2Re = frRe - cos2 * grRe + sin2 * grIm;
      final outK2Im = -frIm + sin2 * grRe + cos2 * grIm;

      output[k1re] = outK1Re;
      output[k1im] = outK1Im;
      output[k2re] = outK2Re;
      output[k2im] = outK2Im;
    }

    output[1] = 0.5 * (input[0] - input[size]);
    output[0] = 0.5 * (input[0] + input[size]);
  }
}
