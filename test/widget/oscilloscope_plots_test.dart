// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/ui/plot/autocorrelation_plot.dart';
import 'package:tuner_flutter/ui/plot/spectrum_plot.dart';

void main() {
  group('Oscilloscope Plots Tests', () {
    testWidgets('SpectrumPlot renders frequency axis and detected pitch line', (
      tester,
    ) async {
      final fakeSpectrum = Float32List(1024);
      // Place a strong synthetic peak at index 20 (~430 Hz at 44100/2048)
      fakeSpectrum[20] = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 200,
              child: SpectrumPlot(
                spectrum: fakeSpectrum,
                currentFrequency: 440.0,
                targetFrequency: 440.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SpectrumPlot), findsOneWidget);
      expect(find.text('Frequency Spectrum (FFT)'), findsOneWidget);
      expect(find.text('440.0 Hz'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'AutocorrelationPlot renders lag axis, zero line, and pitch lag marker',
      (tester) async {
        final fakeCorr = Float32List(1024);
        // Fill normalized values [0, 1]
        for (var i = 0; i < fakeCorr.length; i++) {
          fakeCorr[i] = 0.5 + 0.5 * (i % 50 == 0 ? 1.0 : -0.2);
        }

        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 200,
                child: AutocorrelationPlot(
                  correlation: fakeCorr,
                  zeroPositionNormalized: 0.5,
                  currentFrequency: 440.0,
                  targetFrequency: 440.0,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AutocorrelationPlot), findsOneWidget);
        expect(find.text('Autocorrelation R_xx(τ)'), findsOneWidget);
        // 1000 / 440 = 2.27 ms
        expect(find.text('τ = 2.27 ms'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
