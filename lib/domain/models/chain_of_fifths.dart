import 'fifth_modification.dart';
import 'rational_number.dart';

/// Chain-of-fifths interval generator for historical musical temperaments.
class ChainOfFifths {
  ChainOfFifths({required this.fifths, required this.rootIndex});

  final List<FifthModification> fifths;
  final int rootIndex;

  /// Returns total correction needed to close the circle of fifths (e.g., wolf fifth).
  FifthModification getClosingCircleCorrection() {
    var total = FifthModification(pythagoreanComma: RationalNumber(-1, 1));
    for (final fifth in fifths) {
      total = total - fifth;
    }
    return total;
  }

  /// Calculates frequency ratios relative to the root note along the fifths chain.
  List<double> getRatiosAlongFifths() {
    final ratios = List<double>.filled(fifths.length + 1, 1.0);
    var totalCorrection = FifthModification();
    ratios[rootIndex] = 1.0;
    var fifthRatio = RationalNumber(1, 1);
    final threeHalf = RationalNumber(3, 2);

    // Upwards from root along fifths
    for (var i = rootIndex; i < fifths.length; i++) {
      totalCorrection = totalCorrection + fifths[i];
      fifthRatio = fifthRatio * threeHalf;
      if (fifthRatio.numerator > 2 * fifthRatio.denominator) {
        fifthRatio = RationalNumber(
          fifthRatio.numerator,
          fifthRatio.denominator * 2,
        );
      }
      ratios[i + 1] = fifthRatio.toDouble() * totalCorrection.toDouble();
    }

    // Downwards from root along fourths
    fifthRatio = RationalNumber(1, 1);
    totalCorrection = FifthModification();
    for (var i = rootIndex - 1; i >= 0; i--) {
      totalCorrection = totalCorrection - fifths[i];
      fifthRatio = RationalNumber(
        fifthRatio.numerator * 2,
        fifthRatio.denominator * 3,
      );
      if (fifthRatio.numerator < fifthRatio.denominator) {
        fifthRatio = RationalNumber(
          fifthRatio.numerator * 2,
          fifthRatio.denominator,
        );
      }
      ratios[i] = fifthRatio.toDouble() * totalCorrection.toDouble();
    }

    return ratios;
  }

  /// Returns ratios sorted ascendingly within the [1.0, 2.0) octave.
  List<double> getSortedRatios() {
    final list = List<double>.from(getRatiosAlongFifths());
    list.sort();
    return list;
  }
}
