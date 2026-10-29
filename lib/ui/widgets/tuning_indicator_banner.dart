// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../domain/tuning/tuning_target_computer.dart';

/// Top header banner displaying target note, cent deviation meter,
/// measured frequency, and dynamic tuning status cues.
class TuningIndicatorBanner extends StatelessWidget {
  const TuningIndicatorBanner({
    super.key,
    required this.evaluation,
    this.lockedNote,
    required this.onToggleLock,
    required this.onSelectInstrument,
    required this.currentInstrumentName,
  });

  final TuningEvaluation? evaluation;
  final MusicalNote? lockedNote;
  final VoidCallback onToggleLock;
  final VoidCallback onSelectInstrument;
  final String currentInstrumentName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tunerColors = context.tunerColors;

    final eval = evaluation;
    final state = eval?.state ?? TuningState.unknown;
    final targetNote =
        eval?.target.note ?? const MusicalNote(base: BaseNote.a, octave: 4);
    final measuredFreq = eval?.measuredFrequency ?? 0.0;
    final targetFreq = eval?.target.frequency ?? 440.0;
    final devCents = eval?.deviationCents ?? 0.0;
    final isLocked = lockedNote != null;

    final statusColor = switch (state) {
      TuningState.inTune => tunerColors.inTune,
      TuningState.tooLow || TuningState.tooHigh => tunerColors.outOfTune,
      TuningState.unknown => theme.colorScheme.outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Instrument selector & Lock button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Instrument button
              InkWell(
                onTap: onSelectInstrument,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 16.0,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        currentInstrumentName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(Icons.arrow_drop_down, size: 18.0),
                    ],
                  ),
                ),
              ),

              // Lock button
              IconButton.filledTonal(
                onPressed: onToggleLock,
                icon: Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  size: 18.0,
                  color: isLocked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                tooltip: isLocked
                    ? 'Unlock auto target'
                    : 'Lock current target',
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Main Tuning Readout Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large Note Badge
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2.5),
                  boxShadow: state == TuningState.inTune
                      ? [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.3),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  targetNote.name,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),

              const SizedBox(width: 16.0),

              // Cent Meter & Frequency Readouts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Pill & Cent deviation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(state, statusColor, theme),
                        Text(
                          state == TuningState.unknown
                              ? '-- ct'
                              : '${devCents >= 0 ? '+' : ''}${devCents.toStringAsFixed(1)} ct',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),

                    // Cent Deviation Gauge Bar (-50 cents to +50 cents)
                    _CentMeterBar(
                      deviationCents: devCents,
                      state: state,
                      statusColor: statusColor,
                    ),

                    const SizedBox(height: 6.0),

                    // Frequency Readout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          measuredFreq > 0.0
                              ? '${measuredFreq.toStringAsFixed(1)} Hz'
                              : '0.0 Hz',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Target: ${targetFreq.toStringAsFixed(1)} Hz',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TuningState state, Color color, ThemeData theme) {
    final (icon, text) = switch (state) {
      TuningState.inTune => (Icons.check_circle, 'IN TUNE'),
      TuningState.tooLow => (Icons.arrow_upward, 'TOO LOW'),
      TuningState.tooHigh => (Icons.arrow_downward, 'TOO HIGH'),
      TuningState.unknown => (Icons.mic_none, 'LISTENING...'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.0, color: color),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _CentMeterBar extends StatelessWidget {
  const _CentMeterBar({
    required this.deviationCents,
    required this.state,
    required this.statusColor,
  });

  final double deviationCents;
  final TuningState state;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Clamp deviation to [-50, +50] cents
    final clampedCents = deviationCents.clamp(-50.0, 50.0);
    // Normalized position in [0.0, 1.0]
    final progress = (clampedCents + 50.0) / 100.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final needleX = (width * progress).clamp(0.0, width);
        final centerX = width * 0.5;

        return SizedBox(
          height: 18.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Background Track
              Container(
                height: 6.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),

              // 2. Tolerance Zone (-5 cents to +5 cents)
              Positioned(
                left: centerX - (width * 0.05),
                width: width * 0.10,
                child: Container(
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: context.tunerColors.inTune.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),

              // 3. Center Zero Marker
              Positioned(
                left: centerX - 1.0,
                child: Container(
                  width: 2.0,
                  height: 12.0,
                  color: theme.colorScheme.outline,
                ),
              ),

              // 4. Moving Deviation Needle Indicator
              if (state != TuningState.unknown)
                Positioned(
                  left: (needleX - 4.0).clamp(0.0, width - 8.0),
                  child: Container(
                    width: 8.0,
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
