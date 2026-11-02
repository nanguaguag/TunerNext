import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import '../../l10n/app_localizations.dart';

/// Modal dialog for configuring the reference musical note and reference frequency standard.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.preferences.ReferenceNoteDialog`.
/// Features:
/// - Full 12-semitone note selector (C to B with sharp/flat) across octaves.
/// - Frequency input in Hertz with positive numerical validation.
/// - Live acoustic pitch quick lock (auto-fills currently detected frequency).
/// - Instant standard presets (440 Hz, 442 Hz, 415 Hz, 432 Hz).
/// - One-tap 'Set to Default' (A4 = 440.0 Hz) reset.
class ReferenceNoteDialog extends StatefulWidget {
  const ReferenceNoteDialog({
    super.key,
    required this.initialNote,
    required this.initialFrequency,
    this.detectedFrequency,
    required this.onConfirm,
    this.onDismiss,
  });

  /// Currently configured reference note.
  final MusicalNote initialNote;

  /// Currently configured reference frequency in Hz.
  final double initialFrequency;

  /// Real-time live frequency detected by the acoustic isolate (optional).
  final double? detectedFrequency;

  /// Callback when confirmed with the modified reference note and frequency.
  final void Function(MusicalNote note, double frequency) onConfirm;

  /// Callback when cancelled or dismissed.
  final VoidCallback? onDismiss;

  @override
  State<ReferenceNoteDialog> createState() => _ReferenceNoteDialogState();
}

class _ReferenceNoteDialogState extends State<ReferenceNoteDialog> {
  late MusicalNote _selectedNote;
  late TextEditingController _frequencyController;
  late int _selectedOctave;
  String? _errorMessage;

  static const List<MusicalNote> _chromaticScaleC4 = [
    MusicalNote(base: BaseNote.c, octave: 4),
    MusicalNote(base: BaseNote.c, modifier: NoteModifier.sharp, octave: 4),
    MusicalNote(base: BaseNote.d, octave: 4),
    MusicalNote(base: BaseNote.d, modifier: NoteModifier.sharp, octave: 4),
    MusicalNote(base: BaseNote.e, octave: 4),
    MusicalNote(base: BaseNote.f, octave: 4),
    MusicalNote(base: BaseNote.f, modifier: NoteModifier.sharp, octave: 4),
    MusicalNote(base: BaseNote.g, octave: 4),
    MusicalNote(base: BaseNote.g, modifier: NoteModifier.sharp, octave: 4),
    MusicalNote(base: BaseNote.a, octave: 4),
    MusicalNote(base: BaseNote.a, modifier: NoteModifier.sharp, octave: 4),
    MusicalNote(base: BaseNote.b, octave: 4),
  ];

  @override
  void initState() {
    super.initState();
    _selectedNote = widget.initialNote;
    _selectedOctave = widget.initialNote.octave;
    _frequencyController = TextEditingController(
      text: widget.initialFrequency.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final text = _frequencyController.text.trim();
    final freq = double.tryParse(text);

    if (freq == null) {
      setState(() {
        _errorMessage = 'Invalid number format';
      });
      return;
    }

    if (freq <= 0.0 || freq.isNaN || freq.isInfinite) {
      setState(() {
        _errorMessage = 'Frequency must be greater than zero';
      });
      return;
    }

    widget.onConfirm(_selectedNote, freq);
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _setToDefault() {
    setState(() {
      _selectedNote = const MusicalNote(base: BaseNote.a, octave: 4);
      _selectedOctave = 4;
      _frequencyController.text = '440.0';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final liveFreq = widget.detectedFrequency;
    final hasLiveFreq = liveFreq != null && liveFreq > 20.0;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.tune),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n?.referenceFrequency ?? 'Reference Pitch',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Reference Note Selection (12 Semitones)
            Row(
              children: [
                Text(
                  '${l10n?.referenceNote ?? 'Reference Note'}: ${_selectedNote.name}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: _selectedOctave,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  items: [3, 4, 5].map((oct) {
                    return DropdownMenuItem<int>(
                      value: oct,
                      child: Text('Octave $oct'),
                    );
                  }).toList(),
                  onChanged: (newOctave) {
                    if (newOctave != null) {
                      setState(() {
                        _selectedOctave = newOctave;
                        _selectedNote = MusicalNote(
                          base: _selectedNote.base,
                          modifier: _selectedNote.modifier,
                          octave: newOctave,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _chromaticScaleC4.map((baseSample) {
                final note = MusicalNote(
                  base: baseSample.base,
                  modifier: baseSample.modifier,
                  octave: _selectedOctave,
                );
                final isSelected = _selectedNote.matches(note);
                return ChoiceChip(
                  label: Text(note.pitchClassName),
                  selected: isSelected,
                  visualDensity: VisualDensity.compact,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedNote = note;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 2. Frequency Text Input
            TextField(
              controller: _frequencyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n?.frequency ?? 'Frequency',
                suffixText: 'Hz',
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
            const SizedBox(height: 12),

            // 3. Live Microphone Frequency Quick Fill (Parity with Kotlin detect_frequency)
            if (hasLiveFreq) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.mic, size: 18),
                label: Text(
                  '${l10n?.detectFrequency ?? 'Use Detected Pitch'}: ${liveFreq.toStringAsFixed(2)} Hz',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _frequencyController.text = liveFreq.toStringAsFixed(2);
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],

            // 4. Historical and Standard Presets
            Text(
              'Standard Presets',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildPresetButton(440.0, '440 Hz (Concert)'),
                _buildPresetButton(442.0, '442 Hz (Symphony)'),
                _buildPresetButton(415.0, '415 Hz (Baroque)'),
                _buildPresetButton(432.0, '432 Hz (Verdi)'),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Set to default button
            OutlinedButton.icon(
              icon: const Icon(Icons.restore, size: 16),
              label: Text(l10n?.useDefault ?? 'Set to Default (A4 = 440 Hz)'),
              onPressed: _setToDefault,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDismiss?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text(l10n?.dismiss ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: _validateAndSubmit,
          child: Text(l10n?.unlock ?? 'Done'),
        ),
      ],
    );
  }

  Widget _buildPresetButton(double freq, String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        setState(() {
          _frequencyController.text = freq.toStringAsFixed(1);
          _errorMessage = null;
        });
      },
    );
  }
}
