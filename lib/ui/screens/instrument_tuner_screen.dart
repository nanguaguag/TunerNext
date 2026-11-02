import 'package:flutter/material.dart';

import '../../domain/instruments/instrument.dart';
import '../../domain/instruments/predefined_instruments.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../domain/temperaments/predefined_temperament.dart';
import '../../domain/temperaments/temperament.dart';
import '../../domain/tuning/frequency_to_note_converter.dart';
import '../common/quick_settings_bar.dart';
import '../dialogs/reference_note_dialog.dart';
import '../dialogs/temperament_dialog.dart';
import '../instruments/instrument_button.dart';
import '../instruments/string_with_info.dart';
import '../instruments/strings.dart';
import '../plot/plot_window_outline.dart';
import '../tuning/pitch_history.dart';
import '../tuning/pitch_history_state.dart';

/// Main interactive Instrument Tuner screen.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.screens.InstrumentTuner`.
/// Orchestrates:
/// - Active instrument selection and string configuration.
/// - Acoustic pitch tracking with automatic target note detection and hysteresis stabilization.
/// - Interactive fretboard strings view with manual string selection lock.
/// - High-precision PitchHistory graph with logarithmic scale, tolerance bounds, and silence break prevention.
/// - QuickSettingsBar with real-time modal sheets for 19 temperaments and reference frequency adjustments.
class InstrumentTunerScreen extends StatefulWidget {
  const InstrumentTunerScreen({
    super.key,
    this.initialInstrument = PredefinedInstruments.guitarStandard,
    this.initialTemperament,
    this.initialReferenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.initialReferenceFrequency = 440.0,
    this.initialStretchTuningName,
    this.initialPreferFlat = false,
    this.currentFrequency,
    this.onOpenPreferences,
    this.onOpenInstrumentList,
    this.onOpenScientificMode,
    this.onOpenStretchTuning,
    this.onTemperamentChanged,
    this.onReferenceNoteChanged,
  });

  final Instrument initialInstrument;
  final Temperament? initialTemperament;
  final MusicalNote initialReferenceNote;
  final double initialReferenceFrequency;
  final String? initialStretchTuningName;
  final bool initialPreferFlat;
  final double? currentFrequency;

  final VoidCallback? onOpenPreferences;
  final VoidCallback? onOpenInstrumentList;
  final VoidCallback? onOpenScientificMode;
  final VoidCallback? onOpenStretchTuning;
  final ValueChanged<Temperament>? onTemperamentChanged;
  final void Function(MusicalNote note, double frequency)?
  onReferenceNoteChanged;

  @override
  State<InstrumentTunerScreen> createState() => _InstrumentTunerScreenState();
}

class _InstrumentTunerScreenState extends State<InstrumentTunerScreen> {
  late Instrument _currentInstrument;
  late Temperament _currentTemperament;
  late MusicalNote _referenceNote;
  late double _referenceFrequency;
  late bool _preferFlat;
  String? _stretchTuningName;

  late final PitchHistoryState _pitchHistoryState;
  late FrequencyToNoteConverter _pitchConverter;

  // Selected or detected target note
  int? _lockedStringKey;
  MusicalNote? _targetNote;
  double _targetFrequency = 440.0;
  TuningState _tuningState = TuningState.unknown;

  @override
  void initState() {
    super.initState();
    _currentInstrument = widget.initialInstrument;
    _currentTemperament =
        widget.initialTemperament ?? PredefinedTemperaments.edo12();
    _referenceNote = widget.initialReferenceNote;
    _referenceFrequency = widget.initialReferenceFrequency;
    _stretchTuningName = widget.initialStretchTuningName;
    _preferFlat = widget.initialPreferFlat;

    _pitchHistoryState = PitchHistoryState(capacity: 80);
    _rebuildPitchConverter();
    _initTargetNote();
  }

