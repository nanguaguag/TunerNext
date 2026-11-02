import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/temperaments/predefined_temperament.dart';
import 'package:tuner_flutter/ui/dialogs/temperament_dialog.dart';

void main() {
  group('EDO Temperaments Suite (5 to 72 EDO)', () {
    test('getEdoTemperaments yields all 68 divisions from 5-EDO to 72-EDO', () {
      final edos = PredefinedTemperaments.getEdoTemperaments();
      expect(edos.length, equals(68));

      // First is 5-EDO, last is 72-EDO
      expect(edos.first.name, equals('Equal temperament 5'));
      expect(edos.first.equalOctaveDivision, equals(5));
      expect(edos.last.name, equals('Equal temperament 72'));
      expect(edos.last.equalOctaveDivision, equals(72));

      // 12-EDO is included with stableId = 1
      final edo12 = edos.firstWhere((t) => t.equalOctaveDivision == 12);
      expect(edo12.stableId, equals(1));
      expect(edo12.cents.length, equals(13));
      expect(edo12.cents.last, closeTo(1200.0, 1e-6));

      // Test microtonal scales like 19-EDO, 31-EDO, 53-EDO
      final edo19 = edos.firstWhere((t) => t.equalOctaveDivision == 19);
      expect(edo19.cents.length, equals(20));
      expect(edo19.cents[1], closeTo(1200.0 / 19.0, 1e-4));
      expect(edo19.cents.last, closeTo(1200.0, 1e-6));

      final edo53 = edos.firstWhere((t) => t.equalOctaveDivision == 53);
      expect(edo53.cents.length, equals(54));
      expect(edo53.cents.last, closeTo(1200.0, 1e-6));
    });

    test(
      'getAll contains 86 comprehensive temperaments with 18 historical ones',
      () {
        final all = PredefinedTemperaments.getAll();
        expect(all.length, equals(86));

        // 12-EDO is first
        expect(all.first.equalOctaveDivision, equals(12));

        // Historical temperaments are present
        expect(all.any((t) => t.name.contains('Pythagorean')), isTrue);
        expect(all.any((t) => t.name.contains('Pure')), isTrue);
        expect(all.any((t) => t.name.contains('Werckmeister III')), isTrue);
        expect(all.any((t) => t.name.contains('Kirnberger')), isTrue);
        expect(all.any((t) => t.name.contains('Young II')), isTrue);
      },
    );

    testWidgets(
      'TemperamentDialog displays grouped EDO and Historical sections',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final selected = PredefinedTemperaments.edo12();
        var chosenName = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TemperamentDialog(
                selectedTemperament: selected,
                onSelectTemperament: (t) {
                  chosenName = t.name;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify sections are visible
        expect(find.textContaining('Equal Temperaments'), findsOneWidget);
        expect(find.textContaining('Historical Temperaments'), findsOneWidget);

        // Search functionality
        await tester.enterText(find.byType(TextField), '31');
        await tester.pumpAndSettle();

        expect(find.text('Equal temperament 31'), findsOneWidget);

        // Tap on 31-EDO
        await tester.tap(find.text('Equal temperament 31'));
        await tester.pumpAndSettle();

        expect(chosenName, equals('Equal temperament 31'));
      },
    );
  });
}
