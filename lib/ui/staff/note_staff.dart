// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import 'note_staff_painter.dart';
import 'staff_models.dart';

/// Interactive five-line musical staff widget displaying the target note,
/// Gonville clefs, key signatures, and accidentals.
class NoteStaff extends StatelessWidget {
  const NoteStaff({
    super.key,
    required this.note,
    this.tuningState = TuningState.unknown,
    this.staffClef = StaffClef.grand,
    this.onStaffClefChanged,
    this.keySignature = 0,
    this.onKeySignatureChanged,
    this.onTap,
  });

  final MusicalNote? note;
  final TuningState tuningState;
  final StaffClef staffClef;
  final ValueChanged<StaffClef>? onStaffClefChanged;
  final int keySignature;
  final ValueChanged<int>? onKeySignatureChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = context.tunerColors;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: NoteStaffPainter(
              note: note,
              tuningState: tuningState,
              staffClef: staffClef,
              keySignature: keySignature,
              staffColor: theme.colorScheme.onSurface,
              inTuneColor: tunerColors.inTune,
              outOfTuneColor: tunerColors.outOfTune,
              unknownTuningColor: theme.colorScheme.primary,
              borderColor: theme.colorScheme.outlineVariant,
            ),
          ),

          // Top right: Key signature control buttons
          if (onKeySignatureChanged != null)
            Positioned(
              top: 6,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _KeySignatureButton(
                    symbol: '♭',
                    tooltip: 'Add flat / remove sharp',
                    enabled: keySignature > -maxKeySignature,
                    onPressed: () => onKeySignatureChanged!(keySignature - 1),
                  ),
                  const SizedBox(width: 4),
                  _KeySignatureButton(
                    symbol: '♯',
                    tooltip: 'Add sharp / remove flat',
                    enabled: keySignature < maxKeySignature,
                    onPressed: () => onKeySignatureChanged!(keySignature + 1),
                  ),
                ],
              ),
            ),

          // Bottom right: Clef selector popup menu
          if (onStaffClefChanged != null)
            Positioned(
              bottom: 6,
              right: 6,
              child: _ClefSelectorButton(
                currentClef: staffClef,
                onSelected: onStaffClefChanged!,
              ),
            ),
        ],
      ),
    );
  }
}

class _KeySignatureButton extends StatelessWidget {
  const _KeySignatureButton({
    required this.symbol,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final String symbol;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton.filledTonal(
        padding: EdgeInsets.zero,
        iconSize: 18,
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.38,
                ),
        ),
        icon: Text(
          symbol,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: enabled
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}

class _ClefSelectorButton extends StatelessWidget {
  const _ClefSelectorButton({
    required this.currentClef,
    required this.onSelected,
  });

  final StaffClef currentClef;
  final ValueChanged<StaffClef> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<StaffClef>(
      initialValue: currentClef,
      tooltip: 'Select clef',
      onSelected: onSelected,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_note,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              currentClef.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => StaffClef.values.map((clef) {
        return PopupMenuItem<StaffClef>(
          value: clef,
          child: Row(
            children: [
              Icon(
                clef == currentClef
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: clef == currentClef
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(clef.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }
}
