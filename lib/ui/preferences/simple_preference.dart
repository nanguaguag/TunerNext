import 'package:flutter/material.dart';

/// Clickable preference list tile with title, subtitle, and leading icon.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.preferences.SimplePreference`.
class SimplePreference extends StatelessWidget {
  const SimplePreference({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
