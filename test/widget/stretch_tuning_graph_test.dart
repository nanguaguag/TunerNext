import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/stretch_tuning/predefined_stretch_tunings.dart';
import 'package:tuner_flutter/ui/stretchtuning/stretch_tuning_graph.dart';

void main() {
  group('StretchTuningGraph Widget Tests', () {
    testWidgets('renders StretchTuningGraph with Railsback curve', (
      tester,
    ) async {
      final railsback = PredefinedStretchTunings.railsback();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 300,
              child: StretchTuningGraph(
                stretchTuning: railsback,
                selectedKey: railsback.keys[10],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(StretchTuningGraph), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders empty stretch tuning without error', (tester) async {
      final empty = PredefinedStretchTunings.noStretch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: StretchTuningGraph(stretchTuning: empty),
            ),
          ),
        ),
      );

      expect(find.byType(StretchTuningGraph), findsOneWidget);
    });

    testWidgets('tap resets viewport', (tester) async {
      final railsback = PredefinedStretchTunings.railsback();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: StretchTuningGraph(stretchTuning: railsback),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StretchTuningGraph));
      await tester.pump();
      expect(find.byType(StretchTuningGraph), findsOneWidget);
    });
  });
}
