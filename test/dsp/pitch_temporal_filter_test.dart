import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/filters/pitch_temporal_filter.dart';

void main() {
  group('Temporal Filter Tests', () {
    test('PitchMedianFilter eliminates isolated single-sample pulse spikes', () {
      final filter = PitchMedianFilter();
      // Steady 440 Hz signal with an isolated 880 Hz glitch on 4th frame
      final inputs = [440.0, 440.0, 440.0, 880.0, 440.0, 440.0];
      final outputs = inputs.map(filter.filter).toList();

      // The glitch at index 3 must be completely filtered out by the 3-tap median
      expect(outputs[3], closeTo(440.0, 1e-4));
      expect(outputs[4], closeTo(440.0, 1e-4));
      expect(outputs[5], closeTo(440.0, 1e-4));
    });

    test(
      'OctaveJumpGate folds transient 2x harmonic jump back to fundamental',
      () {
        final gate = OctaveJumpGate(
          tolerance: 0.08,
          requiredSustainedFrames: 2,
        );
        expect(gate.filter(440.0), closeTo(440.0, 1e-3));
        expect(gate.filter(440.0), closeTo(440.0, 1e-3));

        // Single frame transient jump to 880 Hz (2x harmonic)
        final transientJump = gate.filter(880.0);
        // Must be folded back to 440 Hz
        expect(transientJump, closeTo(440.0, 1e-3));

        // Resumed 440 Hz continues as 440 Hz
        expect(gate.filter(440.0), closeTo(440.0, 1e-3));
      },
    );

    test(
      'OctaveJumpGate confirms sustained transition after required frames',
      () {
        final gate = OctaveJumpGate(
          tolerance: 0.08,
          requiredSustainedFrames: 2,
        );
        gate.filter(440.0);

        // Frame 1 of jump: folded back
        expect(gate.filter(880.0), closeTo(440.0, 1e-3));
        // Frame 2 of jump: sustained confirmation -> transitions to 880 Hz
        expect(gate.filter(880.0), closeTo(880.0, 1e-3));
        // Frame 3 continues at confirmed 880 Hz
        expect(gate.filter(880.0), closeTo(880.0, 1e-3));
      },
    );

    test('Filters reset cleanly on non-positive input', () {
      final median = PitchMedianFilter();
      median.filter(440.0);
      expect(median.filter(0.0), equals(0.0));

      final gate = OctaveJumpGate();
      gate.filter(440.0);
      expect(gate.filter(-1.0), equals(0.0));
    });
  });
}
