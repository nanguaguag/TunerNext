import 'package:flutter/material.dart';

import '../../domain/stretch_tuning/stretch_tuning.dart';

/// Data table displaying the control points of a stretch tuning curve.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.stretchtuning.StretchTuningTable`.
class StretchTuningTable extends StatelessWidget {
  const StretchTuningTable({
    super.key,
    required this.stretchTuning,
    this.selectedKey = StretchTuning.noKey,
    this.onLineClicked,
    this.onEditLineClicked,
    this.onDeleteLineClicked,
    this.showOverflowMenu = true,
  });

  final StretchTuning stretchTuning;
  final int selectedKey;
  final ValueChanged<int>? onLineClicked;
  final ValueChanged<int>? onEditLineClicked;
  final ValueChanged<int>? onDeleteLineClicked;
  final bool showOverflowMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Frequency',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Stretch',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showOverflowMenu)
                const SizedBox(
                  width: 96.0,
                  child: Text(
                    'Actions',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        // Table Body
        Expanded(
          child: stretchTuning.isEmpty
              ? Center(
                  child: Text(
                    'No stretch points defined.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: stretchTuning.size,
                  itemBuilder: (context, index) {
                    final key = stretchTuning.keys[index];
                    final f = stretchTuning.unstretchedFrequencies[index];
                    final s = stretchTuning.stretchInCents[index];
                    final isSelected = key == selectedKey;

                    // Check non-monotonic warning
                    final isNonMonotonic =
                        index > 0 &&
                        stretchTuning.stretchedFrequencies[index] <=
                            stretchTuning.stretchedFrequencies[index - 1];

                    return Material(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.4,
                            )
                          : (isNonMonotonic
                                ? theme.colorScheme.errorContainer.withValues(
                                    alpha: 0.2,
                                  )
                                : Colors.transparent),
                      borderRadius: BorderRadius.circular(6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6.0),
                        onTap: () => onLineClicked?.call(key),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${f.toStringAsFixed(2)} Hz',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                    if (isNonMonotonic)
                                      Text(
                                        'Must be > previous',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                              fontSize: 10,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  s >= 0
                                      ? '+${s.toStringAsFixed(2)} ¢'
                                      : '${s.toStringAsFixed(2)} ¢',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: s > 0
                                        ? theme.colorScheme.primary
                                        : (s < 0
                                              ? theme.colorScheme.secondary
                                              : null),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (showOverflowMenu)
                                SizedBox(
                                  width: 96.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 20.0,
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Edit',
                                        onPressed: () =>
                                            onEditLineClicked?.call(key),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 20.0,
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Delete',
                                        onPressed: () =>
                                            onDeleteLineClicked?.call(key),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
