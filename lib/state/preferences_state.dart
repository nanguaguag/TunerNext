// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../domain/models/dsp_enums.dart';
import '../domain/models/musical_note.dart';
import '../domain/preferences/preferences_models.dart';
import '../domain/temperaments/temperament_models.dart';
import '../ui/staff/staff_models.dart';
import 'scientific_mode_provider.dart';
import 'tuner_worker_provider.dart';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main via overrides');
});

/// Comprehensive immutable model holding all app settings and preferences.
class PreferencesState {
  const PreferencesState({
    this.themeMode = AppThemeMode.system,
    this.localeCode,
    this.screenAlwaysOn = false,
    this.displayOnLockScreen = false,
    this.referenceFrequency = 440.0,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.temperament = const TemperamentEDO(notesPerOctave: 12, stableId: -1),
    this.toleranceInCents = 5,
    this.preferFlat = false,
    this.notationType = NotationType.regional,
    this.octaveNotation = OctaveNotation.scientific,
    this.chromaticAsStaff = false,
    this.sensitivity = 90,
    this.pitchAlgorithm = PitchAlgorithm.classic,
    this.acousticWeightingMode = AcousticWeightingMode.aWeighting,
    this.octaveJumpGate = true,
    this.medianFilter = true,
    this.scientificMode = false,
    this.numMovingAverage = 5,
    this.windowSizeExponent = 12, // 2^12 = 4096
    this.windowing = WindowingFunction.tophat,
    this.overlapPercent = 75,
    this.pitchHistoryDuration = 1.5,
    this.pitchHistoryNumFaultyValues = 3,
    this.waveWriterDuration = 0,
    this.staffClef = StaffClef.grand,
    this.keySignature = 0,
  });

  final AppThemeMode themeMode;
  final String? localeCode;
  final bool screenAlwaysOn;
  final bool displayOnLockScreen;
  final double referenceFrequency;
  final MusicalNote referenceNote;
  final Temperament temperament;
  final int toleranceInCents;
  final bool preferFlat;
  final NotationType notationType;
  final OctaveNotation octaveNotation;
  final bool chromaticAsStaff;
  final int sensitivity;
  final PitchAlgorithm pitchAlgorithm;
  final AcousticWeightingMode acousticWeightingMode;
  final bool octaveJumpGate;
  final bool medianFilter;
  final bool scientificMode;
  final int numMovingAverage;
  final int windowSizeExponent;
  final WindowingFunction windowing;
  final int overlapPercent;
  final double pitchHistoryDuration;
  final int pitchHistoryNumFaultyValues;
  final int waveWriterDuration;
  final StaffClef staffClef;
  final int keySignature;

  int get windowSize => math.pow(2, windowSizeExponent).round();
  double get overlapRatio => overlapPercent / 100.0;
  Locale? get locale => localeCode != null ? Locale(localeCode!) : null;

  PreferencesState copyWith({
    AppThemeMode? themeMode,
    String? Function()? localeCode,
    bool? screenAlwaysOn,
    bool? displayOnLockScreen,
    double? referenceFrequency,
    MusicalNote? referenceNote,
    Temperament? temperament,
    int? toleranceInCents,
    bool? preferFlat,
    NotationType? notationType,
    OctaveNotation? octaveNotation,
    bool? chromaticAsStaff,
    int? sensitivity,
    PitchAlgorithm? pitchAlgorithm,
    AcousticWeightingMode? acousticWeightingMode,
    bool? octaveJumpGate,
    bool? medianFilter,
    bool? scientificMode,
    int? numMovingAverage,
    int? windowSizeExponent,
    WindowingFunction? windowing,
    int? overlapPercent,
    double? pitchHistoryDuration,
    int? pitchHistoryNumFaultyValues,
    int? waveWriterDuration,
    StaffClef? staffClef,
    int? keySignature,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode != null ? localeCode() : this.localeCode,
      screenAlwaysOn: screenAlwaysOn ?? this.screenAlwaysOn,
      displayOnLockScreen: displayOnLockScreen ?? this.displayOnLockScreen,
      referenceFrequency: referenceFrequency ?? this.referenceFrequency,
      referenceNote: referenceNote ?? this.referenceNote,
      temperament: temperament ?? this.temperament,
      toleranceInCents: toleranceInCents ?? this.toleranceInCents,
      preferFlat: preferFlat ?? this.preferFlat,
      notationType: notationType ?? this.notationType,
      octaveNotation: octaveNotation ?? this.octaveNotation,
      chromaticAsStaff: chromaticAsStaff ?? this.chromaticAsStaff,
      sensitivity: sensitivity ?? this.sensitivity,
      pitchAlgorithm: pitchAlgorithm ?? this.pitchAlgorithm,
      acousticWeightingMode:
          acousticWeightingMode ?? this.acousticWeightingMode,
      octaveJumpGate: octaveJumpGate ?? this.octaveJumpGate,
      medianFilter: medianFilter ?? this.medianFilter,
      scientificMode: scientificMode ?? this.scientificMode,
      numMovingAverage: numMovingAverage ?? this.numMovingAverage,
      windowSizeExponent: windowSizeExponent ?? this.windowSizeExponent,
      windowing: windowing ?? this.windowing,
      overlapPercent: overlapPercent ?? this.overlapPercent,
      pitchHistoryDuration: pitchHistoryDuration ?? this.pitchHistoryDuration,
      pitchHistoryNumFaultyValues:
          pitchHistoryNumFaultyValues ?? this.pitchHistoryNumFaultyValues,
      waveWriterDuration: waveWriterDuration ?? this.waveWriterDuration,
      staffClef: staffClef ?? this.staffClef,
      keySignature: keySignature ?? this.keySignature,
    );
  }
}

