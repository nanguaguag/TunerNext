import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../l10n/app_localizations.dart';
import '../common/quick_settings_bar.dart';
import '../plot/gesture_based_viewport.dart';
import '../plot/line_coordinates.dart';
import '../plot/plot_window_outline.dart';
import '../tuning/correlation_plot.dart';
import '../tuning/frequency_plot.dart';
import '../tuning/pitch_history.dart';
import '../tuning/pitch_history_state.dart';

/// Scientific analysis screen displaying synchronized FFT spectrum, autocorrelation,
/// and log-frequency pitch history with interactive zooming and WAV snapshot export.
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
    this.frequencyPlotData,
    this.harmonicFrequencies,
    this.correlationPlotData,
    this.correlationPlotDataYZeroPosition = 0.5,
    this.pitchHistoryState,
    this.waveWriterDuration = 1,
    this.canNavigateUp = false,
    this.onNavigateUp,
    this.onOpenPreferences,
    this.onOpenInstrumentTunerMode,
    this.onTogglePreferFlat,
    this.onOpenReferenceNote,
    this.onOpenTemperament,
    this.onOpenStretchTuning,
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

  final LineCoordinates? frequencyPlotData;
  final List<double>? harmonicFrequencies;
  final LineCoordinates? correlationPlotData;
  final double correlationPlotDataYZeroPosition;
  final PitchHistoryState? pitchHistoryState;
  final int waveWriterDuration;

  final bool canNavigateUp;
  final VoidCallback? onNavigateUp;
  final VoidCallback? onOpenPreferences;
  final VoidCallback? onOpenInstrumentTunerMode;
  final VoidCallback? onTogglePreferFlat;
  final VoidCallback? onOpenReferenceNote;
  final VoidCallback? onOpenTemperament;
  final VoidCallback? onOpenStretchTuning;
  final VoidCallback? onExportWav;

  @override
  State<ScientificTunerScreen> createState() => _ScientificTunerScreenState();
}

class _ScientificTunerScreenState extends State<ScientificTunerScreen> {
  late final GestureBasedViewPort _freqViewPort;
  late final GestureBasedViewPort _corrViewPort;
  late final PitchHistoryState _historyState;

  @override
  void initState() {
    super.initState();
    _freqViewPort = GestureBasedViewPort();
    _corrViewPort = GestureBasedViewPort();
    _historyState =
        widget.pitchHistoryState ?? PitchHistoryState(capacity: 120);
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
      color: theme.colorScheme.outline,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: widget.waveWriterDuration > 0
          ? FloatingActionButton.small(
              tooltip: l10n?.exportWav ?? 'Export WAV snapshot',
              onPressed: widget.onExportWav,
              child: const Icon(Icons.mic),
            )
          : null,
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
              ? _buildLandscapeLayout(
                  freqData,
                  corrData,
                  outline,
                  theme.textTheme,
                )
              : _buildPortraitLayout(
                  freqData,
                  corrData,
                  outline,
                  theme.textTheme,
                ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    LineCoordinates freqData,
    LineCoordinates corrData,
    PlotWindowOutline outline,
    TextTheme textTheme,
  ) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Spectrum section (~22.5%)
        Expanded(
          flex: 225,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.spectrum ?? 'Spectrum',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Expanded(
                child: FrequencyPlot(
                  frequencyPlotData: freqData,
                  targetNote: widget.targetNote,
                  targetFrequency: widget.targetFrequency,
                  gestureBasedViewPort: _freqViewPort,
                  currentFrequency: widget.currentFrequency,
                  harmonicFrequencies: widget.harmonicFrequencies,
                  plotWindowOutline: outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        // Autocorrelation section (~22.5%)
        Expanded(
          flex: 225,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.autocorrelation ?? 'Autocorrelation',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Expanded(
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        // Pitch history section (~55%)
        Expanded(
          flex: 550,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.pitchHistory ?? 'Pitch History',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Expanded(
                child: PitchHistory(
                  state: _historyState,
                  targetNote: widget.targetNote,
                  targetFrequency: widget.targetFrequency,
                  tuningState: widget.tuningState,
                  toleranceInCents: widget.toleranceInCents,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    LineCoordinates freqData,
    LineCoordinates corrData,
    PlotWindowOutline outline,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left column (Spectrum + Autocorrelation)
        Expanded(
          flex: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spectrum',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Expanded(
                      child: FrequencyPlot(
                        frequencyPlotData: freqData,
                        targetNote: widget.targetNote,
                        targetFrequency: widget.targetFrequency,
                        gestureBasedViewPort: _freqViewPort,
                        currentFrequency: widget.currentFrequency,
                        harmonicFrequencies: widget.harmonicFrequencies,
                        plotWindowOutline: outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autocorrelation',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Expanded(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        // Right column (Pitch History)
        Expanded(
          flex: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pitch History',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2.0),
              Expanded(
                child: PitchHistory(
                  state: _historyState,
                  targetNote: widget.targetNote,
                  targetFrequency: widget.targetFrequency,
                  tuningState: widget.tuningState,
                  toleranceInCents: widget.toleranceInCents,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
