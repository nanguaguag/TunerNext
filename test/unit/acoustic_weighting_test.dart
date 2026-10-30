import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/filters/acoustic_weighting.dart';

double ampRatioToLog(double amp, double ampRef) =>
    20.0 * (math.log(amp / ampRef) / math.ln10);

void main() {
  group('Acoustic Weighting Tests matching Kotlin AcousticWeightingTest.kt', () {
    test('AcousticAWeighting matches Kotlin reference points and IEC 61672', () {
      final weighting = AcousticAWeighting();

      expect(weighting.mode, equals(AcousticWeightingMode.aWeighting));

      // 1000 Hz normalization check (0 dB, amplitude unchanged)
      expect(weighting.applyToAmplitude(10.0, 1000.0), closeTo(10.0, 1e-6));

      // 100 Hz attenuation matches -19.1 dB
      final db100 = ampRatioToLog(
        weighting.applyToAmplitude(10.0, 100.0),
        10.0,
      );
      expect(db100, closeTo(-19.1, 0.1));

      // 10000 Hz attenuation matches -2.5 dB
      final db10000 = ampRatioToLog(
        weighting.applyToAmplitude(10.0, 10000.0),
        10.0,
      );
      expect(db10000, closeTo(-2.5, 0.1));

      // 50 Hz power-line interference attenuation is strongly suppressed (> 30 dB)
      final db50 = ampRatioToLog(weighting.applyToAmplitude(1.0, 50.0), 1.0);
      expect(db50, lessThan(-30.0));
    });

    test(
      'AcousticCWeighting matches Kotlin reference points and IEC 61672',
      () {
        final weighting = AcousticCWeighting();

        expect(weighting.mode, equals(AcousticWeightingMode.cWeighting));

        // 1000 Hz normalization check (0 dB, amplitude unchanged)
        expect(weighting.applyToAmplitude(10.0, 1000.0), closeTo(10.0, 1e-6));

        // 10 Hz attenuation matches -14.3 dB
        final db10 = ampRatioToLog(
          weighting.applyToAmplitude(10.0, 10.0),
          10.0,
        );
        expect(db10, closeTo(-14.3, 0.1));

        // 10000 Hz attenuation matches -4.5 dB
        final db10000 = ampRatioToLog(
          weighting.applyToAmplitude(10.0, 10000.0),
          10.0,
        );
        expect(db10000, closeTo(-4.5, 0.1));
      },
    );

    test('AcousticZeroWeighting passes amplitude untouched', () {
      final weighting = AcousticZeroWeighting();
      expect(weighting.mode, equals(AcousticWeightingMode.none));
      expect(weighting.applyToAmplitude(42.5, 50.0), equals(42.5));
      expect(weighting.applyToAmplitude(42.5, 1000.0), equals(42.5));
      expect(weighting.applyToAmplitude(42.5, 20000.0), equals(42.5));
    });

    test('Factory fromMode creates expected concrete implementations', () {
      expect(
        AcousticWeighting.fromMode(AcousticWeightingMode.aWeighting),
        isA<AcousticAWeighting>(),
      );
      expect(
        AcousticWeighting.fromMode(AcousticWeightingMode.cWeighting),
        isA<AcousticCWeighting>(),
      );
      expect(
        AcousticWeighting.fromMode(AcousticWeightingMode.none),
        isA<AcousticZeroWeighting>(),
      );
    });

    test('Zero or negative frequencies return 0.0 safely', () {
      final aWeighting = AcousticAWeighting();
      final cWeighting = AcousticCWeighting();

      expect(aWeighting.applyToAmplitude(10.0, 0.0), equals(0.0));
      expect(aWeighting.applyToAmplitude(10.0, -100.0), equals(0.0));
      expect(cWeighting.applyToAmplitude(10.0, 0.0), equals(0.0));
      expect(cWeighting.applyToAmplitude(10.0, -50.0), equals(0.0));
    });
  });
}
