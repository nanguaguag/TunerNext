import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import '../core/constants/acoustic_constants.dart';
import '../domain/models/dsp_enums.dart';
import '../dsp/correlation/auto_correlation.dart';
import '../dsp/correlation/correlation.dart';
import '../dsp/fft/fft.dart';
import '../dsp/pipeline/tuner_dsp_pipeline.dart';
import 'audio_messages.dart';
import 'audio_ring_buffer.dart';

/// Top-level initialization parameter bundle passed to [Isolate.spawn].
class _IsolateInitParams {
  const _IsolateInitParams({
    required this.toMainSendPort,
    required this.sampleRate,
    required this.windowSize,
    required this.stride,
    required this.algorithm,
    required this.weightingMode,
    required this.smootherOrder,
    required this.includeWaveformSnapshot,
    required this.snapshotSize,
    required this.includeSpectrum,
  });

  final SendPort toMainSendPort;
  final int sampleRate;
  final int windowSize;
  final int stride;
  final PitchAlgorithm algorithm;
  final AcousticWeightingMode weightingMode;
  final int smootherOrder;
  final bool includeWaveformSnapshot;
  final int snapshotSize;
  final bool includeSpectrum;
}

/// Top-level worker isolate entry function executing DSP algorithms in isolation.
void _audioWorkerEntry(_IsolateInitParams initParams) async {
  final fromMainPort = ReceivePort();
  // Handshake step 1: send worker SendPort to main isolate
  initParams.toMainSendPort.send(fromMainPort.sendPort);

  var currentSampleRate = initParams.sampleRate;
  var currentWindowSize = initParams.windowSize;
  var currentStride = initParams.stride;
  var includeSnapshot = initParams.includeWaveformSnapshot;
  var snapshotSize = initParams.snapshotSize;
  var includeSpectrum = initParams.includeSpectrum;

  // Internal sliding ring buffer for the worker
  var ringBuffer = AudioRingBuffer(
    capacity: math.max(16384, currentWindowSize * 4),
  );

  var pipeline = TunerDspPipeline(
    frameSize: currentWindowSize,
    algorithm: initParams.algorithm,
    weightingMode: initParams.weightingMode,
    smootherOrder: initParams.smootherOrder,
  );

  var analysisBuffer = Float32List(currentWindowSize);
  var correlationInstance = Correlation(currentWindowSize);
  var autoCorrData = AutoCorrelationData(
    size: currentWindowSize,
    dt: 1.0 / currentSampleRate,
  );
  FFT? fftInstance;
  Float32List? fftOutBuffer;

  // Handshake step 2: worker ready
  initParams.toMainSendPort.send(const WorkerReadyMessage());

  await for (final message in fromMainPort) {
    if (message is AudioDataMessage) {
      try {
        ringBuffer.write(message.samples);

        while (ringBuffer.canReadWindow(currentWindowSize)) {
          final readCount = ringBuffer.read(
            analysisBuffer,
            windowSize: currentWindowSize,
            stride: currentStride,
          );

          if (readCount <= 0) break;

          final result = pipeline.process(
            analysisBuffer,
            sampleRate: currentSampleRate,
          );

          Float32List? snapshot;
          if (includeSnapshot && snapshotSize > 0) {
            snapshot = ringBuffer.getLatestSnapshot(snapshotSize);
          }

          Float32List? correlationValues;
          Float32List? correlationTimes;
          var correlationZero = 0.5;

          if (includeSnapshot) {
            if (correlationInstance.size != currentWindowSize) {
              correlationInstance = Correlation(currentWindowSize);
              autoCorrData = AutoCorrelationData(
                size: currentWindowSize,
                dt: 1.0 / currentSampleRate,
              );
            }
            correlationInstance.correlateToData(
              analysisBuffer,
              autoCorrData,
              disableWindow: false,
            );
            correlationValues = Float32List.fromList(
              autoCorrData.plotValuesNormalized,
            );
            correlationTimes = Float32List.fromList(autoCorrData.times);
            correlationZero = autoCorrData.plotValuesNormalizedZero;
          }

          Float32List? spectrumAmplitudes;
          if (includeSpectrum) {
            if (fftInstance == null || fftInstance.size != currentWindowSize) {
              fftInstance = FFT(currentWindowSize);
              fftOutBuffer = Float32List(currentWindowSize + 2);
            }
            fftInstance.fftReal(analysisBuffer, fftOutBuffer!);
            final numBins = currentWindowSize ~/ 2 + 1;
            spectrumAmplitudes = Float32List(numBins);
            for (var i = 0; i < numBins; i++) {
              final re = fftOutBuffer[2 * i];
              final im = fftOutBuffer[2 * i + 1];
              spectrumAmplitudes[i] = math.sqrt(re * re + im * im);
            }
          }

          final analysisResult = AudioAnalysisResult.fromPipelineResult(
            result,
            waveformSnapshot: snapshot,
            spectrumAmplitudes: spectrumAmplitudes,
            correlationValues: correlationValues,
            correlationTimes: correlationTimes,
            correlationZeroPosition: correlationZero,
            timestampMicros: DateTime.now().microsecondsSinceEpoch,
          );

          initParams.toMainSendPort.send(analysisResult);
        }
      } catch (e, st) {
        initParams.toMainSendPort.send(
          WorkerErrorMessage(e.toString(), st.toString()),
        );
      }
    } else if (message is ConfigureDspMessage) {
      if (message.algorithm != null) {
        pipeline.setAlgorithm(message.algorithm!);
      }
      if (message.weightingMode != null) {
        pipeline.setWeightingMode(message.weightingMode!);
      }
      if (message.smootherOrder != null) {
        pipeline.setSmootherOrder(message.smootherOrder!);
      }
      if (message.sampleRate != null && message.sampleRate! > 0) {
        currentSampleRate = message.sampleRate!;
        autoCorrData = AutoCorrelationData(
          size: currentWindowSize,
          dt: 1.0 / currentSampleRate,
        );
      }
      if (message.windowSize != null && message.windowSize! > 0) {
        currentWindowSize = message.windowSize!;
        analysisBuffer = Float32List(currentWindowSize);
        ringBuffer = AudioRingBuffer(
          capacity: math.max(16384, currentWindowSize * 4),
        );
        fftInstance = null;
        fftOutBuffer = null;
        correlationInstance = Correlation(currentWindowSize);
        autoCorrData = AutoCorrelationData(
          size: currentWindowSize,
          dt: 1.0 / currentSampleRate,
        );
      }
      if (message.stride != null && message.stride! > 0) {
        currentStride = message.stride!;
      }
      includeSnapshot = message.includeWaveformSnapshot;
      snapshotSize = message.snapshotSize;
      includeSpectrum = message.includeSpectrum;
    } else if (message is ResetDspMessage) {
      ringBuffer.clear();
      pipeline.reset();
    } else if (message is DisposeWorkerMessage) {
      fromMainPort.close();
      break;
    }
  }
}

