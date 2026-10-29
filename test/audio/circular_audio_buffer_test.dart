// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/circular_audio_buffer.dart';

void main() {
  group('CircularAudioBuffer Tests', () {
    test('Initialization and step calculation', () {
      final buffer = CircularAudioBuffer(windowSize: 4096, overlap: 0.75);
      expect(buffer.windowSize, 4096);
      expect(buffer.overlap, 0.75);
      expect(buffer.step, 1024);
      expect(buffer.availableSamples, 0);
      expect(buffer.hasNextWindow(), isFalse);
    });

    test('PCM16 byte conversion accurately normalizes to [-1.0, 1.0]', () {
      final buffer = CircularAudioBuffer(windowSize: 4, overlap: 0.0);
      final byteData = ByteData(8);
      byteData.setInt16(0, 0, Endian.little);
      byteData.setInt16(2, 32767, Endian.little);
      byteData.setInt16(4, -32768, Endian.little);
      byteData.setInt16(6, 16384, Endian.little);

      buffer.writePcm16Bytes(byteData.buffer.asUint8List());
      expect(buffer.availableSamples, 4);
      expect(buffer.hasNextWindow(), isTrue);

      final window = buffer.readNextWindow();
      expect(window, isNotNull);
      expect(window![0], closeTo(0.0, 1e-4));
      expect(window[1], closeTo(32767.0 / 32768.0, 1e-4));
      expect(window[2], closeTo(-1.0, 1e-4));
      expect(window[3], closeTo(0.5, 1e-4));
    });

    test(
      'Sliding window extraction with 50% overlap and frame position tracking',
      () {
        // windowSize = 4, overlap = 0.5 -> step = 2
        final buffer = CircularAudioBuffer(windowSize: 4, overlap: 0.5);

        final input = Float32List.fromList([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]);
        buffer.writeSamples(input);

        expect(buffer.totalSamplesIngested, 7);
        expect(buffer.availableSamples, 7);
        expect(buffer.currentWindowFramePosition, 0);

        // First window: [1, 2, 3, 4]
        expect(buffer.hasNextWindow(), isTrue);
        final w1 = buffer.readNextWindow();
        expect(w1, equals([1.0, 2.0, 3.0, 4.0]));
        expect(buffer.currentWindowFramePosition, 2); // advanced by step=2
        expect(buffer.availableSamples, 5); // 7 - 2 = 5

        // Second window: [3, 4, 5, 6]
        expect(buffer.hasNextWindow(), isTrue);
        final w2 = buffer.readNextWindow();
        expect(w2, equals([3.0, 4.0, 5.0, 6.0]));
        expect(buffer.currentWindowFramePosition, 4); // advanced by step=2
        expect(buffer.availableSamples, 3); // 5 - 2 = 3

        // Third window cannot be read because available=3 < windowSize=4
        expect(buffer.hasNextWindow(), isFalse);
        expect(buffer.readNextWindow(), isNull);

        // Append 1 more sample [8.0], now available = 4
        buffer.writeSamples(Float32List.fromList([8.0]));
        expect(buffer.hasNextWindow(), isTrue);
        final w3 = buffer.readNextWindow();
        expect(w3, equals([5.0, 6.0, 7.0, 8.0]));
        expect(buffer.currentWindowFramePosition, 6);
        expect(buffer.availableSamples, 2);
      },
    );

    test('Circular buffer boundary wrap-around retains data integrity', () {
      // Use small capacity to force multiple wrap-arounds
      final buffer = CircularAudioBuffer(
        windowSize: 4,
        overlap: 0.0, // step = 4
        capacity: 8,
      );

      // Push 8 samples and read 2 windows
      buffer.writeSamples(
        Float32List.fromList([10, 20, 30, 40, 50, 60, 70, 80]),
      );
      final w1 = buffer.readNextWindow();
      expect(w1, equals([10.0, 20.0, 30.0, 40.0]));
      final w2 = buffer.readNextWindow();
      expect(w2, equals([50.0, 60.0, 70.0, 80.0]));
      expect(buffer.availableSamples, 0);

      // Write samples that wrap around buffer boundary
      buffer.writeSamples(Float32List.fromList([90, 100, 110, 120]));
      final w3 = buffer.readNextWindow();
      expect(w3, equals([90.0, 100.0, 110.0, 120.0]));
    });

    test(
      'Overflow drops oldest samples while preserving frame monotonicity',
      () {
        final buffer = CircularAudioBuffer(
          windowSize: 4,
          overlap: 0.0, // step = 4
          capacity: 8,
        );

        // Write 8 samples: [1, 2, 3, 4, 5, 6, 7, 8]
        buffer.writeSamples(Float32List.fromList([1, 2, 3, 4, 5, 6, 7, 8]));
        expect(buffer.availableSamples, 8);
        expect(buffer.currentWindowFramePosition, 0);

        // Write 4 more samples without reading: causes overflow of 4 samples
        buffer.writeSamples(Float32List.fromList([9, 10, 11, 12]));
        // Oldest 4 samples [1, 2, 3, 4] should have been dropped
        expect(buffer.availableSamples, 8);
        expect(buffer.currentWindowFramePosition, 4);

        final w1 = buffer.readNextWindow();
        expect(w1, equals([5.0, 6.0, 7.0, 8.0]));
        final w2 = buffer.readNextWindow();
        expect(w2, equals([9.0, 10.0, 11.0, 12.0]));
        expect(buffer.availableSamples, 0);
      },
    );

    test('Reconfigure resets state with new parameters cleanly', () {
      final buffer = CircularAudioBuffer(windowSize: 2048, overlap: 0.5);
      expect(buffer.step, 1024);

      buffer.writeSamples(Float32List(1000));
      expect(buffer.availableSamples, 1000);

      buffer.reconfigure(windowSize: 4096, overlap: 0.75);
      expect(buffer.windowSize, 4096);
      expect(buffer.overlap, 0.75);
      expect(buffer.step, 1024);
      expect(buffer.availableSamples, 0);
      expect(buffer.currentWindowFramePosition, 0);
    });
  });
}
