import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../l10n/app_localizations.dart';
import '../common/quick_settings_bar.dart';
import '../plot/autocorrelation_plot.dart';
import '../plot/gesture_based_viewport.dart';
import '../plot/line_coordinates.dart';
import '../plot/plot_window_outline.dart';
import '../plot/spectrum_plot.dart';
import '../staff/note_staff.dart';
import '../staff/staff_models.dart';
import '../tuning/correlation_plot.dart';
import '../tuning/frequency_plot.dart';
import '../tuning/pitch_history.dart';
import '../tuning/pitch_history_state.dart';

/// Scientific analysis screen displaying synchronized FFT spectrum, autocorrelation,
/// log-frequency pitch history with interactive zooming, classical note staff, and WAV snapshot export.
class ScientificTunerScreen extends StatefulWidget {
  const ScientificTunerScreen({
    super.key,
    this.targetNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.targetFrequency = 440.0,
    this.referenceFrequency = 440.0,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.temperamentName = 'EDO 12',
    this.stretchTuningName,
    this.currentFrequency,
    this.tuningState = TuningState.inTune,
    this.toleranceInCents = 10,
    this.preferFlat = false,
    this.spectrumAmplitudes,
    this.correlationValues,
    this.frequencyPlotData,
    this.harmonicFrequencies,
    this.correlationPlotData,
    this.correlationPlotDataYZeroPosition = 0.5,
    this.pitchHistoryState,
    this.waveWriterDuration = 1,
    this.canNavigateUp = false,
    this.initialStaffClef = StaffClef.grand,
    this.initialKeySignature = 0,
    this.onNavigateUp,
    this.onOpenPreferences,
    this.onOpenInstrumentTunerMode,
    this.onTogglePreferFlat,
    this.onOpenReferenceNote,
    this.onOpenTemperament,
    this.onOpenStretchTuning,
    this.onOpenAudioAnalysis,
    this.onExportWav,
  });

  final MusicalNote targetNote;
  final double targetFrequency;
  final double referenceFrequency;
  final MusicalNote referenceNote;
  final String temperamentName;
  final String? stretchTuningName;
  final double? currentFrequency;
  final TuningState tuningState;
  final int toleranceInCents;
  final bool preferFlat;

  final Float32List? spectrumAmplitudes;
  final Float32List? correlationValues;
  final LineCoordinates? frequencyPlotData;
  final List<double>? harmonicFrequencies;
  final LineCoordinates? correlationPlotData;
  final double correlationPlotDataYZeroPosition;
  final PitchHistoryState? pitchHistoryState;
  final int waveWriterDuration;

  final bool canNavigateUp;
  final StaffClef initialStaffClef;
  final int initialKeySignature;
  final VoidCallback? onNavigateUp;
  final VoidCallback? onOpenPreferences;
  final VoidCallback? onOpenInstrumentTunerMode;
  final VoidCallback? onTogglePreferFlat;
  final VoidCallback? onOpenReferenceNote;
  final VoidCallback? onOpenTemperament;
  final VoidCallback? onOpenStretchTuning;
  final VoidCallback? onOpenAudioAnalysis;
  final VoidCallback? onExportWav;

  @override
  State<ScientificTunerScreen> createState() => _ScientificTunerScreenState();
}

class _ScientificTunerScreenState extends State<ScientificTunerScreen> {
  late final GestureBasedViewPort _freqViewPort;
  late final GestureBasedViewPort _corrViewPort;
  late final PitchHistoryState _historyState;
  late StaffClef _staffClef;
  late int _keySignature;

  @override
  void initState() {
    super.initState();
    _freqViewPort = GestureBasedViewPort();
    _corrViewPort = GestureBasedViewPort();
    _historyState =
        widget.pitchHistoryState ?? PitchHistoryState(capacity: 120);
    _staffClef = widget.initialStaffClef;
    _keySignature = widget.initialKeySignature;
  }