/// Notifier coordinating SharedPreferences persistence and reactive settings updates.
final preferencesProvider =
    NotifierProvider<PreferencesNotifier, PreferencesState>(
      PreferencesNotifier.new,
    );

class PreferencesNotifier extends Notifier<PreferencesState> {
  static const _keyTheme = 'appearance_mode';
  static const _keyLocale = 'app_locale';
  static const _keyScreenOn = 'screenon';
  static const _keyLockScreen = 'onlockscreen';
  static const _keyRefFreq = 'reference_frequency';
  static const _keyTolerance = 'tolerance_in_cents';
  static const _keyPreferFlat = 'prefer_flat';
  static const _keyNotation = 'notation_type';
  static const _keyOctaveNotation = 'octave_notation';
  static const _keyChromaticStaff = 'chromatic_as_staff';
  static const _keySensitivity = 'sensitivity';
  static const _keyAlgorithm = 'pitch_algorithm';
  static const _keyWeighting = 'acoustic_weighting_mode_enum';
  static const _keyOctaveGate = 'octave_jump_gate';
  static const _keyMedianFilter = 'median_filter';
  static const _keyScientific = 'scientific_mode';
  static const _keyMovingAvg = 'num_moving_average';
  static const _keyWindowExp = 'window_size_exponent';
  static const _keyWindowing = 'windowing';
  static const _keyOverlap = 'overlap';
  static const _keyHistoryDur = 'pitch_history_duration';
  static const _keyFaultyValues = 'pitch_history_num_faulty_values';
  static const _keyWaveDur = 'wave_writer_duration_in_seconds';
  static const _keyClef = 'staff_clef';
  static const _keyKeySignature = 'key_signature';

  SharedPreferences? _prefs;

  @override
  PreferencesState build() {
    try {
      _prefs = ref.watch(sharedPreferencesProvider);
    } catch (_) {
      // SharedPreferences not overridden (e.g. in standalone tests)
      _prefs = null;
    }
    return _loadInitialState();
  }

  PreferencesState _loadInitialState() {
    final p = _prefs;
    if (p == null) return const PreferencesState();

    final themeStr = p.getString(_keyTheme);
    final theme = themeStr != null
        ? AppThemeMode.values.firstWhere(
            (e) => e.name == themeStr,
            orElse: () => AppThemeMode.system,
          )
        : AppThemeMode.system;

    final algoStr = p.getString(_keyAlgorithm);
    final algo = algoStr != null
        ? PitchAlgorithm.values.firstWhere(
            (e) => e.name == algoStr,
            orElse: () => PitchAlgorithm.classic,
          )
        : PitchAlgorithm.classic;

    final weightStr = p.getString(_keyWeighting);
    final weighting = weightStr != null
        ? AcousticWeightingMode.values.firstWhere(
            (e) => e.name == weightStr,
            orElse: () => AcousticWeightingMode.aWeighting,
          )
        : AcousticWeightingMode.aWeighting;

    final winStr = p.getString(_keyWindowing);
    final windowing = winStr != null
        ? WindowingFunction.values.firstWhere(
            (e) => e.name == winStr,
            orElse: () => WindowingFunction.tophat,
          )
        : WindowingFunction.tophat;

    final clefStr = p.getString(_keyClef);
    final clef = clefStr != null
        ? StaffClef.values.firstWhere(
            (e) => e.name == clefStr,
            orElse: () => StaffClef.grand,
          )
        : StaffClef.grand;

    final notStr = p.getString(_keyNotation);
    final notation = notStr != null
        ? NotationType.values.firstWhere(
            (e) => e.name == notStr,
            orElse: () => NotationType.regional,
          )
        : NotationType.regional;

    final octStr = p.getString(_keyOctaveNotation);
    final octave = octStr != null
        ? OctaveNotation.values.firstWhere(
            (e) => e.name == octStr,
            orElse: () => OctaveNotation.scientific,
          )
        : OctaveNotation.scientific;

    final screenOn = p.getBool(_keyScreenOn) ?? false;
    _syncWakelock(screenOn);

    return PreferencesState(
      themeMode: theme,
      localeCode: p.getString(_keyLocale),
      screenAlwaysOn: screenOn,
      displayOnLockScreen: p.getBool(_keyLockScreen) ?? false,
      referenceFrequency: p.getDouble(_keyRefFreq) ?? 440.0,
      toleranceInCents: p.getInt(_keyTolerance) ?? 5,
      preferFlat: p.getBool(_keyPreferFlat) ?? false,
      notationType: notation,
      octaveNotation: octave,
      chromaticAsStaff: p.getBool(_keyChromaticStaff) ?? false,
      sensitivity: p.getInt(_keySensitivity) ?? 90,
      pitchAlgorithm: algo,
      acousticWeightingMode: weighting,
      octaveJumpGate: p.getBool(_keyOctaveGate) ?? true,
      medianFilter: p.getBool(_keyMedianFilter) ?? true,
      scientificMode: p.getBool(_keyScientific) ?? false,
      numMovingAverage: p.getInt(_keyMovingAvg) ?? 5,
      windowSizeExponent: p.getInt(_keyWindowExp) ?? 12,
      windowing: windowing,
      overlapPercent: p.getInt(_keyOverlap) ?? 75,
      pitchHistoryDuration: p.getDouble(_keyHistoryDur) ?? 1.5,
      pitchHistoryNumFaultyValues: p.getInt(_keyFaultyValues) ?? 3,
      waveWriterDuration: p.getInt(_keyWaveDur) ?? 0,
      staffClef: clef,
      keySignature: p.getInt(_keyKeySignature) ?? 0,
    );
  }

