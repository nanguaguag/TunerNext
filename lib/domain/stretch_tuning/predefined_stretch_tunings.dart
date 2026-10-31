import 'stretch_tuning.dart';

/// Predefined standard acoustic stretch tunings.
class PredefinedStretchTunings {
  PredefinedStretchTunings._();

  static const int idNoStretch = -1;
  static const int idRailsback = -2;

  /// Theoretical un-stretched tuning (0 cents stretch across all octaves).
  static StretchTuning noStretch({int stableId = idNoStretch}) {
    return StretchTuning(
      name: 'No Stretch Tuning',
      description: 'Theoretical tuning with zero frequency stretching.',
      unstretchedFrequencies: const [],
      stretchInCents: const [],
      stableId: stableId,
    );
  }

  /// Classic empirical Railsback stretch tuning for acoustic grand pianos.
  ///
  /// Low register strings (e.g. A0 ~27.5 Hz) are tuned flat (~-35 cents) and
  /// high register strings (e.g. C8 ~4186 Hz) are tuned sharp (~+32 cents)
  /// to align fundamental pitches with inharmonic stiff-string upper partials.
  static StretchTuning railsback({int stableId = idRailsback}) {
    return StretchTuning(
      name: 'Railsback Stretch Tuning',
      description:
          'Standard piano stretch curve compensating for string stiffness inharmonicity.',
      unstretchedFrequencies: const [
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
      stretchInCents: const [
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
      stableId: stableId,
    );
  }

  /// All predefined stretch tuning curves.
  static List<StretchTuning> get all => [noStretch(), railsback()];
}
