import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tuner_flutter/audio/audio_source_interface.dart';
import 'package:tuner_flutter/core/constants/acoustic_constants.dart';

/// Base class for configurable acoustic signal models.
sealed class MockAudioSignal {
  const MockAudioSignal();

  /// Generates the sample value at time [t] (seconds), sample index [sampleIndex],
  /// given the audio [sampleRate].
  double sampleAt(double t, int sampleIndex, int sampleRate);
}

/// Generates pure silence (all 0.0 values).
class MockSilenceSignal extends MockAudioSignal {
  const MockSilenceSignal();

  @override
  double sampleAt(double t, int sampleIndex, int sampleRate) => 0.0;
}

/// Generates a pure sine wave:
/// \[ s(t) = A \sin(2\pi f t + \phi_0) \]
class MockSineWaveSignal extends MockAudioSignal {
  const MockSineWaveSignal({
    required this.frequency,
    this.amplitude = 1.0,
    this.initialPhase = 0.0,
  }) : assert(frequency >= 0, 'Frequency must be non-negative'),
       assert(amplitude >= 0, 'Amplitude must be non-negative');

  final double frequency;
  final double amplitude;
  final double initialPhase;

  @override
  double sampleAt(double t, int sampleIndex, int sampleRate) {
    if (frequency == 0.0 || amplitude == 0.0) return 0.0;
    final phase = 2.0 * math.pi * frequency * t + initialPhase;
    return amplitude * math.sin(phase);
  }
}

/// Generates a complex harmonic series with optional string stiffness dispersion.
///
/// Inharmonicity dispersion formula for piano/string stiffness:
/// \[ f_k = k \cdot f_0 \sqrt{1 + B k^2} \]
class MockHarmonicSignal extends MockAudioSignal {
  MockHarmonicSignal({
    required this.fundamentalFrequency,
    this.harmonicAmplitudes = const [1.0],
    this.stiffnessCoefficientB = 0.0,
    this.overallAmplitude = 1.0,
    this.normalize = true,
  }) : assert(fundamentalFrequency >= 0, 'Frequency must be non-negative'),
       assert(stiffnessCoefficientB >= 0, 'Stiffness B must be non-negative'),
       assert(overallAmplitude >= 0, 'Overall amplitude must be non-negative') {
    if (normalize && harmonicAmplitudes.isNotEmpty) {
      final sum = harmonicAmplitudes.fold<double>(
        0.0,
        (acc, a) => acc + a.abs(),
      );
      _normFactor = sum > 0.0 ? (overallAmplitude / sum) : 1.0;
    } else {
      _normFactor = overallAmplitude;
    }
  }

  final double fundamentalFrequency;
  final List<double> harmonicAmplitudes;
  final double stiffnessCoefficientB;
  final double overallAmplitude;
  final bool normalize;
  late final double _normFactor;

  @override
  double sampleAt(double t, int sampleIndex, int sampleRate) {
    if (fundamentalFrequency == 0.0 || overallAmplitude == 0.0) return 0.0;
    final nyquist = sampleRate / 2.0;
    double sample = 0.0;

    for (int i = 0; i < harmonicAmplitudes.length; i++) {
      final k = i + 1; // 1-based harmonic index
      final amp = harmonicAmplitudes[i];
      if (amp == 0.0) continue;

      // Inharmonic frequency calculation
      final fk = (stiffnessCoefficientB > 0.0)
          ? fundamentalFrequency *
                k *
                math.sqrt(1.0 + stiffnessCoefficientB * k * k)
          : fundamentalFrequency * k;

      // Anti-aliasing / Nyquist protection
      if (fk >= nyquist) break;

      sample += amp * math.sin(2.0 * math.pi * fk * t);
    }
    return sample * _normFactor;
  }
}

/// Generates white noise with uniform distribution in `[-amplitude, amplitude]`.
class MockWhiteNoiseSignal extends MockAudioSignal {
  MockWhiteNoiseSignal({this.amplitude = 0.1, int? seed})
    : _random = math.Random(seed),
      assert(amplitude >= 0, 'Amplitude must be non-negative');

