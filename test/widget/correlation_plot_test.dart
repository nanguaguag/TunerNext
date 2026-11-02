import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/plot/line_coordinates.dart';
import 'package:tuner_flutter/ui/tuning/correlation_plot.dart';

void main() {
  group('CorrelationPlot Widget Tests', () {
    testWidgets('renders CorrelationPlot with waveform and zero line', (
      tester,
    ) async {
      final corrData = LineCoordinates.create(
        [0.0, 0.001, 0.002, 0.00227, 0.003, 0.004],
        [1.0, 0.7, 0.2, 0.9, 0.3, 0.1],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: CorrelationPlot(
                correlationPlotData: corrData,
                correlationPlotDataYZeroPosition: 0.5,
                targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                targetFrequency: 440.0,
                currentFrequency: 440.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CorrelationPlot), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('tap resets viewport gesture', (tester) async {
      final corrData = LineCoordinates.create([0.0, 0.005], [1.0, 0.0]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: CorrelationPlot(
                correlationPlotData: corrData,
                targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                targetFrequency: 440.0,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CorrelationPlot));
      await tester.pump();
      expect(find.byType(CorrelationPlot), findsOneWidget);
    });
  });
}
