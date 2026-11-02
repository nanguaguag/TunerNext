import 'package:flutter/material.dart';

import '../../domain/temperaments/chain_of_fifths_temperament.dart';
import '../../domain/temperaments/rational_temperament.dart';
import '../../domain/temperaments/temperament.dart';

/// Modal dialog showing mathematical and historical details of a musical temperament.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.temperaments.TemperamentDetailsDialog`.
class TemperamentInfoDialog extends StatelessWidget {
  const TemperamentInfoDialog({super.key, required this.temperament});

  final Temperament temperament;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intervals = temperament.cents;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              temperament.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Abbreviation & Root
              Row(
                children: [
                  Chip(
                    label: Text(temperament.abbreviation),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Root: ${temperament.rootNote.name}'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (temperament.description.isNotEmpty) ...[
                Text(
                  temperament.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],

              // Chain of fifths details if applicable
              if (temperament is ChainOfFifthsTemperament) ...[
                Text(
                  'Circle of Fifths Modifications',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Syntonic / Pythagorean comma fraction modifications across 12 fifths.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Rational intervals if applicable
              if (temperament is RationalTemperament) ...[
                Text(
                  'Harmonic Frequency Ratios',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (temperament as RationalTemperament).rationalNumbers
                      .map(
                        (r) => Chip(
                          label: Text(
                            '${r.numerator}/${r.denominator}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Scale Cents Table
              Text(
                'Scale Degree Intervals (Cents)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                  borderRadius: BorderRadius.circular(4),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'Degree',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'Cents',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (int i = 0; i < intervals.length; i++)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            '$i',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            intervals[i].toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
