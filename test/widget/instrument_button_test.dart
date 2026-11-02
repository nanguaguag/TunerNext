import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/domain/instruments/instrument_icon.dart';
import 'package:tuner_flutter/ui/instruments/instrument_button.dart';
import 'package:tuner_flutter/ui/instruments/instrument_icons.dart';
import 'package:tuner_flutter/ui/plot/plot_window_outline.dart';

void main() {
  group('InstrumentButton Widget Tests', () {
    testWidgets('renders instrument name and icon with default outline', (
      tester,
    ) async {
      var clicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 250,
                child: InstrumentButton(
                  icon: InstrumentIcon.guitar,
                  name: '6-string guitar',
                  onClick: () {
                    clicked = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('6-string guitar'), findsOneWidget);
      expect(find.byType(InstrumentIconWidget), findsOneWidget);

      await tester.tap(find.byType(InstrumentButton));
      expect(clicked, isTrue);
    });

    testWidgets('renders error state when errorMessage is provided', (
      tester,
    ) async {
      const errorText = 'Incorrect temperament';

      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.light(),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 280,
                child: InstrumentButton(
                  icon: InstrumentIcon.violin,
                  name: 'Violin',
                  errorMessage: errorText,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Violin'), findsOneWidget);
      expect(find.text(errorText), findsOneWidget);

      // Verify Material surface color reflects error container
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(InstrumentButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, TunerTheme.light().colorScheme.errorContainer);

      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.side.color, TunerTheme.light().colorScheme.error);
    });

    testWidgets('respects custom PlotWindowOutline parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TunerTheme.dark(),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: InstrumentButton(
                  icon: InstrumentIcon.piano,
                  name: 'Piano',
                  outline: PlotWindowOutline(
                    lineWidth: 2.5,
                    cornerRadius: 16.0,
                    color: Colors.cyan,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(InstrumentButton),
          matching: find.byType(Material),
        ),
      );
      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.side.width, 2.5);
      expect(shape.side.color, Colors.cyan);
      expect(shape.borderRadius, BorderRadius.circular(16.0));
    });

    testWidgets(
      'handles very long instrument name gracefully without overflow',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: TunerTheme.light(),
            home: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: InstrumentButton(
                    icon: InstrumentIcon.doubleBass,
                    name: 'Extremely Long Symphony Double Bass Special Edition',
                    errorMessage: 'Incompatible tuning temperament scale',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('Extremely Long Symphony Double Bass Special Edition'),
          findsOneWidget,
        );
      },
    );
  });
}
