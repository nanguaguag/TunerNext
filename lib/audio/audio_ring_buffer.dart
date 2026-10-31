import 'dart:math' as math;
import 'dart:typed_data';

/// High-performance, zero-allocation circular ring buffer for real-time PCM audio streaming.
///
/// Designed for single-producer single-consumer audio processing pipelines (e.g. microphone
/// input streaming -> overlapping sliding window FFT/DSP extraction).
///
/// Features:
/// - Efficient block writes from [Float32List] or [Int16List] (with automatic normalization).
/// - Overlapping sliding window extraction with custom stride $L = N \times (1 - \text{overlap})$.
/// - Non-destructive peak / waveform snapshot extraction for UI oscilloscopes and WAV writers.
/// - Configurable overflow handling (drop oldest for real-time low latency or reject overflow).
/// - Comprehensive throughput and drop diagnostics.
class AudioRingBuffer {
  /// Creates an [AudioRingBuffer] with a fixed [capacity] in samples.
  ///
  /// - [capacity]: Total number of Float32 samples stored before wrapping.
  /// - [allowOverwriteOnOverflow]: If `true` (standard for real-time streaming), incoming
  ///   data overwrites the oldest unread samples when full, incrementing [droppedSamples].
  ///   If `false`, writes that exceed available capacity are truncated or rejected.
  AudioRingBuffer({
    required this.capacity,
    this.allowOverwriteOnOverflow = true,
  }) : assert(capacity > 0, 'Capacity must be positive'),
       _buffer = Float32List(capacity);

  /// Total storage capacity in samples.
  final int capacity;

  /// Whether incoming writes overwrite unconsumed samples when the buffer overflows.
  final bool allowOverwriteOnOverflow;

  final Float32List _buffer;

  int _writeIndex = 0;
  int _readIndex = 0;
  int _availableSamples = 0;

  int _totalSamplesWritten = 0;
  int _totalSamplesRead = 0;
  int _droppedSamples = 0;
  int _overflowOccurrences = 0;

  /// Current number of unread samples available for consumer reading.
  int get availableSamples => _availableSamples;

  /// Remaining free space in the buffer before overflow occurs.
  int get freeSpace => capacity - _availableSamples;

  /// Whether the buffer contains zero unread samples.
  bool get isEmpty => _availableSamples == 0;

  /// Whether the buffer has reached maximum capacity.
  bool get isFull => _availableSamples == capacity;

  /// Total count of samples written since creation or the last [resetStats].
  int get totalSamplesWritten => _totalSamplesWritten;

  /// Total count of samples consumed via [read] since creation or the last [resetStats].
  int get totalSamplesRead => _totalSamplesRead;

  /// Total count of unread samples dropped due to overflow.
  int get droppedSamples => _droppedSamples;

  /// Number of distinct overflow events encountered.
  int get overflowOccurrences => _overflowOccurrences;

  /// Current write pointer index in `[0, capacity - 1]`.
  int get writeIndex => _writeIndex;

  /// Current read pointer index in `[0, capacity - 1]`.
  int get readIndex => _readIndex;

  /// Writes [Float32List] audio samples into the ring buffer.
  ///
  /// - [samples]: Source audio buffer.
  /// - [count]: Optional number of samples to write from [samples] (defaults to `samples.length`).
  /// - Returns the actual number of samples written.
  int write(Float32List samples, [int? count]) {
    final toWrite = count ?? samples.length;
    if (toWrite <= 0) return 0;

    if (toWrite > capacity) {
      // If the incoming chunk is larger than total buffer capacity, only the latest
      // `capacity` samples can fit in the buffer.
      final excess = toWrite - capacity;
      _droppedSamples += excess + _availableSamples;
      _overflowOccurrences++;

      final skip = excess;
      final actualChunk = capacity;

      // Copy the tail `capacity` samples from input directly into _buffer
      _buffer.setRange(0, actualChunk, samples, skip);
      _writeIndex = 0;
      _readIndex = 0;
      _availableSamples = capacity;
      _totalSamplesWritten += toWrite;
      return actualChunk;
    }

    // Check for overflow
    if (_availableSamples + toWrite > capacity) {
      if (!allowOverwriteOnOverflow) {
        final space = capacity - _availableSamples;
        if (space <= 0) return 0;
        return write(samples, space);
      }

      final overflow = (_availableSamples + toWrite) - capacity;
      _droppedSamples += overflow;
      _overflowOccurrences++;
      _readIndex = (_readIndex + overflow) % capacity;
      _availableSamples = capacity - toWrite;
    }

    // Two-stage wrap-around copy
    final firstChunk = math.min(toWrite, capacity - _writeIndex);
    _buffer.setRange(_writeIndex, _writeIndex + firstChunk, samples, 0);

    final secondChunk = toWrite - firstChunk;
    if (secondChunk > 0) {
      _buffer.setRange(0, secondChunk, samples, firstChunk);
    }

    _writeIndex = (_writeIndex + toWrite) % capacity;
    _availableSamples += toWrite;
    _totalSamplesWritten += toWrite;

    return toWrite;
  }

