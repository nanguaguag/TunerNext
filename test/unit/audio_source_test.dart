import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_source_interface.dart';
import 'package:tuner_flutter/audio/mock_audio_source.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/fft/fft.dart';
import 'package:tuner_flutter/dsp/pitch/mcleod_pitch_method.dart';
import 'package:tuner_flutter/dsp/windowing/windowing.dart';

void main() {
  group('AudioSource Lifecycle & State Machine Tests', () {
    test('Initial state is idle and channels/sampleRate match defaults', () {
      final source = MockAudioSource();
      expect(source.state, AudioSourceState.idle);
      expect(source.sampleRate, 44100);
      expect(source.channelCount, 1);
      expect(source.frameSize, 1024);
      expect(source.lastError, isNull);
      expect(source.currentSampleIndex, 0);
    });

    test(
      'State machine transitions: idle -> recording -> paused -> recording -> idle',
      () async {
        final source = MockAudioSource();
        final states = <AudioSourceState>[];
        final sub = source.stateStream.listen(states.add);

        expect(source.state, AudioSourceState.idle);

        await source.start();
        expect(source.state, AudioSourceState.recording);

        // Calling start again while recording should be a no-op
        await source.start();
        expect(source.state, AudioSourceState.recording);

        await source.pause();
        expect(source.state, AudioSourceState.paused);

        // Calling pause again while paused should be a no-op
        await source.pause();
        expect(source.state, AudioSourceState.paused);

        await source.resume();
        expect(source.state, AudioSourceState.recording);

        await source.stop();
        expect(source.state, AudioSourceState.idle);

        // Calling stop again while idle should be a no-op
        await source.stop();
        expect(source.state, AudioSourceState.idle);

        await source.dispose();
        expect(source.state, AudioSourceState.disposed);

        // Calling dispose again should be idempotent
        await source.dispose();
        expect(source.state, AudioSourceState.disposed);

        await sub.cancel();

        expect(states, [
          AudioSourceState.recording,
          AudioSourceState.paused,
          AudioSourceState.recording,
          AudioSourceState.idle,
          AudioSourceState.disposed,
        ]);
      },
    );

    test('Operations after dispose throw AudioSourceClosedError', () async {
      final source = MockAudioSource();
      await source.dispose();

      expect(() => source.start(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.pause(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.resume(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.stop(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.pushFrame(), throwsA(isA<AudioSourceClosedError>()));
      expect(
        () => source.pushBuffer(Float32List(10)),
        throwsA(isA<AudioSourceClosedError>()),
      );
      expect(
        () => source.simulateError(const MicrophoneUnavailableError()),
        throwsA(isA<AudioSourceClosedError>()),
      );
    });

    test('Simulating error notifies listeners and updates lastError', () async {
      final source = MockAudioSource();
      final states = <AudioSourceState>[];
      source.stateStream.listen(states.add);

      dynamic receivedError;
      final errorCompleter = Completer<void>();
      source.sampleStream.listen(
        (_) {},
        onError: (e) {
          receivedError = e;
          if (!errorCompleter.isCompleted) errorCompleter.complete();
        },
      );

      await source.start();
      const testError = PermissionDeniedError(isPermanentlyDenied: true);
      source.simulateError(testError);

      await errorCompleter.future;

      expect(source.state, AudioSourceState.error);
      expect(source.lastError, testError);
      expect(receivedError, testError);
      expect(states, [AudioSourceState.recording, AudioSourceState.error]);

      // Starting after error resets lastError
      await source.start();
      expect(source.state, AudioSourceState.recording);
      expect(source.lastError, isNull);

      await source.dispose();
    });
  });

  group('MockAudioSignal Acoustic Physics & Signal Generation Tests', () {
    test('MockSilenceSignal generates exact 0.0 values', () {
      const silence = MockSilenceSignal();
      final source = MockAudioSource(initialSignal: silence);

      final buffer = source.generateBuffer(512);
      expect(buffer.length, 512);
      for (final sample in buffer) {
        expect(sample, 0.0);
      }
    });

    test('MockSineWaveSignal generates mathematically continuous sine waves', () {
      const freq = 440.0;
      final sine = MockSineWaveSignal(frequency: freq, amplitude: 0.8);
      final source = MockAudioSource(sampleRate: 44100, initialSignal: sine);

      final buffer = source.generateBuffer(44100);
      expect(buffer.length, 44100);

      // Check max and min amplitudes
      double maxVal = -1.0;
      double minVal = 1.0;
      for (final s in buffer) {
        if (s > maxVal) maxVal = s;
        if (s < minVal) minVal = s;
      }

      expect(maxVal, closeTo(0.8, 1e-3));
      expect(minVal, closeTo(-0.8, 1e-3));

      // Verify pitch detection accuracy using McLeodPitchDetector
      final mpm = McLeodPitchDetector();
      final window = Float32List.sublistView(buffer, 0, 4096);
      final pitchResult = mpm.detectPitch(samples: window, sampleRate: 44100);

      expect(pitchResult.isSilence, isFalse);
      // Error within 0.2 Hz (< 0.5 cents at 440Hz), well within theoretical parity
      expect(pitchResult.frequency, closeTo(freq, 0.2));
    });

    test('MockHarmonicSignal generates rich timbre with harmonic overtone decay', () {
      // Violin-like harmonic spectrum: fundamental (1.0), 2nd (0.5), 3rd (0.3), 4th (0.15)
      final harmonics = MockHarmonicSignal(
        fundamentalFrequency: 220.0, // A3
        harmonicAmplitudes: [1.0, 0.5, 0.3, 0.15],
        overallAmplitude: 0.9,
        normalize: true,
      );

      final source = MockAudioSource(
        sampleRate: 44100,
        initialSignal: harmonics,
      );

      final buffer = source.generateBuffer(4096);

      // Verify normalized range [-0.9, 0.9]
      for (final s in buffer) {
        expect(s.abs(), lessThanOrEqualTo(0.9001));
      }

      // Apply Hanning window to suppress rectangular window sidelobe leakage
      final window = Windowing.getWindow(WindowingFunction.hanning, 4096);
      final windowed = Float32List(4096);
      for (int i = 0; i < 4096; i++) {
        windowed[i] = buffer[i] * window[i];
      }

      // FFT spectral analysis to verify harmonics exist at 220, 440, 660, 880 Hz
      final fft = FFT(4096);
      final out = Float32List(4096 + 2);
      fft.fftReal(windowed, out);

      // Compute power at bins: bin = f * 4096 / 44100
      double binPower(double f) {
        final bin = (f * 4096 / 44100).round();
        final re = out[2 * bin];
        final im = out[2 * bin + 1];
        return math.sqrt(re * re + im * im);
      }

      final p1 = binPower(220.0);
      final p2 = binPower(440.0);
      final p3 = binPower(660.0);
      final p4 = binPower(880.0);
      final pNoise = binPower(350.0); // Non-harmonic frequency bin

      expect(p1, greaterThan(10.0));
      expect(p2, greaterThan(5.0));
      expect(p3, greaterThan(2.0));
      expect(p4, greaterThan(1.0));
      // Sidelobe leakage suppressed significantly below fundamental harmonic peak
      expect(p1 / pNoise, greaterThan(30.0));
    });

    test(
      'MockHarmonicSignal handles inharmonic string stiffness B coefficient',
      () {
        // Inharmonic string with stiffness B = 0.0004 (e.g. thick cello or piano string)
        final inharmonic = MockHarmonicSignal(
          fundamentalFrequency: 110.0, // A2
          harmonicAmplitudes: [1.0, 0.8, 0.6],
          stiffnessCoefficientB: 0.0004,
          overallAmplitude: 1.0,
        );

        final source = MockAudioSource(initialSignal: inharmonic);
        final buffer = source.generateBuffer(4096);
        expect(buffer.length, 4096);

        // Calculate theoretical inharmonic frequencies:
        // f_1 = 110 * 1 * sqrt(1 + 0.0004 * 1) = 110.022 Hz
        // f_2 = 110 * 2 * sqrt(1 + 0.0004 * 4) = 220.176 Hz
        // f_3 = 110 * 3 * sqrt(1 + 0.0004 * 9) = 330.593 Hz
        final fft = FFT(4096);
        final out = Float32List(4096 + 2);
        fft.fftReal(buffer, out);

        final bin2Inharmonic = (220.176 * 4096 / 44100).round();
        final re = out[2 * bin2Inharmonic];
        final im = out[2 * bin2Inharmonic + 1];
        final power = math.sqrt(re * re + im * im);
        expect(power, greaterThan(10.0));
      },
    );

    test(
      'MockWhiteNoiseSignal generates bounded random noise with reproducible seed',
      () {
        final noise1 = MockWhiteNoiseSignal(amplitude: 0.4, seed: 12345);
        final noise2 = MockWhiteNoiseSignal(amplitude: 0.4, seed: 12345);

        final buf1 = Float32List(100);
        final buf2 = Float32List(100);

        for (int i = 0; i < 100; i++) {
          buf1[i] = noise1.sampleAt(i / 44100.0, i, 44100);
          buf2[i] = noise2.sampleAt(i / 44100.0, i, 44100);
        }

        // Reproducible pseudo-random sequence
        for (int i = 0; i < 100; i++) {
          expect(buf1[i], buf2[i]);
          expect(buf1[i].abs(), lessThanOrEqualTo(0.40001));
        }

        // Ensure it is not static silence
        final nonZeroCount = buf1.where((s) => s != 0.0).length;
        expect(nonZeroCount, greaterThan(90));
      },
    );

    test(
      'MockFrequencySweepSignal generates continuous linear and logarithmic chirps',
      () {
        const linearChirp = MockFrequencySweepSignal(
          startFrequency: 200.0,
          endFrequency: 800.0,
          durationSeconds: 1.0,
        );
        final sourceLinear = MockAudioSource(initialSignal: linearChirp);
        final bufLinear = sourceLinear.generateBuffer(44100);
        expect(bufLinear.length, 44100);
        for (final s in bufLinear) {
          expect(s.abs(), lessThanOrEqualTo(1.0));
        }

        const logChirp = MockFrequencySweepSignal(
          startFrequency: 100.0,
          endFrequency: 1000.0,
          durationSeconds: 0.5,
          logarithmic: true,
        );
        final sourceLog = MockAudioSource(initialSignal: logChirp);
        final bufLog = sourceLog.generateBuffer(22050);
        expect(bufLog.length, 22050);
        for (final s in bufLog) {
          expect(s.abs(), lessThanOrEqualTo(1.0));
        }
      },
    );

    test('MockCustomSignal correctly passes time t and sampleIndex', () {
      final custom = MockCustomSignal((t, idx) {
        return (idx % 10) / 10.0;
      });

      final source = MockAudioSource(initialSignal: custom);
      final buffer = source.generateBuffer(20);

      for (int i = 0; i < 20; i++) {
        expect(buffer[i], closeTo((i % 10) / 10.0, 1e-6));
      }
    });
  });

  group('Phase Continuity & Buffer Management Tests', () {
    test(
      'Sequential buffers maintain strict phase continuity without clicks',
      () {
        const freq = 300.0;
        final sine = MockSineWaveSignal(frequency: freq, amplitude: 1.0);

        // Source 1: generates two 512-sample blocks sequentially
        final source1 = MockAudioSource(sampleRate: 44100, initialSignal: sine);
        final block1 = source1.generateBuffer(512);
        final block2 = source1.generateBuffer(512);

        // Source 2: generates one 1024-sample block all at once
        final source2 = MockAudioSource(sampleRate: 44100, initialSignal: sine);
        final blockAll = source2.generateBuffer(1024);

        for (int i = 0; i < 512; i++) {
          expect(block1[i], blockAll[i]);
        }
        for (int i = 0; i < 512; i++) {
          expect(block2[i], blockAll[512 + i]);
        }
      },
    );

    test('resetPhase resets sample index counter and phase', () {
      final source = MockAudioSource(
        sampleRate: 44100,
        initialSignal: const MockSineWaveSignal(frequency: 440.0),
      );

      final firstSample = source.generateBuffer(1)[0];
      source.generateBuffer(100);
      expect(source.currentSampleIndex, 101);

      source.resetPhase();
      expect(source.currentSampleIndex, 0);

      final restartedSample = source.generateBuffer(1)[0];
      expect(restartedSample, firstSample);
    });

    test(
      'Stopping source with resetPhaseOnStop=true resets phase, false preserves phase',
      () async {
        final source1 = MockAudioSource(resetPhaseOnStop: true);
        await source1.start();
        source1.generateBuffer(500);
        await source1.stop();
        expect(source1.currentSampleIndex, 0);
        await source1.dispose();

        final source2 = MockAudioSource(resetPhaseOnStop: false);
        await source2.start();
        source2.generateBuffer(500);
        await source2.stop();
        expect(source2.currentSampleIndex, 500);
        await source2.dispose();
      },
    );

    test('Pausing preserves phase and resuming continues smoothly', () async {
      const freq = 440.0;
      final source = MockAudioSource(
        sampleRate: 44100,
        initialSignal: const MockSineWaveSignal(frequency: freq),
      );

      await source.start();
      final p1 = source.generateBuffer(100);
      expect(p1.length, 100);
      await source.pause();
      expect(source.currentSampleIndex, 100);

      await source.resume();
      final p2 = source.generateBuffer(100);
      expect(source.currentSampleIndex, 200);

      // Verify continuity between p1[99] and p2[0]
      final expectedP2_0 = math.sin(2.0 * math.pi * freq * (100 / 44100.0));
      expect(p2[0], closeTo(expectedP2_0, 1e-6));

      await source.dispose();
    });
  });

  group('Streaming & Realtime Mode Tests', () {
    test('Manual pushFrame delivers exact frames to sampleStream', () async {
      final source = MockAudioSource(frameSize: 256);
      final receivedFrames = <Float32List>[];

      final sub = source.sampleStream.listen(receivedFrames.add);

      await source.start();
      await source.pushFrame();
      await source.pushFrame();

      // Give stream controller microtasks a cycle to deliver
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(receivedFrames.length, 2);
      expect(receivedFrames[0].length, 256);
      expect(receivedFrames[1].length, 256);

      await sub.cancel();
      await source.dispose();
    });

    test(
      'Direct pushBuffer delivers arbitrary PCM data to sampleStream',
      () async {
        final source = MockAudioSource();
        final receivedFrames = <Float32List>[];
        final sub = source.sampleStream.listen(receivedFrames.add);

        await source.start();
        final customData = Float32List.fromList([0.1, 0.2, 0.3, 0.4]);
        await source.pushBuffer(customData);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedFrames.length, 1);
        expect(receivedFrames[0], customData);

        await sub.cancel();
        await source.dispose();
      },
    );

    test(
      'Realtime mode pushes frames periodically with correct timing',
      () async {
        final source = MockAudioSource(
          frameSize: 256,
          isRealtime: true,
          pushInterval: const Duration(milliseconds: 20),
        );

        final receivedFrames = <Float32List>[];
        final sub = source.sampleStream.listen(receivedFrames.add);

        await source.start();

        // Wait 100ms (should emit roughly 4-6 frames)
        await Future<void>.delayed(const Duration(milliseconds: 110));

        await source.pause();
        final countAtPause = receivedFrames.length;
        expect(countAtPause, greaterThanOrEqualTo(3));

        // During pause, no new frames should arrive
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(receivedFrames.length, countAtPause);

        // Resume streaming
        await source.resume();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(receivedFrames.length, greaterThan(countAtPause));

        await source.stop();
        await sub.cancel();
        await source.dispose();
      },
    );

    test(
      'Dynamic signal replacement dynamically changes subsequent frames',
      () async {
        final source = MockAudioSource(frameSize: 128);
        final receivedFrames = <Float32List>[];
        final sub = source.sampleStream.listen(receivedFrames.add);

        await source.start();

        // Frame 1: Silence
        await source.pushFrame();

        // Switch to Sine wave
        source.setSignal(const MockSineWaveSignal(frequency: 440.0));
        await source.pushFrame();

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedFrames.length, 2);
        expect(receivedFrames[0].every((s) => s == 0.0), isTrue);
        expect(receivedFrames[1].any((s) => s != 0.0), isTrue);

        await sub.cancel();
        await source.dispose();
      },
    );
  });
}
