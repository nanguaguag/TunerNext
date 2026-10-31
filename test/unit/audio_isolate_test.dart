import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_messages.dart';
import 'package:tuner_flutter/audio/audio_processing_isolate.dart';
import 'package:tuner_flutter/audio/mock_audio_source.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';

void main() {
  group('AudioProcessingIsolate Lifecycle & Initialization Tests', () {
    test(
      'Initializes, connects via handshake, and gracefully disposes',
      () async {
        final isolate = AudioProcessingIsolate();
        expect(isolate.isInitialized, isFalse);
        expect(isolate.isDisposed, isFalse);

        await isolate.start(sampleRate: 44100, windowSize: 1024, stride: 256);

        expect(isolate.isInitialized, isTrue);
        expect(isolate.isDisposed, isFalse);

        // Subsequent start call is idempotent
        await isolate.start();
        expect(isolate.isInitialized, isTrue);

        await isolate.dispose();
        expect(isolate.isInitialized, isFalse);
        expect(isolate.isDisposed, isTrue);

        // Calling dispose again is idempotent
        await isolate.dispose();
        expect(isolate.isDisposed, isTrue);

        // Starting after disposal throws StateError
        expect(() => isolate.start(), throwsA(isA<StateError>()));
      },
    );
  });

  group('End-to-End DSP Worker Pitch Detection Tests', () {
    test(
      'Detects A4 (440 Hz) sine wave accurately on background thread',
      () async {
        final isolate = AudioProcessingIsolate();
        await isolate.start(
          sampleRate: 44100,
          windowSize: 2048,
          stride: 512,
          algorithm: PitchAlgorithm.mpm,
        );

        final results = <AudioAnalysisResult>[];
        final completer = Completer<void>();

        final sub = isolate.unthrottledResultStream.listen((result) {
          results.add(result);
          if (results.length >= 3 && !completer.isCompleted) {
            completer.complete();
          }
        });

        // Generate 440 Hz sine wave frames using MockAudioSource
        final source = MockAudioSource(
          sampleRate: 44100,
          initialSignal: const MockSineWaveSignal(
            frequency: 440.0,
            amplitude: 0.9,
          ),
        );

        // Push 4 blocks of 1024 samples = 4096 samples
        for (var i = 0; i < 4; i++) {
          final block = source.generateBuffer(1024);
          isolate.postSamples(block);
        }

        await completer.future.timeout(const Duration(seconds: 5));
        await sub.cancel();
        await isolate.dispose();

        expect(results.length, greaterThanOrEqualTo(3));
        for (final r in results) {
          expect(r.isSilence, isFalse);
          expect(r.algorithm, PitchAlgorithm.mpm);
          expect(r.confidence, greaterThan(0.8));
          expect(r.smoothedFrequency, closeTo(440.0, 0.5));
          expect(r.waveformSnapshot, isNotNull);
          expect(r.waveformSnapshot!.length, 1024);
        }
      },
    );

    test('Correctly identifies silence from silent input frames', () async {
      final isolate = AudioProcessingIsolate();
      await isolate.start(sampleRate: 44100, windowSize: 1024, stride: 512);

      final results = <AudioAnalysisResult>[];
      final completer = Completer<void>();

      final sub = isolate.unthrottledResultStream.listen((result) {
        results.add(result);
        if (results.length >= 2 && !completer.isCompleted) {
          completer.complete();
        }
      });

      // Push silent blocks
      for (var i = 0; i < 4; i++) {
        isolate.postSamples(Float32List(512));
      }

      await completer.future.timeout(const Duration(seconds: 5));
      await sub.cancel();
      await isolate.dispose();

      expect(results.length, greaterThanOrEqualTo(2));
      for (final r in results) {
        expect(r.isSilence, isTrue);
        expect(r.rawFrequency, 0.0);
        expect(r.smoothedFrequency, 0.0);
        expect(r.confidence, 0.0);
      }
    });
  });

  group('Runtime Configuration & FFT Spectrum Tests', () {
    test(
      'Switches algorithm dynamically and generates FFT magnitude spectrum',
      () async {
        final isolate = AudioProcessingIsolate();
        await isolate.start(
          sampleRate: 44100,
          windowSize: 1024,
          stride: 512,
          algorithm: PitchAlgorithm.mpm,
          includeSpectrum: false,
        );

        final results = <AudioAnalysisResult>[];
        final completer = Completer<void>();

        final sub = isolate.unthrottledResultStream.listen((result) {
          results.add(result);
          if (results.any(
            (r) =>
                r.algorithm == PitchAlgorithm.twm &&
                r.spectrumAmplitudes != null,
          )) {
            if (!completer.isCompleted) completer.complete();
          }
        });

        final source = MockAudioSource(
          sampleRate: 44100,
          initialSignal: const MockSineWaveSignal(
            frequency: 330.0,
            amplitude: 0.8,
          ),
        );

        // Configure to TWM and enable spectrum
        isolate.configure(algorithm: PitchAlgorithm.twm, includeSpectrum: true);

        // Send audio data
        for (var i = 0; i < 6; i++) {
          isolate.postSamples(source.generateBuffer(512));
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }

        await completer.future.timeout(const Duration(seconds: 5));
        await sub.cancel();
        await isolate.dispose();

        final twmWithSpectrum = results.firstWhere(
          (r) =>
              r.algorithm == PitchAlgorithm.twm && r.spectrumAmplitudes != null,
        );

        expect(twmWithSpectrum.algorithm, PitchAlgorithm.twm);
        expect(twmWithSpectrum.spectrumAmplitudes, isNotNull);
        // N/2 + 1 frequency bins for 1024-point FFT = 513
        expect(twmWithSpectrum.spectrumAmplitudes!.length, 513);
      },
    );

    test('reset clears internal state safely', () async {
      final isolate = AudioProcessingIsolate();
      await isolate.start(sampleRate: 44100, windowSize: 1024, stride: 256);

      final source = MockAudioSource(
        sampleRate: 44100,
        initialSignal: const MockSineWaveSignal(frequency: 440.0),
      );

      isolate.postSamples(source.generateBuffer(512));
      isolate.reset();
      isolate.postSamples(source.generateBuffer(512));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await isolate.dispose();
    });
  });

  group('UI Rate-Limiting & Throttler Tests', () {
    test(
      'throttledResultStream rate-limits high-frequency results for UI stability',
      () async {
        final isolate = AudioProcessingIsolate();
        // Configure maxFps to 10 FPS (100ms interval)
        await isolate.start(
          sampleRate: 44100,
          windowSize: 512,
          stride: 128,
          maxFps: 10,
        );

        final unthrottled = <AudioAnalysisResult>[];
        final throttled = <AudioAnalysisResult>[];

        final sub1 = isolate.unthrottledResultStream.listen(unthrottled.add);
        final sub2 = isolate.throttledResultStream.listen(throttled.add);

        final source = MockAudioSource(
          sampleRate: 44100,
          initialSignal: const MockSineWaveSignal(frequency: 440.0),
        );

        // Burst 30 frames rapidly (equivalent to ~30 analysis windows)
        for (var i = 0; i < 15; i++) {
          isolate.postSamples(source.generateBuffer(256));
        }

        // Wait a short time for processing
        await Future<void>.delayed(const Duration(milliseconds: 150));

        await sub1.cancel();
        await sub2.cancel();
        await isolate.dispose();

        expect(unthrottled.length, greaterThanOrEqualTo(10));
        // Throttled stream rate-limited to 10 FPS should have fewer emissions
        expect(throttled.length, lessThan(unthrottled.length));
      },
    );

    test(
      'Disabling throttle causes throttled stream to receive all emissions',
      () async {
        final isolate = AudioProcessingIsolate();
        // maxFps null disables throttling
        await isolate.start(
          sampleRate: 44100,
          windowSize: 512,
          stride: 256,
          maxFps: null,
        );

        final unthrottled = <AudioAnalysisResult>[];
        final throttled = <AudioAnalysisResult>[];

        final sub1 = isolate.unthrottledResultStream.listen(unthrottled.add);
        final sub2 = isolate.throttledResultStream.listen(throttled.add);

        isolate.postSamples(Float32List(1024));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        await sub1.cancel();
        await sub2.cancel();
        await isolate.dispose();

        expect(unthrottled.length, throttled.length);
      },
    );
  });
}
