import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history_state.dart';

void main() {
  group('PitchHistoryState', () {
    test('initial state and capacity handling', () {
      final state = PitchHistoryState(capacity: 5);
      expect(state.capacity, equals(5));
      expect(state.size, equals(0));
      expect(state.frequencies, isEmpty);
      expect(state.latestFrequency, isNull);

      expect(() => PitchHistoryState(capacity: 0), throwsArgumentError);
      expect(() => PitchHistoryState(capacity: -1), throwsArgumentError);
    });

    test('addFrequency stores values and handles capacity trimming', () {
      final state = PitchHistoryState(capacity: 3);

      state.addFrequency(440.0);
      expect(state.size, equals(1));
      expect(state.latestFrequency, equals(440.0));
      expect(state.frequencies, equals([440.0]));

      state.addFrequency(442.0);
      state.addFrequency(444.0);
      expect(state.size, equals(3));
      expect(state.frequencies, equals([440.0, 442.0, 444.0]));

      // Adding 4th element should discard the oldest (440.0)
      state.addFrequency(446.0);
      expect(state.size, equals(3));
      expect(state.frequencies, equals([442.0, 444.0, 446.0]));
      expect(state.latestFrequency, equals(446.0));
    });

    test(
      'addFrequency treats null, non-positive, and NaN as mute break (null)',
      () {
        final state = PitchHistoryState(capacity: 5);

        state.addFrequency(440.0);
        state.addFrequency(null);
        state.addFrequency(0.0);
        state.addFrequency(-50.0);
        state.addFrequency(double.nan);

        expect(state.size, equals(5));
        expect(state.frequencies, equals([440.0, null, null, null, null]));
        expect(state.latestFrequency, isNull);
      },
    );

    test('clear resets historical samples', () {
      final state = PitchHistoryState(capacity: 4);
      state.addFrequency(100.0);
      state.addFrequency(200.0);
      expect(state.size, equals(2));

      state.clear();
      expect(state.size, equals(0));
      expect(state.frequencies, isEmpty);
      expect(state.latestFrequency, isNull);
    });

    test('resize trims excess oldest items or expands capacity', () {
      final state = PitchHistoryState(capacity: 5);
      for (var f in [10.0, 20.0, 30.0, 40.0, 50.0]) {
        state.addFrequency(f);
      }
      expect(state.size, equals(5));

      state.resize(3);
      expect(state.capacity, equals(3));
      expect(state.size, equals(3));
      expect(state.frequencies, equals([30.0, 40.0, 50.0]));

      state.resize(6);
      expect(state.capacity, equals(6));
      expect(state.size, equals(3));

      expect(() => state.resize(0), throwsArgumentError);
    });

    test('computePitchHistorySize calculates correct buffer sizes', () {
      // 3.0 seconds, 44100 Hz, 2048 samples window, 50% overlap
      // hopDuration = (2048 * 0.5) / 44100 = 1024 / 44100 = 0.02321995 sec
      // size = (3.0 / 0.02321995).round() = 129
      final size = PitchHistoryState.computePitchHistorySize(
        durationSeconds: 3.0,
        sampleRate: 44100,
        windowSize: 2048,
        overlap: 0.5,
      );
      expect(size, equals(129));

      // Degenerate inputs fall back to safe minimum
      expect(
        PitchHistoryState.computePitchHistorySize(
          durationSeconds: 0,
          sampleRate: 44100,
          windowSize: 2048,
          overlap: 0.5,
        ),
        equals(100),
      );
    });
  });
}
