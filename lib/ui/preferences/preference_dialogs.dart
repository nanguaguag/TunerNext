import 'package:flutter/material.dart';

import '../../domain/models/dsp_enums.dart';
import '../../l10n/app_localizations.dart';

/// Modal dialog for selecting pitch detection algorithm.
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
    return SimpleDialog(
      title: const Text('Pitch Algorithm'),
      children: [
        _buildOption(
          context,
          algorithm: PitchAlgorithm.mpm,
          name: 'McLeod Pitch Method (MPM)',
          desc: 'High precision, robust octave-jump suppression for strings.',
        ),
        _buildOption(
          context,
          algorithm: PitchAlgorithm.twm,
          name: 'Two-Way Mismatch (TWM)',
          desc: 'Harmonic spectral matching for rich/inharmonic overtones.',
        ),
        _buildOption(
          context,
          algorithm: PitchAlgorithm.classic,
          name: 'Classic Autocorrelation',
          desc: 'FFT-based autocorrelation with parabolic peak fitting.',
        ),
        _buildOption(
          context,
          algorithm: PitchAlgorithm.hybridJacobsen,
          name: 'Hybrid Jacobsen',
          desc: 'Enhanced complex 3-bin phase vocoder interpolation.',
        ),
        _buildOption(
          context,
          algorithm: PitchAlgorithm.pyin,
          name: 'pYIN (Probabilistic)',
          desc: 'Viterbi path candidate tracking over time frames.',
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required PitchAlgorithm algorithm,
    required String name,
    required String desc,
  }) {
    final isSelected = algorithm == selectedAlgorithm;
    final theme = Theme.of(context);

    return ListTile(
      leading: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      onTap: () {
        onSelected(algorithm);
        Navigator.of(context).pop();
      },
    );
  }
}

/// Modal dialog for acoustic weighting curves (A, C, None).
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
    return SimpleDialog(
      title: const Text('Acoustic Weighting'),
      children: [
        _buildOption(
          context,
          mode: AcousticWeightingMode.none,
          name: 'Flat / None (Z-weighting)',
          desc: 'Unweighted flat frequency response.',
        ),
        _buildOption(
          context,
          mode: AcousticWeightingMode.aWeighting,
          name: 'A-Weighting (IEC 61672-1)',
          desc: 'Human ear equal-loudness curve; cuts sub-bass rumble.',
        ),
        _buildOption(
          context,
          mode: AcousticWeightingMode.cWeighting,
          name: 'C-Weighting',
          desc: 'Flatter curve retaining bass for high-SPL musical signals.',
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required AcousticWeightingMode mode,
    required String name,
    required String desc,
  }) {
    final isSelected = mode == selectedMode;
    final theme = Theme.of(context);

    return ListTile(
      leading: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      onTap: () {
        onSelected(mode);
        Navigator.of(context).pop();
      },
    );
  }
}

/// Modal dialog for FFT windowing functions.
class WindowingFunctionDialog extends StatelessWidget {
  const WindowingFunctionDialog({
    super.key,
    required this.selectedWindowing,
    required this.onSelected,
  });

  final WindowingFunction selectedWindowing;
  final ValueChanged<WindowingFunction> onSelected;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Windowing Function'),
      children: [
        _buildOption(
          context,
          func: WindowingFunction.hanning,
          name: 'Hann (Hanning)',
          desc: 'Smooth cosine taper with -31 dB side-lobe suppression.',
        ),
        _buildOption(
          context,
          func: WindowingFunction.hamming,
          name: 'Hamming',
          desc: 'Optimized cosine window with -42 dB first side lobe.',
        ),
        _buildOption(
          context,
          func: WindowingFunction.tophat,
          name: 'Top-hat (Rectangular)',
          desc: 'Narrowest main lobe, no edge tapering.',
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required WindowingFunction func,
    required String name,
    required String desc,
  }) {
    final isSelected = func == selectedWindowing;
    final theme = Theme.of(context);

    return ListTile(
      leading: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      onTap: () {
        onSelected(func);
        Navigator.of(context).pop();
      },
    );
  }
}

