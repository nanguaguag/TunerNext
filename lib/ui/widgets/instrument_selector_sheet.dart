// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../domain/models/instrument.dart';

/// Modal bottom sheet allowing users to switch between predefined instruments.
class InstrumentSelectorSheet extends StatelessWidget {
  const InstrumentSelectorSheet({
    super.key,
    required this.selectedInstrument,
    required this.onSelect,
  });

  final Instrument selectedInstrument;
  final ValueChanged<Instrument> onSelect;

  static Future<void> show({
    required BuildContext context,
    required Instrument selectedInstrument,
    required ValueChanged<Instrument> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => InstrumentSelectorSheet(
        selectedInstrument: selectedInstrument,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instruments = PredefinedInstruments.getAll();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Select Instrument',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // Instrument List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: instruments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final inst = instruments[index];
                final isSelected = inst.stableId == selectedInstrument.stableId;

                final stringsText = inst.isChromatic
                    ? 'All notes (Chromatic Scale)'
                    : inst.strings.map((s) => s.name).join(' - ');

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      inst.isChromatic ? Icons.piano : Icons.music_note,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    inst.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  subtitle: Text(
                    stringsText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    onSelect(inst);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
