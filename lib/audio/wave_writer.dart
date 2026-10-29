// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Lossless circular ring buffer for recording recent audio and exporting
/// standard RIFF WAVE files (matching Kotlin WaveWriter.kt).
///
/// Keeps up to [durationSeconds] worth of audio at [sampleRate] (default: 44100 Hz).
/// When duration is 0, buffering is disabled and consumes no excess memory.
class WaveWriter {
  WaveWriter({this.sampleRate = 44100, int durationSeconds = 0})
    : _durationSeconds = durationSeconds {
    setDurationSeconds(durationSeconds);
  }

  final int sampleRate;
  int _durationSeconds;
  Float32List? _buffer;
  int _insertPosition = 0;
  int _numStoredValues = 0;
  Float32List? _snapshot;

  int get durationSeconds => _durationSeconds;
  bool get isEnabled =>
      _durationSeconds > 0 && _buffer != null && _buffer!.isNotEmpty;
  int get bufferSize => _buffer?.length ?? 0;
  int get numStoredValues => _numStoredValues;
  Float32List? get currentSnapshot => _snapshot;

  /// Sets buffer duration in seconds. Set to 0 to disable buffering.
  void setDurationSeconds(int seconds) {
    _durationSeconds = math.max(0, seconds);
    final capacity = _durationSeconds * sampleRate;
    _numStoredValues = 0;
    _insertPosition = 0;
    if (capacity > 0) {
      if (_buffer?.length != capacity) {
        _buffer = Float32List(capacity);
      }
    } else {
      _buffer = null;
    }
  }

  /// Appends normalized float samples [-1.0, 1.0] to the ring buffer.
  void appendSamples(Float32List input, [int? count]) {
    final bufferLocal = _buffer;
    if (bufferLocal == null || bufferLocal.isEmpty) return;

    final numInputValues = count ?? input.length;
    final maxSize = bufferLocal.length;
    var inputIndexBegin = 0;

    while (inputIndexBegin < numInputValues) {
      final bufferIndexBegin = _insertPosition % maxSize;
      final numCopy = math.min(
        maxSize - bufferIndexBegin,
        numInputValues - inputIndexBegin,
      );
      bufferLocal.setRange(
        bufferIndexBegin,
        bufferIndexBegin + numCopy,
        input,
        inputIndexBegin,
      );
      inputIndexBegin += numCopy;
      _insertPosition += numCopy;
      _numStoredValues += numCopy;
    }

    if (_numStoredValues > maxSize) {
      _numStoredValues = maxSize;
    }
  }

  /// Appends raw PCM 16-bit little-endian bytes to the ring buffer.
  void appendPcm16Bytes(Uint8List bytes, [int? byteLength]) {
    final bufferLocal = _buffer;
    if (bufferLocal == null || bufferLocal.isEmpty) return;

    final length = byteLength ?? bytes.length;
    final numSamples = length ~/ 2;
    if (numSamples == 0) return;

    final byteData = ByteData.sublistView(bytes, 0, numSamples * 2);
    final maxSize = bufferLocal.length;
    const factor = 1.0 / 32768.0;
    var inputIndexBegin = 0;

    while (inputIndexBegin < numSamples) {
      final bufferIndexBegin = _insertPosition % maxSize;
      final numCopy = math.min(
        maxSize - bufferIndexBegin,
        numSamples - inputIndexBegin,
      );
      for (var i = 0; i < numCopy; i++) {
        final shortVal = byteData.getInt16(
          (inputIndexBegin + i) * 2,
          Endian.little,
        );
        bufferLocal[bufferIndexBegin + i] = shortVal * factor;
      }
      inputIndexBegin += numCopy;
      _insertPosition += numCopy;
      _numStoredValues += numCopy;
    }

    if (_numStoredValues > maxSize) {
      _numStoredValues = maxSize;
    }
  }

  /// Freezes the current buffer contents into a linear chronological snapshot array.
  Float32List storeSnapshot() {
    final bufferLocal = _buffer;
    if (bufferLocal == null || _numStoredValues == 0) {
      _snapshot = Float32List(0);
      return _snapshot!;
    }

    final maxSize = bufferLocal.length;
    final out = Float32List(_numStoredValues);
    final bufferIndexBegin =
        ((_insertPosition - _numStoredValues) % maxSize + maxSize) % maxSize;
    final numCopyPart1 = math.min(_numStoredValues, maxSize - bufferIndexBegin);

    out.setRange(0, numCopyPart1, bufferLocal, bufferIndexBegin);
    final numCopyPart2 = _numStoredValues - numCopyPart1;
    if (numCopyPart2 > 0) {
      out.setRange(numCopyPart1, _numStoredValues, bufferLocal, 0);
    }

    _snapshot = out;
    return out;
  }

