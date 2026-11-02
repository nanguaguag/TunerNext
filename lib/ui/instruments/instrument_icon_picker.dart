import 'package:flutter/material.dart';

import '../../domain/instruments/instrument_icon.dart';
import 'instrument_icons.dart';

/// Modal dialog for choosing from all 15 instrument vector icons.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.instruments.InstrumentIconPicker`.
class InstrumentIconPicker extends StatelessWidget {
  const InstrumentIconPicker({
    super.key,
    required this.onIconSelected,
    this.selectedIcon,
  });

  final ValueChanged<InstrumentIcon> onIconSelected;
  final InstrumentIcon? selectedIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icons = InstrumentIcon.values;

    return AlertDialog(
      title: const Text('Pick Icon'),
      content: SizedBox(
        width: 320,
        height: 320,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final icon = icons[index];
            final isSelected = icon == selectedIcon;

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                onIconSelected(icon);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(8.0),
                child: InstrumentIconWidget(
                  icon: icon,
                  size: 36,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