  @override
  void didUpdateWidget(InstrumentTunerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialInstrument != widget.initialInstrument) {
      _currentInstrument = widget.initialInstrument;
      _initTargetNote();
    }
    if (oldWidget.initialTemperament != widget.initialTemperament &&
        widget.initialTemperament != null) {
      _currentTemperament = widget.initialTemperament!;
    }
    if (oldWidget.initialReferenceFrequency !=
            widget.initialReferenceFrequency ||
        oldWidget.initialReferenceNote != widget.initialReferenceNote) {
      _referenceFrequency = widget.initialReferenceFrequency;
      _referenceNote = widget.initialReferenceNote;
      _rebuildPitchConverter();
    }
    if (oldWidget.initialStretchTuningName != widget.initialStretchTuningName) {
      _stretchTuningName = widget.initialStretchTuningName;
    }
    if (oldWidget.initialPreferFlat != widget.initialPreferFlat) {
      _preferFlat = widget.initialPreferFlat;
    }
    if (oldWidget.currentFrequency != widget.currentFrequency) {
      feedPitch(widget.currentFrequency);
    }
  }

  void _rebuildPitchConverter() {
    _pitchConverter = FrequencyToNoteConverter(
      referenceFrequency: _referenceFrequency,
      referenceMidi: _referenceNote.midiNumber,
      toleranceInCents: 5.0,
    );
  }

  void _initTargetNote() {
    if (_currentInstrument.strings.isNotEmpty) {
      _targetNote = _currentInstrument.strings.first;
      _targetFrequency = _pitchConverter.noteToFrequency(_targetNote!);
    } else {
      _targetNote = _referenceNote;
      _targetFrequency = _referenceFrequency;
    }
  }

  List<StringWithInfo> get _currentStringInfos {
    final list = <StringWithInfo>[];
    for (int i = 0; i < _currentInstrument.strings.length; i++) {
      list.add(StringWithInfo(key: i, note: _currentInstrument.strings[i]));
    }
    return list;
  }

  /// Feeds a new acoustic frequency sample into the tuner engine.
  void feedPitch(double? frequency) {
    if (!mounted) return;

    _pitchHistoryState.addFrequency(frequency);

    if (frequency != null && frequency > 0.0 && !frequency.isNaN) {
      if (_lockedStringKey != null) {
        // Manual lock mode
        final cents = _pitchConverter.centsDeviation(
          frequency,
          _targetFrequency,
        );
        final state = _pitchConverter.determineTuningState(cents);
        setState(() {
          _tuningState = state;
        });
      } else {
        // Automatic tracking mode with hysteresis
        final assessment = _pitchConverter.evaluatePitch(
          frequency,
          previousTarget: _targetNote,
        );
        setState(() {
          _targetNote = assessment.target.note;
          _targetFrequency = assessment.target.frequency;
          _tuningState = assessment.tuningState;
        });
      }
    } else {
      setState(() {
        _tuningState = TuningState.unknown;
      });
    }
  }

  void _onStringClicked(int key, MusicalNote note) {
    setState(() {
      if (_lockedStringKey == key) {
        // Unlock
        _lockedStringKey = null;
      } else {
        // Lock to clicked string
        _lockedStringKey = key;
        _targetNote = note;
        _targetFrequency = _pitchConverter.noteToFrequency(note);
      }
    });
  }

  void _showReferenceNoteDialog() {
    showDialog(
      context: context,
      builder: (_) => ReferenceNoteDialog(
        initialNote: _referenceNote,
        initialFrequency: _referenceFrequency,
        detectedFrequency: _pitchHistoryState.latestFrequency,
        onConfirm: (note, frequency) {
          setState(() {
            _referenceNote = note;
            _referenceFrequency = frequency;
            _rebuildPitchConverter();
            if (_lockedStringKey == null) {
              _initTargetNote();
            } else {
              _targetFrequency = _pitchConverter.noteToFrequency(_targetNote!);
            }
          });
          widget.onReferenceNoteChanged?.call(note, frequency);
        },
      ),
    );
  }

  void _showTemperamentDialog() {
    showDialog(
      context: context,
      builder: (_) => TemperamentDialog(
        selectedTemperament: _currentTemperament,
        onSelectTemperament: (temp) {
          setState(() {
            _currentTemperament = temp;
          });
          widget.onTemperamentChanged?.call(temp);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = _currentStringInfos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuner'),
        actions: [
          if (widget.onOpenScientificMode != null)
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              tooltip: 'Scientific Mode',
              onPressed: widget.onOpenScientificMode,
            ),
          if (widget.onOpenPreferences != null)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: widget.onOpenPreferences,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Instrument Switcher Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: InstrumentButton(
                icon: _currentInstrument.icon,
                name: _currentInstrument.name,
                onClick: widget.onOpenInstrumentList,
              ),
            ),

            // 2. Fretboard Strings View (if instrument has strings)
            if (strings.isNotEmpty)
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Strings(
                    strings: strings,
                    highlightedNoteKey: _lockedStringKey,
                    highlightedNote: _targetNote,
                    tuningState: _tuningState,
                    onStringClicked: _onStringClicked,
                    sidebarPosition: StringsSidebarPosition.end,
                    outline: PlotWindowOutline(
                      color: theme.colorScheme.outlineVariant,
                      cornerRadius: 12.0,
                    ),
                  ),
                ),
              ),

            // 3. Acoustic Pitch History Canvas (Filling available space)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: PitchHistory(
                  state: _pitchHistoryState,
                  targetNote: _targetNote ?? _referenceNote,
                  targetFrequency: _targetFrequency,
                  tuningState: _tuningState,
                  toleranceInCents: 5,
                  preferSharp: !_preferFlat,
                  plotWindowOutline: PlotWindowOutline(
                    color: theme.colorScheme.outlineVariant,
                    cornerRadius: 12.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. Bottom Acoustic QuickSettingsBar
      bottomNavigationBar: QuickSettingsBar(
        referenceNote: _referenceNote,
        referenceFrequency: _referenceFrequency,
        temperamentName: _currentTemperament.abbreviation.isNotEmpty
            ? _currentTemperament.abbreviation
            : _currentTemperament.name,
        preferFlat: _preferFlat,
        stretchTuningName: _stretchTuningName,
        onReferenceNoteClicked: _showReferenceNoteDialog,
        onTemperamentClicked: _showTemperamentDialog,
        onStretchTuningClicked: widget.onOpenStretchTuning,
        onSharpFlatClicked: () {
          setState(() {
            _preferFlat = !_preferFlat;
          });
        },
      ),
    );
  }
}
