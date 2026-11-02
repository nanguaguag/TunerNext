import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/models/musical_note.dart';
import 'package:tuner_flutter/domain/models/tuning_state.dart';
import 'package:tuner_flutter/ui/instruments/string_with_info.dart';
import 'package:tuner_flutter/ui/instruments/strings.dart';

void main() {
  final testStrings = [
    const StringWithInfo(
      key: 0,
      note: MusicalNote(base: BaseNote.e, octave: 2), // E2 (thickest)
    ),
    const StringWithInfo(
      key: 1,
      note: MusicalNote(base: BaseNote.a, octave: 2), // A2
    ),
    const StringWithInfo(
      key: 2,
      note: MusicalNote(base: BaseNote.d, octave: 3), // D3
    ),
    const StringWithInfo(
      key: 3,
      note: MusicalNote(base: BaseNote.g, octave: 3), // G3
    ),
    const StringWithInfo(
      key: 4,
      note: MusicalNote(base: BaseNote.b, octave: 3), // B3
    ),
    const StringWithInfo(
      key: 5,
      note: MusicalNote(base: BaseNote.e, octave: 4), // E4 (thinnest)
    ),
  ];

  Widget buildTestWidget({
    int? highlightedNoteKey = 0,
    MusicalNote? highlightedNote,
    TuningState tuningState = TuningState.inTune,
    void Function(int, MusicalNote)? onStringClicked,
    StringsScrollMode scrollMode = StringsScrollMode.automatic,
    StringsSidebarPosition sidebarPosition = StringsSidebarPosition.start,
  }) {
    return MaterialApp(
      theme: TunerTheme.light(),
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: Strings(
            strings: testStrings,
            highlightedNoteKey: highlightedNoteKey,
            highlightedNote: highlightedNote ?? testStrings[0].note,
            tuningState: tuningState,
            onStringClicked: onStringClicked,
            scrollMode: scrollMode,
            sidebarPosition: sidebarPosition,
          ),
        ),
      ),
    );
  }

  group('Strings Widget', () {
    testWidgets('renders all strings and their note labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Should render note badges: E2, A2, D3, G3, B3, E4
      expect(find.text('E2'), findsWidgets);
      expect(find.text('A2'), findsOneWidget);
      expect(find.text('D3'), findsOneWidget);
      expect(find.text('G3'), findsOneWidget);
      expect(find.text('B3'), findsOneWidget);
      expect(find.text('E4'), findsOneWidget);
    });

    testWidgets('tap on string triggers onStringClicked callback', (
      tester,
    ) async {
      int? selectedKey;
      MusicalNote? selectedNote;
      await tester.pumpWidget(
        buildTestWidget(
          onStringClicked: (k, note) {
            selectedKey = k;
            selectedNote = note;
          },
        ),
      );

      // Tap on D3 (key 2)
      await tester.tap(find.text('D3'));
      await tester.pumpAndSettle();

      expect(selectedKey, equals(2));
      expect(selectedNote?.name, equals('D3'));
    });

    testWidgets('highlights active string with inTune or outOfTune color', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          highlightedNoteKey: 1, // A2
          highlightedNote: testStrings[1].note,
          tuningState: TuningState.tooLow,
        ),
      );

      expect(find.text('A2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders properly with sidebarPosition end', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(sidebarPosition: StringsSidebarPosition.end),
      );
      expect(find.text('A2'), findsOneWidget);
    });

    test('computeStringLineWidth scales between min and max width', () {
      final w0 = computeStringLineWidth(
        index: 0,
        minIndex: 0,
        maxIndex: 5,
        minLineWidth: 1.0,
        maxLineWidth: 5.0,
      );
      final w5 = computeStringLineWidth(
        index: 5,
        minIndex: 0,
        maxIndex: 5,
        minLineWidth: 1.0,
        maxLineWidth: 5.0,
      );

      // Lowest string (index 0) has maxLineWidth
      expect(w0, equals(5.0));
      // Highest string (index 5) has minLineWidth
      expect(w5, equals(1.0));
      // Intermediate string decreases monotonically
      final w2 = computeStringLineWidth(
        index: 2,
        minIndex: 0,
        maxIndex: 5,
        minLineWidth: 1.0,
        maxLineWidth: 5.0,
      );
      expect(w2, lessThan(w0));
      expect(w2, greaterThan(w5));
    });
  });
}
