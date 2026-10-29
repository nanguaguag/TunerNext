import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/stretchtuning/stretch_tuning.dart';

void main() {
  group('StretchTuning and Railsback Curve Tests', () {
    test('No Stretch Tuning leaves all frequencies unchanged', () {
      final none = PredefinedStretchTunings.none();
      expect(none.getStretchedFrequency(440.0, 440.0), 440.0);
      expect(none.getStretchedFrequency(110.0, 440.0), 110.0);
      expect(none.getStretchedFrequency(3520.0, 440.0), 3520.0);
    });

    test('Railsback curve anchors 0 cents at reference pitch 440 Hz', () {
      final railsback = PredefinedStretchTunings.railsback();
      // At reference frequency A4=440Hz, stretched frequency must be exactly 440Hz
      expect(
        railsback.getStretchedFrequency(440.0, 440.0),
        closeTo(440.0, 1e-4),
      );
    });

    test('Railsback curve stretches bass downwards and treble upwards', () {
      final railsback = PredefinedStretchTunings.railsback();

      // Deep bass note A0 ~ 27.5 Hz should be stretched flat (lower frequency)
      final stretchedA0 = railsback.getStretchedFrequency(27.5, 440.0);
      expect(stretchedA0, lessThan(27.5));

      // High treble note C8 ~ 4186 Hz should be stretched sharp (higher frequency)
      final stretchedC8 = railsback.getStretchedFrequency(4186.0, 440.0);
      expect(stretchedC8, greaterThan(4186.0));
    });

    test(
      'Logarithmic interpolation between data points is smooth and monotonic',
      () {
        final railsback = PredefinedStretchTunings.railsback();
        var prevFreq = 0.0;
        for (var f = 30.0; f <= 4000.0; f += 20.0) {
          final stretched = railsback.getStretchedFrequency(f, 440.0);
          expect(stretched, greaterThan(prevFreq));
          prevFreq = stretched;
        }
      },
    );
  });
}
