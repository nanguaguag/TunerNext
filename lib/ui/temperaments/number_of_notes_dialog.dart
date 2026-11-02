import 'package:flutter/material.dart';

/// Modal dialog for altering the number of scale steps in a custom musical temperament.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.temperaments.NumberOfNotesDialog`.
class NumberOfNotesDialog extends StatefulWidget {
  const NumberOfNotesDialog({
    super.key,
    required this.initialNumberOfNotes,
    required this.onDone,
    this.minNotes = 2,
    this.maxNotes = 200,
  });

  final int initialNumberOfNotes;
  final ValueChanged<int> onDone;
  final int minNotes;
  final int maxNotes;

  @override
  State<NumberOfNotesDialog> createState() => _NumberOfNotesDialogState();
}

class _NumberOfNotesDialogState extends State<NumberOfNotesDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialNumberOfNotes.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final n = int.tryParse(_controller.text.trim());
      if (n != null && n >= widget.minNotes && n <= widget.maxNotes) {
        widget.onDone(n);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Number of Notes'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the number of scale steps per octave (${widget.minNotes} – ${widget.maxNotes}):',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Number of notes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a number';
                }
                final num = int.tryParse(val.trim());
                if (num == null) {
                  return 'Invalid integer';
                }
                if (num < widget.minNotes || num > widget.maxNotes) {
                  return 'Must be between ${widget.minNotes} and ${widget.maxNotes}';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Done')),
      ],
    );
  }
}
