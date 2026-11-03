import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio/audio_file_loader.dart';
import 'core/theme/tuner_theme.dart';
import 'data/preferences/app_preferences.dart';
import 'domain/instruments/instrument.dart';
import 'domain/models/musical_note.dart';
import 'domain/stretch_tuning/stretch_tuning.dart';
import 'domain/temperaments/temperament.dart';
import 'dsp/analysis/offline_audio_analyzer.dart';
import 'l10n/app_localizations.dart';
import 'state/tuner_controller.dart';
import 'state/tuner_state.dart';
import 'ui/dialogs/reference_note_dialog.dart';
import 'ui/dialogs/temperament_dialog.dart';
import 'ui/instruments/instruments_screen.dart';
import 'ui/screens/audio_analysis_screen.dart';
import 'ui/screens/instrument_tuner_screen.dart';
import 'ui/screens/preferences_screen.dart';
import 'ui/screens/scientific_tuner_screen.dart';
import 'ui/screens/stretch_tuning_overview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = AppPreferences();
  await prefs.load();
  runApp(ProviderScope(child: TunerApp(initialPreferences: prefs)));
}

/// Root widget of the Tuner Flutter application.
///
/// Orchestrates dynamic M3 theming, global preference synchronization,
/// and smooth switching between [InstrumentTunerScreen] and [ScientificTunerScreen].
class TunerApp extends ConsumerStatefulWidget {
  const TunerApp({super.key, this.initialPreferences});

  final AppPreferences? initialPreferences;

  @override
  ConsumerState<TunerApp> createState() => _TunerAppState();
}

class _TunerAppState extends ConsumerState<TunerApp> {
  Locale? _resolveLocale(String? code) {
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPreferences != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(tunerControllerProvider.notifier)
            .initializeWithPreferences(widget.initialPreferences!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tunerControllerProvider);

    return MaterialApp(
      title: 'Tuner',
      debugShowCheckedModeBanner: false,
      theme: TunerTheme.light(),
      darkTheme: TunerTheme.dark(),
      themeMode: state.preferences.themeMode,
      locale: _resolveLocale(state.preferences.language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TunerHomeScreen(),
    );
  }
}

/// Dynamic home coordinator switching between Instrument Tuner and Scientific Tuner.
class TunerHomeScreen extends ConsumerWidget {
  const TunerHomeScreen({super.key});

