import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../audio/audio_messages.dart';
import '../audio/audio_pipeline_coordinator.dart';
import '../data/preferences/app_preferences.dart';
import '../domain/instruments/instrument.dart';
import '../domain/instruments/instrument_io.dart';
import '../domain/models/musical_note.dart';
import '../domain/models/tuning_state.dart';
import '../domain/stretch_tuning/stretch_tuning.dart';
import '../domain/temperaments/temperament.dart';
import '../domain/tuning/frequency_to_note_converter.dart';
import '../ui/plot/line_coordinates.dart';
import 'tuner_state.dart';

/// Main Riverpod notifier managing active application state, settings persistence,
/// and live audio DSP telemetry synchronization.
class TunerController extends Notifier<TunerAppState> {
  static const _kCustomInstrumentsKey = 'pref_custom_instruments_data';

  late final AudioPipelineCoordinator _audioCoordinator;
  late FrequencyToNoteConverter _pitchConverter;
  StreamSubscription<AudioAnalysisResult>? _analysisSubscription;
  AppPreferences? _preferences;

  @override
  TunerAppState build() {
    _audioCoordinator = AudioPipelineCoordinator();
    _rebuildPitchConverter(
      440.0,
      const MusicalNote(base: BaseNote.a, octave: 4),
      10,
    );
    ref.onDispose(() {
      _syncKeepScreenOn(false);
      _analysisSubscription?.cancel();
      _audioCoordinator.dispose();
      _preferences?.removeListener(_onPreferencesChanged);
      _preferences = null;
    });
    return TunerAppState.initial();
  }

  void _rebuildPitchConverter(double freq, MusicalNote note, int tolerance) {
    _pitchConverter = FrequencyToNoteConverter(
      referenceFrequency: freq,
      referenceMidi: note.midiNumber,
      toleranceInCents: tolerance.toDouble(),
    );
  }

  void initializeWithPreferences(
    AppPreferences preferences, {
    bool startAudio = true,
    bool forceMock = false,
  }) {
    if (_preferences != null) {
      _preferences!.removeListener(_onPreferencesChanged);
    }
    _preferences = preferences;

    state = TunerAppState.initial(preferences: preferences);
    _rebuildPitchConverter(
      preferences.referenceFrequency,
      preferences.referenceNote,
      preferences.toleranceInCents,
    );

    preferences.addListener(_onPreferencesChanged);
    _syncKeepScreenOn(preferences.keepScreenOn);

    loadCustomInstruments();

    if (startAudio) {
      startAudioPipeline(forceMock: forceMock);
    }
  }

  void _onPreferencesChanged() {
    _syncKeepScreenOn(state.preferences.keepScreenOn);
    _rebuildPitchConverter(
      state.preferences.referenceFrequency,
      state.preferences.referenceNote,
      state.preferences.toleranceInCents,
    );
    _audioCoordinator.reconfigure(state.preferences);
    state = state.copyWith(
      preferFlat: state.preferences.preferFlat,
      referenceFrequency: state.preferences.referenceFrequency,
      referenceNote: state.preferences.referenceNote,
    );
  }

  void _syncKeepScreenOn(bool enable) {
    try {
      WakelockPlus.toggle(enable: enable).catchError((Object _) {});
    } catch (_) {
      // Graceful fallback for test or unsupported environments.
    }
  }

  /// Starts the platform microphone or mock audio source and connects the Isolate pipeline.
  Future<void> startAudioPipeline({bool forceMock = false}) async {
    await _audioCoordinator.start(
      preferences: state.preferences,
      forceMock: forceMock,
    );

    await _analysisSubscription?.cancel();
    _analysisSubscription = _audioCoordinator.analysisStream.listen(
      (AudioAnalysisResult result) {
        _onAudioAnalysisResult(result);
      },
      onError: (Object error) {
        debugPrint('TunerController audio analysis error: $error');
      },
    );

    state = state.copyWith(isAudioRunning: _audioCoordinator.isRunning);
  }

  void _onAudioAnalysisResult(AudioAnalysisResult result) {
    double? detectedFreq;
    MusicalNote? detectedNote;
    double centsDev = 0.0;
    TuningState stateParam = TuningState.unknown;

    if (!result.isSilence &&
        result.smoothedFrequency > 0 &&
        !result.smoothedFrequency.isNaN) {
      detectedFreq = result.smoothedFrequency;
      final assessment = _pitchConverter.evaluatePitch(detectedFreq);
      stateParam = assessment.tuningState;
      detectedNote = assessment.target.note;
      centsDev = assessment.centsDeviation;
    }

    LineCoordinates? freqData;
    if (result.spectrumAmplitudes != null) {
      freqData = AudioPipelineCoordinator.convertSpectrumToLineCoordinates(
        result.spectrumAmplitudes,
        sampleRate: _audioCoordinator.sampleRate,
        windowSize: state.preferences.windowSize,
      );
    }

    LineCoordinates? corrData;
    var corrZero = 0.5;
    if (result.correlationValues != null && result.correlationTimes != null) {
      corrData = AudioPipelineCoordinator.convertCorrelationToLineCoordinates(
        result.correlationValues,
        result.correlationTimes,
      );
      corrZero = result.correlationZeroPosition;
    } else if (result.waveformSnapshot != null) {
      corrData = AudioPipelineCoordinator.convertWaveformToLineCoordinates(
        result.waveformSnapshot,
        sampleRate: _audioCoordinator.sampleRate,
      );
    }

    state = state.copyWith(
      currentFrequency: detectedFreq,
      clearCurrentFrequency: detectedFreq == null,
      detectedNote: detectedNote,
      clearDetectedNote: detectedNote == null,
      centsDeviation: centsDev,
      tuningState: stateParam,
      spectrumAmplitudes: result.spectrumAmplitudes,
      correlationValues: result.correlationValues,
      waveformSnapshot: result.waveformSnapshot,
      frequencyPlotData: freqData,
      correlationPlotData: corrData,
      correlationPlotDataYZeroPosition: corrZero,
      isAudioRunning: _audioCoordinator.isRunning,
    );
  }