/// Modal dialog for selecting theme mode.
class AppearanceDialog extends StatelessWidget {
  const AppearanceDialog({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Appearance'),
      children: [
        _buildOption(
          context,
          mode: ThemeMode.system,
          name: 'System Default',
          icon: Icons.brightness_auto,
        ),
        _buildOption(
          context,
          mode: ThemeMode.light,
          name: 'Light',
          icon: Icons.light_mode,
        ),
        _buildOption(
          context,
          mode: ThemeMode.dark,
          name: 'Dark',
          icon: Icons.dark_mode,
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required ThemeMode mode,
    required String name,
    required IconData icon,
  }) {
    final isSelected = mode == selectedMode;
    final theme = Theme.of(context);

    return ListTile(
      leading: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : Icon(icon),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onSelected(mode);
        Navigator.of(context).pop();
      },
    );
  }
}

/// Modal dialog for selecting application language.
class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    super.key,
    required this.selectedLanguage,
    required this.onSelected,
  });

  final String? selectedLanguage;
  final ValueChanged<String?> onSelected;

  static const languages = [
    (null, 'System Default'),
    ('cs', 'Čeština (Czech)'),
    ('de', 'Deutsch (German)'),
    ('en', 'English'),
    ('es', 'Español (Spanish)'),
    ('fr', 'Français (French)'),
    ('hu', 'Magyar (Hungarian)'),
    ('it', 'Italiano (Italian)'),
    ('ja', '日本語 (Japanese)'),
    ('pl', 'Polski (Polish)'),
    ('pt', 'Português (Portuguese)'),
    ('ro', 'Română (Romanian)'),
    ('ru', 'Русский (Russian)'),
    ('sv', 'Svenska (Swedish)'),
    ('uk', 'Українська (Ukrainian)'),
    ('vi', 'Tiếng Việt (Vietnamese)'),
    ('zh', '简体中文 (Chinese)'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.language ?? 'Language'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final l = languages[index];
            final isSelected = l.$1 == selectedLanguage;

            return ListTile(
              leading: isSelected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : const Icon(Icons.radio_button_unchecked),
              title: Text(
                l.$2,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                onSelected(l.$1);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.abort ?? 'Cancel'),
        ),
      ],
    );
  }
}

/// Confirmation dialog for resetting all preferences.
class ResetSettingsDialog extends StatelessWidget {
  const ResetSettingsDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset All Settings?'),
      content: const Text(
        'This will restore all tuning, DSP, appearance, and audio capture parameters to their default factory values.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

/// About Tuner information dialog.
class AboutTunerDialog extends StatelessWidget {
  const AboutTunerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('About Tuner'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'High-Precision Acoustic Tuner',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Version 1.0.0\n'
            'Pure Dart Clean Architecture multi-engine acoustic pitch analyzer.\n\n'
            'Features 19 historical & modern temperaments, custom Railsback stretch tuning, '
            'scientific FFT spectrograms, and real-time autocorrelation analysis.',
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

/// Modal dialog for selecting musical notation and octave representation.
class NotationDialog extends StatefulWidget {
  const NotationDialog({
    super.key,
    required this.currentNotation,
    required this.currentOctaveNotation,
    required this.onConfirm,
  });

  final String currentNotation;
  final String currentOctaveNotation;
  final void Function(String notation, String octaveNotation) onConfirm;

  @override
  State<NotationDialog> createState() => _NotationDialogState();
}

class _NotationDialogState extends State<NotationDialog> {
  late String _notation;
  late String _octave;

  @override
  void initState() {
    super.initState();
    _notation = widget.currentNotation;
    _octave = widget.currentOctaveNotation;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    const notationOptions = [
      ('Standard (C D E)', 'Regional', 'C-D-E-…-B'),
      ('Solfège', 'Solfège', 'Do-Re-Mi-…-Si'),
      ('International', 'International', 'C-D-E-…-B'),
    ];

    const octaveOptions = [
      ('Scientific', 'Scientific', '… C¹ C² C³ C⁴ …'),
      ('Helmholtz', 'Helmholtz', '… C, C c c\' …'),
      ('Helmholtz Numbered', 'Helmholtz numbered', '… C₁ C c c¹ …'),
    ];

    return AlertDialog(
      title: Text(l10n?.notation ?? 'Notation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.notation ?? 'Notation',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ...notationOptions.map((opt) {
              final isSelected = _notation == opt.$1;
              return ListTile(
                leading: isSelected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : const Icon(Icons.radio_button_unchecked),
                title: Text(opt.$2),
                subtitle: Text(opt.$3, style: const TextStyle(fontSize: 12)),
                onTap: () => setState(() => _notation = opt.$1),
                contentPadding: EdgeInsets.zero,
              );
            }),
            const Divider(height: 24.0),
            Text(
              l10n?.octaveRepresentation ?? 'Octave representation',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ...octaveOptions.map((opt) {
              final isSelected = _octave == opt.$1;
              return ListTile(
                leading: isSelected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : const Icon(Icons.radio_button_unchecked),
                title: Text(opt.$2),
                subtitle: Text(opt.$3, style: const TextStyle(fontSize: 12)),
                onTap: () => setState(() => _octave = opt.$1),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.abort ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfirm(_notation, _octave);
            Navigator.of(context).pop();
          },
          child: Text(l10n?.done ?? 'Done'),
        ),
      ],
    );
  }
}