  void _openPreferences(BuildContext context, TunerAppState state) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PreferencesScreen(
          preferences: state.preferences,
          currentFrequency: state.currentFrequency,
        ),
      ),
    );
  }

  void _openInstruments(
    BuildContext context,
    WidgetRef ref,
    TunerAppState state,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InstrumentsScreen(
          selectedInstrument: state.currentInstrument,
          customInstruments: state.customInstruments,
          onSelectInstrument: (Instrument inst) {
            ref
                .read(tunerControllerProvider.notifier)
                .setCurrentInstrument(inst);
          },
          onAddCustomInstrument: (Instrument inst) {
            ref
                .read(tunerControllerProvider.notifier)
                .addCustomInstrument(inst);
          },
          onUpdateCustomInstrument: (Instrument inst) {
            ref
                .read(tunerControllerProvider.notifier)
                .updateCustomInstrument(inst);
          },
          onDeleteCustomInstrument: (Instrument inst) {
            ref
                .read(tunerControllerProvider.notifier)
                .deleteCustomInstrument(inst);
          },
        ),
      ),
    );
  }

  void _openStretchTuning(
    BuildContext context,
    WidgetRef ref,
    TunerAppState state,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StretchTuningOverviewScreen(
          selectedStretchTuningId: state.currentStretchTuning.stableId,
          customStretchTunings: state.customStretchTunings,
          onSelectStretchTuning: (StretchTuning st) {
            ref
                .read(tunerControllerProvider.notifier)
                .setCurrentStretchTuning(st);
          },
          onCustomStretchTuningsChanged: (List<StretchTuning> tunings) {
            ref
                .read(tunerControllerProvider.notifier)
                .setCustomStretchTunings(tunings);
          },
        ),
      ),
    );
  }

  void _openReferenceNoteDialog(
    BuildContext context,
    WidgetRef ref,
    TunerAppState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => ReferenceNoteDialog(
        initialNote: state.referenceNote,
        initialFrequency: state.referenceFrequency,
        detectedFrequency: state.currentFrequency,
        onConfirm: (MusicalNote note, double freq) {
          ref.read(tunerControllerProvider.notifier).setReferenceNote(note);
          ref
              .read(tunerControllerProvider.notifier)
              .setReferenceFrequency(freq);
        },
      ),
    );
  }

  void _openTemperamentDialog(
    BuildContext context,
    WidgetRef ref,
    TunerAppState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => TemperamentDialog(
        selectedTemperament: state.currentTemperament,
        onSelectTemperament: (Temperament temp) {
          ref
              .read(tunerControllerProvider.notifier)
              .setCurrentTemperament(temp);
        },
      ),
    );
  }

  void _openAudioAnalysis(BuildContext context, WidgetRef ref) async {
    final state = ref.read(tunerControllerProvider);

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Import Audio for Analysis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select an audio source to analyze offline:'),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note, color: Colors.blue),
                title: const Text('Sample Whistle Audio (Built-in)'),
                subtitle: const Text('High-clarity whistle test WAV (18.5s)'),
                onTap: () => Navigator.of(ctx).pop('builtin://whistle'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.folder_open, color: Colors.orange),
                title: const Text('Choose Audio File from Device...'),
                subtitle: const Text('Standard .wav (uncompressed PCM)'),
                onTap: () async {
                  final files = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['wav', 'm4a', 'mp3', 'aac', 'flac'],
                  );
                  if (files.isNotEmpty && files.first.path != null) {
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop(files.first.path);
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (choice == null || choice.isEmpty || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Decoding and analyzing audio...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final DecodedAudio decoded;
      final String fileName;
      if (choice == 'builtin://whistle') {
        decoded = await AudioFileLoader.loadDefaultTestWhistle();
        fileName = 'Sample Whistle (WAV)';
      } else {
        decoded = await AudioFileLoader.loadFromFile(choice);
        fileName = choice.split('/').last;
      }

      final result = await OfflineAudioAnalyzer.analyze(
        samples: decoded.samples,
        sampleRate: decoded.sampleRate,
        algorithm: state.preferences.pitchAlgorithm,
        weightingMode: state.preferences.acousticWeighting,
        mpmCutoffClarity: state.preferences.mpmCutoffClarity,
        mpmPeakThresholdRatio: state.preferences.mpmPeakThresholdRatio,
        twmMaxHarmonics: state.preferences.twmMaxHarmonics,
        twmInharmonicity: state.preferences.twmInharmonicity,
        twmMaxMismatchError: state.preferences.twmMaxMismatchError,
        useMedianFilter: state.preferences.medianFilter,
        useOctaveJumpGate: state.preferences.octaveJumpGate,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AudioAnalysisScreen(
              analysisResult: result,
              fileName: fileName,
              initialInstrument: state.currentInstrument,
              onSelectNewFile: () {
                Navigator.of(context).pop();
                _openAudioAnalysis(context, ref);
              },
              onReanalyzeWithConfig: (algo, weight) async {
                final newResult = await OfflineAudioAnalyzer.analyze(
                  samples: decoded.samples,
                  sampleRate: decoded.sampleRate,
                  algorithm: algo,
                  weightingMode: weight,
                  mpmCutoffClarity: state.preferences.mpmCutoffClarity,
                  mpmPeakThresholdRatio:
                      state.preferences.mpmPeakThresholdRatio,
                  twmMaxHarmonics: state.preferences.twmMaxHarmonics,
                  twmInharmonicity: state.preferences.twmInharmonicity,
                  twmMaxMismatchError: state.preferences.twmMaxMismatchError,
                  useMedianFilter: state.preferences.medianFilter,
                  useOctaveJumpGate: state.preferences.octaveJumpGate,
                );
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => AudioAnalysisScreen(
                        analysisResult: newResult,
                        fileName: fileName,
                        initialInstrument: state.currentInstrument,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Audio Decoding Notice'),
            content: Text(
              e is FormatException
                  ? e.message
                  : 'Failed to load audio: $e\n\nPlease select an uncompressed standard WAV (.wav) file, or use the built-in whistle sample.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tunerControllerProvider);
    final notifier = ref.read(tunerControllerProvider.notifier);

    if (state.preferences.scientificMode) {
      return ScientificTunerScreen(
        targetNote: state.referenceNote,
        currentNote: state.detectedNote,
        centsDeviation: state.centsDeviation,
        isChromatic: state.currentInstrument.strings.isEmpty,
        showStaffTargetNote: state.preferences.showStaffTargetNote,
        showStaffCurrentNote: state.preferences.showStaffCurrentNote,
        targetFrequency: state.referenceFrequency,
        referenceFrequency: state.referenceFrequency,
        referenceNote: state.referenceNote,
        temperamentName: state.currentTemperament.abbreviation.isNotEmpty
            ? state.currentTemperament.abbreviation
            : state.currentTemperament.name,
        stretchTuningName: state.currentStretchTuning.name,
        preferFlat: state.preferFlat,
        currentFrequency: state.currentFrequency,
        tuningState: state.tuningState,
        toleranceInCents: state.preferences.toleranceInCents,
        spectrumAmplitudes: state.spectrumAmplitudes,
        correlationValues: state.correlationValues,
        frequencyPlotData: state.frequencyPlotData,
        correlationPlotData: state.correlationPlotData,
        correlationPlotDataYZeroPosition:
            state.correlationPlotDataYZeroPosition,
        harmonicFrequencies: state.harmonicFrequencies,
        waveWriterDuration: state.preferences.waveWriterDuration,
        onExportWav: () {
          final wav = notifier.exportWavSnapshot();
          if (wav != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'WAV snapshot exported (${wav.lengthInBytes} bytes)',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onOpenAudioAnalysis: () => _openAudioAnalysis(context, ref),
        onOpenInstrumentTunerMode: () => notifier.setScientificMode(false),
        onOpenPreferences: () => _openPreferences(context, state),
        onTogglePreferFlat: notifier.togglePreferFlat,
        onOpenReferenceNote: () =>
            _openReferenceNoteDialog(context, ref, state),
        onOpenTemperament: () => _openTemperamentDialog(context, ref, state),
        onOpenStretchTuning: () => _openStretchTuning(context, ref, state),
      );
    }

    return InstrumentTunerScreen(
      initialInstrument: state.currentInstrument,
      initialTemperament: state.currentTemperament,
      initialReferenceNote: state.referenceNote,
      initialReferenceFrequency: state.referenceFrequency,
      initialStretchTuningName: state.currentStretchTuning.name,
      initialPreferFlat: state.preferFlat,
      currentFrequency: state.currentFrequency,
      onOpenScientificMode: () => notifier.setScientificMode(true),
      onOpenAudioAnalysis: () => _openAudioAnalysis(context, ref),
      onOpenPreferences: () => _openPreferences(context, state),
      onOpenInstrumentList: () => _openInstruments(context, ref, state),
      onOpenStretchTuning: () => _openStretchTuning(context, ref, state),
      onTogglePreferFlat: notifier.togglePreferFlat,
      onTemperamentChanged: notifier.setCurrentTemperament,
      onReferenceNoteChanged: (note, freq) {
        notifier.setReferenceNote(note);
        notifier.setReferenceFrequency(freq);
      },
    );
  }
}
