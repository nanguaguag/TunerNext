// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../domain/musical_scale/musical_scale.dart';
import '../../state/instrument_provider.dart';
import '../../state/scientific_mode_provider.dart';
import '../../state/tuner_worker_provider.dart';
import '../plot/autocorrelation_plot.dart';
import '../plot/pitch_history_plot.dart';
import '../plot/spectrum_plot.dart';
import '../staff/note_staff.dart';
import '../staff/staff_models.dart';
import '../widgets/tuning_indicator_banner.dart';
import 'preferences_screen.dart';

/// Screen displaying real-time scientific audio analysis tools:
/// 1. Power Spectrum FFT Oscilloscope with harmonic markers
/// 2. Autocorrelation curve with lag marker
/// 3. Pitch History deviation trace
/// 4. Classical Note Staff with Gonville clefs and accidentals
/// 5. WAV Audio export button
class ScientificTunerScreen extends ConsumerWidget {
  const ScientificTunerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerResultAsync = ref.watch(tunerWorkerResultStreamProvider);
    final latestResult = workerResultAsync.value;

    final historyData = ref.watch(pitchHistoryDataProvider);
    final staffClef = ref.watch(staffClefProvider);
    final keySignature = ref.watch(keySignatureProvider);
    final selectedInstrument = ref.watch(instrumentProvider);

    final currentFreq = latestResult?.pitchResult.frequency ?? 0.0;
    final isSilence = latestResult?.isSilence ?? true;
    final state = isSilence
        ? TuningState.unknown
        : (latestResult?.state ?? TuningState.unknown);
    final target = latestResult?.target;
    final activeTargetNote =
        target?.note ?? const MusicalNote(base: BaseNote.a, octave: 4);

    // Feed real-time pitch points to rolling history
    if (!isSilence && currentFreq > 0.0) {
      historyData.add(frequency: currentFreq, isSilence: false);
    }

    final spectrum = latestResult?.spectrum;
    final correlation = latestResult?.correlation;
    final correlationZero = latestResult?.correlationZero ?? 0.5;

    // Musical scale for PitchHistoryPlot coordinates
    final config = ref.watch(tunerDspConfigProvider);
    final scale = MusicalScale(
      temperament: config.temperament,
      referenceFrequency: config.referenceFrequency,
      referenceNote: config.referenceNote,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Tuner'),
        actions: [
          IconButton(
            tooltip: 'Switch to Instrument Tuner',
            icon: const Icon(Icons.piano),
            onPressed: () {
              ref
                  .read(scientificModeProvider.notifier)
                  .setScientificMode(false);
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Export audio buffer snapshot as WAV',
        onPressed: () async {
          final waveWriter = ref.read(waveWriterProvider);
          if (waveWriter.numStoredValues == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No audio buffer data to export')),
            );
            return;
          }

          final exportService = ref.read(waveExportServiceProvider);
          try {
            final path = await exportService.exportSnapshot(
              waveWriter: waveWriter,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exported WAV: $path'),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
            }
          }
        },
        child: const Icon(Icons.save_alt),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top tuning indicator banner
            TuningIndicatorBanner(
              evaluation: latestResult?.evaluation,
              onToggleLock: () {},
              onSelectInstrument: () {},
              currentInstrumentName: selectedInstrument.name,
            ),
            const SizedBox(height: 6),

            // Responsive plots layout
            Expanded(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return _buildLandscapeLayout(
                      ref: ref,
                      spectrum: spectrum,
                      correlation: correlation,
                      correlationZero: correlationZero,
                      currentFreq: isSilence ? null : currentFreq,
                      targetFreq: target?.frequency,
                      historyData: historyData,
                      scale: scale,
                      activeTargetNote: activeTargetNote,
                      state: state,
                      staffClef: staffClef,
                      keySignature: keySignature,
                    );
                  } else {
                    return _buildPortraitLayout(
                      ref: ref,
                      spectrum: spectrum,
                      correlation: correlation,
                      correlationZero: correlationZero,
                      currentFreq: isSilence ? null : currentFreq,
                      targetFreq: target?.frequency,
                      historyData: historyData,
                      scale: scale,
                      activeTargetNote: activeTargetNote,
                      state: state,
                      staffClef: staffClef,
                      keySignature: keySignature,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout({
    required WidgetRef ref,
    required dynamic spectrum,
    required dynamic correlation,
    required double correlationZero,
    required double? currentFreq,
    required double? targetFreq,
    required dynamic historyData,
    required MusicalScale scale,
    required MusicalNote activeTargetNote,
    required TuningState state,
    required StaffClef staffClef,
    required int keySignature,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // 1. FFT Power Spectrum
          Expanded(
            flex: 3,
            child: SpectrumPlot(
              spectrum: spectrum,
              currentFrequency: currentFreq,
              targetFrequency: targetFreq,
            ),
          ),
          const SizedBox(height: 6),

          // 2. Autocorrelation Curve
          Expanded(
            flex: 3,
            child: AutocorrelationPlot(
              correlation: correlation,
              zeroPositionNormalized: correlationZero,
              currentFrequency: currentFreq,
              targetFrequency: targetFreq,
            ),
          ),
          const SizedBox(height: 6),

          // 3. Pitch History Trace
          Expanded(
            flex: 3,
            child: PitchHistoryPlot(
              historyData: historyData,
              scale: scale,
              targetFrequency: targetFreq ?? 440.0,
              targetNote: activeTargetNote,
              tuningState: state,
            ),
          ),
          const SizedBox(height: 6),

          // 4. Classical Note Staff
          Expanded(
            flex: 4,
            child: NoteStaff(
              note: activeTargetNote,
              tuningState: state,
              staffClef: staffClef,
              onStaffClefChanged: (clef) {
                ref.read(staffClefProvider.notifier).setClef(clef);
              },
              keySignature: keySignature,
              onKeySignatureChanged: (sig) {
                ref.read(keySignatureProvider.notifier).setKeySignature(sig);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout({
    required WidgetRef ref,
    required dynamic spectrum,
    required dynamic correlation,
    required double correlationZero,
    required double? currentFreq,
    required double? targetFreq,
    required dynamic historyData,
    required MusicalScale scale,
    required MusicalNote activeTargetNote,
    required TuningState state,
    required StaffClef staffClef,
    required int keySignature,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // Left: Oscilloscopes (Spectrum + Autocorrelation)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SpectrumPlot(
                    spectrum: spectrum,
                    currentFrequency: currentFreq,
                    targetFrequency: targetFreq,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: AutocorrelationPlot(
                    correlation: correlation,
                    zeroPositionNormalized: correlationZero,
                    currentFrequency: currentFreq,
                    targetFrequency: targetFreq,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Right: Pitch History + Note Staff
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PitchHistoryPlot(
                    historyData: historyData,
                    scale: scale,
                    targetFrequency: targetFreq ?? 440.0,
                    targetNote: activeTargetNote,
                    tuningState: state,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: NoteStaff(
                    note: activeTargetNote,
                    tuningState: state,
                    staffClef: staffClef,
                    onStaffClefChanged: (clef) {
                      ref.read(staffClefProvider.notifier).setClef(clef);
                    },
                    keySignature: keySignature,
                    onKeySignatureChanged: (sig) {
                      ref
                          .read(keySignatureProvider.notifier)
                          .setKeySignature(sig);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
