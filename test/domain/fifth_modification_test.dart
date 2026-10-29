import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/fifth_modification.dart';
import 'package:tuner_flutter/domain/models/rational_number.dart';
import 'package:tuner_flutter/domain/temperaments/temperament_models.dart';

void main() {
  group('FifthModification Tests', () {
    test('Pure fifth modification has ratio 1.0 (0 cents)', () {
      final pure = FifthModification();
      expect(pure.toDouble(), closeTo(1.0, 1e-9));
      expect(ratioToCents(pure.toDouble()), closeTo(0.0, 1e-9));
    });

    test(
      '1/4 syntonic comma meantone fifth narrows pure fifth by ~5.38 cents',
      () {
        final quarterSyntonic = FifthModification(
          syntonicComma: RationalNumber(-1, 4),
        );
        final cents = ratioToCents(quarterSyntonic.toDouble());
        // Syntonic comma is ~21.506 cents, 1/4 is ~5.376 cents
        expect(cents, closeTo(-5.376, 1e-3));
      },
    );

    test(
      'Comma relationship equivalence: 1 PythComma = 1 SyntComma + 1 Schisma',
      () {
        final pyth = FifthModification(pythagoreanComma: RationalNumber(1, 1));
        final syntPlusSchisma = FifthModification(
          syntonicComma: RationalNumber(1, 1),
          schisma: RationalNumber(1, 1),
        );

        expect(pyth.toDouble(), closeTo(syntPlusSchisma.toDouble(), 1e-7));
        expect(ratioToCents(pyth.toDouble()), closeTo(23.46, 0.05));
      },
    );
  });
}
