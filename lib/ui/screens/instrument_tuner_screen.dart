// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/permissions/audio_permission_service.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../domain/musical_scale/musical_scale.dart';
import '../../state/audio_permission_provider.dart';
import '../../state/instrument_provider.dart';
import '../../state/scientific_mode_provider.dart';
import '../../state/tuner_worker_provider.dart';
import '../plot/pitch_history_plot.dart';
import '../widgets/instrument_selector_sheet.dart';
import '../widgets/strings_sidebar.dart';
import '../widgets/tuning_indicator_banner.dart';
import 'preferences_screen.dart';

/// Primary Instrument Tuner screen implementing the Material Design 3 UI,
/// real-time pitch history canvas, strings gauge sidebar, and dynamic feedback.
class InstrumentTunerScreen extends ConsumerStatefulWidget {
  const InstrumentTunerScreen({super.key});

  @override
  ConsumerState<InstrumentTunerScreen> createState() =>
      _InstrumentTunerScreenState();
}

class _InstrumentTunerScreenState extends ConsumerState<InstrumentTunerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAudioCapture();
    });
  }

  Future<void> _initAudioCapture() async {
    final permission = await ref
        .read(audioPermissionProvider.notifier)
        .requestPermission();
    if (permission == AudioPermissionStatus.granted) {
      await ref.read(audioStreamControllerProvider).start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instrument = ref.watch(instrumentProvider);
    final lockedNote = ref.watch(lockedStringProvider);
    final evaluation = ref.watch(currentTuningEvaluationProvider);
    final historyData = ref.watch(pitchHistoryDataProvider);
    final controller = ref.watch(audioStreamControllerProvider);
    final permissionState = ref.watch(audioPermissionProvider);

    final targetNote =
        evaluation?.target.note ??
        lockedNote ??
        (instrument.strings.isNotEmpty
            ? instrument.strings.first
            : const MusicalNote(base: BaseNote.a, octave: 4));

    final targetFreq = evaluation?.target.frequency ?? 440.0;
    final tuningState = evaluation?.state ?? TuningState.unknown;

    // Scale for rendering note semitone axis
    final config = ref.watch(tunerDspConfigProvider);
    final scale = MusicalScale(
      temperament: config.temperament,
      referenceFrequency: config.referenceFrequency,
      referenceNote: config.referenceNote,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tuner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // Switch to Scientific Mode
          IconButton(
            tooltip: 'Switch to Scientific Tuner',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              ref.read(scientificModeProvider.notifier).setScientificMode(true);
            },
          ),

          // Audio streaming live indicator and toggle
          IconButton(
            icon: Icon(
              controller.isRunning ? Icons.mic : Icons.mic_off,
              color: controller.isRunning
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            tooltip: controller.isRunning ? 'Pause Audio' : 'Resume Audio',
            onPressed: () async {
              if (controller.isRunning) {
                await controller.stop();
              } else {
                await controller.start();
              }
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Permission request banner if not granted
            if (permissionState.value != null &&
                permissionState.value != AudioPermissionStatus.granted)
              _PermissionBanner(
                status: permissionState.value!,
                onRequest: () => ref
                    .read(audioPermissionProvider.notifier)
                    .requestPermission(),
                onOpenSettings: () =>
                    ref.read(audioPermissionProvider.notifier).openSettings(),
              ),

            // Top Status & Cent Deviation Banner
            TuningIndicatorBanner(
              evaluation: evaluation,
              lockedNote: lockedNote,
              currentInstrumentName: instrument.name,
              onToggleLock: () {
                if (lockedNote != null) {
                  ref.read(lockedStringProvider.notifier).clear();
                } else if (evaluation != null) {
                  ref
                      .read(lockedStringProvider.notifier)
                      .toggleLock(evaluation.target.note);
                }
              },
              onSelectInstrument: () {
                InstrumentSelectorSheet.show(
                  context: context,
                  selectedInstrument: instrument,
                  onSelect: (newInst) {
                    ref
                        .read(instrumentProvider.notifier)
                        .selectInstrument(newInst);
                  },
                );
              },
            ),

            // Main Tuner Viewport: Strings Sidebar + Pitch History Canvas
            Expanded(
              child: Row(
                children: [
                  // Physical Strings Sidebar
                  StringsSidebar(
                    instrument: instrument,
                    targetNote: evaluation?.target.note ?? lockedNote,
                    tuningState: tuningState,
                    lockedNote: lockedNote,
                    onStringTapped: (note) {
                      ref.read(lockedStringProvider.notifier).toggleLock(note);
                    },
                  ),

                  // Real-time Pitch History Custom Canvas
                  Expanded(
                    child: ClipRect(
                      child: PitchHistoryPlot(
                        historyData: historyData,
                        scale: scale,
                        targetFrequency: targetFreq,
                        targetNote: targetNote,
                        tuningState: tuningState,
                        toleranceInCents: config.inTuneToleranceCents,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.status,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final AudioPermissionStatus status;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPermanent = status == AudioPermissionStatus.permanentlyDenied;

    return MaterialBanner(
      backgroundColor: theme.colorScheme.errorContainer,
      leading: Icon(Icons.mic_off, color: theme.colorScheme.onErrorContainer),
      content: Text(
        isPermanent
            ? 'Microphone permission permanently denied. Please grant permission in App Settings to tune.'
            : 'Microphone permission required for real-time acoustic pitch detection.',
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
      actions: [
        if (isPermanent)
          TextButton(
            onPressed: onOpenSettings,
            child: const Text('Open Settings'),
          )
        else
          FilledButton.tonal(
            onPressed: onRequest,
            child: const Text('Grant Access'),
          ),
      ],
    );
  }
}
