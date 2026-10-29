// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';

/// High-performance ring buffer for audio streaming and window extraction.
///
/// Ingests raw PCM 16-bit audio or 32-bit float samples, tracks continuous
/// frame positions, and slices overlapping windows of length [windowSize]
/// with configurable [overlap] ratio.
class CircularAudioBuffer {
  CircularAudioBuffer({
    required int windowSize,
    double overlap = 0.75,
    int? capacity,
  }) : assert(windowSize > 0, 'windowSize must be positive'),
       assert(overlap >= 0.0 && overlap < 1.0, 'overlap must be in [0.0, 1.0)'),
       _windowSize = windowSize,
       _overlap = overlap,
       _capacity = capacity ?? math.max(windowSize * 8, 32768) {
    _buffer = Float32List(_capacity);
    _updateStep();
  }

  int _windowSize;
  double _overlap;
  int _step = 1024;
  int _capacity;
  late Float32List _buffer;

  int _writePos = 0;
  int _readPos = 0;
  int _available = 0;

  /// Absolute frame index in continuous stream corresponding to the first sample
  /// in the next window to be read.
  int _currentWindowFramePosition = 0;

  /// Total number of individual samples ingested since creation or reset.
  int _totalSamplesIngested = 0;

  int get windowSize => _windowSize;
  double get overlap => _overlap;
  int get step => _step;
  int get capacity => _capacity;
  int get availableSamples => _available;
  int get currentWindowFramePosition => _currentWindowFramePosition;
  int get totalSamplesIngested => _totalSamplesIngested;

  void _updateStep() {
    _step = math.max(1, (_windowSize * (1.0 - _overlap)).round());
  }

  /// Reconfigures window size and overlap parameters, clearing unread data
  /// to maintain frame consistency.
  void reconfigure({int? windowSize, double? overlap}) {
    if (windowSize != null) {
      assert(windowSize > 0, 'windowSize must be positive');
      _windowSize = windowSize;
      if (_capacity < _windowSize * 4) {
        _capacity = _windowSize * 8;
        _buffer = Float32List(_capacity);
      }
    }
    if (overlap != null) {
      assert(overlap >= 0.0 && overlap < 1.0, 'overlap must be in [0.0, 1.0)');
      _overlap = overlap;
    }
    _updateStep();
    reset();
  }

  /// Ingests raw 16-bit signed PCM little-endian byte buffer from microphone capture.
  ///
  /// Converts 16-bit integer values in [-32768, 32767] to normalized [-1.0, 1.0] floats.
  void writePcm16Bytes(Uint8List bytes, [int? byteLength]) {
    final length = byteLength ?? bytes.length;
    final numSamples = length ~/ 2;
    if (numSamples == 0) return;

    final byteData = ByteData.sublistView(bytes, 0, numSamples * 2);
    final floats = Float32List(numSamples);
    const scale = 1.0 / 32768.0;

    for (var i = 0; i < numSamples; i++) {
      floats[i] = byteData.getInt16(i * 2, Endian.little) * scale;
    }

    writeSamples(floats);
  }

  /// Ingests normalized float audio samples directly into the circular buffer.
  void writeSamples(Float32List samples, [int? count]) {
    final numSamples = count ?? samples.length;
    if (numSamples == 0) return;

    // Check if new samples exceed capacity; if so, only write the newest tail.
    var sourceOffset = 0;
    var toWrite = numSamples;
    if (toWrite > _capacity) {
      sourceOffset = toWrite - _capacity;
      toWrite = _capacity;
      _totalSamplesIngested += sourceOffset;
    }

    // If writing will overflow unread capacity, drop oldest samples to prevent stale latency
    if (_available + toWrite > _capacity) {
      final overflow = (_available + toWrite) - _capacity;
      _discardOldest(overflow);
    }

    // Write samples in one or two contiguous chunks
    final firstChunk = math.min(toWrite, _capacity - _writePos);
    _buffer.setRange(_writePos, _writePos + firstChunk, samples, sourceOffset);

    final secondChunk = toWrite - firstChunk;
    if (secondChunk > 0) {
      _buffer.setRange(0, secondChunk, samples, sourceOffset + firstChunk);
      _writePos = secondChunk;
    } else {
      _writePos = (_writePos + firstChunk) % _capacity;
    }

    _available += toWrite;
    _totalSamplesIngested += toWrite;
  }

  void _discardOldest(int count) {
    final toDrop = math.min(count, _available);
    _readPos = (_readPos + toDrop) % _capacity;
    _available -= toDrop;
    _currentWindowFramePosition += toDrop;
  }

  /// Returns true if at least [windowSize] samples are available to read.
  bool hasNextWindow() => _available >= _windowSize;

  /// Extracts the next overlapping window of length [windowSize].
  ///
  /// Advances the read cursor by [step] frames and updates [currentWindowFramePosition].
  /// Returns null if fewer than [windowSize] samples are available.
  Float32List? readNextWindow() {
    if (_available < _windowSize) return null;

    final window = Float32List(_windowSize);
    final firstChunk = math.min(_windowSize, _capacity - _readPos);
    window.setRange(0, firstChunk, _buffer, _readPos);

    final secondChunk = _windowSize - firstChunk;
    if (secondChunk > 0) {
      window.setRange(firstChunk, _windowSize, _buffer, 0);
    }

    // Advance read pointer by step
    _readPos = (_readPos + _step) % _capacity;
    _available -= _step;
    _currentWindowFramePosition += _step;

    return window;
  }

  /// Resets the buffer state, discarding all pending samples and resetting frame counter.
  void reset({int initialFramePosition = 0}) {
    _writePos = 0;
    _readPos = 0;
    _available = 0;
    _currentWindowFramePosition = initialFramePosition;
    _totalSamplesIngested = initialFramePosition;
  }
}