/// Controller managing a dedicated background Dart [Isolate] for offloading
/// intensive audio DSP analysis, with built-in throttled event distribution for UI.
class AudioProcessingIsolate {
  AudioProcessingIsolate();

  Isolate? _isolate;
  ReceivePort? _fromWorkerPort;
  SendPort? _toWorkerPort;
  StreamSubscription? _workerSubscription;

  final StreamController<AudioAnalysisResult> _unthrottledController =
      StreamController<AudioAnalysisResult>.broadcast();
  final StreamController<AudioAnalysisResult> _throttledController =
      StreamController<AudioAnalysisResult>.broadcast();
  final StreamController<WorkerErrorMessage> _errorController =
      StreamController<WorkerErrorMessage>.broadcast();

  bool _isInitialized = false;
  bool _isDisposed = false;

  int _throttleIntervalMicros = 0;
  int _lastEmitTimestampMicros = 0;

  /// Whether the background worker isolate is successfully initialized and active.
  bool get isInitialized => _isInitialized;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Unthrottled stream of every single audio analysis frame produced by the worker isolate.
  Stream<AudioAnalysisResult> get unthrottledResultStream =>
      _unthrottledController.stream;

  /// Rate-limited / throttled stream tailored for UI rendering (e.g. 30~60 FPS).
  Stream<AudioAnalysisResult> get throttledResultStream =>
      _throttledController.stream;

  /// Stream of diagnostic or unhandled errors emitted by the worker isolate.
  Stream<WorkerErrorMessage> get errorStream => _errorController.stream;

