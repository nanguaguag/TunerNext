import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import '../../domain/temperaments/custom_temperament.dart';
import '../../domain/temperaments/temperament.dart';
import '../temperaments/number_of_notes_dialog.dart';
import '../temperaments/temperament_table_line.dart';

/// Full interactive editor screen for custom musical temperaments.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.temperaments.TemperamentEditor`.
class TemperamentEditorScreen extends StatefulWidget {
  const TemperamentEditorScreen({
    super.key,
    this.initialTemperament,
    required this.onSave,
    this.onAbort,
  });

  final Temperament? initialTemperament;
  final ValueChanged<CustomTemperament> onSave;
  final VoidCallback? onAbort;

  @override
  State<TemperamentEditorScreen> createState() =>
      _TemperamentEditorScreenState();
}

class _TemperamentEditorScreenState extends State<TemperamentEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _abbrController;
  late final TextEditingController _descController;

  late int _numberOfNotes;
  late List<double> _cents;
  late List<String> _noteNames;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTemperament;
    _nameController = TextEditingController(
      text: init?.name ?? 'Custom Temperament',
    );
    _abbrController = TextEditingController(
      text: init?.abbreviation ?? 'Custom',
    );
    _descController = TextEditingController(
      text: init?.description ?? 'User-defined tuning temperament.',
    );

    _numberOfNotes = init?.size ?? 12;

    if (init != null && init.cents.isNotEmpty) {
      _cents = List<double>.from(init.cents);
      _noteNames = List<String>.generate(
        _cents.length,
        (i) => _getNoteNameForIndex(i, _cents.length - 1),
      );
    } else {
      _generateEdoCents(_numberOfNotes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _abbrController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _generateEdoCents(int n) {
    _numberOfNotes = n;
    _cents = List<double>.generate(
      n + 1,
      (i) => (1200.0 / n) * i,
      growable: true,
    );
    _noteNames = List<String>.generate(
      n + 1,
      (i) => _getNoteNameForIndex(i, n),
      growable: true,
    );
  }

  static String _getNoteNameForIndex(int i, int total) {
    if (total == 12) {
      const names = [
        'C',
        'C♯',
        'D',
        'D♯',
        'E',
        'F',
        'F♯',
        'G',
        'G♯',
        'A',
        'A♯',
        'B',
        'C',
      ];
      if (i < names.length) return names[i];
    }
    return i == total ? 'Octave' : 'Note $i';
  }

  bool _hasErrors() {
    if (_nameController.text.trim().isEmpty) return true;
    for (var i = 1; i < _cents.length; i++) {
      if (_cents[i] <= _cents[i - 1]) return true;
    }
    return false;
  }

  void _onOpenNumberOfNotes() {
    showDialog<void>(
      context: context,
      builder: (ctx) => NumberOfNotesDialog(
        initialNumberOfNotes: _numberOfNotes,
        onDone: (newCount) {
          setState(() {
            _generateEdoCents(newCount);
          });
        },
      ),
    );
  }

  CustomTemperament _buildCustomTemperament() {
    return CustomTemperament(
      name: _nameController.text.trim(),
      abbreviation: _abbrController.text.trim(),
      description: _descController.text.trim(),
      stableId:
          widget.initialTemperament?.stableId ??
          DateTime.now().millisecondsSinceEpoch,
      rootNote:
          widget.initialTemperament?.rootNote ??
          const MusicalNote(base: BaseNote.c, octave: 4),
      cents: _cents,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasErr = _hasErrors();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperament Editor'),
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
            onPressed: !hasErr
                ? () {
                    widget.onSave(_buildCustomTemperament());
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          // Name Field
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Temperament Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _nameController.clear(),
                ),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Abbreviation Field
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: TextField(
              controller: _abbrController,
              decoration: InputDecoration(
                labelText: 'Abbreviation',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _abbrController.clear(),
                ),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Description Field
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: TextField(
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
          ),
          // Number of Notes Card
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: _onOpenNumberOfNotes,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NUMBER OF NOTES',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '$_numberOfNotes steps per octave',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          // Pitch steps list
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32.0,
                  child: Text(
                    '#',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Note',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Cents Offset',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_cents.length, (index) {
            final isOctave = index == _cents.length - 1;
            final prevCents = index > 0 ? _cents[index - 1] : -1.0;
            final isDecreasing = index > 0 && _cents[index] <= prevCents;

            return TemperamentTableLine(
              key: ValueKey(index),
              index: index,
              noteName: _noteNames[index],
              cents: _cents[index],
              isOctaveLine: isOctave,
              errorMessage: isDecreasing
                  ? 'Must be > ${prevCents.toStringAsFixed(2)} ¢'
                  : null,
              onCentsChanged: (newVal) {
                setState(() {
                  _cents[index] = newVal;
                });
              },
              onNoteNameChanged: (newName) {
                setState(() {
                  _noteNames[index] = newName;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
