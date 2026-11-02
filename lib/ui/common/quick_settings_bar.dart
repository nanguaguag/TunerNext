import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import 'notation_icons.dart';

/// Bottom acoustic settings bar for instantaneous parameter adjustments.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.misc.QuickSettingsBar`.
/// Displays:
/// 1. Reference note and frequency in Hz (e.g., "A4" and "440.0 Hz").
/// 2. Active temperament abbreviation/name (e.g., "EDO 12", "Werck. III").
/// 3. Prefer sharp (#) vs flat (b) toggle icon with 1:1 original Android vector art.
/// 4. Optional active stretch tuning curve name (e.g., "Piano").
class QuickSettingsBar extends StatelessWidget {
  const QuickSettingsBar({
    super.key,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.referenceFrequency = 440.0,
    this.temperamentName = 'EDO 12',
    this.preferFlat = false,
    this.stretchTuningName,
    this.onSharpFlatClicked,
    this.onTemperamentClicked,
    this.onReferenceNoteClicked,
    this.onStretchTuningClicked,
  });

  /// Reference musical note (default A4).
  final MusicalNote referenceNote;

  /// Reference frequency in Hertz (default 440.0 Hz).
  final double referenceFrequency;

  /// Display name or abbreviation of the current musical temperament.
  final String temperamentName;

  /// Whether flat accidentals (b) are preferred over sharp (#).
  final bool preferFlat;

  /// Name of active stretch tuning, or null if stretch tuning is disabled.
  final String? stretchTuningName;

  /// Callback when the sharp/flat toggle button is pressed.
  final VoidCallback? onSharpFlatClicked;

  /// Callback when the temperament cell is tapped.
  final VoidCallback? onTemperamentClicked;

  /// Callback when the reference note/frequency cell is tapped.
  final VoidCallback? onReferenceNoteClicked;

  /// Callback when the stretch tuning cell is tapped.
  final VoidCallback? onStretchTuningClicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ) ??
        TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant);

    return BottomAppBar(
      color: colorScheme.surface,
      elevation: 2.0,
      padding: EdgeInsets.zero,
      height: 64.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Reference note and frequency cell
          Expanded(
            child: InkWell(
              onTap: onReferenceNoteClicked,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    referenceNote.name,
                    style: textStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${referenceFrequency.toStringAsFixed(1)} Hz',
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),

          // 2. Temperament name / abbreviation cell
          Expanded(
            child: InkWell(
              onTap: onTemperamentClicked,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    temperamentName.isNotEmpty ? temperamentName : '-',
                    textAlign: TextAlign.center,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),

          // 3. Prefer sharp vs flat toggle cell
          Expanded(
            child: InkWell(
              onTap: onSharpFlatClicked,
              child: Center(
                child: PreferFlatIconWidget(
                  preferFlat: preferFlat,
                  size: 24.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // 4. Stretch tuning cell (if stretch tuning active)
          if (stretchTuningName != null && stretchTuningName!.isNotEmpty)
            Expanded(
              child: InkWell(
                onTap: onStretchTuningClicked,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      stretchTuningName!,
                      textAlign: TextAlign.center,
                      style: textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