  void _syncWakelock(bool enable) {
    try {
      WakelockPlus.toggle(enable: enable).catchError((_) {});
    } catch (_) {}
  }

  void update(PreferencesState Function(PreferencesState prev) updater) {
    final next = updater(state);
    state = next;
    _persist(next);
    _syncWithApp(next);
  }

  void resetAllSettings() {
    _prefs?.clear();
    const defaults = PreferencesState();
    state = defaults;
    _syncWithApp(defaults);
    _syncWakelock(defaults.screenAlwaysOn);
  }

  void _persist(PreferencesState s) {
    final p = _prefs;
    if (p == null) return;

    p.setString(_keyTheme, s.themeMode.name);
    if (s.localeCode != null) {
      p.setString(_keyLocale, s.localeCode!);
    } else {
      p.remove(_keyLocale);
    }
    p.setBool(_keyScreenOn, s.screenAlwaysOn);
    p.setBool(_keyLockScreen, s.displayOnLockScreen);
    p.setDouble(_keyRefFreq, s.referenceFrequency);
    p.setInt(_keyTolerance, s.toleranceInCents);
    p.setBool(_keyPreferFlat, s.preferFlat);
    p.setString(_keyNotation, s.notationType.name);
    p.setString(_keyOctaveNotation, s.octaveNotation.name);
    p.setBool(_keyChromaticStaff, s.chromaticAsStaff);
    p.setInt(_keySensitivity, s.sensitivity);
    p.setString(_keyAlgorithm, s.pitchAlgorithm.name);
    p.setString(_keyWeighting, s.acousticWeightingMode.name);
    p.setBool(_keyOctaveGate, s.octaveJumpGate);
    p.setBool(_keyMedianFilter, s.medianFilter);
    p.setBool(_keyScientific, s.scientificMode);
    p.setInt(_keyMovingAvg, s.numMovingAverage);
    p.setInt(_keyWindowExp, s.windowSizeExponent);
    p.setString(_keyWindowing, s.windowing.name);
    p.setInt(_keyOverlap, s.overlapPercent);
    p.setDouble(_keyHistoryDur, s.pitchHistoryDuration);
    p.setInt(_keyFaultyValues, s.pitchHistoryNumFaultyValues);
    p.setInt(_keyWaveDur, s.waveWriterDuration);
    p.setString(_keyClef, s.staffClef.name);
    p.setInt(_keyKeySignature, s.keySignature);

    _syncWakelock(s.screenAlwaysOn);
  }

  void _syncWithApp(PreferencesState s) {
    // 1. Sync DSP configuration
    ref
        .read(tunerDspConfigProvider.notifier)
        .update(
          (prev) => prev.copyWith(
            windowSize: s.windowSize,
            overlap: s.overlapRatio,
            pitchAlgorithm: s.pitchAlgorithm,
            weightingMode: s.acousticWeightingMode,
            octaveJumpGateEnabled: s.octaveJumpGate,
            medianFilterEnabled: s.medianFilter,
            movingAverageCount: s.numMovingAverage,
            inTuneToleranceCents: s.toleranceInCents.toDouble(),
            referenceFrequency: s.referenceFrequency,
            exportSpectrum: s.scientificMode,
            exportCorrelation: s.scientificMode,
          ),
        );

    // 2. Sync scientific mode
    ref
        .read(scientificModeProvider.notifier)
        .setScientificMode(s.scientificMode);

    // 3. Sync staff clef
    ref.read(staffClefProvider.notifier).setClef(s.staffClef);

    // 4. Sync key signature
    ref.read(keySignatureProvider.notifier).setKeySignature(s.keySignature);
  }
}
