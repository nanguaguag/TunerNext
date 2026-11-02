import 'package:flutter/material.dart';

/// Single row in the temperament editor table representing a pitch step.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.temperaments.TemperamentTableLine`.
class TemperamentTableLine extends StatelessWidget {
  const TemperamentTableLine({
    super.key,
    required this.index,
    required this.noteName,
    required this.cents,
    this.isOctaveLine = false,
    this.errorMessage,
    required this.onCentsChanged,
    this.onNoteNameChanged,
  });

  final int index;
  final String noteName;
  final double cents;
  final bool isOctaveLine;
  final String? errorMessage;
  final ValueChanged<double> onCentsChanged;
  final ValueChanged<String>? onNoteNameChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorMessage != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: hasError
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.25)
            : (isOctaveLine
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    )
                  : Colors.transparent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          // Index Badge
          SizedBox(
            width: 32.0,
            child: Text(
              '$index',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Note Name
          Expanded(
            flex: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(4.0),
              onTap: onNoteNameChanged != null
                  ? () => _editNoteName(context)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 6.0,
                ),
                child: Row(
                  children: [
                    Text(
                      noteName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onNoteNameChanged != null) ...[
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.edit_outlined,
                        size: 14.0,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Cents Input
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (index == 0)
                  Text(
                    '0.00 ¢',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  )
                else
                  TextFormField(
                    initialValue: cents.toStringAsFixed(2),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      suffixText: ' ¢',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.trim());
                      if (parsed != null) {
                        onCentsChanged(parsed);
                      }
                    },
                  ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editNoteName(BuildContext context) {
    final controller = TextEditingController(text: noteName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Note #$index Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Note name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onNoteNameChanged?.call(text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
