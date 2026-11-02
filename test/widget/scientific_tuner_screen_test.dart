import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/common/quick_settings_bar.dart';
import 'package:tuner_flutter/ui/screens/scientific_tuner_screen.dart';
import 'package:tuner_flutter/ui/tuning/correlation_plot.dart';
import 'package:tuner_flutter/ui/tuning/frequency_plot.dart';
import 'package:tuner_flutter/ui/tuning/pitch_history.dart';

void main() {
  group('ScientificTunerScreen Widget Tests', () {
    testWidgets('renders all 3 plots and quick settings in portrait mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var wavExported = false;
      var openedPrefs = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ScientificTunerScreen(
            targetNote: const MusicalNote(base: BaseNote.a, octave: 4),
            currentFrequency: 440.0,
            tuningState: TuningState.inTune,
            canNavigateUp: true,
            onOpenPreferences: () => openedPrefs = true,
            onExportWav: () => wavExported = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scientific Tuner'), findsOneWidget);
      expect(find.text('Spectrum'), findsOneWidget);
      expect(find.text('Autocorrelation'), findsOneWidget);
      expect(find.text('Pitch History'), findsOneWidget);

      expect(find.byType(FrequencyPlot), findsOneWidget);
      expect(find.byType(CorrelationPlot), findsOneWidget);
      expect(find.byType(PitchHistory), findsOneWidget);
      expect(find.byType(QuickSettingsBar), findsOneWidget);

      // Verify FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      expect(wavExported, isTrue);

      // Verify Settings action
      final settingsIcon = find.byIcon(Icons.settings);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      expect(openedPrefs, isTrue);
    });

    testWidgets('renders side-by-side layout in landscape mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificTunerScreen(
            targetNote: MusicalNote(base: BaseNote.a, octave: 4),
            currentFrequency: 440.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scientific Tuner'), findsOneWidget);
      expect(find.text('Spectrum'), findsOneWidget);
      expect(find.text('Autocorrelation'), findsOneWidget);
      expect(find.text('Pitch History'), findsOneWidget);
    });
  });
}
