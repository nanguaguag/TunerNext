import 'package:flutter/material.dart';

/// Category header for preference lists.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.preferences.Section`.
class PreferenceSection extends StatelessWidget {
  const PreferenceSection({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 6.0),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
