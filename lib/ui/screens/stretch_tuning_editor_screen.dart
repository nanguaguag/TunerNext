import 'package:flutter/material.dart';

import '../../domain/stretch_tuning/stretch_tuning.dart';
import '../plot/gesture_based_viewport.dart';
import '../plot/plot_window_outline.dart';
import '../stretchtuning/modify_stretch_tuning_line_dialog.dart';
import '../stretchtuning/stretch_tuning_graph.dart';
import '../stretchtuning/stretch_tuning_table.dart';

/// Full interactive editor screen for custom Railsback stretch tuning curves.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.screens.StretchTuningEditor`.
class StretchTuningEditorScreen extends StatefulWidget {
  const StretchTuningEditorScreen({
    super.key,
    this.initialStretchTuning,
    required this.onSave,
    this.onAbort,
  });

  final StretchTuning? initialStretchTuning;
  final ValueChanged<StretchTuning> onSave;
  final VoidCallback? onAbort;

  @override
  State<StretchTuningEditorScreen> createState() =>
      _StretchTuningEditorScreenState();
}

class _StretchTuningEditorScreenState extends State<StretchTuningEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final GestureBasedViewPort _viewPort;

  late List<double> _frequencies;
  late List<double> _stretchInCents;
  late List<int> _keys;
  int _selectedKey = StretchTuning.noKey;
  int _nextKey = 1000;

  @override
  void initState() {
    super.initState();
    final init = widget.initialStretchTuning;
    _nameController = TextEditingController(
      text: init?.name ?? 'Custom Stretch',
    );
    _descController = TextEditingController(text: init?.description ?? '');
    _viewPort = GestureBasedViewPort();

    _frequencies = List<double>.from(init?.unstretchedFrequencies ?? []);
    _stretchInCents = List<double>.from(init?.stretchInCents ?? []);
    _keys = List<int>.from(
      init?.keys ?? List.generate(_frequencies.length, (i) => i),
    );
    if (_keys.isNotEmpty) {
      _nextKey = (_keys.reduce((a, b) => a > b ? a : b)) + 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  StretchTuning _buildCurrentStretchTuning() {
    return StretchTuning(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      unstretchedFrequencies: _frequencies,
      stretchInCents: _stretchInCents,
      keys: _keys,
      stableId:
          widget.initialStretchTuning?.stableId ?? StretchTuning.noStableId,
    );
  }

  void _sortPoints() {
    final zipped = List.generate(_frequencies.length, (i) {
      return (f: _frequencies[i], s: _stretchInCents[i], k: _keys[i]);
    });
    zipped.sort((a, b) => a.f.compareTo(b.f));
    _frequencies = zipped.map((e) => e.f).toList();
    _stretchInCents = zipped.map((e) => e.s).toList();
    _keys = zipped.map((e) => e.k).toList();
  }

  void _onAddLine() {
    // Propose frequency between existing points or default 440
    var proposedFreq = 440.0;
    if (_frequencies.isNotEmpty) {
      proposedFreq = (_frequencies.last * 1.25).clamp(20.0, 20000.0);
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => ModifyStretchTuningLineDialog(
        initialUnstretchedFrequency: proposedFreq,
        initialStretchInCents: 0.0,
        pointKey: _nextKey++,
        onConfirmed: (f, s, k) {
          setState(() {
            _frequencies.add(f);
            _stretchInCents.add(s);
            _keys.add(k);
            _selectedKey = k;
            _sortPoints();
          });
        },
      ),
    );
  }

  void _onEditLine(int key) {
    final idx = _keys.indexOf(key);
    if (idx < 0) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => ModifyStretchTuningLineDialog(
        initialUnstretchedFrequency: _frequencies[idx],
        initialStretchInCents: _stretchInCents[idx],
        pointKey: key,
        onConfirmed: (f, s, k) {
          setState(() {
            _frequencies[idx] = f;
            _stretchInCents[idx] = s;
            _selectedKey = k;
            _sortPoints();
          });
        },
      ),
    );
  }

  void _onDeleteLine(int key) {
    final idx = _keys.indexOf(key);
    if (idx < 0) return;
    setState(() {
      _frequencies.removeAt(idx);
      _stretchInCents.removeAt(idx);
      _keys.removeAt(idx);
      if (_selectedKey == key) {
        _selectedKey = StretchTuning.noKey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTuning = _buildCurrentStretchTuning();
    final isMonotonic = currentTuning.isMonotonic;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stretch Tuning Editor'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.onAbort != null) {
              widget.onAbort!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: isMonotonic
                ? () {
                    widget.onSave(currentTuning);
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add stretch point',
        onPressed: _onAddLine,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: isLandscape
              ? _buildLandscape(currentTuning)
              : _buildPortrait(currentTuning),
        ),
      ),
    );
  }

  Widget _buildPortrait(StretchTuning currentTuning) {
    return Column(
      children: [
        _buildTextFields(),
        const SizedBox(height: 8.0),
        Expanded(
          flex: 4,
          child: StretchTuningGraph(
            stretchTuning: currentTuning,
            selectedKey: _selectedKey,
            gestureBasedViewPort: _viewPort,
            plotWindowOutline: PlotWindowOutline(
              lineWidth: 1.0,
              cornerRadius: 8.0,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          flex: 5,
          child: StretchTuningTable(
            stretchTuning: currentTuning,
            selectedKey: _selectedKey,
            onLineClicked: (k) => setState(() => _selectedKey = k),
            onEditLineClicked: _onEditLine,
            onDeleteLineClicked: _onDeleteLine,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(StretchTuning currentTuning) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildTextFields(),
              const SizedBox(height: 8.0),
              Expanded(
                child: StretchTuningGraph(
                  stretchTuning: currentTuning,
                  selectedKey: _selectedKey,
                  gestureBasedViewPort: _viewPort,
                  plotWindowOutline: PlotWindowOutline(
                    lineWidth: 1.0,
                    cornerRadius: 8.0,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 5,
          child: StretchTuningTable(
            stretchTuning: currentTuning,
            selectedKey: _selectedKey,
            onLineClicked: (k) => setState(() => _selectedKey = k),
            onEditLineClicked: _onEditLine,
            onDeleteLineClicked: _onDeleteLine,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => _nameController.clear(),
            ),
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _descController,
          decoration: InputDecoration(
            labelText: 'Description',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => _descController.clear(),
            ),
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
