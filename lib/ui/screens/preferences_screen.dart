// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/preferences/preferences_models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/preferences_state.dart';
import '../widgets/settings_dialogs.dart';

/// Full preferences and settings configuration screen.
///
/// Organized into 4 Material 3 sections:
/// 1. Basic Settings (Theme, Language, Screen Always On, Notation, Pitch, Tolerance)
/// 2. Advanced Acoustic DSP (Algorithm, Acoustic Weighting, Windowing, Overlap, Buffer Size)
/// 3. Expert Settings (Sensitivity, Octave Jump Gate, Median Filter, Moving Average, History)
/// 4. Others (Reset to defaults, About Tuner)
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settings ?? 'Settings',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // ==================== 1. BASIC SETTINGS ====================
          _SectionHeader(title: l10n?.basic ?? 'Basic Settings'),
          ListTile(
            leading: const Icon(Icons.brightness_medium),
            title: Text(l10n?.appearance ?? 'Appearance'),
            subtitle: Text(prefs.themeMode.displayName),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AppearanceDialog(
                  selectedMode: prefs.themeMode,
                  onModeSelected: (mode) {
                    notifier.update((s) => s.copyWith(themeMode: mode));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n?.language ?? 'Language'),
            subtitle: Text(
              LanguageOption.supportedLanguages
                  .firstWhere(
                    (opt) =>
                        (opt.locale == null && prefs.localeCode == null) ||
                        (opt.locale?.languageCode == prefs.localeCode),
                    orElse: () => LanguageOption.supportedLanguages.first,
                  )
                  .name,
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => LanguageDialog(
                  selectedLocaleCode: prefs.localeCode,
                  onLocaleSelected: (code) {
                    notifier.update((s) => s.copyWith(localeCode: () => code));
                  },
                ),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.screen_lock_portrait),
            title: Text(l10n?.keepScreenOn ?? 'Keep screen on'),
            subtitle: const Text('Prevent display from sleeping while tuning'),
            value: prefs.screenAlwaysOn,
            onChanged: (val) {
              notifier.update((s) => s.copyWith(screenAlwaysOn: val));
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(l10n?.notation ?? 'Musical Notation'),
            subtitle: Text(
              '${prefs.notationType.displayName} • ${prefs.octaveNotation.displayName}',
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => NotationDialog(
                  currentNotation: prefs.notationType,
                  currentOctave: prefs.octaveNotation,
                  onNotationSelected: (type) {
                    notifier.update((s) => s.copyWith(notationType: type));
                  },
                  onOctaveSelected: (oct) {
                    notifier.update((s) => s.copyWith(octaveNotation: oct));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq),
            title: const Text('Reference Pitch (A4)'),
            subtitle: Text('${prefs.referenceFrequency.toStringAsFixed(1)} Hz'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => ReferenceFrequencyDialog(
                  currentFrequency: prefs.referenceFrequency,
                  onFrequencyConfirmed: (f) {
                    notifier.update((s) => s.copyWith(referenceFrequency: f));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(l10n?.toleranceInCents ?? 'Tuning Tolerance'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '±${prefs.toleranceInCents} ¢ (cents)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: prefs.toleranceInCents.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '±${prefs.toleranceInCents}¢',
                  onChanged: (val) {
                    notifier.update(
                      (s) => s.copyWith(toleranceInCents: val.round()),
                    );
                  },
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.swap_horiz),
            title: Text(l10n?.preferFlat ?? 'Prefer ♭ over ♯'),
            subtitle: const Text('Use flat notation for accidental semitones'),
            value: prefs.preferFlat,
            onChanged: (val) {
              notifier.update((s) => s.copyWith(preferFlat: val));
            },
          ),
          const Divider(),

          // ==================== 2. ADVANCED ACOUSTIC DSP ====================
          _SectionHeader(
            title: l10n?.advancedAcousticDsp ?? 'Advanced Acoustic DSP',
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: Text(l10n?.pitchAlgorithm ?? 'Pitch Detection Engine'),
            subtitle: Text(prefs.pitchAlgorithm.displayName),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => PitchAlgorithmDialog(
                  selectedAlgorithm: prefs.pitchAlgorithm,
                  onSelected: (algo) {
                    notifier.update((s) => s.copyWith(pitchAlgorithm: algo));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.filter_alt),
            title: Text(l10n?.acousticWeighting ?? 'Acoustic Weighting'),
            subtitle: Text(prefs.acousticWeightingMode.displayName),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AcousticWeightingDialog(
                  selectedMode: prefs.acousticWeightingMode,
                  onSelected: (mode) {
                    notifier.update(
                      (s) => s.copyWith(acousticWeightingMode: mode),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph),
            title: Text(l10n?.windowingFunction ?? 'Window Function'),
            subtitle: Text(prefs.windowing.displayName),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => WindowingFunctionDialog(
                  selectedFunction: prefs.windowing,
                  onSelected: (fn) {
                    notifier.update((s) => s.copyWith(windowing: fn));
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.layers),
            title: Text(l10n?.overlap ?? 'Window Overlap Rate'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prefs.overlapPercent}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: prefs.overlapPercent.toDouble(),
                  min: 0,
                  max: 90,
                  divisions: 18,
                  label: '${prefs.overlapPercent}%',
                  onChanged: (val) {
                    notifier.update(
                      (s) => s.copyWith(overlapPercent: val.round()),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: Text(l10n?.windowSize ?? 'FFT Buffer Window Size'),
            subtitle: Text(
              '${prefs.windowSize} samples (2^${prefs.windowSizeExponent})',
            ),
            trailing: DropdownButton<int>(
              value: prefs.windowSizeExponent,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 10, child: Text('1024 samples')),
                DropdownMenuItem(value: 11, child: Text('2048 samples')),
                DropdownMenuItem(value: 12, child: Text('4096 samples')),
                DropdownMenuItem(value: 13, child: Text('8192 samples')),
                DropdownMenuItem(value: 14, child: Text('16384 samples')),
              ],
              onChanged: (exp) {
                if (exp != null) {
                  notifier.update((s) => s.copyWith(windowSizeExponent: exp));
                }
              },
            ),
          ),
          const Divider(),

          // ==================== 3. EXPERT SETTINGS ====================
          _SectionHeader(title: l10n?.expert ?? 'Expert Settings'),
          ListTile(
            leading: const Icon(Icons.hearing),
            title: const Text('Pitch Detection Sensitivity'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prefs.sensitivity}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: prefs.sensitivity.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: '${prefs.sensitivity}%',
                  onChanged: (val) {
                    notifier.update(
                      (s) => s.copyWith(sensitivity: val.round()),
                    );
                  },
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: Text(l10n?.octaveJumpGate ?? 'Attack Octave Jump Gate'),
            subtitle: const Text(
              'Suppresses sudden octave jumping on violin bow scratch overtones',
            ),
            value: prefs.octaveJumpGate,
            onChanged: (val) {
              notifier.update((s) => s.copyWith(octaveJumpGate: val));
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.filter_alt_outlined),
            title: Text(l10n?.medianFilter ?? 'Anti-Jitter Median Filter'),
            subtitle: const Text(
              '3-tap median smoothing to suppress single-sample spikes',
            ),
            value: prefs.medianFilter,
            onChanged: (val) {
              notifier.update((s) => s.copyWith(medianFilter: val));
            },
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: Text(l10n?.numMovingAverage ?? 'Moving Average Filter'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prefs.numMovingAverage} results',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: prefs.numMovingAverage.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: '${prefs.numMovingAverage}',
                  onChanged: (val) {
                    notifier.update(
                      (s) => s.copyWith(numMovingAverage: val.round()),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n?.pitchHistoryDuration ?? 'Pitch History Duration'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prefs.pitchHistoryDuration.toStringAsFixed(1)} seconds',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: prefs.pitchHistoryDuration,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  label: '${prefs.pitchHistoryDuration.toStringAsFixed(1)}s',
                  onChanged: (val) {
                    notifier.update(
                      (s) => s.copyWith(
                        pitchHistoryDuration: (val * 10).round() / 10.0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(
              l10n?.pitchHistoryNumFaultyValues ??
                  'Faulty Pitch Jump Threshold',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prefs.pitchHistoryNumFaultyValues} samples',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: prefs.pitchHistoryNumFaultyValues.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${prefs.pitchHistoryNumFaultyValues}',
                  onChanged: (val) {
                    notifier.update(
                      (s) =>
                          s.copyWith(pitchHistoryNumFaultyValues: val.round()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // ==================== 4. OTHERS ====================
          _SectionHeader(title: l10n?.others ?? 'Others'),
          ListTile(
            leading: Icon(Icons.restart_alt, color: theme.colorScheme.error),
            title: Text(
              l10n?.resetAllSettings ?? 'Reset All Settings',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Restore factory defaults for all options'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => ResetSettingsDialog(
                  onConfirm: () {
                    notifier.resetAllSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'All settings restored to factory defaults',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n?.about ?? 'About Tuner'),
            subtitle: const Text(
              'Version 1.0.0 • GPLv3 License & Gonville Font',
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => const AboutTunerDialog(),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