  final double amplitude;
  final math.Random _random;

  @override
  double sampleAt(double t, int sampleIndex, int sampleRate) {
    if (amplitude == 0.0) return 0.0;
    return (2.0 * _random.nextDouble() - 1.0) * amplitude;
  }
}

/// Generates a frequency sweep (chirp) signal.
class MockFrequencySweepSignal extends MockAudioSignal {
  const MockFrequencySweepSignal({
    required this.startFrequency,
    required this.endFrequency,
    required this.durationSeconds,
    this.amplitude = 1.0,
    this.logarithmic = false,
  }) : assert(startFrequency > 0, 'Start frequency must be positive'),
       assert(endFrequency > 0, 'End frequency must be positive'),
       assert(durationSeconds > 0, 'Duration must be positive');

  final double startFrequency;
  final double endFrequency;
  final double durationSeconds;
  final double amplitude;
  final bool logarithmic;

  @override
  double sampleAt(double t, int sampleIndex, int sampleRate) {
    if (durationSeconds <= 0.0) return 0.0;
    final wrappedTime = t % durationSeconds;
    double instantaneousPhase;

    if (logarithmic) {
      final ratio = endFrequency / startFrequency;
      final k = math.log(ratio) / durationSeconds;
      instantaneousPhase =
          2.0 *
          math.pi *
          startFrequency *
          (math.exp(k * wrappedTime) - 1.0) /
          k;
    } else {
      final sweepRate = (endFrequency - startFrequency) / durationSeconds;
      instantaneousPhase =
          2.0 *
          math.pi *
          (startFrequency * wrappedTime +
              0.5 * sweepRate * wrappedTime * wrappedTime);
    }
    return amplitude * math.sin(instantaneousPhase);
  }
}

/// Custom programmatic signal callback, mirroring Kotlin TestFunction.
class MockCustomSignal extends MockAudioSignal {
  const MockCustomSignal(this.generator);

  final double Function(double t, int sampleIndex) generator;

  @override
  double sampleAt(double t, int sampleIndex, int sampleRate) {
    return generator(t, sampleIndex);
  }
}

/// Pure Dart mock audio source for high-fidelity acoustic simulation and automated unit testing.
class MockAudioSource implements AudioSource {
  MockAudioSource({
    this.sampleRate = AcousticConstants.defaultSampleRate,
    this.channelCount = 1,
    this.frameSize = 1024,
    this.isRealtime = false,
    Duration? pushInterval,
    MockAudioSignal initialSignal = const MockSilenceSignal(),
    this.resetPhaseOnStop = true,
  }) : _currentSignal = initialSignal,
       pushInterval =
           pushInterval ??
           Duration(microseconds: ((frameSize / sampleRate) * 1000000).round()),
       assert(sampleRate > 0, 'Sample rate must be positive'),
       assert(channelCount == 1, 'Only mono audio is currently supported'),
       assert(frameSize > 0, 'Frame size must be positive');

  @override
  final int sampleRate;

  @override
  final int channelCount;

  /// Number of samples produced in a single pushed frame.
  final int frameSize;

  /// Whether the mock source automatically produces frames using an internal periodic timer.
  final bool isRealtime;

  /// Periodic timer interval when [isRealtime] is true.
  final Duration pushInterval;

  /// Whether stopping the source resets the elapsed sample phase counter.
  final bool resetPhaseOnStop;

  final StreamController<Float32List> _sampleController =
      StreamController<Float32List>.broadcast();
  final StreamController<AudioSourceState> _stateController =
      StreamController<AudioSourceState>.broadcast();

  AudioSourceState _state = AudioSourceState.idle;
  AudioSourceError? _lastError;
  Timer? _timer;
  int _currentSampleIndex = 0;
  MockAudioSignal _currentSignal;

  @override
  Stream<Float32List> get sampleStream => _sampleController.stream;

