import 'package:flutter/foundation.dart';

import '../data/preferences/app_preferences.dart';
import '../domain/instruments/instrument.dart';
import '../domain/instruments/predefined_instruments.dart';
import '../domain/models/musical_note.dart';
import '../domain/models/tuning_state.dart';
import '../domain/stretch_tuning/predefined_stretch_tunings.dart';
import '../domain/stretch_tuning/stretch_tuning.dart';
import '../domain/temperaments/predefined_temperament.dart';
import '../domain/temperaments/temperament.dart';
import '../ui/plot/line_coordinates.dart';

/// Immutable state bundle representing the entire active state of the Tuner application.
@immutable
class TunerAppState {
  const TunerAppState({
    required this.preferences,
    required this.currentInstrument,
    this.customInstruments = const [],
    required this.currentTemperament,
    this.customTemperaments = const [],
    required this.currentStretchTuning,
    this.customStretchTunings = const [],
    this.preferFlat = false,
    this.referenceFrequency = 440.0,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.currentFrequency,
    this.tuningState = TuningState.unknown,
    this.spectrumAmplitudes,
    this.waveformSnapshot,
    this.frequencyPlotData,
    this.correlationPlotData,
    this.correlationPlotDataYZeroPosition = 0.5,
    this.harmonicFrequencies,
    this.isAudioRunning = false,
  });

  factory TunerAppState.initial({AppPreferences? preferences}) {
    final prefs = preferences ?? AppPreferences();
    return TunerAppState(
      preferences: prefs,
      currentInstrument: PredefinedInstruments.guitarStandard,
      currentTemperament: PredefinedTemperaments.edo12(),
      currentStretchTuning: PredefinedStretchTunings.noStretch(),
      preferFlat: prefs.preferFlat,
      referenceFrequency: prefs.referenceFrequency,
      referenceNote: prefs.referenceNote,
    );
  }

  final AppPreferences preferences;
  final Instrument currentInstrument;
  final List<Instrument> customInstruments;
  final Temperament currentTemperament;
  final List<Temperament> customTemperaments;
  final StretchTuning currentStretchTuning;
  final List<StretchTuning> customStretchTunings;
  final bool preferFlat;
  final double referenceFrequency;
  final MusicalNote referenceNote;
  final double? currentFrequency;
  final TuningState tuningState;
  final Float32List? spectrumAmplitudes;
  final Float32List? waveformSnapshot;
  final LineCoordinates? frequencyPlotData;
  final LineCoordinates? correlationPlotData;
  final double correlationPlotDataYZeroPosition;
  final List<double>? harmonicFrequencies;
  final bool isAudioRunning;

  TunerAppState copyWith({
    AppPreferences? preferences,
    Instrument? currentInstrument,
    List<Instrument>? customInstruments,
    Temperament? currentTemperament,
    List<Temperament>? customTemperaments,
    StretchTuning? currentStretchTuning,
    List<StretchTuning>? customStretchTunings,
    bool? preferFlat,
    double? referenceFrequency,
    MusicalNote? referenceNote,
    double? currentFrequency,
    bool clearCurrentFrequency = false,
    TuningState? tuningState,
    Float32List? spectrumAmplitudes,
    Float32List? waveformSnapshot,
    LineCoordinates? frequencyPlotData,
    LineCoordinates? correlationPlotData,
    double? correlationPlotDataYZeroPosition,
    List<double>? harmonicFrequencies,
    bool? isAudioRunning,
  }) {
    return TunerAppState(
      preferences: preferences ?? this.preferences,
      currentInstrument: currentInstrument ?? this.currentInstrument,
      customInstruments: customInstruments ?? this.customInstruments,
      currentTemperament: currentTemperament ?? this.currentTemperament,
      customTemperaments: customTemperaments ?? this.customTemperaments,
      currentStretchTuning: currentStretchTuning ?? this.currentStretchTuning,
      customStretchTunings: customStretchTunings ?? this.customStretchTunings,
      preferFlat: preferFlat ?? this.preferFlat,
      referenceFrequency: referenceFrequency ?? this.referenceFrequency,
      referenceNote: referenceNote ?? this.referenceNote,
      currentFrequency: clearCurrentFrequency
          ? null
          : (currentFrequency ?? this.currentFrequency),
      tuningState: tuningState ?? this.tuningState,
      spectrumAmplitudes: spectrumAmplitudes ?? this.spectrumAmplitudes,
      waveformSnapshot: waveformSnapshot ?? this.waveformSnapshot,
      frequencyPlotData: frequencyPlotData ?? this.frequencyPlotData,
      correlationPlotData: correlationPlotData ?? this.correlationPlotData,
      correlationPlotDataYZeroPosition:
          correlationPlotDataYZeroPosition ??
          this.correlationPlotDataYZeroPosition,
      harmonicFrequencies: harmonicFrequencies ?? this.harmonicFrequencies,
      isAudioRunning: isAudioRunning ?? this.isAudioRunning,
    );
  }
}
