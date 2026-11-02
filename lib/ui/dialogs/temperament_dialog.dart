import 'package:flutter/material.dart';

import '../../domain/temperaments/predefined_temperament.dart';
import '../../domain/temperaments/temperament.dart';
import 'temperament_info_dialog.dart';

/// Interactive modal sheet/dialog for selecting from all 19 predefined and custom temperaments.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.temperaments.TemperamentDialog2`.
/// Features:
/// - Real-time filtering search bar.
/// - Full list of all 19 historical & modern European musical temperaments.
/// - Visual active checkmark indicator.
/// - Direct access to `TemperamentInfoDialog` for mathematical cents breakdown and circle of fifths.
class TemperamentDialog extends StatefulWidget {
  const TemperamentDialog({
    super.key,
    required this.selectedTemperament,
    this.customTemperaments = const [],
    required this.onSelectTemperament,
  });

  /// Currently active musical temperament.
  final Temperament selectedTemperament;

  /// Optional list of user-created or imported custom temperaments.
  final List<Temperament> customTemperaments;

  /// Callback when a temperament is selected.
  final ValueChanged<Temperament> onSelectTemperament;

  @override
  State<TemperamentDialog> createState() => _TemperamentDialogState();
}

class _TemperamentDialogState extends State<TemperamentDialog> {
  late final List<Temperament> _allTemperaments;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allTemperaments = [
      ...PredefinedTemperaments.getAll(
        rootNote: widget.selectedTemperament.rootNote,
      ),
      ...widget.customTemperaments,
    ];
  }

  List<Temperament> get _filteredTemperaments {
    if (_searchQuery.trim().isEmpty) {
      return _allTemperaments;
    }
    final q = _searchQuery.toLowerCase();
    return _allTemperaments.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.abbreviation.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filteredTemperaments;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.music_note),
                  const SizedBox(width: 8),
                  Text('Temperaments', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search 19 historical scales...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const Divider(height: 16),

            // List of Temperaments
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected =
                      item.name == widget.selectedTemperament.name;

                  return ListTile(
                    leading: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : const Icon(Icons.radio_button_unchecked),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      item.abbreviation.isNotEmpty
                          ? '${item.abbreviation} • ${item.description}'
                          : item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              TemperamentInfoDialog(temperament: item),
                        );
                      },
                    ),
                    onTap: () {
                      widget.onSelectTemperament(item);
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
