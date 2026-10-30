import 'fifth_modification.dart';
import 'rational_number.dart';

/// Models a 12-tone circle of fifths with individual comma corrections applied
/// across every step around the circle.
class TemperamentCircleOfFifths {
  const TemperamentCircleOfFifths({
    required this.cg,
    required this.gd,
    required this.da,
    required this.ae,
    required this.eb,
    required this.bfSharp,
    required this.fSharpCSharp,
    required this.cSharpGSharp,
    required this.gSharpEFlat,
    required this.eFlatBFlat,
    required this.bFlatF,
    required this.fc,
  });

  final FifthModification cg;
  final FifthModification gd;
  final FifthModification da;
  final FifthModification ae;
  final FifthModification eb;
  final FifthModification bfSharp;
  final FifthModification fSharpCSharp;
  final FifthModification cSharpGSharp;
  final FifthModification gSharpEFlat;
  final FifthModification eFlatBFlat;
  final FifthModification bFlatF;
  final FifthModification fc;

  /// Standard 12-EDO circle of fifths where every fifth is narrowed by exactly 1/12 Pythagorean comma.
  static final TemperamentCircleOfFifths edo12 = TemperamentCircleOfFifths(
    cg: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    gd: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    da: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    ae: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    eb: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    bfSharp: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    fSharpCSharp: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    cSharpGSharp: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    gSharpEFlat: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    eFlatBFlat: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    bFlatF: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
    fc: FifthModification(pythagoreanComma: RationalNumber(-1, 12)),
  );

  /// Computes the 13 ascending chromatic frequency ratios (from C0 to C1) relative to root C = 1.0.
  List<double> getRatios() {
    final ratios = List<double>.filled(13, 0.0);
    final threeHalf = RationalNumber(3, 2);
    var totalCorrection = FifthModification();

    ratios[0] = 1.0;

    totalCorrection += cg;
    ratios[7] = threeHalf.toDouble() * totalCorrection.toDouble();

    totalCorrection += gd;
    ratios[2] =
        ((threeHalf * threeHalf) / RationalNumber(2, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += da;
    ratios[9] =
        ((threeHalf.pow(3)) / RationalNumber(2, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += ae;
    ratios[4] =
        ((threeHalf.pow(4)) / RationalNumber(4, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += eb;
    ratios[11] =
        ((threeHalf.pow(5)) / RationalNumber(4, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += bfSharp;
    ratios[6] =
        ((threeHalf.pow(6)) / RationalNumber(8, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += fSharpCSharp;
    ratios[1] =
        ((threeHalf.pow(7)) / RationalNumber(16, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += cSharpGSharp;
    ratios[8] =
        ((threeHalf.pow(8)) / RationalNumber(16, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += gSharpEFlat;
    ratios[3] =
        ((threeHalf.pow(9)) / RationalNumber(32, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += eFlatBFlat;
    ratios[10] =
        ((threeHalf.pow(10)) / RationalNumber(32, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += bFlatF;
    ratios[5] =
        ((threeHalf.pow(11)) / RationalNumber(64, 1)).toDouble() *
        totalCorrection.toDouble();

    totalCorrection += fc;
    ratios[12] =
        ((threeHalf.pow(12)) / RationalNumber(64, 1)).toDouble() *
        totalCorrection.toDouble();

    return ratios;
  }
}
