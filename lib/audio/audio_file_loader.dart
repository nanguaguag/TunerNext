import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

/// Represents decoded uncompressed single-channel float audio data.
class DecodedAudio {
  const DecodedAudio({
    required this.samples,
    required this.sampleRate,
    required this.duration,
  });

  /// Normalized audio samples in range `[-1.0, 1.0]`.
  final Float32List samples;

  /// Audio sample rate in Hertz (e.g. 44100, 48000).
  final int sampleRate;

  /// Duration of the audio track.
  final Duration duration;
}

/// Service capable of decoding WAV audio files and converting media files to PCM.
class AudioFileLoader {
  const AudioFileLoader();

  /// Decodes raw standard RIFF/WAVE binary bytes into [DecodedAudio].
  /// Supports 16-bit signed integer and 32-bit IEEE float formats (mono or stereo).
  static DecodedAudio decodeWavBytes(Uint8List bytes) {
    if (bytes.lengthInBytes < 44) {
      throw const FormatException(
        'Invalid WAV file: data too short (< 44 bytes)',
      );
    }

    final byteData = ByteData.sublistView(bytes);

    // Validate RIFF header
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final wave = String.fromCharCodes(bytes.sublist(8, 12));
    if (riff != 'RIFF' || wave != 'WAVE') {
      throw const FormatException(
        'Invalid WAV format: missing RIFF/WAVE signature',
      );
    }

    // Parse chunks
    var offset = 12;
    int audioFormat = 1;
    int numChannels = 1;
    int sampleRate = 44100;
    int bitsPerSample = 16;
    int dataOffset = -1;
    int dataSize = 0;

    while (offset + 8 <= bytes.lengthInBytes) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      offset += 8;

      if (chunkId == 'fmt ') {
        if (chunkSize >= 16 && offset + 16 <= bytes.lengthInBytes) {
          audioFormat = byteData.getUint16(offset, Endian.little);
          numChannels = byteData.getUint16(offset + 2, Endian.little);
          sampleRate = byteData.getUint32(offset + 4, Endian.little);
          bitsPerSample = byteData.getUint16(offset + 14, Endian.little);
        }
      } else if (chunkId == 'data') {
        dataOffset = offset;
        dataSize = chunkSize;
        break;
      }
      offset += chunkSize;
    }

    if (dataOffset < 0 || dataOffset + dataSize > bytes.lengthInBytes) {
      dataOffset = 44;
      dataSize = bytes.lengthInBytes - 44;
    }

    if (numChannels <= 0) numChannels = 1;

    Float32List samples;

    if (audioFormat == 1 && bitsPerSample == 16) {
      // 16-bit PCM Signed Integer
      final totalPcmSamples = dataSize ~/ 2;
      final totalFrames = totalPcmSamples ~/ numChannels;
      samples = Float32List(totalFrames);

      for (var f = 0; f < totalFrames; f++) {
        var sum = 0.0;
        for (var c = 0; c < numChannels; c++) {
          final sIdx = (f * numChannels + c) * 2;
          if (dataOffset + sIdx + 2 <= bytes.lengthInBytes) {
            final sampleInt = byteData.getInt16(
              dataOffset + sIdx,
              Endian.little,
            );
            sum += sampleInt / 32768.0;
          }
        }
        samples[f] = (sum / numChannels).clamp(-1.0, 1.0);
      }
    } else if (audioFormat == 3 && bitsPerSample == 32) {
      // 32-bit IEEE 754 Float
      final totalPcmSamples = dataSize ~/ 4;
      final totalFrames = totalPcmSamples ~/ numChannels;
      samples = Float32List(totalFrames);

      for (var f = 0; f < totalFrames; f++) {
        var sum = 0.0;
        for (var c = 0; c < numChannels; c++) {
          final sIdx = (f * numChannels + c) * 4;
          if (dataOffset + sIdx + 4 <= bytes.lengthInBytes) {
            sum += byteData.getFloat32(dataOffset + sIdx, Endian.little);
          }
        }
        samples[f] = (sum / numChannels).clamp(-1.0, 1.0);
      }
    } else {
      throw FormatException(
        'Unsupported WAV encoding: format=$audioFormat, bits=$bitsPerSample, channels=$numChannels',
      );
    }

    final durationSec = samples.isNotEmpty ? samples.length / sampleRate : 0.0;
    return DecodedAudio(
      samples: samples,
      sampleRate: sampleRate,
      duration: Duration(milliseconds: (durationSec * 1000).round()),
    );
  }

  /// Loads and decodes an audio file from Flutter assets bundle.
  static Future<DecodedAudio> loadFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    return decodeWavBytes(bytes);
  }

  /// Loads the built-in test whistle audio sample seamlessly across all platforms.
  static Future<DecodedAudio> loadDefaultTestWhistle() async {
    try {
      return await loadFromAsset('assets/audio/test_music.wav');
    } catch (_) {
      // Fallback for standalone test runners or dev paths
      final candidates = ['assets/audio/test_music.wav', 'docs/test_music.m4a'];
      for (final p in candidates) {
        if (File(p).existsSync()) {
          return await loadFromFile(p);
        }
      }
      rethrow;
    }
  }

  /// Loads and decodes an audio file from local storage at [path].
  /// Supports direct WAV loading, and transcode fallback (via macOS `afconvert` or `ffmpeg`) for m4a/mp3.
  static Future<DecodedAudio> loadFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('Audio file not found at path', path);
    }

    final lower = path.toLowerCase();
    if (lower.endsWith('.wav')) {
      final bytes = await file.readAsBytes();
      return decodeWavBytes(bytes);
    }

    // For m4a, mp3, aac, flac: try converting via /usr/bin/afconvert or ffmpeg
    final tempDir = Directory.systemTemp;
    final tempWavPath =
        '${tempDir.path}/tuner_transcode_${DateTime.now().millisecondsSinceEpoch}.wav';

    ProcessResult? result;
    if (Platform.isMacOS) {
      // Try absolute path /usr/bin/afconvert first
      const afconvertPath = '/usr/bin/afconvert';
      final exe = File(afconvertPath).existsSync()
          ? afconvertPath
          : 'afconvert';
      try {
        result = await Process.run(exe, [
          '-f',
          'WAVE',
          '-d',
          'LEI16',
          '-c',
          '1',
          path,
          tempWavPath,
        ]);
      } catch (_) {}
    }

    if (result == null || result.exitCode != 0) {
      // Try ffmpeg fallback if available
      try {
        result = await Process.run('ffmpeg', [
          '-y',
          '-i',
          path,
          '-ac',
          '1',
          '-ar',
          '44100',
          tempWavPath,
        ]);
      } catch (_) {}
    }

    final tempFile = File(tempWavPath);
    if (await tempFile.exists()) {
      try {
        final bytes = await tempFile.readAsBytes();
        return decodeWavBytes(bytes);
      } finally {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }

    throw FormatException(
      'Cannot decode non-WAV audio format without system converter (afconvert/ffmpeg): $path. Please select a standard .wav file.',
    );
  }
}
