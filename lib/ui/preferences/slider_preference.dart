import 'package:flutter/material.dart';

/// Preference item offering continuous or stepped numerical adjustment via slider.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.preferences.SliderPreference`.
class SliderPreference extends StatelessWidget {
  const SliderPreference({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.valueLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 16.0),
              ],
              Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
              if (valueLabel != null)
                Text(
                  valueLabel!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(
                left: icon != null ? 40.0 : 0.0,
                top: 2.0,
              ),
              child: Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: icon != null ? 24.0 : 0.0),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
