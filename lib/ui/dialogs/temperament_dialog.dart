import 'package:flutter/material.dart';

import '../../domain/temperaments/predefined_temperament.dart';
import '../../domain/temperaments/temperament.dart';
import '../../l10n/app_localizations.dart';
import 'temperament_info_dialog.dart';

/// Interactive modal dialog for selecting from all predefined (EDO 5-72 and 18 historical) and custom temperaments.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.temperaments.TemperamentDialog2`.
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
  late final Temperament _edo12;
  late final List<Temperament> _edoTemperaments;
  late final List<Temperament> _historicalTemperaments;
  late final List<Temperament> _customTemperaments;
  String _searchQuery = '';
  bool _edoExpanded = false;
  bool _historicalExpanded = true;
  bool _customExpanded = true;

  @override
  void initState() {
    super.initState();
    final root = widget.selectedTemperament.rootNote;
    _edo12 = PredefinedTemperaments.edo12(rootNote: root);
    _edoTemperaments = PredefinedTemperaments.getEdoTemperaments(
      rootNote: root,
    ).where((t) => t.equalOctaveDivision != 12).toList();
    _historicalTemperaments = PredefinedTemperaments.getHistoricalTemperaments(
      rootNote: root,
    );
    _customTemperaments = widget.customTemperaments;
  }

  bool _matches(Temperament t, String query) {
    if (query.isEmpty) return true;
    return t.name.toLowerCase().contains(query) ||
        t.abbreviation.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query);
  }

  List<Temperament> _filter(List<Temperament> list, String query) {
    if (query.isEmpty) return list;
    return list.where((t) => _matches(t, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final q = _searchQuery.trim().toLowerCase();

    final filteredEdo = _filter(_edoTemperaments, q);
    final filteredHistorical = _filter(_historicalTemperaments, q);
    final filteredCustom = _filter(_customTemperaments, q);

    final isSearching = q.isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.music_note),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.temperaments ?? 'Temperaments',
                    style: theme.textTheme.titleLarge,
                  ),
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
                  hintText:
                      l10n?.searchTemperamentsHint ??
                      'Search temperaments (e.g. 19-EDO, Pure)...',
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

            // Categorized List
            Expanded(
              child: ListView(
                children: [
                  if (_matches(_edo12, q)) ...[
                    _buildItem(context, _edo12),
                    const Divider(height: 1),
                  ],
                  if (_customTemperaments.isNotEmpty)
                    _buildSection(
                      context,
                      title: l10n?.customTemperaments ?? 'Custom Temperaments',
                      items: filteredCustom,
                      isExpanded: _customExpanded,
                      isSearching: isSearching,
                      onToggle: () =>
                          setState(() => _customExpanded = !_customExpanded),
                    ),
                  _buildSection(
                    context,
                    title: l10n?.otherTemperaments ?? 'Historical Temperaments',
                    items: filteredHistorical,
                    isExpanded: _historicalExpanded,
                    isSearching: isSearching,
                    onToggle: () => setState(
                      () => _historicalExpanded = !_historicalExpanded,
                    ),
                  ),
                  _buildSection(
                    context,
                    title:
                        l10n?.edoTemperaments ??
                        'Equal Temperaments (5 - 72 EDO)',
                    items: filteredEdo,
                    isExpanded: _edoExpanded,
                    isSearching: isSearching,
                    onToggle: () =>
                        setState(() => _edoExpanded = !_edoExpanded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Temperament> items,
    required bool isExpanded,
    required bool isSearching,
    required VoidCallback onToggle,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: isSearching ? null : onToggle,
          child: Container(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$title (${items.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isSearching)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
        if (isExpanded || isSearching)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildItem(context, items[index]),
          ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, Temperament item) {
    final theme = Theme.of(context);
    final isSelected = item.name == widget.selectedTemperament.name;

    return ListTile(
      leading: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          showDialog<void>(
            context: context,
            builder: (_) => TemperamentInfoDialog(temperament: item),
          );
        },
      ),
      onTap: () {
        widget.onSelectTemperament(item);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }
}
