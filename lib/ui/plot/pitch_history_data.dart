// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

/// Single measurement entry in pitch history plot.
class PitchHistoryPoint {
  const PitchHistoryPoint({
    required this.frequency,
    required this.isSilence,
    required this.timestampMs,
  });

  final double frequency;
  final bool isSilence;
  final int timestampMs;
}

/// Rolling ring buffer holding pitch history points for 60/120 FPS canvas rendering.
class PitchHistoryData {
  PitchHistoryData({this.capacity = 100})
    : _buffer = List.filled(capacity, null);

  int capacity;
  List<PitchHistoryPoint?> _buffer;
  int _insertIndex = 0;
  int _count = 0;

  int get count => _count;
  bool get isEmpty => _count == 0;
  bool get isNotEmpty => _count > 0;

  /// Resizes the history capacity, retaining as many recent points as possible.
  void resize(int newCapacity) {
    if (newCapacity == capacity) return;
    final points = toList();
    capacity = math.max(10, newCapacity);
    _buffer = List.filled(capacity, null);
    _insertIndex = 0;
    _count = 0;
    final startIdx = math.max(0, points.length - capacity);
    for (var i = startIdx; i < points.length; i++) {
      addPoint(points[i]);
    }
  }

  /// Appends a new point to the rolling ring buffer.
  void add({
    required double frequency,
    required bool isSilence,
    int? timestampMs,
  }) {
    final pt = PitchHistoryPoint(
      frequency: frequency,
      isSilence: isSilence,
      timestampMs: timestampMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    addPoint(pt);
  }

  void addPoint(PitchHistoryPoint point) {
    _buffer[_insertIndex] = point;
    _insertIndex = (_insertIndex + 1) % capacity;
    if (_count < capacity) {
      _count++;
    }
  }

  /// Extracts chronological list of points from oldest to newest.
  List<PitchHistoryPoint> toList() {
    if (_count == 0) return const [];
    final result = List<PitchHistoryPoint>.filled(
      _count,
      const PitchHistoryPoint(frequency: 0, isSilence: true, timestampMs: 0),
    );
    final startIndex = (_insertIndex - _count + capacity) % capacity;
    for (var i = 0; i < _count; i++) {
      result[i] = _buffer[(startIndex + i) % capacity]!;
    }
    return result;
  }

  /// Returns the latest point, or null if buffer is empty.
  PitchHistoryPoint? get latestPoint {
    if (_count == 0) return null;
    final lastIdx = (_insertIndex - 1 + capacity) % capacity;
    return _buffer[lastIdx];
  }

  void clear() {
    _insertIndex = 0;
    _count = 0;
    _buffer.fillRange(0, capacity, null);
  }
}
