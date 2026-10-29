import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/dsp/filters/acoustic_weighting.dart';

void main() {
  group('Acoustic Weighting Curve Tests', () {
    test('A-weighting is normalized to 1.0 (0 dB) at 1000 Hz', () {
      final aWeighting = AcousticAWeighting();
      final factor1000 = aWeighting.applyToAmplitude(1.0, 1000.0);
      expect(factor1000, closeTo(1.0, 1e-4));
    });

    test('A-weighting strongly attenuates 50 Hz and 100 Hz mains hum', () {
      final aWeighting = AcousticAWeighting();
      final factor50 = aWeighting.applyToAmplitude(1.0, 50.0);
      final factor100 = aWeighting.applyToAmplitude(1.0, 100.0);

      // At 50 Hz, A-weighting attenuation is approx -30 dB (amplitude factor < 0.05)
      expect(factor50, lessThan(0.05));
      // At 100 Hz, A-weighting attenuation is approx -19 dB (amplitude factor < 0.15)
      expect(factor100, lessThan(0.15));
    });

    test('C-weighting is normalized to 1.0 at 1000 Hz', () {
      final cWeighting = AcousticCWeighting();
      final factor1000 = cWeighting.applyToAmplitude(1.0, 1000.0);
      expect(factor1000, closeTo(1.0, 1e-4));
    });

    test('Zero weighting leaves amplitude completely unchanged', () {
      final zeroWeighting = AcousticZeroWeighting();
      expect(zeroWeighting.applyToAmplitude(4.2, 50.0), equals(4.2));
      expect(zeroWeighting.applyToAmplitude(4.2, 1000.0), equals(4.2));
    });
  });
}
