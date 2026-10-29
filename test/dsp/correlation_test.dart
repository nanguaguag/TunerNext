import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/dsp/correlation/auto_correlation.dart';

Float32List classicDirectCorrelation(Float32List values) {
  final result = Float32List(values.length);
  for (var i = 0; i < values.length; i++) {
    var v = 0.0;
    for (var j = 0; j < values.length - i; j++) {
      v += values[j + i] * values[j];
    }
    result[i] = v;
  }
  return result;
}

void main() {
  group('Correlation Tests matching Kotlin CorrelationTest.kt baseline', () {
    test(
      'Random test vector matches direct correlation and Kotlin expected values',
      () {
        final values = Float32List.fromList([
          0.63696,
          0.26979,
          0.04097,
          0.01653,
          0.81327,
          0.91276,
          0.60664,
          0.72950,
          0.54362,
          0.93507,
          0.81585,
          0.00274,
          0.85740,
          0.03359,
          0.72966,
          0.17566,
        ]);

        final expected = [
          6.01020,
          3.78942,
          4.02729,
          3.51248,
          3.68700,
          3.76005,
          2.39249,
          2.09610,
          1.93074,
          1.62987,
          1.30983,
          0.38935,
          0.58799,
          0.22544,
          0.51215,
          0.11189,
        ];

        final direct = classicDirectCorrelation(values);
        for (var i = 0; i < values.length; i++) {
          expect(direct[i], closeTo(expected[i], 1e-4));
        }

        final correlator = CorrelationComputer(
          values.length,
          windowType: WindowingFunction.tophat,
        );
        final autoCorr = AutoCorrelationData(size: values.length, dt: 1.0);
        correlator.compute(values, autoCorr, disableWindow: true);

        for (var i = 0; i < values.length; i++) {
          // Output from FFT autocorrelation is scaled by N = values.length
          expect(
            autoCorr.values[i] / values.length,
            closeTo(expected[i], 1e-3),
          );
        }
      },
    );
  });
}
