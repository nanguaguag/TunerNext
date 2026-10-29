// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';
import '../../domain/models/instrument.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';

/// Interactive sidebar displaying instrument strings with physical thickness
/// gradients, note indicators, and manual string lock toggling.
class StringsSidebar extends StatelessWidget {
  const StringsSidebar({
    super.key,
    required this.instrument,
    required this.targetNote,
    required this.tuningState,
    this.lockedNote,
    required this.onStringTapped,
  });

  final Instrument instrument;
  final MusicalNote? targetNote;
  final TuningState tuningState;
  final MusicalNote? lockedNote;
  final ValueChanged<MusicalNote> onStringTapped;

  @override
  Widget build(BuildContext context) {
    if (instrument.isChromatic || instrument.strings.isEmpty) {
      return const SizedBox.shrink();
    }

    final strings = instrument.stringsHighToLow;
    final totalStrings = strings.length;

    return Container(
      width: 72.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < totalStrings; i++)
            Expanded(
              child: _StringRow(
                note: strings[i],
                // Physical gauge: index 0 (highest pitch) has min thickness,
                // index total-1 (lowest pitch) has max thickness.
                thickness: _computeThickness(i, totalStrings),
                isTarget: targetNote != null && targetNote!.matches(strings[i]),
                isLocked: lockedNote != null && lockedNote!.matches(strings[i]),
                tuningState: tuningState,
                onTap: () => onStringTapped(strings[i]),
              ),
            ),
        ],
      ),
    );
  }

  double _computeThickness(int indexFromHigh, int total) {
    if (total <= 1) return 2.5;
    const minThickness = 1.5;
    const maxThickness = 5.0;
    final progress = indexFromHigh / (total - 1);
    return minThickness + (maxThickness - minThickness) * progress;
  }
}

class _StringRow extends StatelessWidget {
  const _StringRow({
    required this.note,
    required this.thickness,
    required this.isTarget,
    required this.isLocked,
    required this.tuningState,
    required this.onTap,
  });

  final MusicalNote note;
  final double thickness;
  final bool isTarget;
  final bool isLocked;
  final TuningState tuningState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tunerColors = context.tunerColors;

    final targetHighlightColor = switch (tuningState) {
      TuningState.inTune => tunerColors.inTune,
      TuningState.tooLow || TuningState.tooHigh => tunerColors.outOfTune,
      TuningState.unknown => theme.colorScheme.primary,
    };

    final stringLineColor = isTarget
        ? targetHighlightColor
        : theme.colorScheme.outline.withValues(alpha: 0.45);

    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Horizontal physical string wire line
          Positioned.fill(
            child: Center(
              child: Container(height: thickness, color: stringLineColor),
            ),
          ),

          // 2. Center Note badge pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: isTarget
                  ? (isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surface)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.7,
                    ),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isTarget
                    ? targetHighlightColor
                    : theme.colorScheme.outlineVariant,
                width: isTarget ? 2.0 : 1.0,
              ),
              boxShadow: isTarget
                  ? [
                      BoxShadow(
                        color: targetHighlightColor.withValues(alpha: 0.25),
                        blurRadius: 6.0,
                        spreadRadius: 1.0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked) ...[
                  Icon(
                    Icons.lock,
                    size: 11.0,
                    color: isTarget
                        ? targetHighlightColor
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 3.0),
                ],
                Text(
                  note.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isTarget ? FontWeight.bold : FontWeight.w600,
                    color: isTarget
                        ? targetHighlightColor
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
