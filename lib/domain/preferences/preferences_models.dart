// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// App theme visual appearance modes.
enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

/// Supported musical notation styles for note display.
enum NotationType {
  regional,
  solfege,
  international;

  String get displayName {
    switch (this) {
      case NotationType.regional:
        return 'Regional (C, D, E...)';
      case NotationType.solfege:
        return 'Solfège (Do, Re, Mi...)';
      case NotationType.international:
        return 'International (C, D, E...)';
    }
  }
}

/// Octave numbering notation conventions.
enum OctaveNotation {
  scientific,
  helmholtz;

  String get displayName {
    switch (this) {
      case OctaveNotation.scientific:
        return 'Scientific (C4, A4)';
      case OctaveNotation.helmholtz:
        return "Helmholtz (c', a')";
    }
  }
}

/// Supported language locale option entry.
class LanguageOption {
  const LanguageOption({
    required this.name,
    required this.nativeName,
    this.locale,
  });

  final String name;
  final String nativeName;
  final Locale? locale;

  String get tag => locale?.languageCode ?? 'system';

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      name: 'System Default',
      nativeName: 'Follow System',
      locale: null,
    ),
    LanguageOption(
      name: 'English',
      nativeName: 'English',
      locale: Locale('en'),
    ),
    LanguageOption(
      name: 'Simplified Chinese',
      nativeName: '简体中文',
      locale: Locale('zh'),
    ),
    LanguageOption(name: 'German', nativeName: 'Deutsch', locale: Locale('de')),
    LanguageOption(
      name: 'French',
      nativeName: 'Français',
      locale: Locale('fr'),
    ),
    LanguageOption(
      name: 'Spanish',
      nativeName: 'Español',
      locale: Locale('es'),
    ),
    LanguageOption(
      name: 'Portuguese',
      nativeName: 'Português (Brasil)',
      locale: Locale('pt'),
    ),
    LanguageOption(name: 'Polish', nativeName: 'Polski', locale: Locale('pl')),
    LanguageOption(
      name: 'Romanian',
      nativeName: 'Română',
      locale: Locale('ro'),
    ),
    LanguageOption(
      name: 'Hungarian',
      nativeName: 'Magyar',
      locale: Locale('hu'),
    ),
    LanguageOption(
      name: 'Ukrainian',
      nativeName: 'Українська',
      locale: Locale('uk'),
    ),
    LanguageOption(name: 'Czech', nativeName: 'Čeština', locale: Locale('cs')),
    LanguageOption(name: 'Catalan', nativeName: 'Català', locale: Locale('ca')),
    LanguageOption(
      name: 'Breton',
      nativeName: 'Brezhoneg',
      locale: Locale('br'),
    ),
    LanguageOption(
      name: 'Swedish',
      nativeName: 'Svenska',
      locale: Locale('sv'),
    ),
    LanguageOption(
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      locale: Locale('vi'),
    ),
    LanguageOption(
      name: 'Arabic (RTL)',
      nativeName: 'العربية',
      locale: Locale('ar'),
    ),
  ];
}
