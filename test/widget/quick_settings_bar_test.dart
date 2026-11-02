import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/common/notation_icons.dart';
import 'package:tuner_flutter/ui/common/quick_settings_bar.dart';

void main() {
  group('QuickSettingsBar Widget', () {
    testWidgets('renders all cells with defaults', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: const Scaffold(
            bottomNavigationBar: QuickSettingsBar(
              referenceNote: MusicalNote(base: BaseNote.a, octave: 4),
              referenceFrequency: 440.0,
              temperamentName: 'EDO 12',
              preferFlat: false,
            ),
          ),
        ),
      );

      expect(find.text('A4'), findsOneWidget);
      expect(find.text('440.0 Hz'), findsOneWidget);
      expect(find.text('EDO 12'), findsOneWidget);
      expect(find.byType(PreferFlatIconWidget), findsOneWidget);
      // No stretch tuning cell by default
      expect(find.text('Piano'), findsNothing);
    });

    testWidgets(
      'renders stretch tuning cell when stretchTuningName is provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: const Scaffold(
              bottomNavigationBar: QuickSettingsBar(
                referenceNote: MusicalNote(base: BaseNote.a, octave: 4),
                referenceFrequency: 442.0,
                temperamentName: 'Werck. III',
                preferFlat: true,
                stretchTuningName: 'Piano',
              ),
            ),
          ),
        );

        expect(find.text('A4'), findsOneWidget);
        expect(find.text('442.0 Hz'), findsOneWidget);
        expect(find.text('Werck. III'), findsOneWidget);
        expect(find.text('Piano'), findsOneWidget);
        expect(find.byType(PreferFlatIconWidget), findsOneWidget);
      },
    );

    testWidgets('handles cell click callbacks accurately', (tester) async {
      bool refClicked = false;
      bool tempClicked = false;
      bool sharpFlatClicked = false;
      bool stretchClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            bottomNavigationBar: QuickSettingsBar(
              referenceNote: const MusicalNote(base: BaseNote.a, octave: 4),
              referenceFrequency: 440.0,
              temperamentName: 'EDO 12',
              preferFlat: false,
              stretchTuningName: 'Guitar Railsback',
              onReferenceNoteClicked: () => refClicked = true,
              onTemperamentClicked: () => tempClicked = true,
              onSharpFlatClicked: () => sharpFlatClicked = true,
              onStretchTuningClicked: () => stretchClicked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('A4'));
      await tester.pumpAndSettle();
      expect(refClicked, isTrue);

      await tester.tap(find.text('EDO 12'));
      await tester.pumpAndSettle();
      expect(tempClicked, isTrue);

      await tester.tap(find.byType(PreferFlatIconWidget));
      await tester.pumpAndSettle();
      expect(sharpFlatClicked, isTrue);

      await tester.tap(find.text('Guitar Railsback'));
      await tester.pumpAndSettle();
      expect(stretchClicked, isTrue);
    });

    testWidgets('PreferFlatIconWidget toggles between sharp and flat SVGs', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PreferFlatIconWidget(preferFlat: false)),
        ),
      );
      expect(find.byType(PreferFlatIconWidget), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PreferFlatIconWidget(preferFlat: true)),
        ),
      );
      expect(find.byType(PreferFlatIconWidget), findsOneWidget);
    });
  });
}
