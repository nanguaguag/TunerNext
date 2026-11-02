import 'package:flutter/material.dart';

import '../../domain/models/dsp_enums.dart';

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
    ('en', 'English'),
    ('zh', '中文 (Chinese)'),
    ('de', 'Deutsch (German)'),
    ('fr', 'Français (French)'),
    ('es', 'Español (Spanish)'),
    ('it', 'Italiano (Italian)'),
    ('ja', '日本語 (Japanese)'),
    ('ru', 'Русский (Russian)'),
    ('pt', 'Português (Portuguese)'),
  ];

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Language'),
      children: languages.map((l) {
        final isSelected = l.$1 == selectedLanguage;
        final theme = Theme.of(context);

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
      }).toList(),
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
