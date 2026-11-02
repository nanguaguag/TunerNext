import 'package:flutter/material.dart';

/// Preference list tile with a toggle switch.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.preferences.SwitchPreference`.
class SwitchPreference extends StatelessWidget {
  const SwitchPreference({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
