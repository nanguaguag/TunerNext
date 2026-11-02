import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/preferences/app_preferences.dart';
import '../domain/instruments/instrument.dart';
import '../domain/models/musical_note.dart';
import '../domain/models/tuning_state.dart';
import '../domain/stretch_tuning/stretch_tuning.dart';
import '../domain/temperaments/temperament.dart';
import 'tuner_state.dart';

/// Main Riverpod notifier managing active application state and audio synchronization.
class TunerController extends Notifier<TunerAppState> {
  @override
  TunerAppState build() {
    return TunerAppState.initial();
  }

  void initializeWithPreferences(AppPreferences preferences) {
    state = TunerAppState.initial(preferences: preferences);
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
  }

  void deleteCustomInstrument(Instrument instrument) {
    final list = List<Instrument>.from(state.customInstruments)
      ..removeWhere((i) => i.stableId == instrument.stableId);
    state = state.copyWith(customInstruments: list);
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
  }) {
    state = state.copyWith(
      currentFrequency: frequency,
      clearCurrentFrequency: frequency == null,
      tuningState: stateParam ?? state.tuningState,
      spectrumAmplitudes: spectrum ?? state.spectrumAmplitudes,
      waveformSnapshot: waveform ?? state.waveformSnapshot,
    );
  }
}

/// Global provider for TunerController
final tunerControllerProvider =
    NotifierProvider<TunerController, TunerAppState>(TunerController.new);
