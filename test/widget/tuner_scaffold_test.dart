import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/ui/common/tuner_scaffold.dart';

void main() {
  testWidgets('TunerScaffold renders default title, settings, and bottom bar', (
    tester,
  ) async {
    bool preferenceClicked = false;
    bool sharpFlatClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TunerScaffold(
          title: 'Tuner Test Title',
          referenceNote: const MusicalNote(base: BaseNote.a, octave: 4),
          referenceFrequency: 440.0,
          temperamentName: 'EDO 12',
          onPreferenceButtonClicked: () => preferenceClicked = true,
          onSharpFlatClicked: () => sharpFlatClicked = true,
          body: const Center(child: Text('Main Content Area')),
        ),
      ),
    );

    expect(find.text('Tuner Test Title'), findsOneWidget);
    expect(find.text('Main Content Area'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.text('A4'), findsOneWidget);
    expect(find.text('440.0 Hz'), findsOneWidget);
    expect(find.text('EDO 12'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    expect(preferenceClicked, isTrue);

    await tester.tap(find.text('440.0 Hz'));
    // Sharp/flat toggle is tap on PreferFlatIconWidget
    final barFind = find.byType(BottomAppBar);
    expect(barFind, findsOneWidget);

    final inkWells = find.descendant(
      of: barFind,
      matching: find.byType(InkWell),
    );
    // The 3rd inkwell is sharp/flat toggle
    await tester.tap(inkWells.at(2));
    expect(sharpFlatClicked, isTrue);
  });

  testWidgets('TunerScaffold renders action mode and back button correctly', (
    tester,
  ) async {
    bool closeClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TunerScaffold(
          actionModeActive: true,
          actionModeTitle: 'Action Selected: 3 items',
          onActionModeFinishedClicked: () => closeClicked = true,
          body: const SizedBox(),
        ),
      ),
    );

    expect(find.text('Action Selected: 3 items'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    expect(closeClicked, isTrue);
  });
}