  /// Exports recent audio as a WAV snapshot.
  Uint8List? exportWavSnapshot() {
    return _audioCoordinator.exportWavSnapshot(
      durationSeconds: state.preferences.waveWriterDuration,
    );
  }

  // --- Persistence for Custom Instruments ---
  Future<void> loadCustomInstruments() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = sp.getString(_kCustomInstrumentsKey);
      if (data != null && data.isNotEmpty) {
        final parsed = InstrumentIO.stringToInstruments(data);
        if (parsed.isOk && parsed.instruments.isNotEmpty) {
          state = state.copyWith(customInstruments: parsed.instruments);
        }
      }
    } catch (e) {
      debugPrint('Error loading custom instruments: $e');
    }
  }

  Future<void> _saveCustomInstruments() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final str = InstrumentIO.instrumentsListToString(state.customInstruments);
      await sp.setString(_kCustomInstrumentsKey, str);
    } catch (e) {
      debugPrint('Error saving custom instruments: $e');
    }
  }

  void setScientificMode(bool enabled) {
    state.preferences.setScientificMode(enabled);
    state = state.copyWith();
  }

  void setThemeMode(ThemeMode mode) {
    state.preferences.setThemeMode(mode);
    state = state.copyWith();
  }

  void togglePreferFlat() {
    final next = !state.preferFlat;
    state.preferences.setPreferFlat(next);
    state = state.copyWith(preferFlat: next);
  }

  void setPreferFlat(bool preferFlat) {
    state.preferences.setPreferFlat(preferFlat);
    state = state.copyWith(preferFlat: preferFlat);
  }

  void setReferenceFrequency(double freq) {
    state.preferences.setReferenceFrequency(freq);
    state = state.copyWith(referenceFrequency: freq);
  }

  void setReferenceNote(MusicalNote note) {
    state.preferences.setReferenceNote(note);
    state = state.copyWith(referenceNote: note);
  }

  void setCurrentInstrument(Instrument instrument) {
    state = state.copyWith(currentInstrument: instrument);
  }

  void addCustomInstrument(Instrument instrument) {
    final list = List<Instrument>.from(state.customInstruments)
      ..add(instrument);
    state = state.copyWith(
      customInstruments: list,
      currentInstrument: instrument,
    );
    _saveCustomInstruments();
  }

  void updateCustomInstrument(Instrument instrument) {
    final list = List<Instrument>.from(state.customInstruments);
    final idx = list.indexWhere((i) => i.stableId == instrument.stableId);
    if (idx >= 0) {
      list[idx] = instrument;
    }
    final isCurrent = state.currentInstrument.stableId == instrument.stableId;
    state = state.copyWith(
      customInstruments: list,
      currentInstrument: isCurrent ? instrument : null,
    );
    _saveCustomInstruments();
  }

  void deleteCustomInstrument(Instrument instrument) {
    final list = List<Instrument>.from(state.customInstruments)
      ..removeWhere((i) => i.stableId == instrument.stableId);
    state = state.copyWith(customInstruments: list);
    _saveCustomInstruments();
  }

  void setCurrentTemperament(Temperament temperament) {
    state.preferences.setTemperamentName(temperament.name);
    state = state.copyWith(currentTemperament: temperament);
  }

  void setCurrentStretchTuning(StretchTuning stretchTuning) {
    state.preferences.setStretchTuningName(stretchTuning.name);
    state = state.copyWith(currentStretchTuning: stretchTuning);
  }

  void setCustomStretchTunings(List<StretchTuning> tunings) {
    state = state.copyWith(customStretchTunings: tunings);
  }

  void feedPitch(double? frequency, [TuningState? tuningState]) {
    state = state.copyWith(
      currentFrequency: frequency,
      clearCurrentFrequency: frequency == null,
      tuningState: tuningState ?? state.tuningState,
    );
  }

  void updateAcoustics({
    double? frequency,
    TuningState? stateParam,
    Float32List? spectrum,
    Float32List? waveform,
    LineCoordinates? freqData,
    LineCoordinates? corrData,
  }) {
    state = state.copyWith(
      currentFrequency: frequency,
      clearCurrentFrequency: frequency == null,
      tuningState: stateParam ?? state.tuningState,
      spectrumAmplitudes: spectrum ?? state.spectrumAmplitudes,
      waveformSnapshot: waveform ?? state.waveformSnapshot,
      frequencyPlotData: freqData ?? state.frequencyPlotData,
      correlationPlotData: corrData ?? state.correlationPlotData,
    );
  }
}

/// Global provider for TunerController
final tunerControllerProvider =
    NotifierProvider<TunerController, TunerAppState>(TunerController.new);
