import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/wave_writer.dart';

void main() {
  group('WaveWriter Unit Tests', () {
    test('Initialization with custom buffer size', () {
      final writer = WaveWriter(bufferSize: 100);
      expect(writer.bufferSize, 100);
      expect(writer.numValues, 0);
      expect(writer.snapshot, isNull);
    });

    test('appendData within capacity', () {
      final writer = WaveWriter(bufferSize: 10);
      final input = Float32List.fromList([1.0, 2.0, 3.0]);
      writer.appendData(input);

      expect(writer.numValues, 3);
      writer.storeSnapshot();
      expect(writer.snapshot, isNotNull);
      expect(writer.snapshot!.length, 3);
      expect(writer.snapshot![0], 1.0);
      expect(writer.snapshot![1], 2.0);
      expect(writer.snapshot![2], 3.0);
    });

    test(
      'appendData overflows circular buffer preserving chronological order',
      () {
        final writer = WaveWriter(bufferSize: 4);
        writer.appendData(Float32List.fromList([1.0, 2.0, 3.0]));
        expect(writer.numValues, 3);

        // Append 3 more values -> buffer total input 6, but max capacity 4
        // Oldest [1.0, 2.0] get dropped, [3.0, 4.0, 5.0, 6.0] should remain
        writer.appendData(Float32List.fromList([4.0, 5.0, 6.0]));
        expect(writer.numValues, 4);

        writer.storeSnapshot();
        expect(writer.snapshot!.length, 4);
        expect(writer.snapshot![0], 3.0);
        expect(writer.snapshot![1], 4.0);
        expect(writer.snapshot![2], 5.0);
        expect(writer.snapshot![3], 6.0);
      },
    );

    test('setBufferSize clears and resizes correctly', () {
      final writer = WaveWriter(bufferSize: 5);
      writer.appendData(Float32List.fromList([1.0, 2.0]));
      expect(writer.numValues, 2);

      writer.setBufferSize(8);
      expect(writer.bufferSize, 8);
      expect(writer.numValues, 0);
    });

    test('encodeWavBytes creates valid IEEE 32-bit float WAV header', () {
      final samples = Float32List.fromList([0.0, 0.5, -0.5, 1.0]);
      final wavBytes = WaveWriter.encodeWavBytes(
        data: samples,
        sampleRate: 44100,
      );

      // 58 bytes header + 4 samples * 4 bytes = 74 bytes total
      expect(wavBytes.length, 58 + 16);

      // Check 'RIFF'
      expect(String.fromCharCodes(wavBytes.sublist(0, 4)), 'RIFF');
      // Check 'WAVE'
      expect(String.fromCharCodes(wavBytes.sublist(8, 12)), 'WAVE');
      // Check 'fmt '
      expect(String.fromCharCodes(wavBytes.sublist(12, 16)), 'fmt ');

      final bd = ByteData.sublistView(wavBytes);
      // Audio format = 3 (IEEE float)
      expect(bd.getUint16(20, Endian.little), 3);
      // Channels = 1
      expect(bd.getUint16(22, Endian.little), 1);
      // Sample rate = 44100
      expect(bd.getUint32(24, Endian.little), 44100);
      // Bits per sample = 32
      expect(bd.getUint16(34, Endian.little), 32);

      // Check 'data'
      expect(String.fromCharCodes(wavBytes.sublist(50, 54)), 'data');
      expect(bd.getUint32(54, Endian.little), 16);

      // Verify float values
      expect(bd.getFloat32(58, Endian.little), 0.0);
      expect(bd.getFloat32(62, Endian.little), 0.5);
      expect(bd.getFloat32(66, Endian.little), -0.5);
      expect(bd.getFloat32(70, Endian.little), 1.0);
    });

    test('encodeSnapshotWav returns null on empty snapshot', () {
      final writer = WaveWriter(bufferSize: 10);
      expect(writer.encodeSnapshotWav(sampleRate: 44100), isNull);

      writer.storeSnapshot();
      expect(writer.encodeSnapshotWav(sampleRate: 44100), isNull);
    });
  });
}
