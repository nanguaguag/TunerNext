// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../domain/models/dsp_enums.dart';
import '../../domain/preferences/preferences_models.dart';

/// Modal dialog for choosing application language across 16 supported locales.
class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    super.key,
    required this.selectedLocaleCode,
    required this.onLocaleSelected,
  });

  final String? selectedLocaleCode;
  final ValueChanged<String?> onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.language),
          SizedBox(width: 8),
          Text('Select Language'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: LanguageOption.supportedLanguages.length,
          itemBuilder: (context, index) {
            final opt = LanguageOption.supportedLanguages[index];
            final isSelected =
                (opt.locale == null && selectedLocaleCode == null) ||
                (opt.locale?.languageCode == selectedLocaleCode);

            return RadioListTile<String?>(
              value: opt.locale?.languageCode,
              groupValue: selectedLocaleCode,
              title: Text(opt.name),
              subtitle: Text(
                opt.nativeName,
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onChanged: (code) {
                onLocaleSelected(code);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Modal dialog for visual theme mode.
class AppearanceDialog extends StatelessWidget {
  const AppearanceDialog({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final AppThemeMode selectedMode;
  final ValueChanged<AppThemeMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.brightness_medium),
          SizedBox(width: 8),
          Text('Appearance'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((mode) {
          return RadioListTile<AppThemeMode>(
            value: mode,
            groupValue: selectedMode,
            title: Text(mode.displayName),
            onChanged: (m) {
              if (m != null) {
                onModeSelected(m);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Modal dialog for calibrating reference frequency (e.g. A4 = 440 Hz).
class ReferenceFrequencyDialog extends StatefulWidget {
  const ReferenceFrequencyDialog({
    super.key,
    required this.currentFrequency,
    required this.onFrequencyConfirmed,
  });

  final double currentFrequency;
  final ValueChanged<double> onFrequencyConfirmed;

  @override
  State<ReferenceFrequencyDialog> createState() =>
      _ReferenceFrequencyDialogState();
}

class _ReferenceFrequencyDialogState extends State<ReferenceFrequencyDialog> {
  late double _freq;

  @override
  void initState() {
    super.initState();
    _freq = widget.currentFrequency;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.graphic_eq),
          SizedBox(width: 8),
          Text('Reference Pitch'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_freq.toStringAsFixed(1)} Hz',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: '-1 Hz',
                onPressed: () =>
                    setState(() => _freq = (_freq - 1.0).clamp(400.0, 480.0)),
                icon: const Text('-1'),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: '-0.1 Hz',
                onPressed: () =>
                    setState(() => _freq = (_freq - 0.1).clamp(400.0, 480.0)),
                icon: const Text('-0.1'),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: '+0.1 Hz',
                onPressed: () =>
                    setState(() => _freq = (_freq + 0.1).clamp(400.0, 480.0)),
                icon: const Text('+0.1'),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: '+1 Hz',
                onPressed: () =>
                    setState(() => _freq = (_freq + 1.0).clamp(400.0, 480.0)),
                icon: const Text('+1'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _freq = 440.0),
            child: const Text('Reset to Standard A4 = 440.0 Hz'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onFrequencyConfirmed(_freq);
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

/// Modal dialog for notation convention options.
class NotationDialog extends StatelessWidget {
  const NotationDialog({
    super.key,
    required this.currentNotation,
    required this.currentOctave,
    required this.onNotationSelected,
    required this.onOctaveSelected,
  });

  final NotationType currentNotation;
  final OctaveNotation currentOctave;
  final ValueChanged<NotationType> onNotationSelected;
  final ValueChanged<OctaveNotation> onOctaveSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Musical Notation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pitch Class Naming',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...NotationType.values.map(
              (not) => RadioListTile<NotationType>(
                value: not,
                groupValue: currentNotation,
                title: Text(not.displayName),
                onChanged: (n) {
                  if (n != null) onNotationSelected(n);
                },
              ),
            ),
            const Divider(),
            Text(
              'Octave Numbering',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...OctaveNotation.values.map(
              (oct) => RadioListTile<OctaveNotation>(
                value: oct,
                groupValue: currentOctave,
                title: Text(oct.displayName),
                onChanged: (o) {
                  if (o != null) onOctaveSelected(o);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// Modal dialog for choosing Pitch Detection Algorithm.
class PitchAlgorithmDialog extends StatelessWidget {
  const PitchAlgorithmDialog({
    super.key,
    required this.selectedAlgorithm,
    required this.onSelected,
  });

  final PitchAlgorithm selectedAlgorithm;
  final ValueChanged<PitchAlgorithm> onSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pitch Detection Algorithm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: PitchAlgorithm.values.map((algo) {
          return RadioListTile<PitchAlgorithm>(
            value: algo,
            groupValue: selectedAlgorithm,
            title: Text(algo.displayName),
            onChanged: (a) {
              if (a != null) {
                onSelected(a);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Modal dialog for Acoustic Weighting mode.
class AcousticWeightingDialog extends StatelessWidget {
  const AcousticWeightingDialog({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final AcousticWeightingMode selectedMode;
  final ValueChanged<AcousticWeightingMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Acoustic Weighting Filter'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AcousticWeightingMode.values.map((mode) {
            return RadioListTile<AcousticWeightingMode>(
              value: mode,
              groupValue: selectedMode,
              title: Text(mode.displayName),
              onChanged: (m) {
                if (m != null) {
                  onSelected(m);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Modal dialog for FFT Windowing function.
class WindowingFunctionDialog extends StatelessWidget {
  const WindowingFunctionDialog({
    super.key,
    required this.selectedFunction,
    required this.onSelected,
  });

  final WindowingFunction selectedFunction;
  final ValueChanged<WindowingFunction> onSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('FFT Window Function'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: WindowingFunction.values.map((fn) {
          return RadioListTile<WindowingFunction>(
            value: fn,
            groupValue: selectedFunction,
            title: Text(fn.displayName),
            onChanged: (f) {
              if (f != null) {
                onSelected(f);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Confirmation dialog for factory resetting all settings.
class ResetSettingsDialog extends StatelessWidget {
  const ResetSettingsDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset All Settings?'),
      content: const Text(
        'This will restore all tuning tolerances, algorithms, display preferences, and DSP settings back to default factory values.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Reset All'),
        ),
      ],
    );
  }
}

/// About dialog presenting licenses, version, and repository information.
class AboutTunerDialog extends StatelessWidget {
  const AboutTunerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [Icon(Icons.tune), SizedBox(width: 8), Text('About Tuner')],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuner Flutter 1.0.0',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'High-precision chromatic and acoustic instrument tuner featuring progressive clean architecture, real-time DSP pitch detection (Classic, Jacobsen, MPM, TWM, pYIN), and Simon Tatham\'s Gonville vector musical staff.',
          ),
          SizedBox(height: 10),
          Text(
            'License: GNU General Public License v3.0 (GPLv3)',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 4),
          Text(
            'Music Glyphs: Gonville Font © 2009 Simon Tatham',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
