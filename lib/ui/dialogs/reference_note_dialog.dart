import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';

/// Modal dialog for configuring the reference musical note and reference frequency standard.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.preferences.ReferenceNoteDialog`.
/// Features:
/// - Reference note selection across base note and octave.
/// - Editable reference frequency in Hertz with validation (positive number).
/// - Instant acoustic presets (440 Hz Concert, 432 Hz Verdi, 415 Hz Baroque, 442 Hz Symphony).
/// - Live microphone frequency sampler input.
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedNote = widget.initialNote;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tune),
          SizedBox(width: 8),
          Text('Reference Pitch'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Note Selection
            Text(
              'Reference Note',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildNoteChip(const MusicalNote(base: BaseNote.a, octave: 4)),
                _buildNoteChip(const MusicalNote(base: BaseNote.c, octave: 4)),
                _buildNoteChip(const MusicalNote(base: BaseNote.d, octave: 4)),
                _buildNoteChip(const MusicalNote(base: BaseNote.e, octave: 4)),
                _buildNoteChip(const MusicalNote(base: BaseNote.g, octave: 4)),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Frequency Text Input
            TextField(
              controller: _frequencyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Frequency',
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

            // 3. Historical and Standard Presets
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

            // 4. Detected microphone frequency quick lock
            if (widget.detectedFrequency != null &&
                widget.detectedFrequency! > 20.0) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.mic, size: 18),
                label: Text(
                  'Use Live Pitch: ${widget.detectedFrequency!.toStringAsFixed(1)} Hz',
                ),
                onPressed: () {
                  setState(() {
                    _frequencyController.text = widget.detectedFrequency!
                        .toStringAsFixed(1);
                    _errorMessage = null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDismiss?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _validateAndSubmit, child: const Text('Done')),
      ],
    );
  }

  Widget _buildNoteChip(MusicalNote note) {
    final isSelected = _selectedNote.matches(note);
    return ChoiceChip(
      label: Text(note.name),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedNote = note;
          });
        }
      },
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
