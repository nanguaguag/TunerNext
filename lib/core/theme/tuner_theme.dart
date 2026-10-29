import 'package:flutter/material.dart';
import 'tuner_colors.dart';

/// Central theme definitions conforming to Material Design 3.
class TunerTheme {
  TunerTheme._();

  static const _primaryColor = Color(0xFF1976D2); // Material Blue 700

  /// Light Material 3 theme.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const [TunerColors.light],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Dark Material 3 theme.
  static ThemeData dark({bool pureBlack = false}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    );

    final resolvedScheme = pureBlack
        ? colorScheme.copyWith(
            surface: Colors.black,
            surfaceContainerLowest: Colors.black,
            surfaceContainerLow: const Color(0xFF121212),
            surfaceContainer: const Color(0xFF181818),
            surfaceContainerHigh: const Color(0xFF242424),
          )
        : colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: resolvedScheme,
      scaffoldBackgroundColor: pureBlack ? Colors.black : null,
      extensions: const [TunerColors.dark],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: pureBlack ? Colors.black : resolvedScheme.surface,
        foregroundColor: resolvedScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
