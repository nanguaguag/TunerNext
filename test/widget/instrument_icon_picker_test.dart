import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/instruments/instrument_icon.dart';
import 'package:tuner_flutter/ui/instruments/instrument_icon_picker.dart';
import 'package:tuner_flutter/ui/instruments/instrument_icons.dart';

void main() {
  group('InstrumentIconPicker Widget', () {
    testWidgets('renders all 15 icons in grid and selects on tap', (
      tester,
    ) async {
      InstrumentIcon? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: InstrumentIconPicker(
              selectedIcon: InstrumentIcon.guitar,
              onIconSelected: (i) => selected = i,
            ),
          ),
        ),
      );

      expect(find.text('Pick Icon'), findsOneWidget);
      expect(find.byType(InstrumentIconWidget), findsNWidgets(15));

      // Tap on second icon
      await tester.tap(find.byType(InstrumentIconWidget).at(1));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
    });
  });
}
