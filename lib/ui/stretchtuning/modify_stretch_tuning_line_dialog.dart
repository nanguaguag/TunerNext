import 'package:flutter/material.dart';

/// Modal dialog for modifying or inserting a stretch tuning control point line.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.stretchtuning.ModifyStretchTuningLineDialog`.
class ModifyStretchTuningLineDialog extends StatefulWidget {
  const ModifyStretchTuningLineDialog({
    super.key,
    required this.initialUnstretchedFrequency,
    required this.initialStretchInCents,
    required this.pointKey,
    required this.onConfirmed,
  });

  final double initialUnstretchedFrequency;
  final double initialStretchInCents;
  final int pointKey;
  final void Function(
    double unstretchedFrequency,
    double stretchInCents,
    int pointKey,
  )
  onConfirmed;

  @override
  State<ModifyStretchTuningLineDialog> createState() =>
      _ModifyStretchTuningLineDialogState();
}

class _ModifyStretchTuningLineDialogState
    extends State<ModifyStretchTuningLineDialog> {
  late final TextEditingController _freqController;
  late final TextEditingController _centsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _freqController = TextEditingController(
      text: widget.initialUnstretchedFrequency.toStringAsFixed(2),
    );
    _centsController = TextEditingController(
      text: widget.initialStretchInCents.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _freqController.dispose();
    _centsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final f = double.tryParse(_freqController.text.trim());
      final s = double.tryParse(_centsController.text.trim());
      if (f != null && s != null && f > 0) {
        widget.onConfirmed(f, s, widget.pointKey);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Stretch Point'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _freqController,
              decoration: const InputDecoration(
                labelText: 'Nominal Frequency (Hz)',
                suffixText: 'Hz',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Frequency is required';
                }
                final num = double.tryParse(val.trim());
                if (num == null || num <= 0) {
                  return 'Must be a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _centsController,
              decoration: const InputDecoration(
                labelText: 'Stretch in Cents',
                suffixText: '¢',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Stretch is required';
                }
                final num = double.tryParse(val.trim());
                if (num == null) {
                  return 'Must be a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Confirm')),
      ],
    );
  }
}
