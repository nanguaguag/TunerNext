// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:tuner_flutter/audio/record_audio_source.dart';

class _ThrowingRecorder extends AudioRecorder {
  int disposeCallCount = 0;

  @override
  Future<void> dispose() async {
    disposeCallCount++;
    throw PlatformException(
      code: 'record',
      message: 'Recorder has not yet been created or has already been disposed.',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (MethodCall methodCall) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          null,
        );
  });

  group('RecordAudioSource Lifecycle & Error Resilience Tests', () {
    test(
      'Swallows PlatformException when recorder is already disposed or not created',
      () async {
        final mockRecorder = _ThrowingRecorder();
        final source = RecordAudioSource(recorder: mockRecorder);

        // Should complete normally without throwing unhandled PlatformException
        await expectLater(source.dispose(), completes);
        expect(mockRecorder.disposeCallCount, equals(1));

        // Calling dispose again should be an idempotent no-op
        await expectLater(source.dispose(), completes);
        expect(mockRecorder.disposeCallCount, equals(1));
      },
    );

    test('RecordAudioSource start is no-op after disposal', () async {
      final mockRecorder = _ThrowingRecorder();
      final source = RecordAudioSource(recorder: mockRecorder);

      await source.dispose();
      await source.start();

      // State remains idle/disposed without attempting to access recorder
      expect(source.state.name, equals('idle'));
    });
  });
}
