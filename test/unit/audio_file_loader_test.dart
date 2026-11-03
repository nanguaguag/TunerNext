import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_file_loader.dart';
import 'package:tuner_flutter/audio/wave_writer.dart';

void main() {
  group('AudioFileLoader Unit Tests', () {
    test('Roundtrip 32-bit float WAV encoding and decoding', () {
      const sampleRate = 44100;
      const durationSec = 0.5;
      final numSamples = (sampleRate * durationSec).toInt();
      final original = Float32List(numSamples);

      // 440 Hz Sine wave
      for (var i = 0; i < numSamples; i++) {
        original[i] = math.sin(2 * math.pi * 440.0 * i / sampleRate) * 0.8;
      }

      final wavBytes = WaveWriter.encodeWavBytes(
        data: original,
        sampleRate: sampleRate,
      );

      final decoded = AudioFileLoader.decodeWavBytes(wavBytes);
      expect(decoded.sampleRate, equals(sampleRate));
      expect(decoded.samples.length, equals(numSamples));
      expect(decoded.duration.inMilliseconds, equals(500));

      for (var i = 0; i < numSamples; i++) {
        expect(decoded.samples[i], closeTo(original[i], 1e-5));
      }
    });

    test('Decodes synthetic 16-bit PCM WAV correctly', () {
      const sampleRate = 22050;
      const numSamples = 100;
      final pcmBytes = BytesBuilder();

      // RIFF header
      pcmBytes.add('RIFF'.codeUnits);
      final fileSize = 36 + numSamples * 2;
      final bData = ByteData(4)..setUint32(0, fileSize, Endian.little);
      pcmBytes.add(bData.buffer.asUint8List());
      pcmBytes.add('WAVE'.codeUnits);

      // fmt subchunk
      pcmBytes.add('fmt '.codeUnits);
      final fmtSize = ByteData(4)..setUint32(0, 16, Endian.little);
      pcmBytes.add(fmtSize.buffer.asUint8List());

      final fmtData = ByteData(16)
        ..setUint16(0, 1, Endian.little) // PCM
        ..setUint16(2, 1, Endian.little) // 1 channel
        ..setUint32(4, sampleRate, Endian.little)
        ..setUint32(8, sampleRate * 2, Endian.little) // byteRate
        ..setUint16(12, 2, Endian.little) // blockAlign
        ..setUint16(14, 16, Endian.little); // bitsPerSample
      pcmBytes.add(fmtData.buffer.asUint8List());

      // data subchunk
      pcmBytes.add('data'.codeUnits);
      final dataChunkSize = ByteData(4)
        ..setUint32(0, numSamples * 2, Endian.little);
      pcmBytes.add(dataChunkSize.buffer.asUint8List());

      // Samples: ramp from -0.5 to +0.5
      final sampleBytes = ByteData(numSamples * 2);
      for (var i = 0; i < numSamples; i++) {
        final val = (i / numSamples) - 0.5;
        final int16Val = (val * 32767.0).round().clamp(-32768, 32767);
        sampleBytes.setInt16(i * 2, int16Val, Endian.little);
      }
      pcmBytes.add(sampleBytes.buffer.asUint8List());

      final decoded = AudioFileLoader.decodeWavBytes(pcmBytes.toBytes());
      expect(decoded.sampleRate, equals(sampleRate));
      expect(decoded.samples.length, equals(numSamples));
      expect(decoded.samples[0], closeTo(-0.5, 0.01));
      expect(decoded.samples[numSamples - 1], closeTo(0.49, 0.02));
    });

    test('Throws on corrupted or truncated WAV data', () {
      expect(
        () => AudioFileLoader.decodeWavBytes(Uint8List(10)),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => AudioFileLoader.decodeWavBytes(Uint8List(50)),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