  /// Spawns and initializes the background DSP worker isolate.
  Future<void> start({
    int sampleRate = AcousticConstants.defaultSampleRate,
    int windowSize = 2048,
    int stride = 512,
    PitchAlgorithm algorithm = PitchAlgorithm.mpm,
    AcousticWeightingMode weightingMode = AcousticWeightingMode.none,
    int smootherOrder = 3,
    bool includeWaveformSnapshot = true,
    int snapshotSize = 1024,
    bool includeSpectrum = false,
    int? maxFps = 60,
  }) async {
    if (_isDisposed) {
      throw StateError('Cannot start a disposed AudioProcessingIsolate');
    }
    if (_isInitialized) return;

    setThrottleFps(maxFps);

    final fromWorkerPort = ReceivePort();
    _fromWorkerPort = fromWorkerPort;
    final workerReadyCompleter = Completer<void>();

    final initParams = _IsolateInitParams(
      toMainSendPort: fromWorkerPort.sendPort,
      sampleRate: sampleRate,
      windowSize: windowSize,
      stride: stride,
      algorithm: algorithm,
      weightingMode: weightingMode,
      smootherOrder: smootherOrder,
      includeWaveformSnapshot: includeWaveformSnapshot,
      snapshotSize: snapshotSize,
      includeSpectrum: includeSpectrum,
    );

    final workerIsolate = await Isolate.spawn<_IsolateInitParams>(
      _audioWorkerEntry,
      initParams,
      debugName: 'AudioProcessingWorkerIsolate',
    );

    if (_isDisposed) {
      fromWorkerPort.close();
      workerIsolate.kill(priority: Isolate.immediate);
      return;
    }
    _isolate = workerIsolate;

    _workerSubscription = fromWorkerPort.listen((message) {
      if (message is SendPort) {
        _toWorkerPort = message;
      } else if (message is WorkerReadyMessage) {
        if (!workerReadyCompleter.isCompleted) {
          workerReadyCompleter.complete();
        }
      } else if (message is AudioAnalysisResult) {
        _dispatchResult(message);
      } else if (message is WorkerErrorMessage) {
        if (!_errorController.isClosed) {
          _errorController.add(message);
        }
      }
    });

    await workerReadyCompleter.future;
    _isInitialized = true;
  }

  /// Sets the maximum UI frame rate cap in frames per second.
  ///
  /// Passing `null` or `<= 0` disables throttling, causing [throttledResultStream]
  /// to mirror [unthrottledResultStream].
  void setThrottleFps(int? maxFps) {
    if (maxFps != null && maxFps > 0) {
      _throttleIntervalMicros = (1000000 / maxFps).round();
    } else {
      _throttleIntervalMicros = 0;
    }
  }

  void _dispatchResult(AudioAnalysisResult result) {
    if (!_unthrottledController.isClosed) {
      _unthrottledController.add(result);
    }

    if (_throttleIntervalMicros <= 0) {
      if (!_throttledController.isClosed) {
        _throttledController.add(result);
      }
      return;
    }

    final nowMicros = DateTime.now().microsecondsSinceEpoch;
    if (nowMicros - _lastEmitTimestampMicros >= _throttleIntervalMicros) {
      _lastEmitTimestampMicros = nowMicros;
      if (!_throttledController.isClosed) {
        _throttledController.add(result);
      }
    }
  }

  /// Sends a chunk of PCM audio samples to the background worker isolate.
  void postSamples(Float32List samples) {
    if (!_isInitialized || _isDisposed) return;
    _toWorkerPort?.send(AudioDataMessage(samples));
  }

  /// Updates DSP analysis and engine parameters on the background worker isolate.
  void configure({
    PitchAlgorithm? algorithm,
    AcousticWeightingMode? weightingMode,
    int? windowSize,
    int? stride,
    int? sampleRate,
    int? smootherOrder,
    bool includeWaveformSnapshot = true,
    int snapshotSize = 1024,
    bool includeSpectrum = false,
  }) {
    if (!_isInitialized || _isDisposed) return;
    _toWorkerPort?.send(
      ConfigureDspMessage(
        algorithm: algorithm,
        weightingMode: weightingMode,
        windowSize: windowSize,
        stride: stride,
        sampleRate: sampleRate,
        smootherOrder: smootherOrder,
        includeWaveformSnapshot: includeWaveformSnapshot,
        snapshotSize: snapshotSize,
        includeSpectrum: includeSpectrum,
      ),
    );
  }

  /// Resets internal sliding window buffers and temporal filters on the worker isolate.
  void reset() {
    if (!_isInitialized || _isDisposed) return;
    _toWorkerPort?.send(const ResetDspMessage());
  }

  /// Gracefully terminates the background isolate and releases all ports and controllers.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isInitialized = false;

    try {
      _toWorkerPort?.send(const DisposeWorkerMessage());
    } catch (_) {}

    await _workerSubscription?.cancel();
    _workerSubscription = null;

    _fromWorkerPort?.close();
    _fromWorkerPort = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    await _unthrottledController.close();
    await _throttledController.close();
    await _errorController.close();
  }
}
