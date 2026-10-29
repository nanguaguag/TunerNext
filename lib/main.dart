// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/tuner_theme.dart';
import 'l10n/app_localizations.dart';
import 'state/preferences_state.dart';
import 'state/scientific_mode_provider.dart';
import 'ui/screens/instrument_tuner_screen.dart';
import 'ui/screens/scientific_tuner_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TunerApp(),
    ),
  );
}

/// Root widget of the Tuner Flutter application.
class TunerApp extends ConsumerWidget {
  const TunerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScientific = ref.watch(scientificModeProvider);
    final preferences = ref.watch(preferencesProvider);

    return MaterialApp(
      title: 'Tuner',
      debugShowCheckedModeBanner: false,
      theme: TunerTheme.light(),
      darkTheme: TunerTheme.dark(),
      themeMode: preferences.themeMode.toThemeMode,
      locale: preferences.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: isScientific
          ? const ScientificTunerScreen()
          : const InstrumentTunerScreen(),
    );
  }
}
