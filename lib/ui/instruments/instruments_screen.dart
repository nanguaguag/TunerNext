import 'package:flutter/material.dart';

import '../../domain/instruments/instrument.dart';
import '../../domain/instruments/predefined_instruments.dart';
import 'instrument_editor_screen.dart';
import 'instrument_icons.dart';

/// Comprehensive instrument management screen.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.instruments.Instruments`.
/// Supports:
/// - Browsing all predefined instruments (Guitar, Bass, Ukulele, Violin, etc.).
/// - Search filter by instrument name.
/// - Adding new custom instruments via [InstrumentEditorScreen].
/// - Editing existing custom instruments.
/// - Active instrument selection.
class InstrumentsScreen extends StatefulWidget {
  const InstrumentsScreen({
    super.key,
    required this.selectedInstrument,
    this.customInstruments = const [],
    required this.onSelectInstrument,
    this.onAddCustomInstrument,
    this.onUpdateCustomInstrument,
    this.onDeleteCustomInstrument,
  });

  final Instrument selectedInstrument;
  final List<Instrument> customInstruments;
  final ValueChanged<Instrument> onSelectInstrument;
  final ValueChanged<Instrument>? onAddCustomInstrument;
  final ValueChanged<Instrument>? onUpdateCustomInstrument;
  final ValueChanged<Instrument>? onDeleteCustomInstrument;

  @override
  State<InstrumentsScreen> createState() => _InstrumentsScreenState();
}

class _InstrumentsScreenState extends State<InstrumentsScreen> {
  late List<Instrument> _customList;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _customList = List.from(widget.customInstruments);
  }

  List<Instrument> get _allPredefined => PredefinedInstruments.all;

  List<Instrument> get _filteredPredefined {
    if (_searchQuery.trim().isEmpty) return _allPredefined;
    final q = _searchQuery.toLowerCase();
    return _allPredefined
        .where((i) => i.name.toLowerCase().contains(q))
        .toList();
  }

  List<Instrument> get _filteredCustom {
    if (_searchQuery.trim().isEmpty) return _customList;
    final q = _searchQuery.toLowerCase();
    return _customList.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  void _openEditor({Instrument? instrumentToEdit, bool isDuplicate = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InstrumentEditorScreen(
          initialInstrument: instrumentToEdit,
          onSaveInstrument: (saved) {
            setState(() {
              if (instrumentToEdit != null && !isDuplicate) {
                final idx = _customList.indexWhere(
                  (inst) => inst.stableId == instrumentToEdit.stableId,
                );
                if (idx >= 0) {
                  _customList[idx] = saved;
                } else {
                  _customList.add(saved);
                }
                widget.onUpdateCustomInstrument?.call(saved);
              } else {
                _customList.add(saved);
                widget.onAddCustomInstrument?.call(saved);
              }
            });
          },
        ),
      ),
    );
  }

  void _confirmDelete(Instrument inst) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Instrument'),
        content: Text('Are you sure you want to delete "${inst.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _customList.removeWhere((i) => i.stableId == inst.stableId);
              });
              widget.onDeleteCustomInstrument?.call(inst);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final predefined = _filteredPredefined;
    final custom = _filteredCustom;

    return Scaffold(
      appBar: AppBar(title: const Text('Instruments')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Instrument',
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search instruments...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
              onChanged: (q) {
                setState(() {
                  _searchQuery = q;
                });
              },
            ),
          ),
          const Divider(),

          // Instrument list
          Expanded(
            child: ListView(
              children: [
                if (custom.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      'Custom Instruments',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final inst in custom)
                    _buildInstrumentTile(inst, isCustom: true),
                  const Divider(),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Predefined Instruments',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (final inst in predefined)
                  _buildInstrumentTile(inst, isCustom: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentTile(Instrument inst, {required bool isCustom}) {
    final isSelected =
        inst.stableId == widget.selectedInstrument.stableId ||
        inst.name == widget.selectedInstrument.name;
    final stringsSubtitle = inst.isChromatic
        ? 'All semitones (Chromatic)'
        : inst.strings.map((s) => s.name).join(' • ');

    return ListTile(
      leading: InstrumentIconWidget(
        icon: inst.icon,
        size: 32,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        inst.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        stringsSubtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCustom) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit',
              onPressed: () => _openEditor(instrumentToEdit: inst),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              tooltip: 'Copy',
              onPressed: () => _openEditor(
                instrumentToEdit: inst.copyWith(
                  name: '${inst.name} (Copy)',
                  stableId: DateTime.now().millisecondsSinceEpoch,
                ),
                isDuplicate: true,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(inst),
            ),
          ] else if (!inst.isChromatic) ...[
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              tooltip: 'Copy to customize',
              onPressed: () => _openEditor(
                instrumentToEdit: inst.copyWith(
                  name: '${inst.name} (Custom)',
                  stableId: DateTime.now().millisecondsSinceEpoch,
                ),
                isDuplicate: true,
              ),
            ),
          ],
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
      onTap: () {
        widget.onSelectInstrument(inst);
        Navigator.of(context).pop();
      },
    );
  }
}