  /// Encodes audio samples into a standard RIFF WAVE file binary payload.
  ///
  /// Supports both 32-bit IEEE float (default, matching Kotlin WaveWriter)
  /// and standard 16-bit linear PCM format.
  static Uint8List encodeWave({
    required Float32List data,
    int sampleRate = 44100,
    int numChannels = 1,
    bool useIeeeFloat = true,
  }) {
    final bitsPerSample = useIeeeFloat ? 32 : 16;
    final bytesPerSample = bitsPerSample ~/ 8;
    final byteRate = sampleRate * numChannels * bytesPerSample;
    final blockAlign = numChannels * bytesPerSample;
    final dataSize = data.length * bytesPerSample;

    // RIFF chunk descriptor: 12 bytes
    // fmt subchunk:
    //   If IEEE float: subchunk1Size = 18 (16 fmt + 2 cbSize = 0)
    //   If PCM:        subchunk1Size = 16
    final fmtSize = useIeeeFloat ? 18 : 16;
    final subchunk1Size = fmtSize;
    final totalFmtChunkSize = 8 + subchunk1Size; // 'fmt ' (4) + size (4) + data
    final totalDataChunkHeaderSize = 8; // 'data' (4) + size (4)
    final totalFileSize =
        12 + totalFmtChunkSize + totalDataChunkHeaderSize + dataSize;

    final output = Uint8List(totalFileSize);
    final byteData = ByteData.sublistView(output);
    var offset = 0;

    // 1. RIFF Header
    // "RIFF"
    output.setRange(offset, offset + 4, 'RIFF'.codeUnits);
    offset += 4;
    // Chunk size: totalFileSize - 8
    byteData.setUint32(offset, totalFileSize - 8, Endian.little);
    offset += 4;
    // "WAVE"
    output.setRange(offset, offset + 4, 'WAVE'.codeUnits);
    offset += 4;

    // 2. fmt subchunk
    output.setRange(offset, offset + 4, 'fmt '.codeUnits);
    offset += 4;
    byteData.setUint32(offset, subchunk1Size, Endian.little);
    offset += 4;
    // Audio Format: 3 = IEEE_FLOAT, 1 = PCM
    byteData.setUint16(offset, useIeeeFloat ? 3 : 1, Endian.little);
    offset += 2;
    // Channels
    byteData.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    // Sample Rate
    byteData.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    // Byte Rate
    byteData.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    // Block Align
    byteData.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    // Bits Per Sample
    byteData.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;
    if (useIeeeFloat) {
      // Extra params size: 0
      byteData.setUint16(offset, 0, Endian.little);
      offset += 2;
    }

    // 3. data subchunk
    output.setRange(offset, offset + 4, 'data'.codeUnits);
    offset += 4;
    byteData.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // Write audio sample payload
    if (useIeeeFloat) {
      for (var i = 0; i < data.length; i++) {
        byteData.setFloat32(offset, data[i], Endian.little);
        offset += 4;
      }
    } else {
      for (var i = 0; i < data.length; i++) {
        final sample = data[i].clamp(-1.0, 1.0);
        final shortVal = sample < 0.0
            ? (sample * 32768.0).round().clamp(-32768, 32767)
            : (sample * 32767.0).round().clamp(-32768, 32767);
        byteData.setInt16(offset, shortVal, Endian.little);
        offset += 2;
      }
    }

    return output;
  }

  /// Writes the currently stored snapshot to [file] in WAVE format.
  Future<void> writeStoredSnapshotToFile(
    File file, {
    bool useIeeeFloat = true,
  }) async {
    final snapshot = _snapshot ?? storeSnapshot();
    final bytes = encodeWave(
      data: snapshot,
      sampleRate: sampleRate,
      useIeeeFloat: useIeeeFloat,
    );
    await file.writeAsBytes(bytes, flush: true);
  }
}