  /// Writes raw 16-bit PCM [Int16List] samples with automatic float normalization to `[-1.0, 1.0]`.
  ///
  /// Avoids intermediate memory allocations when reading directly from platform audio streams.
  int writeInt16(Int16List samples, [int? count]) {
    final toWrite = count ?? samples.length;
    if (toWrite <= 0) return 0;

    const norm = 1.0 / 32768.0;

    if (toWrite > capacity) {
      final excess = toWrite - capacity;
      _droppedSamples += excess + _availableSamples;
      _overflowOccurrences++;

      final skip = excess;
      for (var i = 0; i < capacity; i++) {
        _buffer[i] = samples[skip + i] * norm;
      }
      _writeIndex = 0;
      _readIndex = 0;
      _availableSamples = capacity;
      _totalSamplesWritten += toWrite;
      return capacity;
    }

    if (_availableSamples + toWrite > capacity) {
      if (!allowOverwriteOnOverflow) {
        final space = capacity - _availableSamples;
        if (space <= 0) return 0;
        return writeInt16(samples, space);
      }

      final overflow = (_availableSamples + toWrite) - capacity;
      _droppedSamples += overflow;
      _overflowOccurrences++;
      _readIndex = (_readIndex + overflow) % capacity;
      _availableSamples = capacity - toWrite;
    }

    final firstChunk = math.min(toWrite, capacity - _writeIndex);
    for (var i = 0; i < firstChunk; i++) {
      _buffer[_writeIndex + i] = samples[i] * norm;
    }

    final secondChunk = toWrite - firstChunk;
    for (var i = 0; i < secondChunk; i++) {
      _buffer[i] = samples[firstChunk + i] * norm;
    }

    _writeIndex = (_writeIndex + toWrite) % capacity;
    _availableSamples += toWrite;
    _totalSamplesWritten += toWrite;

    return toWrite;
  }

  /// Checks if at least [windowSize] unread samples are currently available.
  bool canReadWindow(int windowSize) => _availableSamples >= windowSize;

  /// Reads a sliding analysis window of [windowSize] samples into [destination].
  ///
  /// - [destination]: Destination array (must have `length >= windowSize`).
  /// - [windowSize]: Number of samples to copy into [destination].
  /// - [stride]: Step size in samples to advance the read cursor.
  ///   If `null`, defaults to [windowSize] (100% disjoint non-overlapping windows).
  ///   If `stride < windowSize`, creates overlapping sliding windows (e.g. `stride = windowSize ~/ 4`
  ///   for 75% overlap).
  ///
  /// Returns the number of samples copied ([windowSize]), or `0` if insufficient samples
  /// are available ([availableSamples] < [windowSize]).
  int read(Float32List destination, {required int windowSize, int? stride}) {
    if (destination.length < windowSize) {
      throw ArgumentError(
        'destination buffer length (${destination.length}) must be >= windowSize ($windowSize)',
      );
    }
    if (windowSize <= 0) {
      throw ArgumentError.value(windowSize, 'windowSize', 'Must be positive');
    }
    final effectiveStride = stride ?? windowSize;
    if (effectiveStride <= 0) {
      throw ArgumentError.value(effectiveStride, 'stride', 'Must be positive');
    }

    if (_availableSamples < windowSize) {
      return 0; // Insufficient data to form a complete window
    }

    // Two-stage wrap-around copy from _readIndex
    final firstChunk = math.min(windowSize, capacity - _readIndex);
    destination.setRange(0, firstChunk, _buffer, _readIndex);

    final secondChunk = windowSize - firstChunk;
    if (secondChunk > 0) {
      destination.setRange(firstChunk, windowSize, _buffer, 0);
    }

    // Advance read pointer by stride
    final advance = math.min(effectiveStride, _availableSamples);
    _readIndex = (_readIndex + advance) % capacity;
    _availableSamples -= advance;
    _totalSamplesRead += advance;

    return windowSize;
  }

