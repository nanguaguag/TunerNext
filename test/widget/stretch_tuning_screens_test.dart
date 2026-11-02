import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/stretch_tuning/predefined_stretch_tunings.dart';
import 'package:tuner_flutter/domain/stretch_tuning/stretch_tuning.dart';
import 'package:tuner_flutter/ui/screens/stretch_tuning_editor_screen.dart';
import 'package:tuner_flutter/ui/screens/stretch_tuning_overview_screen.dart';
import 'package:tuner_flutter/ui/stretchtuning/stretch_tuning_graph.dart';
import 'package:tuner_flutter/ui/stretchtuning/stretch_tuning_table.dart';

void main() {
  group('StretchTuningEditorScreen Widget Tests', () {
    testWidgets('renders graph, table, text inputs and saves', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      StretchTuning? savedTuning;

      final initial = StretchTuning(
        name: 'My Piano Curve',
        description: 'Upright piano',
        unstretchedFrequencies: [220.0, 440.0],
        stretchInCents: [-2.0, 0.0],
        keys: [1, 2],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StretchTuningEditorScreen(
            initialStretchTuning: initial,
            onSave: (t) => savedTuning = t,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stretch Tuning Editor'), findsOneWidget);
      expect(find.byType(StretchTuningGraph), findsOneWidget);
      expect(find.byType(StretchTuningTable), findsOneWidget);

      // Verify Name field
      expect(find.text('My Piano Curve'), findsOneWidget);

      // Save button is enabled
      final saveBtn = find.text('Save');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(savedTuning, isNotNull);
      expect(savedTuning!.name, 'My Piano Curve');
    });
  });

  group('StretchTuningOverviewScreen Widget Tests', () {
    testWidgets('displays predefined tunings and custom tunings with search', (
      tester,
    ) async {
      StretchTuning? selectedTuning;

      final custom = [
        StretchTuning(
          name: 'Custom Honky Tonk',
          description: 'Detuned piano stretch',
          unstretchedFrequencies: [440.0],
          stretchInCents: [10.0],
          stableId: 999,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: StretchTuningOverviewScreen(
            selectedStretchTuningId: PredefinedStretchTunings.idNoStretch,
            customStretchTunings: custom,
            onSelectStretchTuning: (t) => selectedTuning = t,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stretch Tuning'), findsOneWidget);
      expect(find.text('PREDEFINED'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);
      expect(find.text('No Stretch Tuning'), findsOneWidget);
      expect(find.text('Railsback Stretch Tuning'), findsOneWidget);
      expect(find.text('Custom Honky Tonk'), findsOneWidget);

      // Select Railsback
      await tester.tap(find.text('Railsback Stretch Tuning'));
      await tester.pumpAndSettle();

      expect(selectedTuning, isNotNull);
      expect(selectedTuning!.name, 'Railsback Stretch Tuning');
    });

    testWidgets('filters list via search field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StretchTuningOverviewScreen()),
      );
      await tester.pumpAndSettle();

      // Search for 'Railsback'
      await tester.enterText(find.byType(TextField), 'Rails');
      await tester.pumpAndSettle();

      expect(find.text('Railsback Stretch Tuning'), findsOneWidget);
      expect(find.text('No Stretch Tuning'), findsNothing);
    });
  });
}
