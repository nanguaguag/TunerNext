import 'dart:typed_data';
import '../../domain/models/dsp_enums.dart';
import '../correlation/auto_correlation.dart';
import '../correlation/correlation.dart';
import '../fft/fft.dart';
import '../pipeline/tuner_dsp_pipeline.dart';
import '../windowing/windowing.dart';

/// Single temporal snapshot in an offline audio analysis result.
class AnalysisFrame {
  const AnalysisFrame({
    required this.timeSeconds,
    required this.frequency,
    required this.confidence,
    required this.rms,
    required this.isSilence,
    this.spectrum,
    this.correlation,
    this.correlationZero = 0.5,
  });

  /// Time offset from audio start in seconds.
  final double timeSeconds;

  /// Detected fundamental frequency in Hertz (0.0 if unvoiced/silent).
  final double frequency;

  /// Periodicity clarity / confidence in `[0.0, 1.0]`.
  final double confidence;

  /// RMS amplitude level.
  final double rms;

  /// Whether this frame is considered silence.
  final bool isSilence;

  /// FFT magnitude spectrum (normalized `[0.0, 1.0]`).
  final Float32List? spectrum;

  /// Autocorrelation normalized curve.
  final Float32List? correlation;

  /// Zero level normalized offset in correlation curve.
  final double correlationZero;
}

/// Aggregated result of offline audio analysis across the entire audio buffer.
class OfflineAnalysisResult {
  const OfflineAnalysisResult({
    required this.frames,
    required this.durationSeconds,
    required this.sampleRate,
    required this.algorithm,
    required this.weightingMode,
  });

  final List<AnalysisFrame> frames;
  final double durationSeconds;
  final int sampleRate;
  final PitchAlgorithm algorithm;
  final AcousticWeightingMode weightingMode;

  /// Retrieves the closest [AnalysisFrame] at or near [timeSeconds].
  AnalysisFrame getFrameAt(double timeSeconds) {
    if (frames.isEmpty) {
      return AnalysisFrame(
        timeSeconds: timeSeconds,
        frequency: 0.0,
        confidence: 0.0,
        rms: 0.0,
        isSilence: true,
      );
    }
    final clampedTime = timeSeconds.clamp(0.0, durationSeconds);
    var low = 0;
    var high = frames.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midTime = frames[mid].timeSeconds;
      if ((midTime - clampedTime).abs() < 0.005) {
        return frames[mid];
      } else if (midTime < clampedTime) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    final idx = low.clamp(0, frames.length - 1);
    return frames[idx];
  }

  /// Extracts ordered frequency samples (null for silence) suitable for pitch history plot.
  List<double?> extractFrequencies() {
    return frames
        .map((f) => (!f.isSilence && f.frequency > 0.0) ? f.frequency : null)
        .toList();
  }
}

/// Offline batch audio processor.
class OfflineAudioAnalyzer {
  const OfflineAudioAnalyzer();

  /// Analyzes complete float [samples] into [OfflineAnalysisResult].
  static Future<OfflineAnalysisResult> analyze({
    required Float32List samples,
    required int sampleRate,
    int windowSize = 2048,
    int stride = 512,
    PitchAlgorithm algorithm = PitchAlgorithm.mpm,
    AcousticWeightingMode weightingMode = AcousticWeightingMode.none,
    double mpmCutoffClarity = 0.45,
    double mpmPeakThresholdRatio = 0.85,
    int twmMaxHarmonics = 10,
    double twmInharmonicity = 0.0,
    double twmMaxMismatchError = 0.40,
    bool useMedianFilter = true,
    bool useOctaveJumpGate = true,
  }) async {
    final numSamples = samples.length;
    final durationSeconds = numSamples > 0 ? numSamples / sampleRate : 0.0;

    final pipeline = TunerDspPipeline(
      frameSize: windowSize,
      algorithm: algorithm,
      weightingMode: weightingMode,
      smootherOrder: 3,
      useMedianFilter: useMedianFilter,
      useOctaveJumpGate: useOctaveJumpGate,
      mpmCutoffClarity: mpmCutoffClarity,
      mpmPeakThresholdRatio: mpmPeakThresholdRatio,
      twmMaxHarmonics: twmMaxHarmonics,
      twmInharmonicity: twmInharmonicity,
      twmMaxMismatchError: twmMaxMismatchError,
    );

    final correlator = Correlation(windowSize);
    final autoCorrData = AutoCorrelationData(
      size: windowSize,
      dt: 1.0 / sampleRate,
    );

    final fft = FFT(windowSize);
    final fftOut = Float32List(windowSize + 2);
    final windowedInput = Float32List(windowSize);
    final hanningWindow = Windowing.getWindow(
      WindowingFunction.hanning,
      windowSize,
    );

    final frames = <AnalysisFrame>[];

    for (var offset = 0; offset + windowSize <= numSamples; offset += stride) {
      final frame = Float32List(windowSize);
      for (var i = 0; i < windowSize; i++) {
        frame[i] = samples[offset + i];
      }

      final timeSec = offset / sampleRate;

      // Pipeline pitch result
      final res = pipeline.process(frame, sampleRate: sampleRate);

      // FFT Spectrum
      for (var i = 0; i < windowSize; i++) {
        windowedInput[i] = frame[i] * hanningWindow[i];
      }
      fft.fftReal(windowedInput, fftOut);
      final numBins = windowSize ~/ 2 + 1;
      final spectrumAmps = Float32List(numBins);
      var minVal = double.infinity;
      var maxVal = double.negativeInfinity;
      for (var i = 0; i < numBins; i++) {
        final re = fftOut[2 * i];
        final im = fftOut[2 * i + 1];
        final ampSqr = re * re + im * im;
        spectrumAmps[i] = ampSqr;
        if (ampSqr < minVal) minVal = ampSqr;
        if (ampSqr > maxVal) maxVal = ampSqr;
      }
      final range = maxVal - minVal;
      final scale = (range > 1e-9) ? (1.0 / range) : 1.0;
      for (var i = 0; i < numBins; i++) {
        spectrumAmps[i] = ((spectrumAmps[i] - minVal) * scale).clamp(0.0, 1.0);
      }

      // Autocorrelation
      correlator.correlateToData(frame, autoCorrData, disableWindow: false);
      final corrValues = Float32List.fromList(
        autoCorrData.plotValuesNormalized,
      );

      frames.add(
        AnalysisFrame(
          timeSeconds: timeSec,
          frequency: res.smoothedFrequency > 0
              ? res.smoothedFrequency
              : res.rawFrequency,
          confidence: res.confidence,
          rms: res.rms,
          isSilence: res.isSilence,
          spectrum: spectrumAmps,
          correlation: corrValues,
          correlationZero: autoCorrData.plotValuesNormalizedZero,
        ),
      );
    }

    return OfflineAnalysisResult(
      frames: frames,
      durationSeconds: durationSeconds,
      sampleRate: sampleRate,
      algorithm: algorithm,
      weightingMode: weightingMode,
    );
  }
}
