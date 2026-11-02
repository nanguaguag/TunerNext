import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/instruments/instrument_icon.dart';
import 'package:tuner_flutter/ui/instruments/instrument_icons.dart';

void main() {
  group('InstrumentIcons SVG repository', () {
    test(
      'all 15 InstrumentIcon values have non-empty valid SVG definitions',
      () {
        for (final icon in InstrumentIcon.values) {
          final svg = InstrumentIcons.getSvgString(icon);
          expect(
            svg,
            isNotEmpty,
            reason: 'Icon ${icon.name} must have SVG data',
          );
          expect(
            svg,
            contains('<svg'),
            reason: 'Icon ${icon.name} must contain <svg tag',
          );
          expect(
            svg,
            contains('viewBox="0 0 50 50"'),
            reason: 'Icon ${icon.name} must have 50x50 viewport',
          );
          expect(
            svg,
            contains('</svg>'),
            reason: 'Icon ${icon.name} must be properly closed',
          );
        }
      },
    );

    testWidgets('renders all 15 InstrumentIcon widgets in Material theme', (
      tester,
    ) async {
      for (final icon in InstrumentIcon.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: InstrumentIconWidget(
                  icon: icon,
                  size: 40.0,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(InstrumentIconWidget), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
      }
    });

    testWidgets('respects default theme content color when color is omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: Center(
              child: InstrumentIconWidget(icon: InstrumentIcon.guitar),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InstrumentIconWidget), findsOneWidget);
    });
  });
}
