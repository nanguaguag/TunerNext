import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/plot/line_coordinates.dart';
import 'package:tuner_flutter/ui/tuning/frequency_plot.dart';

void main() {
  group('FrequencyPlot Widget Tests', () {
    testWidgets('renders FrequencyPlot with spectrum data and markers', (
      tester,
    ) async {
      final freqData = LineCoordinates.create(
        [0, 100, 200, 300, 440, 600, 880],
        [0.0, 0.1, 0.2, 0.5, 1.0, 0.3, 0.6],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: FrequencyPlot(
                frequencyPlotData: freqData,
                targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                targetFrequency: 440.0,
                currentFrequency: 440.0,
                harmonicFrequencies: const [440.0, 880.0, 1320.0],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FrequencyPlot), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('tap resets viewport gesture', (tester) async {
      final freqData = LineCoordinates.create([0, 440], [0.0, 1.0]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: FrequencyPlot(
                frequencyPlotData: freqData,
                targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
                targetFrequency: 440.0,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FrequencyPlot));
      await tester.pump();
      expect(find.byType(FrequencyPlot), findsOneWidget);
    });
  });
}
