import 'dart:math' as math;
import '../temperaments/temperament_models.dart';

/// Represents acoustic stretch tuning applied to compensate for string inharmonicity.
class StretchTuning {
  const StretchTuning({
    this.name = 'No Stretch Tuning',
    this.description = 'Flat tuning without acoustic stretch',
    this.unstretchedFrequencies = const [],
    this.stretchInCents = const [],
    this.stableId = -1,
  });

  final String name;
  final String description;
  final List<double> unstretchedFrequencies;
  final List<double> stretchInCents;
  final int stableId;

  int get size => unstretchedFrequencies.length;
  bool get isEmpty => unstretchedFrequencies.isEmpty;

  /// Calculates the stretched frequency for [unstretchedFrequency],
  /// anchoring zero-stretch at [referenceFrequency].
  double getStretchedFrequency(
    double unstretchedFrequency,
    double referenceFrequency,
  ) {
    if (unstretchedFrequencies.length <= 1 || unstretchedFrequency <= 0.0) {
      return unstretchedFrequency;
    }
    final refStretch = getStretch(referenceFrequency);
    final stretch = getStretch(unstretchedFrequency) - refStretch;
    return centsToFrequency(stretch, unstretchedFrequency);
  }

  /// Interpolates the cent stretch value for [f] on a logarithmic frequency scale.
  double getStretch(double f) {
    final n = unstretchedFrequencies.length;
    if (n <= 1 || f <= 0.0) return 0.0;

    // Binary search
    var low = 0;
    var high = n - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final midVal = unstretchedFrequencies[mid];
      if (midVal == f) {
        return stretchInCents[mid];
      } else if (midVal < f) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    // low is insertion index
    final i0 = (low - 1).clamp(0, n - 2);
    final i1 = i0 + 1;

    final lf = math.log(f) / math.ln10;
    final lf0 = math.log(unstretchedFrequencies[i0]) / math.ln10;
    final lf1 = math.log(unstretchedFrequencies[i1]) / math.ln10;

    final c0 = stretchInCents[i0];
    final c1 = stretchInCents[i1];

    if (lf1 == lf0) return c0;
    return c0 + (c1 - c0) * (lf - lf0) / (lf1 - lf0);
  }
}

/// Catalog of standard acoustic stretch tuning models.
class PredefinedStretchTunings {
  static const int stableIdNone = -1;
  static const int stableIdRailsback = -2;

  static StretchTuning none() => const StretchTuning(
    name: 'No Stretch Tuning',
    description: 'Standard flat pitch scale without acoustic stretch',
    unstretchedFrequencies: [],
    stretchInCents: [],
    stableId: stableIdNone,
  );

  /// Standard Railsback curve derived from acoustic piano stretch measurements.
  static StretchTuning railsback() => const StretchTuning(
    name: 'Railsback Stretch Curve',
    description: 'Compensates for piano string wire stiffness inharmonicity',
    unstretchedFrequencies: [
      28.409,
      33.377,
      39.215,
      46.074,
      54.132,
      63.599,
      74.723,
      87.792,
      103.146,
      121.186,
      142.381,
      167.283,
      196.541,
      230.915,
      271.302,
      318.752,
      374.501,
      440.000,
      516.955,
      607.369,
      713.596,
      838.403,
      985.037,
      1157.318,
      1359.730,
      1597.543,
      1876.950,
      2205.224,
      2590.912,
      3044.056,
      3576.454,
      4201.967,
    ],
    stretchInCents: [
      -35.949,
      -27.623,
      -21.288,
      -16.107,
      -12.202,
      -8.756,
      -6.136,
      -4.509,
      -3.601,
      -2.863,
      -2.295,
      -1.767,
      -1.245,
      -0.904,
      -0.643,
      -0.389,
      -0.196,
      0.000,
      0.254,
      0.508,
      0.763,
      1.443,
      2.156,
      3.549,
      5.130,
      6.889,
      9.121,
      11.786,
      15.102,
      19.362,
      24.684,
      32.065,
    ],
    stableId: stableIdRailsback,
  );
}
