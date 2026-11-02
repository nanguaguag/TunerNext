import 'package:flutter/material.dart';

import '../../domain/instruments/instrument.dart';
import '../../domain/instruments/instrument_icon.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../plot/plot_window_outline.dart';
import 'instrument_icon_picker.dart';
import 'instrument_icons.dart';
import 'string_with_info.dart';
import 'strings.dart';

/// Full-featured instrument tuning and string configuration editor.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.instruments.InstrumentEditor`.
/// Allows:
/// - Editing instrument name and selecting from 15 vector icons.
/// - Adding, deleting, and re-tuning strings.
/// - Setting individual string notes (pitch class and octave).
/// - Real-time visual fretboard preview with dynamic string gauges.
class InstrumentEditorScreen extends StatefulWidget {
  const InstrumentEditorScreen({
    super.key,
    this.initialInstrument,
    required this.onSaveInstrument,
  });

  /// The instrument to edit (or null to create a new one).
  final Instrument? initialInstrument;

  /// Callback when saving the instrument.
  final ValueChanged<Instrument> onSaveInstrument;

  @override
  State<InstrumentEditorScreen> createState() => _InstrumentEditorScreenState();
}

class _InstrumentEditorScreenState extends State<InstrumentEditorScreen> {
  late TextEditingController _nameController;
  late InstrumentIcon _icon;
  late List<MusicalNote> _strings;
  int _selectedStringIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final inst = widget.initialInstrument;
    _nameController = TextEditingController(
      text: inst?.name ?? 'Custom Instrument',
    );
    _icon = inst?.icon ?? InstrumentIcon.guitar;
    _strings = inst != null && inst.strings.isNotEmpty
        ? List<MusicalNote>.from(inst.strings)
        : [
            const MusicalNote(base: BaseNote.e, octave: 2),
            const MusicalNote(base: BaseNote.a, octave: 2),
            const MusicalNote(base: BaseNote.d, octave: 3),
            const MusicalNote(base: BaseNote.g, octave: 3),
            const MusicalNote(base: BaseNote.b, octave: 3),
            const MusicalNote(base: BaseNote.e, octave: 4),
          ];
    _selectedStringIndex = 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<StringWithInfo> get _stringInfos {
    return List<StringWithInfo>.generate(
      _strings.length,
      (i) => StringWithInfo(key: i, note: _strings[i]),
    );
  }

  void _addString() {
    setState(() {
      final lastNote = _strings.isNotEmpty
          ? _strings.last
          : const MusicalNote(base: BaseNote.a, octave: 4);
      final newMidi = lastNote.midiNumber + 5; // Perfect 4th higher by default
      final newNote = MusicalNote.fromMidiNumber(newMidi);
      _strings.add(newNote);
      _selectedStringIndex = _strings.length - 1;
    });
  }

  void _deleteString() {
    if (_strings.isEmpty) return;
    setState(() {
      _strings.removeAt(_selectedStringIndex);
      if (_selectedStringIndex >= _strings.length) {
        _selectedStringIndex = (_strings.length - 1).clamp(0, 999);
      }
    });
  }

  void _updateSelectedNote(MusicalNote newNote) {
    if (_strings.isEmpty || _selectedStringIndex >= _strings.length) return;
    setState(() {
      _strings[_selectedStringIndex] = newNote;
    });
  }

  void _pickIcon() {
    showDialog(
      context: context,
      builder: (_) => InstrumentIconPicker(
        selectedIcon: _icon,
        onIconSelected: (newIcon) {
          setState(() {
            _icon = newIcon;
          });
        },
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Instrument name cannot be empty';
      });
      return;
    }

    final saved = Instrument(
      name: name,
      strings: List.unmodifiable(_strings),
      icon: _icon,
      stableId:
          widget.initialInstrument?.stableId ??
          DateTime.now().millisecondsSinceEpoch,
      isChromatic: _strings.isEmpty,
    );

    widget.onSaveInstrument(saved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentNote =
        _strings.isNotEmpty && _selectedStringIndex < _strings.length
        ? _strings[_selectedStringIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialInstrument != null
              ? 'Edit Instrument'
              : 'New Instrument',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Icon & Name Row
            Row(
              children: [
                InkWell(
                  onTap: _pickIcon,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    child: Center(
                      child: InstrumentIconWidget(
                        icon: _icon,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Instrument Name',
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Fretboard Strings Preview
            Text(
              'Strings Preview (${_strings.length} Strings)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_strings.isNotEmpty)
              SizedBox(
                height: 160,
                child: Strings(
                  strings: _stringInfos,
                  highlightedNoteKey: _selectedStringIndex,
                  highlightedNote: currentNote,
                  tuningState: TuningState.inTune,
                  onStringClicked: (key, _) {
                    setState(() {
                      _selectedStringIndex = key;
                    });
                  },
                  outline: PlotWindowOutline(
                    color: theme.colorScheme.outlineVariant,
                    cornerRadius: 12.0,
                  ),
                ),
              )
            else
              Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No strings (Chromatic mode)'),
              ),
            const SizedBox(height: 12),

            // 3. String Add / Remove buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Delete String'),
                  onPressed: _strings.isNotEmpty ? _deleteString : null,
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add String'),
                  onPressed: _addString,
                ),
              ],
            ),
            const Divider(height: 24),

            // 4. Note Pitch Adjuster for Selected String
            if (currentNote != null) ...[
              Text(
                'Pitch for String ${_selectedStringIndex + 1}: ${currentNote.name}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Pitch class chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final base in BaseNote.values)
                    ChoiceChip(
                      label: Text(base.name.toUpperCase()),
                      selected:
                          currentNote.base == base &&
                          currentNote.modifier == NoteModifier.none,
                      onSelected: (sel) {
                        if (sel) {
                          _updateSelectedNote(
                            MusicalNote(
                              base: base,
                              modifier: NoteModifier.none,
                              octave: currentNote.octave,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Accidentals chips (Sharp / Flat / Natural)
              Row(
                children: [
                  const Text('Accidental: '),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Natural (♮)'),
                    selected: currentNote.modifier == NoteModifier.none,
                    onSelected: (sel) {
                      if (sel) {
                        _updateSelectedNote(
                          MusicalNote(
                            base: currentNote.base,
                            modifier: NoteModifier.none,
                            octave: currentNote.octave,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Sharp (♯)'),
                    selected: currentNote.modifier == NoteModifier.sharp,
                    onSelected: (sel) {
                      if (sel) {
                        _updateSelectedNote(
                          MusicalNote(
                            base: currentNote.base,
                            modifier: NoteModifier.sharp,
                            octave: currentNote.octave,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Flat (♭)'),
                    selected: currentNote.modifier == NoteModifier.flat,
                    onSelected: (sel) {
                      if (sel) {
                        _updateSelectedNote(
                          MusicalNote(
                            base: currentNote.base,
                            modifier: NoteModifier.flat,
                            octave: currentNote.octave,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Octave stepper
              Row(
                children: [
                  const Text('Octave: '),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove),
                    onPressed: currentNote.octave > 0
                        ? () {
                            _updateSelectedNote(
                              MusicalNote(
                                base: currentNote.base,
                                modifier: currentNote.modifier,
                                octave: currentNote.octave - 1,
                              ),
                            );
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${currentNote.octave}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: currentNote.octave < 8
                        ? () {
                            _updateSelectedNote(
                              MusicalNote(
                                base: currentNote.base,
                                modifier: currentNote.modifier,
                                octave: currentNote.octave + 1,
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
