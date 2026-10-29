import 'dart:math' as math;
import 'dart:typed_data';
import '../../core/constants/acoustic_constants.dart';
import '../correlation/auto_correlation.dart';
import 'accurate_spectrum_peak.dart';
import 'pitch_detector_interface.dart';
import 'polynomial_fit.dart';

/// Baseline Classic pitch detector based on Autocorrelation and phase vocoder refinement,
/// optionally enhanced with 3-bin complex Jacobsen spectral interpolation.
class ClassicPitchDetector implements PitchDetector {
  ClassicPitchDetector({
    this.useJacobsen = false,
    this.subharmonicsTolerance = 0.1,
    this.subharmonicPeakRatio = 0.75,
  });

  final bool useJacobsen;
  final double subharmonicsTolerance;
  final double subharmonicPeakRatio;

  CorrelationComputer? _correlator;
  AutoCorrelationData? _autoCorr;
  Float32List? _spectrumStorage;
  Float32List? _previousSpectrum;
  int _previousFramePosition = -1;

  @override
  PitchDetectionResult detectPitch({
    required Float32List samples,
    required int sampleRate,
    double frequencyMin = 16.0,
    double frequencyMax = 20000.0,
    int? framePosition,
  }) {
    final size = samples.length;
    if (size < 64) return PitchDetectionResult.silence;

    // Check RMS silence threshold (-80 dBFS)
    var sumSq = 0.0;
    for (var i = 0; i < size; i++) {
      sumSq += samples[i] * samples[i];
    }
    final rms = math.sqrt(sumSq / size);
    if (rms < AcousticConstants.silenceThresholdRms) {
      return PitchDetectionResult.silence;
    }

    final dt = 1.0 / sampleRate;
    _correlator ??= CorrelationComputer(size);
    _autoCorr ??= AutoCorrelationData(size: size, dt: dt);
    _spectrumStorage ??= Float32List(2 * size + 2);
    _previousSpectrum ??= Float32List(2 * size + 2);

    // Compute autocorrelation and spectrum
    _correlator!.compute(samples, _autoCorr!, spectrumOut: _spectrumStorage!);

    final r0 = _autoCorr!.values[0];
    if (r0 <= AcousticConstants.minZeroLagEnergy || r0.isNaN) {
      return PitchDetectionResult.silence;
    }

    // Determine lag search bounds
    final globalIndexEnd = (frequencyMin > 0.0)
        ? math.min(size - 1, (sampleRate / frequencyMin).floor() + 1)
        : size - 1;

    final firstMin = _findFirstMinimum(_autoCorr!.values);
    final globalIndexBegin = (frequencyMax > 0.0)
        ? math.max((sampleRate / frequencyMax).ceil(), firstMin)
        : firstMin;

    if (globalIndexBegin >= globalIndexEnd) {
      return PitchDetectionResult.silence;
    }

    // Find global maximum
    var globalMaxIndex = 0;
    var maxVal = double.negativeInfinity;

    for (var i = globalIndexBegin; i < globalIndexEnd; i++) {
      final v = _autoCorr!.values[i];
      if (v > maxVal && _isLocalMax(i, _autoCorr!.values)) {
        globalMaxIndex = i;
        maxVal = v;
      }
    }

    // Defensive zero check against division by zero (BUG-05 fix)
    if (globalMaxIndex <= 0 || maxVal <= 0.0) {
      return PitchDetectionResult.silence;
    }

    // Filter non-periodic noise (ACOUSTIC-01 fix: must exceed 15% of zero-lag energy)
    if (maxVal < AcousticConstants.minNormalizedPeakRatio * r0) {
      return PitchDetectionResult.silence;
    }

    // Polynomial fit around maximum peak
    final fit = getPeakOfPolynomialFit(
      _autoCorr!.values[globalMaxIndex - 1],
      _autoCorr!.values[globalMaxIndex],
      _autoCorr!.values[globalMaxIndex + 1],
      globalMaxIndex.toDouble(),
      1.0,
    );

    var fittedMaxIndex = fit.timeOrIndex;
    var fittedPeak = fit.value;

    // Subharmonic verification to prevent octave jumping
    final requiredMaxVal = subharmonicPeakRatio * fittedPeak;
    final maxDivision = (fittedMaxIndex / globalIndexBegin).ceil();

    for (var division = maxDivision; division >= 2; division--) {
      var idxBegin = (fittedMaxIndex / (division + subharmonicsTolerance))
          .ceil();
      idxBegin = math.max(idxBegin, 1);

      var idxEnd =
          (fittedMaxIndex / (division - subharmonicsTolerance)).floor() + 1;
      idxEnd = math.min(idxEnd, size - 1);

      if (idxEnd - idxBegin < 1) {
        idxBegin = (fittedMaxIndex / division).round();
        idxEnd = idxBegin + 1;
      }

      var localMax = double.negativeInfinity;
      var localMaxIndex = 0;
      for (var i = idxBegin; i < idxEnd; i++) {
        if (_autoCorr!.values[i] > localMax &&
            _isLocalMax(i, _autoCorr!.values)) {
          localMax = _autoCorr!.values[i];
          localMaxIndex = i;
        }
      }

      if (localMaxIndex > 0) {
        final localFit = getPeakOfPolynomialFit(
          _autoCorr!.values[localMaxIndex - 1],
          _autoCorr!.values[localMaxIndex],
          _autoCorr!.values[localMaxIndex + 1],
          localMaxIndex.toDouble(),
          1.0,
        );
        if (localFit.value >= requiredMaxVal) {
          fittedMaxIndex = localFit.timeOrIndex;
          fittedPeak = localFit.value;
          break;
        }
      }
    }

    if (fittedMaxIndex <= 0.0) return PitchDetectionResult.silence;

    final rawFreq = sampleRate / fittedMaxIndex;
    if (rawFreq < frequencyMin || rawFreq > frequencyMax) {
      return PitchDetectionResult.silence;
    }

    // Sub-bin phase vocoder and Jacobsen refinement
    final df = (sampleRate / (2 * size)).toDouble();
    final centerBin = (rawFreq / df).round().clamp(1, size - 2);
    var specBin = centerBin;
    var maxPeakAmp = 0.0;
    for (
      var b = math.max(1, centerBin - 2);
      b <= math.min(size - 2, centerBin + 2);
      b++
    ) {
      final re = _spectrumStorage![2 * b];
      final im = _spectrumStorage![2 * b + 1];
      final amp = re * re + im * im;
      if (amp > maxPeakAmp) {
        maxPeakAmp = amp;
        specBin = b;
      }
    }

    final accurateComputer = AccurateSpectrumPeakFrequency(
      df: df,
      useJacobsen: useJacobsen,
    );

    double refinedFreq = rawFreq;
    if (_previousFramePosition >= 0 &&
        framePosition != null &&
        _previousSpectrum != null) {
      final timeShift = (framePosition - _previousFramePosition) / sampleRate;
      if (timeShift > 0.0) {
        refinedFreq = accurateComputer.computeFrequency(
          specBin,
          _spectrumStorage!,
          previousSpectrum: _previousSpectrum,
          timeShift: timeShift,
          rawFrequency: rawFreq,
        );
      }
    }

    // Save previous spectrum and frame position for next frame
    _previousSpectrum!.setAll(0, _spectrumStorage!);
    _previousFramePosition = framePosition ?? -1;

    final confidence = (fittedPeak / r0).clamp(0.0, 1.0);

    return PitchDetectionResult(
      frequency: refinedFreq > 0 ? refinedFreq : rawFreq,
      confidence: confidence,
      periodSamples: fittedMaxIndex,
      isSilence: false,
      noiseRatio: (1.0 - confidence).clamp(0.0, 1.0),
      harmonicEnergy: rms,
    );
  }

  bool _isLocalMax(int i, Float32List data) {
    if (i <= 0 || i >= data.length - 1) return false;
    return data[i] >= data[i - 1] && data[i] >= data[i + 1];
  }

  int _findFirstMinimum(Float32List data, {int radius = 2}) {
    for (var i = radius; i < data.length - radius; i++) {
      var isMin = true;
      for (var j = i - radius; j <= i + radius; j++) {
        if (i != j && data[j] < data[i]) {
          isMin = false;
          break;
        }
      }
      if (isMin) return i;
    }
    return data.length;
  }

  @override
  void reset() {
    _previousFramePosition = -1;
  }
}
