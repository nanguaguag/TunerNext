import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/audio_ring_buffer.dart';

void main() {
  group('AudioRingBuffer Initialization & Basics', () {
    test('Initial properties match defaults and buffer is empty', () {
      final rb = AudioRingBuffer(capacity: 1024);

      expect(rb.capacity, 1024);
      expect(rb.allowOverwriteOnOverflow, isTrue);
      expect(rb.availableSamples, 0);
      expect(rb.freeSpace, 1024);
      expect(rb.isEmpty, isTrue);
      expect(rb.isFull, isFalse);
      expect(rb.totalSamplesWritten, 0);
      expect(rb.totalSamplesRead, 0);
      expect(rb.droppedSamples, 0);
      expect(rb.overflowOccurrences, 0);
      expect(rb.writeIndex, 0);
      expect(rb.readIndex, 0);
    });

    test('Rejects non-positive capacity with AssertionError', () {
      expect(
        () => AudioRingBuffer(capacity: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => AudioRingBuffer(capacity: -10),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Sequential Read and Write Operations', () {
    test('Writes and reads sequential Float32List samples correctly', () {
      final rb = AudioRingBuffer(capacity: 100);
      final input = Float32List.fromList([1.0, 2.0, 3.0, 4.0, 5.0]);

      final written = rb.write(input);
      expect(written, 5);
      expect(rb.availableSamples, 5);
      expect(rb.freeSpace, 95);
      expect(rb.isEmpty, isFalse);
      expect(rb.isFull, isFalse);
      expect(rb.totalSamplesWritten, 5);

      final output = Float32List(5);
      final readCount = rb.read(output, windowSize: 5);

      expect(readCount, 5);
      expect(output, [1.0, 2.0, 3.0, 4.0, 5.0]);
      expect(rb.availableSamples, 0);
      expect(rb.freeSpace, 100);
      expect(rb.isEmpty, isTrue);
      expect(rb.totalSamplesRead, 5);
    });

    test('Partial write count argument limits written samples', () {
      final rb = AudioRingBuffer(capacity: 50);
      final input = Float32List.fromList([10.0, 20.0, 30.0, 40.0, 50.0]);

      final written = rb.write(input, 3);
      expect(written, 3);
      expect(rb.availableSamples, 3);

      final output = Float32List(3);
      rb.read(output, windowSize: 3);
      expect(output, [10.0, 20.0, 30.0]);
    });

    test('Zero or negative write count performs no operation', () {
      final rb = AudioRingBuffer(capacity: 10);
      final input = Float32List.fromList([1.0, 2.0]);

      expect(rb.write(input, 0), 0);
      expect(rb.write(input, -5), 0);
      expect(rb.availableSamples, 0);
    });
  });

  group('Wrap-around Boundary Crossing Tests', () {
    test('Seamlessly wraps around buffer boundaries across multiple cycles', () {
      // Capacity of 8 samples
      final rb = AudioRingBuffer(capacity: 8);

      // 1. Write 6 samples: [0, 1, 2, 3, 4, 5], writeIndex = 6
      rb.write(Float32List.fromList([0, 1, 2, 3, 4, 5]));
      expect(rb.writeIndex, 6);
      expect(rb.readIndex, 0);
      expect(rb.availableSamples, 6);

      // 2. Read 4 samples: consumes [0, 1, 2, 3], readIndex = 4
      final out1 = Float32List(4);
      rb.read(out1, windowSize: 4);
      expect(out1, [0, 1, 2, 3]);
      expect(rb.readIndex, 4);
      expect(rb.availableSamples, 2); // [4, 5] remain

      // 3. Write 5 more samples: [6, 7, 8, 9, 10]
      // Buffer layout:
      // index 6..7 receives 6, 7
      // index 0..2 wraps around and receives 8, 9, 10
      // writeIndex becomes 3
      rb.write(Float32List.fromList([6, 7, 8, 9, 10]));
      expect(rb.writeIndex, 3);
      expect(rb.availableSamples, 7); // 2 + 5 = 7

      // 4. Read all 7 available samples: [4, 5, 6, 7, 8, 9, 10]
      // This read crosses the wrap-around boundary (from index 4 to 7, then 0 to 2)
      final out2 = Float32List(7);
      rb.read(out2, windowSize: 7);
      expect(out2, [4, 5, 6, 7, 8, 9, 10]);
      expect(rb.readIndex, 3);
      expect(rb.availableSamples, 0);
      expect(rb.isEmpty, isTrue);
    });
  });

  group('Sliding Window & Overlap Extraction Tests', () {
    test('Overlapping sliding window extraction with custom stride', () {
      final rb = AudioRingBuffer(capacity: 64);
      final data = Float32List.fromList(
        List<double>.generate(32, (i) => i.toDouble()),
      );
      rb.write(data);

      // windowSize = 8, stride = 4 (50% overlap)
      final win = Float32List(8);

      // Window 1: samples 0..7, advances read cursor by 4
      expect(rb.read(win, windowSize: 8, stride: 4), 8);
      expect(win, [0, 1, 2, 3, 4, 5, 6, 7]);
      expect(rb.availableSamples, 28); // 32 - 4 = 28

      // Window 2: samples 4..11, advances read cursor by 4
      expect(rb.read(win, windowSize: 8, stride: 4), 8);
      expect(win, [4, 5, 6, 7, 8, 9, 10, 11]);
      expect(rb.availableSamples, 24);

      // Window 3: samples 8..15, advances read cursor by 4
      expect(rb.read(win, windowSize: 8, stride: 4), 8);
      expect(win, [8, 9, 10, 11, 12, 13, 14, 15]);
      expect(rb.availableSamples, 20);
    });

    test('canReadWindow accurately reports readiness', () {
      final rb = AudioRingBuffer(capacity: 20);
      expect(rb.canReadWindow(10), isFalse);

      rb.write(Float32List(9));
      expect(rb.canReadWindow(10), isFalse);

      rb.write(Float32List(1));
      expect(rb.canReadWindow(10), isTrue);
      expect(rb.canReadWindow(11), isFalse);
    });

    test('Returns 0 on underrun without advancing cursor', () {
      final rb = AudioRingBuffer(capacity: 20);
      rb.write(Float32List.fromList([1.0, 2.0, 3.0]));

      final win = Float32List(5);
      final readCount = rb.read(win, windowSize: 5);

      expect(readCount, 0);
      expect(rb.availableSamples, 3);
      expect(rb.readIndex, 0);
    });
  });

  group('Overflow Handling Strategies', () {
    test(
      'allowOverwriteOnOverflow: true drops oldest unread samples and advances readIndex',
      () {
        final rb = AudioRingBuffer(capacity: 5, allowOverwriteOnOverflow: true);

        // Write 4 samples: [1, 2, 3, 4]
        rb.write(Float32List.fromList([1, 2, 3, 4]));
        expect(rb.availableSamples, 4);

        // Write 3 more samples: [5, 6, 7] -> total 7, capacity 5, overflows by 2
        // Drops oldest 2 samples: 1 and 2
        final written = rb.write(Float32List.fromList([5, 6, 7]));
        expect(written, 3);
        expect(rb.availableSamples, 5);
        expect(rb.isFull, isTrue);
        expect(rb.droppedSamples, 2);
        expect(rb.overflowOccurrences, 1);

        // Read remaining 5 samples, should be [3, 4, 5, 6, 7]
        final out = Float32List(5);
        rb.read(out, windowSize: 5);
        expect(out, [3, 4, 5, 6, 7]);
      },
    );

    test(
      'allowOverwriteOnOverflow: false rejects writes exceeding free space',
      () {
        final rb = AudioRingBuffer(
          capacity: 5,
          allowOverwriteOnOverflow: false,
        );

        rb.write(Float32List.fromList([1, 2, 3]));
        expect(rb.availableSamples, 3);
        expect(rb.freeSpace, 2);

        // Attempt to write 4 samples: only 2 fit
        final written = rb.write(Float32List.fromList([4, 5, 6, 7]));
        expect(written, 2);
        expect(rb.availableSamples, 5);
        expect(rb.isFull, isTrue);

        // Attempt write on full buffer returns 0
        expect(rb.write(Float32List.fromList([8, 9])), 0);

        final out = Float32List(5);
        rb.read(out, windowSize: 5);
        expect(out, [1, 2, 3, 4, 5]);

        // Now buffer is empty, writes succeed again
        expect(rb.write(Float32List.fromList([8, 9])), 2);
      },
    );

    test(
      'Writing a block larger than capacity retains the latest capacity samples',
      () {
        final rb = AudioRingBuffer(capacity: 4);

        final hugeBlock = Float32List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        final written = rb.write(hugeBlock);

        expect(written, 4);
        expect(rb.availableSamples, 4);
        expect(rb.droppedSamples, 6);
        expect(rb.overflowOccurrences, 1);

        final out = Float32List(4);
        rb.read(out, windowSize: 4);
        expect(out, [7, 8, 9, 10]);
      },
    );
  });

  group('Int16 PCM Normalized Writing Tests', () {
    test('writeInt16 normalizes 16-bit signed PCM values into [-1.0, 1.0]', () {
      final rb = AudioRingBuffer(capacity: 10);
      final pcm16 = Int16List.fromList([-32768, -16384, 0, 16384, 32767]);

      final written = rb.writeInt16(pcm16);
      expect(written, 5);
      expect(rb.availableSamples, 5);

      final out = Float32List(5);
      rb.read(out, windowSize: 5);

      expect(out[0], closeTo(-1.0, 1e-6));
      expect(out[1], closeTo(-0.5, 1e-6));
      expect(out[2], closeTo(0.0, 1e-6));
      expect(out[3], closeTo(0.5, 1e-6));
      expect(out[4], closeTo(32767.0 / 32768.0, 1e-6));
    });

    test('writeInt16 handles wrap-around and oversized inputs correctly', () {
      final rb = AudioRingBuffer(capacity: 4);
      final pcmHuge = Int16List.fromList([1000, 2000, 3000, 4000, 5000, 6000]);

      rb.writeInt16(pcmHuge);
      expect(rb.availableSamples, 4);
      expect(rb.droppedSamples, 2);

      final out = Float32List(4);
      rb.read(out, windowSize: 4);
      expect(out[0], closeTo(3000 / 32768.0, 1e-6));
      expect(out[1], closeTo(4000 / 32768.0, 1e-6));
      expect(out[2], closeTo(5000 / 32768.0, 1e-6));
      expect(out[3], closeTo(6000 / 32768.0, 1e-6));
    });
  });

  group('Non-destructive Latest Snapshot & Peeking Tests', () {
    test(
      'getLatestSnapshot extracts recent samples without advancing read pointer',
      () {
        final rb = AudioRingBuffer(capacity: 10);
        rb.write(Float32List.fromList([1, 2, 3, 4, 5, 6, 7]));

        // Read pointer has not moved
        expect(rb.readIndex, 0);

        // Snapshot of last 4 samples: [4, 5, 6, 7]
        final snap = rb.getLatestSnapshot(4);
        expect(snap, [4, 5, 6, 7]);
        expect(rb.readIndex, 0);
        expect(rb.availableSamples, 7);

        // Consume 2 samples: [1, 2]
        final dummy = Float32List(2);
        rb.read(dummy, windowSize: 2);
        expect(rb.readIndex, 2);
        expect(rb.availableSamples, 5);

        // Snapshot of last 4 samples remains [4, 5, 6, 7]
        final snap2 = rb.getLatestSnapshot(4);
        expect(snap2, [4, 5, 6, 7]);
      },
    );

    test(
      'getLatestSnapshot pads leading silence if written samples < requested count',
      () {
        final rb = AudioRingBuffer(capacity: 10);
        rb.write(Float32List.fromList([99.0, 100.0]));

        final snap = rb.getLatestSnapshot(5);
        expect(snap.length, 5);
        expect(snap, [0.0, 0.0, 0.0, 99.0, 100.0]);
      },
    );

    test('getLatestSnapshot correctly unwraps circular buffer boundaries', () {
      final rb = AudioRingBuffer(capacity: 5);
      // Write 8 samples total: 1..8 -> buffer contains [6, 7, 8, 4, 5], writeIndex = 3
      rb.write(Float32List.fromList([1, 2, 3, 4, 5, 6, 7, 8]));

      // Latest 4 samples: [5, 6, 7, 8]
      final snap = rb.getLatestSnapshot(4);
      expect(snap, [5, 6, 7, 8]);
    });

    test('peek inspects ahead without changing state', () {
      final rb = AudioRingBuffer(capacity: 10);
      rb.write(Float32List.fromList([10, 20, 30, 40, 50]));

      final peekDest = Float32List(3);
      final peeked = rb.peek(peekDest, windowSize: 3, offset: 1);

      expect(peeked, 3);
      expect(peekDest, [20, 30, 40]);
      expect(rb.availableSamples, 5);
      expect(rb.readIndex, 0);

      // Offset exceeds available samples returns 0
      expect(rb.peek(peekDest, windowSize: 3, offset: 4), 0);
    });

    test(
      'discard fast-forwards read pointer and decreases available samples',
      () {
        final rb = AudioRingBuffer(capacity: 10);
        rb.write(Float32List.fromList([1, 2, 3, 4, 5]));

        final discarded = rb.discard(3);
        expect(discarded, 3);
        expect(rb.availableSamples, 2);
        expect(rb.readIndex, 3);
        expect(rb.totalSamplesRead, 3);

        final remaining = Float32List(2);
        rb.read(remaining, windowSize: 2);
        expect(remaining, [4, 5]);
      },
    );
  });

  group('Clearing, Resetting & Diagnostic Stats Tests', () {
    test('clear resets pointers and available samples but preserves stats', () {
      final rb = AudioRingBuffer(capacity: 10);
      rb.write(Float32List.fromList([1, 2, 3, 4]));
      rb.read(Float32List(2), windowSize: 2);

      rb.clear();
      expect(rb.availableSamples, 0);
      expect(rb.isEmpty, isTrue);
      expect(rb.writeIndex, 0);
      expect(rb.readIndex, 0);
      expect(rb.totalSamplesWritten, 4);
      expect(rb.totalSamplesRead, 2);
    });

    test('resetStats resets diagnostic counters to zero', () {
      final rb = AudioRingBuffer(capacity: 5);
      rb.write(Float32List.fromList([1, 2, 3, 4, 5, 6, 7]));
      expect(rb.totalSamplesWritten, 7);
      expect(rb.droppedSamples, 2);
      expect(rb.overflowOccurrences, 1);

      rb.resetStats();
      expect(rb.totalSamplesWritten, 0);
      expect(rb.totalSamplesRead, 0);
      expect(rb.droppedSamples, 0);
      expect(rb.overflowOccurrences, 0);
    });
  });

  group('Argument Validation & Defensive Boundaries', () {
    test('Throws ArgumentError on insufficient destination buffer length', () {
      final rb = AudioRingBuffer(capacity: 20);
      rb.write(Float32List(10));

      final shortDest = Float32List(4);
      expect(
        () => rb.read(shortDest, windowSize: 8),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => rb.peek(shortDest, windowSize: 8),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => rb.getLatestSnapshot(10, destination: shortDest),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'Throws ArgumentError on invalid non-positive windowSize or stride',
      () {
        final rb = AudioRingBuffer(capacity: 20);
        final dest = Float32List(10);

        expect(
          () => rb.read(dest, windowSize: 0),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => rb.read(dest, windowSize: 5, stride: 0),
          throwsA(isA<ArgumentError>()),
        );
        expect(() => rb.getLatestSnapshot(0), throwsA(isA<ArgumentError>()));
      },
    );
  });
}
