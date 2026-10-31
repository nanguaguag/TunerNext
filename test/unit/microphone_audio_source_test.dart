import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_source_interface.dart';
import 'package:tuner_flutter/audio/microphone_audio_source.dart';

/// Fake in-memory [MicrophoneDriver] for deterministic testing.
class FakeMicrophoneDriver implements MicrophoneDriver {
  FakeMicrophoneDriver({this.initialHasPermission = true});

  bool initialHasPermission;
  final StreamController<Uint8List> streamController =
      StreamController<Uint8List>.broadcast();

  bool isStarted = false;
  bool isPaused = false;
  bool isStopped = false;
  bool isDisposed = false;

  @override
  Future<bool> hasPermission() async => initialHasPermission;

  @override
  Future<Stream<Uint8List>> startStream(int sampleRate) async {
    isStarted = true;
    isStopped = false;
    isPaused = false;
    return streamController.stream;
  }

  @override
  Future<void> pause() async {
    isPaused = true;
  }

  @override
  Future<void> resume() async {
    isPaused = false;
  }

  @override
  Future<void> stop() async {
    isStopped = true;
    isStarted = false;
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await streamController.close();
  }
}

void main() {
  group('PCM 16-bit to Float32 Conversion Tests (pcm16BytesToFloat32)', () {
    test(
      'Accurately converts standard aligned 16-bit PCM bytes to [-1.0, 1.0]',
      () {
        // 4 samples: -32768, 0, 16384, 32767
        final bytes = Uint8List.fromList([
          0x00, 0x80, // -32768
          0x00, 0x00, // 0
          0x00, 0x40, // 16384
          0xFF, 0x7F, // 32767
        ]);

        final floats = pcm16BytesToFloat32(bytes);
        expect(floats.length, 4);
        expect(floats[0], closeTo(-1.0, 1e-6));
        expect(floats[1], closeTo(0.0, 1e-6));
        expect(floats[2], closeTo(0.5, 1e-6));
        expect(floats[3], closeTo(32767.0 / 32768.0, 1e-6));
      },
    );

    test('Handles unaligned byte buffers defensively via ByteData fallback', () {
      // Create a buffer with an unaligned offset: offset = 1 (odd byte offset)
      final raw = Uint8List.fromList([
        0xFF, // padding dummy byte
        0x00, 0x80, // -32768
        0x00, 0x40, // 16384
      ]);
      final unalignedView = Uint8List.sublistView(raw, 1);
      expect(unalignedView.offsetInBytes % 2, 1); // Confirm odd offset

      final floats = pcm16BytesToFloat32(unalignedView);
      expect(floats.length, 2);
      expect(floats[0], closeTo(-1.0, 1e-6));
      expect(floats[1], closeTo(0.5, 1e-6));
    });

    test('Defensively truncates trailing odd byte without throwing', () {
      // 5 bytes = 2 complete 16-bit samples + 1 trailing odd byte
      final bytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x40, 0xAA]);
      final floats = pcm16BytesToFloat32(bytes);
      expect(floats.length, 2);
      expect(floats[0], closeTo(0.0, 1e-6));
      expect(floats[1], closeTo(0.5, 1e-6));
    });

    test('Empty bytes returns empty Float32List', () {
      final floats = pcm16BytesToFloat32(Uint8List(0));
      expect(floats.length, 0);
    });
  });

  group('MicrophoneAudioSource Lifecycle & Stream Tests', () {
    test(
      'State machine transitions: idle -> recording -> paused -> recording -> idle',
      () async {
        final driver = FakeMicrophoneDriver();
        final source = MicrophoneAudioSource(
          driver: driver,
          sampleRate: 44100,
          handleLifecycleEvents: false,
        );

        final states = <AudioSourceState>[];
        final sub = source.stateStream.listen(states.add);

        expect(source.state, AudioSourceState.idle);

        await source.start();
        expect(source.state, AudioSourceState.recording);
        expect(driver.isStarted, isTrue);

        await source.pause();
        expect(source.state, AudioSourceState.paused);
        expect(driver.isPaused, isTrue);

        await source.resume();
        expect(source.state, AudioSourceState.recording);
        expect(driver.isPaused, isFalse);

        await source.stop();
        expect(source.state, AudioSourceState.idle);
        expect(driver.isStopped, isTrue);

        await source.dispose();
        expect(source.state, AudioSourceState.disposed);
        expect(driver.isDisposed, isTrue);

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

    test(
      'Receives and converts PCM byte chunks into Float32List sample stream',
      () async {
        final driver = FakeMicrophoneDriver();
        final source = MicrophoneAudioSource(
          driver: driver,
          sampleRate: 44100,
          handleLifecycleEvents: false,
        );

        final receivedFrames = <Float32List>[];
        final sub = source.sampleStream.listen(receivedFrames.add);

        await source.start();

        // Emit two chunks of 16-bit PCM bytes
        final chunk1 = Uint8List.fromList([0x00, 0x40]); // 0.5
        final chunk2 = Uint8List.fromList([0x00, 0x80]); // -1.0

        driver.streamController.add(chunk1);
        driver.streamController.add(chunk2);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedFrames.length, 2);
        expect(receivedFrames[0][0], closeTo(0.5, 1e-6));
        expect(receivedFrames[1][0], closeTo(-1.0, 1e-6));

        await sub.cancel();
        await source.dispose();
      },
    );

    test('Operations after dispose throw AudioSourceClosedError', () async {
      final driver = FakeMicrophoneDriver();
      final source = MicrophoneAudioSource(
        driver: driver,
        handleLifecycleEvents: false,
      );

      await source.dispose();

      expect(() => source.start(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.pause(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.resume(), throwsA(isA<AudioSourceClosedError>()));
      expect(() => source.stop(), throwsA(isA<AudioSourceClosedError>()));
    });
  });

  group('Permission & Hardware Error Handling Tests', () {
    test(
      'Permission denied switches to error state with PermissionDeniedError',
      () async {
        final driver = FakeMicrophoneDriver(initialHasPermission: false);
        final source = MicrophoneAudioSource(
          driver: driver,
          handleLifecycleEvents: false,
        );

        dynamic receivedError;
        final completer = Completer<void>();
        source.sampleStream.listen(
          (_) {},
          onError: (e) {
            receivedError = e;
            if (!completer.isCompleted) completer.complete();
          },
        );

        await source.start();
        await completer.future;

        expect(source.state, AudioSourceState.error);
        expect(source.lastError, isA<PermissionDeniedError>());
        expect(receivedError, isA<PermissionDeniedError>());

        await source.dispose();
      },
    );

    test(
      'Hardware stream error switches to error state with MicrophoneUnavailableError',
      () async {
        final driver = FakeMicrophoneDriver();
        final source = MicrophoneAudioSource(
          driver: driver,
          handleLifecycleEvents: false,
        );

        dynamic receivedError;
        final completer = Completer<void>();
        source.sampleStream.listen(
          (_) {},
          onError: (e) {
            receivedError = e;
            if (!completer.isCompleted) completer.complete();
          },
        );

        await source.start();
        driver.streamController.addError(Exception('Mic hardware failure'));

        await completer.future;

        expect(source.state, AudioSourceState.error);
        expect(source.lastError, isA<MicrophoneUnavailableError>());
        expect(receivedError, isA<MicrophoneUnavailableError>());

        await source.dispose();
      },
    );
  });

  group('App Lifecycle Management Tests (handleAppLifecycleChange)', () {
    test(
      'Suspends recording on background and resumes on foreground return',
      () async {
        final driver = FakeMicrophoneDriver();
        final source = MicrophoneAudioSource(
          driver: driver,
          handleLifecycleEvents: false,
        );

        await source.start();
        expect(source.state, AudioSourceState.recording);

        // App goes to background (paused/inactive)
        await source.handleAppLifecycleChange(AppLifecycleState.paused);
        expect(source.state, AudioSourceState.paused);
        expect(driver.isPaused, isTrue);

        // App returns to foreground (resumed)
        await source.handleAppLifecycleChange(AppLifecycleState.resumed);
        expect(source.state, AudioSourceState.recording);
        expect(driver.isPaused, isFalse);

        await source.dispose();
      },
    );

    test(
      'Idle state is preserved when entering background and returning',
      () async {
        final driver = FakeMicrophoneDriver();
        final source = MicrophoneAudioSource(
          driver: driver,
          handleLifecycleEvents: false,
        );

        expect(source.state, AudioSourceState.idle);

        await source.handleAppLifecycleChange(AppLifecycleState.paused);
        expect(source.state, AudioSourceState.idle);

        await source.handleAppLifecycleChange(AppLifecycleState.resumed);
        expect(source.state, AudioSourceState.idle);

        await source.dispose();
      },
    );

    test('Detached lifecycle state disposes audio source', () async {
      final driver = FakeMicrophoneDriver();
      final source = MicrophoneAudioSource(
        driver: driver,
        handleLifecycleEvents: false,
      );

      await source.handleAppLifecycleChange(AppLifecycleState.detached);
      expect(source.state, AudioSourceState.disposed);
    });
  });
}