  @override
  void didUpdateWidget(ScientificTunerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFrequency != null && widget.currentFrequency! > 0) {
      _historyState.addFrequency(widget.currentFrequency);
    } else {
      _historyState.addFrequency(null);
    }
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
    required PlotWindowOutline outline,
  }) {
    final theme = Theme.of(context);
    final tunerColors = TunerColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(outline.cornerRadius),
        border: Border.all(
          color: outline.color ?? theme.colorScheme.outlineVariant,
          width: outline.lineWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tunerColors.positive,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;

    final freqData =
        widget.frequencyPlotData ??
        LineCoordinates([
          const Offset(0, 0),
          const Offset(220, 0.4),
          const Offset(440, 1.0),
          const Offset(880, 0.6),
          const Offset(1320, 0.2),
          const Offset(2000, 0.05),
        ]);

    final corrData =
        widget.correlationPlotData ??
        LineCoordinates([
          const Offset(0.000, 1.0),
          const Offset(0.001, 0.6),
          const Offset(0.002, 0.1),
          const Offset(0.00227, 0.95), // ~440 Hz
          const Offset(0.0035, 0.2),
          const Offset(0.00454, 0.85),
          const Offset(0.006, 0.1),
        ]);

    final outline = PlotWindowOutline(
      lineWidth: 1.0,
      cornerRadius: 8.0,
      color: theme.colorScheme.outlineVariant,
    );

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.scientificTuner ?? 'Scientific Tuner'),
        leading: widget.canNavigateUp
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onNavigateUp,
              )
            : null,
        actions: [
          if (widget.onOpenAudioAnalysis != null)
            IconButton(
              icon: const Icon(Icons.audio_file_outlined),
              tooltip: 'Import & Analyze Audio',
              onPressed: widget.onOpenAudioAnalysis,
            ),
          if (widget.waveWriterDuration > 0 && widget.onExportWav != null)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: l10n?.exportWav ?? 'Export WAV snapshot',
              onPressed: widget.onExportWav,
            ),
          if (widget.onOpenInstrumentTunerMode != null)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: l10n?.instrumentTuner ?? 'Instrument Tuner',
              onPressed: widget.onOpenInstrumentTunerMode,
            ),
          if (widget.onOpenPreferences != null)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n?.settings ?? 'Settings',
              onPressed: widget.onOpenPreferences,
            ),
        ],
      ),
      bottomNavigationBar: QuickSettingsBar(
        referenceFrequency: widget.referenceFrequency,
        referenceNote: widget.referenceNote,
        temperamentName: widget.temperamentName,
        preferFlat: widget.preferFlat,
        stretchTuningName: widget.stretchTuningName,
        onReferenceNoteClicked: widget.onOpenReferenceNote,
        onTemperamentClicked: widget.onOpenTemperament,
        onSharpFlatClicked: widget.onTogglePreferFlat,
        onStretchTuningClicked: widget.onOpenStretchTuning,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: orientation == Orientation.landscape
              ? _buildLandscapeLayout(freqData, corrData, outline)
              : _buildPortraitLayout(freqData, corrData, outline),
        ),
      ),
    );
  }

  Widget _buildSpectrumWidget({
    required LineCoordinates freqData,
    required PlotWindowOutline outline,
    required AppLocalizations? l10n,
    required bool hasFreq,
    required double? currentFreq,
  }) {
    if (widget.spectrumAmplitudes != null &&
        widget.spectrumAmplitudes!.isNotEmpty) {
      return SpectrumPlot(
        spectrum: widget.spectrumAmplitudes,
        sampleRate: 44100,
        maxFrequency: 4000.0,
        currentFrequency: hasFreq ? currentFreq : null,
        targetFrequency: widget.targetFrequency,
        title: l10n?.spectrum ?? 'Frequency Spectrum (FFT)',
      );
    }

    return _buildSectionCard(
      title: l10n?.spectrum ?? 'Spectrum',
      subtitle: hasFreq ? '${currentFreq!.toStringAsFixed(1)} Hz' : null,
      outline: outline,
      child: FrequencyPlot(
        frequencyPlotData: freqData,
        targetNote: widget.targetNote,
        targetFrequency: widget.targetFrequency,
        gestureBasedViewPort: _freqViewPort,
        currentFrequency: widget.currentFrequency,
        harmonicFrequencies: widget.harmonicFrequencies,
        plotWindowOutline: outline,
      ),
    );
  }

  Widget _buildAutocorrelationWidget({
    required LineCoordinates corrData,
    required PlotWindowOutline outline,
    required AppLocalizations? l10n,
    required double? currentLagMs,
  }) {
    if (widget.correlationValues != null &&
        widget.correlationValues!.isNotEmpty) {
      return AutocorrelationPlot(
        correlation: widget.correlationValues,
        zeroPositionNormalized: widget.correlationPlotDataYZeroPosition,
        sampleRate: 44100,
        maxLagMs: 25.0,
        currentFrequency: widget.currentFrequency,
        targetFrequency: widget.targetFrequency,
        title: l10n?.autocorrelation ?? 'Autocorrelation R_xx(τ)',
      );
    }

    return _buildSectionCard(
      title: l10n?.autocorrelation ?? 'Autocorrelation',
      subtitle: currentLagMs != null
          ? 'τ = ${currentLagMs.toStringAsFixed(2)} ms'
          : null,
      outline: outline,
      child: CorrelationPlot(
        correlationPlotData: corrData,
        correlationPlotDataYZeroPosition:
            widget.correlationPlotDataYZeroPosition,
        targetNote: widget.targetNote,
        targetFrequency: widget.targetFrequency,
        gestureBasedViewPort: _corrViewPort,
        currentFrequency: widget.currentFrequency,
        plotWindowOutline: outline,
      ),
    );
  }

  Widget _buildPortraitLayout(
    LineCoordinates freqData,
    LineCoordinates corrData,
    PlotWindowOutline outline,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentFreq = widget.currentFrequency;
    final hasFreq = currentFreq != null && currentFreq > 0;
    final currentLagMs = hasFreq ? 1000.0 / currentFreq : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Spectrum section (~25%)
        Expanded(
          flex: 25,
          child: _buildSpectrumWidget(
            freqData: freqData,
            outline: outline,
            l10n: l10n,
            hasFreq: hasFreq,
            currentFreq: currentFreq,
          ),
        ),
        const SizedBox(height: 6.0),

        // 2. Autocorrelation section (~25%)
        Expanded(
          flex: 25,
          child: _buildAutocorrelationWidget(
            corrData: corrData,
            outline: outline,
            l10n: l10n,
            currentLagMs: currentLagMs,
          ),
        ),
        const SizedBox(height: 6.0),

        // 3. Pitch History section (~25%)
        Expanded(
          flex: 25,
          child: _buildSectionCard(
            title: l10n?.pitchHistory ?? 'Pitch History',
            outline: outline,
            child: PitchHistory(
              state: _historyState,
              targetNote: widget.targetNote,
              targetFrequency: widget.targetFrequency,
              tuningState: widget.tuningState,
              toleranceInCents: widget.toleranceInCents,
            ),
          ),
        ),
        const SizedBox(height: 6.0),

        // 4. Classical Note Staff (~25%)
        Expanded(
          flex: 25,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(outline.cornerRadius),
              border: Border.all(
                color: outline.color ?? theme.colorScheme.outlineVariant,
                width: outline.lineWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: NoteStaff(
              note: widget.targetNote,
              tuningState: widget.tuningState,
              staffClef: _staffClef,
              onStaffClefChanged: (clef) {
                setState(() {
                  _staffClef = clef;
                });
              },
              keySignature: _keySignature,
              onKeySignatureChanged: (sig) {
                setState(() {
                  _keySignature = sig;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    LineCoordinates freqData,
    LineCoordinates corrData,
    PlotWindowOutline outline,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentFreq = widget.currentFrequency;
    final hasFreq = currentFreq != null && currentFreq > 0;
    final currentLagMs = hasFreq ? 1000.0 / currentFreq : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left column (Spectrum + Autocorrelation)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSpectrumWidget(
                  freqData: freqData,
                  outline: outline,
                  l10n: l10n,
                  hasFreq: hasFreq,
                  currentFreq: currentFreq,
                ),
              ),
              const SizedBox(height: 6.0),
              Expanded(
                child: _buildAutocorrelationWidget(
                  corrData: corrData,
                  outline: outline,
                  l10n: l10n,
                  currentLagMs: currentLagMs,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),

        // Right column (Pitch History + Note Staff)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSectionCard(
                  title: l10n?.pitchHistory ?? 'Pitch History',
                  outline: outline,
                  child: PitchHistory(
                    state: _historyState,
                    targetNote: widget.targetNote,
                    targetFrequency: widget.targetFrequency,
                    tuningState: widget.tuningState,
                    toleranceInCents: widget.toleranceInCents,
                  ),
                ),
              ),
              const SizedBox(height: 6.0),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(outline.cornerRadius),
                    border: Border.all(
                      color: outline.color ?? theme.colorScheme.outlineVariant,
                      width: outline.lineWidth,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: NoteStaff(
                    note: widget.targetNote,
                    tuningState: widget.tuningState,
                    staffClef: _staffClef,
                    onStaffClefChanged: (clef) {
                      setState(() {
                        _staffClef = clef;
                      });
                    },
                    keySignature: _keySignature,
                    onKeySignatureChanged: (sig) {
                      setState(() {
                        _keySignature = sig;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
