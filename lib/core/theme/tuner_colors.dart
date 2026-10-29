import 'package:flutter/material.dart';

/// Semantic colors specifically for tuner state feedback, integrated as a
/// [ThemeExtension] so that widgets can access them via `Theme.of(context).extension<TunerColors>()`.
class TunerColors extends ThemeExtension<TunerColors> {
  const TunerColors({
    required this.inTune,
    required this.onInTune,
    required this.outOfTune,
    required this.onOutOfTune,
    required this.inactive,
    required this.onInactive,
    required this.toleranceBand,
  });

  /// Color used when pitch is within acceptable tolerance (green).
  final Color inTune;

  /// Contrast foreground on [inTune].
  final Color onInTune;

  /// Color used when pitch is too sharp or too flat (red/amber).
  final Color outOfTune;

  /// Contrast foreground on [outOfTune].
  final Color onOutOfTune;

  /// Color used when no pitch is detected or tuner is idle (neutral gray).
  final Color inactive;

  /// Contrast foreground on [inactive].
  final Color onInactive;

  /// Color used for the dashed tolerance band boundary lines.
  final Color toleranceBand;

  /// Light theme default tuner semantic colors.
  static const light = TunerColors(
    inTune: Color(0xFF2E7D32), // Material Green 800
    onInTune: Color(0xFFFFFFFF),
    outOfTune: Color(0xFFC62828), // Material Red 800
    onOutOfTune: Color(0xFFFFFFFF),
    inactive: Color(0xFF757575), // Material Grey 600
    onInactive: Color(0xFFFFFFFF),
    toleranceBand: Color(0xFF9E9E9E),
  );

  /// Dark theme default tuner semantic colors.
  static const dark = TunerColors(
    inTune: Color(0xFF66BB6A), // Material Green 400
    onInTune: Color(0xFF003300),
    outOfTune: Color(0xFFEF5350), // Material Red 400
    onOutOfTune: Color(0xFF330000),
    inactive: Color(0xFF9E9E9E), // Material Grey 500
    onInactive: Color(0xFF1E1E1E),
    toleranceBand: Color(0xFF616161),
  );

  @override
  TunerColors copyWith({
    Color? inTune,
    Color? onInTune,
    Color? outOfTune,
    Color? onOutOfTune,
    Color? inactive,
    Color? onInactive,
    Color? toleranceBand,
  }) {
    return TunerColors(
      inTune: inTune ?? this.inTune,
      onInTune: onInTune ?? this.onInTune,
      outOfTune: outOfTune ?? this.outOfTune,
      onOutOfTune: onOutOfTune ?? this.onOutOfTune,
      inactive: inactive ?? this.inactive,
      onInactive: onInactive ?? this.onInactive,
      toleranceBand: toleranceBand ?? this.toleranceBand,
    );
  }

  @override
  TunerColors lerp(ThemeExtension<TunerColors>? other, double t) {
    if (other is! TunerColors) return this;
    return TunerColors(
      inTune: Color.lerp(inTune, other.inTune, t) ?? inTune,
      onInTune: Color.lerp(onInTune, other.onInTune, t) ?? onInTune,
      outOfTune: Color.lerp(outOfTune, other.outOfTune, t) ?? outOfTune,
      onOutOfTune: Color.lerp(onOutOfTune, other.onOutOfTune, t) ?? onOutOfTune,
      inactive: Color.lerp(inactive, other.inactive, t) ?? inactive,
      onInactive: Color.lerp(onInactive, other.onInactive, t) ?? onInactive,
      toleranceBand:
          Color.lerp(toleranceBand, other.toleranceBand, t) ?? toleranceBand,
    );
  }
}

/// Convenience extension on [BuildContext] to retrieve [TunerColors].
extension TunerColorsExtension on BuildContext {
  TunerColors get tunerColors =>
      Theme.of(this).extension<TunerColors>() ?? TunerColors.light;
}
