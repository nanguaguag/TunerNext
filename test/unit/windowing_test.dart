import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/windowing/windowing.dart';

void main() {
  group('Windowing Function Tests', () {
    test('Tophat window is rectangular with all 1.0 values', () {
      const size = 64;
      final window = Windowing.getWindow(WindowingFunction.tophat, size);

      expect(window.length, equals(size));
      for (var i = 0; i < size; i++) {
        expect(window[i], equals(1.0));
      }

      expect(
        Windowing.getWindowIntegral(WindowingFunction.tophat),
        equals(1.0),
      );
    });

    test('Hamming window matches theoretical formula and integral', () {
      const size = 64;
      final window = Windowing.getWindow(WindowingFunction.hamming, size);

      expect(window.length, equals(size));
      // First point at i=0: 0.54 - 0.46 * cos(0) = 0.08
      expect(window[0], closeTo(0.08, 1e-4));
      // Mid point at i=size/2: 0.54 - 0.46 * cos(pi) = 1.00
      expect(window[size ~/ 2], closeTo(1.00, 1e-4));

      // Numerical average matches analytical integral 0.54
      var sum = 0.0;
      for (var i = 0; i < size; i++) {
        sum += window[i];
      }
      final numericalIntegral = sum / size;
      expect(
        numericalIntegral,
        closeTo(Windowing.getWindowIntegral(WindowingFunction.hamming), 1e-3),
      );
    });

    test('Hanning window matches theoretical formula and integral', () {
      const size = 64;
      final window = Windowing.getWindow(WindowingFunction.hanning, size);

      expect(window.length, equals(size));
      // First point at i=0: 0.5 * (1 - cos(0)) = 0.0
      expect(window[0], closeTo(0.0, 1e-4));
      // Mid point at i=size/2: 0.5 * (1 - cos(pi)) = 1.0
      expect(window[size ~/ 2], closeTo(1.0, 1e-4));

      // Numerical average matches analytical integral 0.5
      var sum = 0.0;
      for (var i = 0; i < size; i++) {
        sum += window[i];
      }
      final numericalIntegral = sum / size;
      expect(
        numericalIntegral,
        closeTo(Windowing.getWindowIntegral(WindowingFunction.hanning), 1e-3),
      );
    });

    test('Window compensation factor accurately restores sine amplitude', () {
      const size = 256;
      final kTophat = Windowing.getWindowCompensationFactor(
        WindowingFunction.tophat,
        size,
      );
      final kHann = Windowing.getWindowCompensationFactor(
        WindowingFunction.hanning,
        size,
      );
      final kHamming = Windowing.getWindowCompensationFactor(
        WindowingFunction.hamming,
        size,
      );

      expect(kTophat, closeTo(2.0 / size, 1e-6));
      expect(kHann, closeTo(2.0 / (size * 0.5), 1e-6));
      expect(kHamming, closeTo(2.0 / (size * 0.54), 1e-6));
    });

    test('Throws ArgumentError on negative or zero size', () {
      expect(
        () => Windowing.getWindow(WindowingFunction.tophat, 0),
        throwsArgumentError,
      );
      expect(
        () => Windowing.getWindow(WindowingFunction.hanning, -10),
        throwsArgumentError,
      );
      expect(
        () =>
            Windowing.getWindowCompensationFactor(WindowingFunction.tophat, 0),
        throwsArgumentError,
      );
    });
  });
}