  /// Peeks at [windowSize] samples starting at [offset] from the current read pointer
  /// without advancing the read position.
  int peek(Float32List destination, {required int windowSize, int offset = 0}) {
    if (destination.length < windowSize) {
      throw ArgumentError(
        'destination buffer length (${destination.length}) must be >= windowSize ($windowSize)',
      );
    }
    if (_availableSamples < offset + windowSize) {
      return 0;
    }

    final startIdx = (_readIndex + offset) % capacity;
    final firstChunk = math.min(windowSize, capacity - startIdx);
    destination.setRange(0, firstChunk, _buffer, startIdx);

    final secondChunk = windowSize - firstChunk;
    if (secondChunk > 0) {
      destination.setRange(firstChunk, windowSize, _buffer, 0);
    }

    return windowSize;
  }

  /// Extracts the most recently written [count] samples in chronological order
  /// without modifying read or write pointers.
  ///
  /// Useful for oscilloscope wave plotting, FFT previews, and WAV snapshot writing.
  ///
  /// - [count]: Number of recent samples desired.
  /// - [destination]: Optional pre-allocated buffer (length must be >= [count]).
  ///   If omitted, a new [Float32List] of length [count] is allocated.
  ///
  /// If the buffer has not yet accumulated [count] total samples, the leading
  /// unrecorded portion is padded with `0.0`.
  Float32List getLatestSnapshot(int count, {Float32List? destination}) {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'Must be positive');
    }
    final target = destination ?? Float32List(count);
    if (target.length < count) {
      throw ArgumentError(
        'destination length (${target.length}) must be >= count ($count)',
      );
    }

    final effectiveCount = math.min(count, capacity);
    final validSamples = math.min(effectiveCount, _totalSamplesWritten);
    final padCount = count - validSamples;

    // Pad beginning with silence if not enough samples written yet
    if (padCount > 0) {
      target.fillRange(0, padCount, 0.0);
    }

    if (validSamples > 0) {
      final startIdx = (_writeIndex - validSamples + capacity) % capacity;
      final firstChunk = math.min(validSamples, capacity - startIdx);
      target.setRange(padCount, padCount + firstChunk, _buffer, startIdx);

      final secondChunk = validSamples - firstChunk;
      if (secondChunk > 0) {
        target.setRange(
          padCount + firstChunk,
          padCount + validSamples,
          _buffer,
          0,
        );
      }
    }

    return target;
  }

  /// Discards [count] unread samples, advancing the read pointer.
  int discard(int count) {
    if (count <= 0) return 0;
    final toDiscard = math.min(count, _availableSamples);
    _readIndex = (_readIndex + toDiscard) % capacity;
    _availableSamples -= toDiscard;
    _totalSamplesRead += toDiscard;
    return toDiscard;
  }

  /// Clears all stored samples and resets read/write pointers to zero.
  void clear() {
    _writeIndex = 0;
    _readIndex = 0;
    _availableSamples = 0;
  }

  /// Resets cumulative diagnostic counters ([totalSamplesWritten], [totalSamplesRead],
  /// [droppedSamples], [overflowOccurrences]).
  void resetStats() {
    _totalSamplesWritten = 0;
    _totalSamplesRead = 0;
    _droppedSamples = 0;
    _overflowOccurrences = 0;
  }
}