  @override
  Stream<AudioSourceState> get stateStream => _stateController.stream;

  @override
  AudioSourceState get state => _state;

  @override
  AudioSourceError? get lastError => _lastError;

  /// Gets the currently configured acoustic signal model.
  MockAudioSignal get currentSignal => _currentSignal;

  /// The total number of samples generated since start or the last phase reset.
  int get currentSampleIndex => _currentSampleIndex;

  /// Dynamically updates the acoustic signal model without phase discontinuity.
  void setSignal(MockAudioSignal newSignal) {
    _currentSignal = newSignal;
  }

  /// Resets the phase / sample index counter to zero.
  void resetPhase() {
    _currentSampleIndex = 0;
  }

  void _changeState(AudioSourceState newState) {
    if (_state != newState) {
      _state = newState;
      if (!_stateController.isClosed) {
        _stateController.add(newState);
      }
    }
  }

  void _checkNotDisposed() {
    if (_state == AudioSourceState.disposed) {
      throw const AudioSourceClosedError('MockAudioSource is already disposed');
    }
  }

  @override
  Future<void> start() async {
    _checkNotDisposed();
    if (_state == AudioSourceState.recording) return;

    _lastError = null;
    _changeState(AudioSourceState.recording);

    if (isRealtime) {
      _startTimer();
    }
  }

  @override
  Future<void> pause() async {
    _checkNotDisposed();
    if (_state != AudioSourceState.recording) return;

    _stopTimer();
    _changeState(AudioSourceState.paused);
  }

  @override
  Future<void> resume() async {
    _checkNotDisposed();
    if (_state == AudioSourceState.recording) return;

    if (_state == AudioSourceState.paused) {
      _changeState(AudioSourceState.recording);
      if (isRealtime) {
        _startTimer();
      }
    } else {
      await start();
    }
  }

  @override
  Future<void> stop() async {
    _checkNotDisposed();
    if (_state == AudioSourceState.idle) return;

    _stopTimer();
    _changeState(AudioSourceState.idle);

    if (resetPhaseOnStop) {
      resetPhase();
    }
  }

  @override
  Future<void> dispose() async {
    if (_state == AudioSourceState.disposed) return;

    _stopTimer();
    _changeState(AudioSourceState.disposed);

    await _sampleController.close();
    await _stateController.close();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(pushInterval, (_) {
      if (_state == AudioSourceState.recording) {
        pushFrame();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Generates a continuous block of [count] samples, advancing internal sample index.
  Float32List generateBuffer(int count) {
    final buffer = Float32List(count);
    final dt = 1.0 / sampleRate;

    for (int i = 0; i < count; i++) {
      final sampleIdx = _currentSampleIndex + i;
      final t = sampleIdx * dt;
      final raw = _currentSignal.sampleAt(t, sampleIdx, sampleRate);
      buffer[i] = raw.clamp(-1.0, 1.0);
    }

    _currentSampleIndex += count;
    return buffer;
  }

  /// Pushes one frame of [frameSize] samples into [sampleStream].
  ///
  /// If [force] is true, pushes the frame regardless of whether the source is
  /// currently in [AudioSourceState.recording], provided it has not been disposed.
  Future<void> pushFrame({bool force = false}) async {
    _checkNotDisposed();
    if (!force && _state != AudioSourceState.recording) return;

    final buffer = generateBuffer(frameSize);
    if (!_sampleController.isClosed) {
      _sampleController.add(buffer);
    }
  }

  /// Directly injects an external [buffer] into [sampleStream].
  Future<void> pushBuffer(Float32List buffer) async {
    _checkNotDisposed();
    if (!_sampleController.isClosed) {
      _sampleController.add(buffer);
    }
  }

  /// Simulates an audio hardware or capture error, triggering state change and stream error.
  void simulateError(AudioSourceError error) {
    _checkNotDisposed();
    _stopTimer();
    _lastError = error;
    _changeState(AudioSourceState.error);
    if (!_sampleController.isClosed) {
      _sampleController.addError(error);
    }
  }
}
