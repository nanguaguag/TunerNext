// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/wave_writer.dart';

void main() {
  group('WaveWriter Tests', () {
    test('Buffering disabled when durationSeconds is 0', () {
      final writer = WaveWriter(durationSeconds: 0);
      expect(writer.isEnabled, isFalse);
      expect(writer.bufferSize, 0);

      writer.appendSamples(Float32List.fromList([0.1, 0.2, 0.3]));
      expect(writer.numStoredValues, 0);

      final snapshot = writer.storeSnapshot();
      expect(snapshot.isEmpty, isTrue);
    });

    test(
      'Circular buffer retains newest data in chronological order across wrap-around',
      () {
        // 4 samples capacity
        final writer = WaveWriter(sampleRate: 4, durationSeconds: 1);
        expect(writer.isEnabled, isTrue);
        expect(writer.bufferSize, 4);

        // Append 3 samples
        writer.appendSamples(Float32List.fromList([1.0, 2.0, 3.0]));
        expect(writer.numStoredValues, 3);
        var snap = writer.storeSnapshot();
        expect(snap, equals([1.0, 2.0, 3.0]));

        // Append 3 more samples: [4.0, 5.0, 6.0]. Total appended: 6 samples.
        // Should now hold the last 4: [3.0, 4.0, 5.0, 6.0]
        writer.appendSamples(Float32List.fromList([4.0, 5.0, 6.0]));
        expect(writer.numStoredValues, 4);
        snap = writer.storeSnapshot();
        expect(snap, equals([3.0, 4.0, 5.0, 6.0]));
      },
    );

    test('Appending PCM 16-bit bytes scales correctly to floats', () {
      final writer = WaveWriter(sampleRate: 4, durationSeconds: 1);
      final byteData = ByteData(8);
      byteData.setInt16(0, 0, Endian.little);
      byteData.setInt16(2, 32767, Endian.little);
      byteData.setInt16(4, -32768, Endian.little);
      byteData.setInt16(6, 16384, Endian.little);

      writer.appendPcm16Bytes(byteData.buffer.asUint8List());
      expect(writer.numStoredValues, 4);

      final snap = writer.storeSnapshot();
      expect(snap[0], closeTo(0.0, 1e-4));
      expect(snap[1], closeTo(32767.0 / 32768.0, 1e-4));
      expect(snap[2], closeTo(-1.0, 1e-4));
      expect(snap[3], closeTo(0.5, 1e-4));
    });

    test(
      'encodeWave produces valid 32-bit IEEE Float RIFF WAVE header and payload',
      () {
        final samples = Float32List.fromList([0.0, 0.5, -0.5, 1.0, -1.0]);
        final waveBytes = WaveWriter.encodeWave(
          data: samples,
          sampleRate: 44100,
          numChannels: 1,
          useIeeeFloat: true,
        );

        // Total file size: 12 + (8 + 18) + (8 + 5 * 4) = 12 + 26 + 28 = 66 bytes
        expect(waveBytes.length, 66);

        // Verify ASCII header markers
        expect(ascii.decode(waveBytes.sublist(0, 4)), 'RIFF');
        expect(ascii.decode(waveBytes.sublist(8, 12)), 'WAVE');
        expect(ascii.decode(waveBytes.sublist(12, 16)), 'fmt ');
        expect(ascii.decode(waveBytes.sublist(38, 42)), 'data');

        final byteData = ByteData.sublistView(waveBytes);
        // Chunk size = total length - 8 = 58
        expect(byteData.getUint32(4, Endian.little), 58);
        // fmt chunk size = 18
        expect(byteData.getUint32(16, Endian.little), 18);
        // Audio format = 3 (IEEE_FLOAT)
        expect(byteData.getUint16(20, Endian.little), 3);
        // Num channels = 1
        expect(byteData.getUint16(22, Endian.little), 1);
        // Sample rate = 44100
        expect(byteData.getUint32(24, Endian.little), 44100);
        // Byte rate = 44100 * 4 = 176400
        expect(byteData.getUint32(28, Endian.little), 176400);
        // Block align = 4
        expect(byteData.getUint16(32, Endian.little), 4);
        // Bits per sample = 32
        expect(byteData.getUint16(34, Endian.little), 32);
        // Data chunk size = 5 * 4 = 20
        expect(byteData.getUint32(42, Endian.little), 20);

        // Verify payload decoded back
        for (var i = 0; i < samples.length; i++) {
          final floatVal = byteData.getFloat32(46 + i * 4, Endian.little);
          expect(floatVal, closeTo(samples[i], 1e-6));
        }
      },
    );

    test(
      'encodeWave produces valid 16-bit PCM RIFF WAVE header and payload',
      () {
        final samples = Float32List.fromList([0.0, 0.5, -0.5, 1.0, -1.0]);
        final waveBytes = WaveWriter.encodeWave(
          data: samples,
          sampleRate: 44100,
          numChannels: 1,
          useIeeeFloat: false,
        );

        // Total file size: 12 + (8 + 16) + (8 + 5 * 2) = 12 + 24 + 18 = 54 bytes
        expect(waveBytes.length, 54);

        expect(ascii.decode(waveBytes.sublist(0, 4)), 'RIFF');
        expect(ascii.decode(waveBytes.sublist(8, 12)), 'WAVE');
        expect(ascii.decode(waveBytes.sublist(12, 16)), 'fmt ');
        expect(ascii.decode(waveBytes.sublist(36, 40)), 'data');

        final byteData = ByteData.sublistView(waveBytes);
        // Audio format = 1 (PCM)
        expect(byteData.getUint16(20, Endian.little), 1);
        // Bits per sample = 16
        expect(byteData.getUint16(34, Endian.little), 16);
        // Data chunk size = 5 * 2 = 10
        expect(byteData.getUint32(40, Endian.little), 10);

        // Verify 16-bit PCM values
        expect(byteData.getInt16(44, Endian.little), 0);
        expect(byteData.getInt16(46, Endian.little), closeTo(16384, 1));
        expect(byteData.getInt16(48, Endian.little), closeTo(-16384, 1));
        expect(byteData.getInt16(50, Endian.little), 32767);
        expect(byteData.getInt16(52, Endian.little), -32768);
      },
    );
  });
}
