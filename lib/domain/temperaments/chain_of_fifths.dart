import 'fifth_modification.dart';
import 'rational_number.dart';

/// Models a chain of fifths starting at a chosen root note index.
///
/// Each link in the chain represents a fifth interval with an optional microtonal modification.
class ChainOfFifths {
  ChainOfFifths(List<FifthModification> fifths, this.rootIndex)
    : fifths = List.unmodifiable(fifths) {
    if (rootIndex < 0 || (fifths.isNotEmpty && rootIndex > fifths.length)) {
      throw RangeError.range(rootIndex, 0, fifths.length, 'rootIndex');
    }
  }

  /// Ordered fifth interval modifications between consecutive notes.
  final List<FifthModification> fifths;

  /// Index in the resulting notes sequence where the root note (ratio 1.0) sits.
  final int rootIndex;

  /// Total number of notes produced by this chain (fifths.length + 1).
  int get size => fifths.length + 1;

  /// Calculates the closing correction required to complete a circular circle of fifths.
  FifthModification getClosingCircleCorrection() {
    var totalCorrection = FifthModification(
      pythagoreanComma: RationalNumber(-1, 1),
    );
    for (final fifth in fifths) {
      totalCorrection = totalCorrection - fifth;
    }
    return totalCorrection;
  }

  /// Calculates the frequency ratios of all notes relative to the root note (ratio 1.0).
  ///
  /// Traverses upwards and downwards along the chain of fifths, folding all ratios
  /// into the base octave range [1.0, 2.0).
  List<double> getRatiosAlongFifths() {
    final ratios = List<double>.filled(size, 0.0);
    var totalCorrection = FifthModification();
    ratios[rootIndex] = 1.0;

    var fifthRatio = RationalNumber(1, 1);
    final threeHalf = RationalNumber(3, 2);

    // 1. Traverse upward from rootIndex to end of fifths
    for (int i = rootIndex; i < fifths.length; i++) {
      totalCorrection = totalCorrection + fifths[i];
      fifthRatio = fifthRatio * threeHalf;
      if (fifthRatio.numerator >= 2 * fifthRatio.denominator) {
        fifthRatio = fifthRatio / RationalNumber(2, 1);
      }
      ratios[i + 1] = fifthRatio.toDouble() * totalCorrection.toDouble();
    }

    // 2. Traverse downward from rootIndex - 1 to 0
    fifthRatio = RationalNumber(1, 1);
    totalCorrection = FifthModification();
    for (int i = rootIndex - 1; i >= 0; i--) {
      totalCorrection = totalCorrection - fifths[i];
      fifthRatio = fifthRatio / threeHalf;
      if (fifthRatio.numerator < fifthRatio.denominator) {
        fifthRatio = fifthRatio * RationalNumber(2, 1);
      }
      ratios[i] = fifthRatio.toDouble() * totalCorrection.toDouble();
    }

    return ratios;
  }

  /// Returns the frequency ratios sorted in strictly ascending pitch order.
  List<double> getSortedRatios() {
    final list = getRatiosAlongFifths();
    list.sort();
    return list;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainOfFifths &&
          rootIndex == other.rootIndex &&
          fifths.length == other.fifths.length &&
          _listEquals(fifths, other.fifths);

  @override
  int get hashCode => Object.hash(rootIndex, Object.hashAll(fifths));

  static bool _listEquals(
    List<FifthModification> a,
    List<FifthModification> b,
  ) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
