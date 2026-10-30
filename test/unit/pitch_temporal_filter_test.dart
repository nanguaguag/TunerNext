import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/filters/pitch_temporal_filter.dart';

void main() {
  group('PitchMedianFilter Unit Tests', () {
    test('Suppresses single-frame impulse spike noise', () {
      final filter = PitchMedianFilter();

      // Steady 440 Hz
      expect(filter.filter(440.0), closeTo(440.0, 1e-4));
      expect(filter.filter(440.0), closeTo(440.0, 1e-4));

      // Single-frame violent spike (e.g. 1760 Hz 4th harmonic noise burst)
      final filteredSpike = filter.filter(1760.0);
      expect(filteredSpike, closeTo(440.0, 1e-4));

      // Subsequent frame returns to steady 440 Hz
      expect(filter.filter(440.0), closeTo(440.0, 1e-4));
    });

    test('Transitions smoothly on genuine note changes', () {
      final filter = PitchMedianFilter();

      filter.filter(440.0);
      filter.filter(440.0);
      filter.filter(440.0);

      // Transition to C5 (523.25 Hz)
      final frame1 = filter.filter(523.25);
      expect(frame1, closeTo(440.0, 1e-4)); // 1 frame median hold

      final frame2 = filter.filter(523.25);
      expect(frame2, closeTo(523.25, 1e-4)); // Transitions cleanly
    });

    test('Silence or zero frequency resets median state', () {
      final filter = PitchMedianFilter();
      filter.filter(440.0);
      filter.filter(440.0);

      expect(filter.filter(0.0), equals(0.0));
      // After reset, single new tone is passed directly
      expect(filter.filter(330.0), equals(330.0));
    });
  });

  group('OctaveJumpGate Unit Tests', () {
    test('Folds back transient upper harmonic bow friction attacks', () {
      final gate = OctaveJumpGate(tolerance: 0.08, requiredSustainedFrames: 2);

      // Baseline note A4 (440 Hz)
      expect(gate.filter(440.0), closeTo(440.0, 1e-4));

      // Transient bow attack scratch picks up 2nd harmonic (880 Hz) for 1 frame
      final suppressedOctave = gate.filter(880.0);
      expect(
        suppressedOctave,
        closeTo(440.0, 1e-3),
      ); // Folded back to fundamental

      // Steady fundamental
      expect(gate.filter(440.0), closeTo(440.0, 1e-4));

      // Transient bow attack scratch picks up 3rd harmonic (1320 Hz) for 1 frame
      final suppressedTwelfth = gate.filter(1320.0);
      expect(
        suppressedTwelfth,
        closeTo(440.0, 1e-3),
      ); // Folded back to fundamental
    });

    test('Folds back transient sub-octave jumps', () {
      final gate = OctaveJumpGate(tolerance: 0.08, requiredSustainedFrames: 2);

      expect(gate.filter(440.0), closeTo(440.0, 1e-4));

      // Momentary sub-octave dip to 220 Hz
      final foldedSubOctave = gate.filter(220.0);
      expect(foldedSubOctave, closeTo(440.0, 1e-3));
    });

    test('Allows sustained intentional octave transitions', () {
      final gate = OctaveJumpGate(tolerance: 0.08, requiredSustainedFrames: 2);

      gate.filter(440.0);

      // Frame 1 of new note A5 (880 Hz): transient check folds back
      expect(gate.filter(880.0), closeTo(440.0, 1e-3));

      // Frame 2 of sustained A5: confirmed as intentional note transition
      expect(gate.filter(880.0), closeTo(880.0, 1e-3));

      // Frame 3 continues at A5
      expect(gate.filter(880.0), closeTo(880.0, 1e-3));
    });

    test('Does not interfere with normal melodic intervals', () {
      final gate = OctaveJumpGate(tolerance: 0.08, requiredSustainedFrames: 2);

      gate.filter(440.0);

      // Minor third (C5 = 523.25 Hz) has ratio ~1.189, well below 1.8x threshold
      expect(gate.filter(523.25), closeTo(523.25, 1e-4));

      // Fourth (D5 = 587.33 Hz)
      expect(gate.filter(587.33), closeTo(587.33, 1e-4));
    });

    test('Reset clears confirmed state and candidate counters', () {
      final gate = OctaveJumpGate();
      gate.filter(440.0);
      gate.reset();

      // After reset, first incoming tone establishes fresh baseline
      expect(gate.filter(880.0), closeTo(880.0, 1e-4));
    });
  });
}
