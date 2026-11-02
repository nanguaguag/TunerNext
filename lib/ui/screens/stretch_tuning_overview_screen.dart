import 'package:flutter/material.dart';

import '../../domain/stretch_tuning/predefined_stretch_tunings.dart';
import '../../domain/stretch_tuning/stretch_tuning.dart';
import 'stretch_tuning_editor_screen.dart';

/// Screen listing available stretch tunings (Predefined and Custom) with selection and editing.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.screens.StretchTuningOverview`.
class StretchTuningOverviewScreen extends StatefulWidget {
  const StretchTuningOverviewScreen({
    super.key,
    this.selectedStretchTuningId,
    this.customStretchTunings = const [],
    this.onSelectStretchTuning,
    this.onCustomStretchTuningsChanged,
  });

  final int? selectedStretchTuningId;
  final List<StretchTuning> customStretchTunings;
  final ValueChanged<StretchTuning>? onSelectStretchTuning;
  final ValueChanged<List<StretchTuning>>? onCustomStretchTuningsChanged;

  @override
  State<StretchTuningOverviewScreen> createState() =>
      _StretchTuningOverviewScreenState();
}

class _StretchTuningOverviewScreenState
    extends State<StretchTuningOverviewScreen> {
  late List<StretchTuning> _customTunings;
  int? _selectedId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _customTunings = List<StretchTuning>.from(widget.customStretchTunings);
    _selectedId =
        widget.selectedStretchTuningId ?? PredefinedStretchTunings.idNoStretch;
  }

  List<StretchTuning> get _predefinedTunings => [
    PredefinedStretchTunings.noStretch(),
    PredefinedStretchTunings.railsback(),
  ];

  void _onAddNew() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StretchTuningEditorScreen(
          initialStretchTuning: StretchTuning(
            name: 'New Stretch Tuning',
            description: '',
            unstretchedFrequencies: [110.0, 220.0, 440.0, 880.0, 1760.0],
            stretchInCents: [-5.0, -2.0, 0.0, 3.0, 8.0],
            stableId: DateTime.now().millisecondsSinceEpoch,
          ),
          onSave: (newTuning) {
            setState(() {
              _customTunings.add(newTuning);
              _selectedId = newTuning.stableId;
            });
            widget.onCustomStretchTuningsChanged?.call(_customTunings);
            widget.onSelectStretchTuning?.call(newTuning);
          },
        ),
      ),
    );
  }

  void _onEdit(StretchTuning tuning) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StretchTuningEditorScreen(
          initialStretchTuning: tuning,
          onSave: (updated) {
            setState(() {
              final idx = _customTunings.indexWhere(
                (t) => t.stableId == tuning.stableId,
              );
              if (idx >= 0) {
                _customTunings[idx] = updated;
              }
              if (_selectedId == tuning.stableId) {
                _selectedId = updated.stableId;
              }
            });
            widget.onCustomStretchTuningsChanged?.call(_customTunings);
            if (_selectedId == updated.stableId) {
              widget.onSelectStretchTuning?.call(updated);
            }
          },
        ),
      ),
    );
  }

  void _onDelete(StretchTuning tuning) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Stretch Tuning'),
        content: Text('Are you sure you want to delete "${tuning.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _customTunings.removeWhere(
                  (t) => t.stableId == tuning.stableId,
                );
                if (_selectedId == tuning.stableId) {
                  _selectedId = PredefinedStretchTunings.idNoStretch;
                }
              });
              widget.onCustomStretchTuningsChanged?.call(_customTunings);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredPredefined = _predefinedTunings.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final filteredCustom = _customTunings.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Stretch Tuning')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new stretch tuning',
        onPressed: _onAddNew,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search stretch tunings...',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (filteredPredefined.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                    child: Text(
                      'PREDEFINED',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...filteredPredefined.map(
                    (t) => _buildTuningTile(t, isCustom: false),
                  ),
                ],
                if (filteredCustom.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                    child: Text(
                      'CUSTOM',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...filteredCustom.map(
                    (t) => _buildTuningTile(t, isCustom: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTuningTile(StretchTuning tuning, {required bool isCustom}) {
    final isSelected = tuning.stableId == _selectedId;
    final theme = Theme.of(context);

    return ListTile(
      leading: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      title: Text(
        tuning.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: tuning.description.isNotEmpty
          ? Text(
              tuning.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isCustom
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _onEdit(tuning),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _onDelete(tuning),
                ),
              ],
            )
          : null,
      onTap: () {
        setState(() => _selectedId = tuning.stableId);
        widget.onSelectStretchTuning?.call(tuning);
        Navigator.of(context).pop();
      },
    );
  }
}
