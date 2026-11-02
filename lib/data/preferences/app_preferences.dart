import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/dsp_enums.dart';
import '../../domain/models/musical_note.dart';

/// Central container and persistence layer for user preferences.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.preferences.PreferenceResources`.
class AppPreferences extends ChangeNotifier {
  AppPreferences() {
    _loadFromDefaults();
  }

  // --- Keys ---
  static const _kThemeMode = 'pref_theme_mode';
  static const _kLanguage = 'pref_language';
  static const _kKeepScreenOn = 'pref_keep_screen_on';
  static const _kReferenceFrequency = 'pref_reference_frequency';
  static const _kReferenceNoteBase = 'pref_reference_note_base';
  static const _kReferenceNoteOctave = 'pref_reference_note_octave';
  static const _kTemperamentName = 'pref_temperament_name';
  static const _kToleranceInCents = 'pref_tolerance_in_cents';
  static const _kPreferFlat = 'pref_prefer_flat';
  static const _kNotationType = 'pref_notation_type';
  static const _kChromaticAsStaff = 'pref_chromatic_as_staff';
  static const _kSensitivity = 'pref_sensitivity';
  static const _kPitchAlgorithm = 'pref_pitch_algorithm';
  static const _kAcousticWeighting = 'pref_acoustic_weighting';
  static const _kOctaveJumpGate = 'pref_octave_jump_gate';
  static const _kMedianFilter = 'pref_median_filter';
  static const _kScientificMode = 'pref_scientific_mode';
  static const _kNumMovingAverage = 'pref_num_moving_average';
  static const _kStretchTuningName = 'pref_stretch_tuning_name';
  static const _kWindowSizeExponent = 'pref_window_size_exponent';
  static const _kWindowingFunction = 'pref_windowing_function';
  static const _kOverlapPercent = 'pref_overlap_percent';
  static const _kPitchHistoryDuration = 'pref_pitch_history_duration';
  static const _kPitchHistoryNumFaultyValues =
      'pref_pitch_history_num_faulty_values';
  static const _kWaveWriterDuration = 'pref_wave_writer_duration';
  static const _kDisplayOnLockScreen = 'pref_display_on_lock_screen';

  // --- Properties ---
  ThemeMode themeMode = ThemeMode.system;
  String? language; // null = system default
  bool keepScreenOn = true;
  double referenceFrequency = 440.0;
  MusicalNote referenceNote = const MusicalNote(base: BaseNote.a, octave: 4);
  String temperamentName = 'EDO 12';
  int toleranceInCents = 10;
  bool preferFlat = false;
  String notationType = 'Standard (C D E)';
  bool chromaticAsStaff = false;
  int sensitivity = 50;

  // DSP
  PitchAlgorithm pitchAlgorithm = PitchAlgorithm.mpm;
  AcousticWeightingMode acousticWeighting = AcousticWeightingMode.none;
  bool octaveJumpGate = true;
  bool medianFilter = true;

  // Expert / Scientific
  bool scientificMode = false;
  int numMovingAverage = 3;
  String stretchTuningName = 'No Stretch Tuning';
  int windowSizeExponent = 11; // 2^11 = 2048
  WindowingFunction windowingFunction = WindowingFunction.hanning;
  int overlapPercent = 50;
  double pitchHistoryDuration = 4.0;
  int pitchHistoryNumFaultyValues = 3;
  int waveWriterDuration = 1;
  bool displayOnLockScreen = false;

  int get windowSize => 1 << windowSizeExponent;

  void _loadFromDefaults() {
    themeMode = ThemeMode.system;
    language = null;
    keepScreenOn = true;
    referenceFrequency = 440.0;
    referenceNote = const MusicalNote(base: BaseNote.a, octave: 4);
    temperamentName = 'EDO 12';
    toleranceInCents = 10;
    preferFlat = false;
    notationType = 'Standard (C D E)';
    chromaticAsStaff = false;
    sensitivity = 50;

    pitchAlgorithm = PitchAlgorithm.mpm;
    acousticWeighting = AcousticWeightingMode.none;
    octaveJumpGate = true;
    medianFilter = true;

    scientificMode = false;
    numMovingAverage = 3;
    stretchTuningName = 'No Stretch Tuning';
    windowSizeExponent = 11;
    windowingFunction = WindowingFunction.hanning;
    overlapPercent = 50;
    pitchHistoryDuration = 4.0;
    pitchHistoryNumFaultyValues = 3;
    waveWriterDuration = 1;
    displayOnLockScreen = false;
  }

  /// Loads persisted settings from device [SharedPreferences].
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeStr = prefs.getString(_kThemeMode);
    if (themeStr == 'light') {
      themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }

    language = prefs.getString(_kLanguage);
    keepScreenOn = prefs.getBool(_kKeepScreenOn) ?? true;
    referenceFrequency = prefs.getDouble(_kReferenceFrequency) ?? 440.0;

    final noteBaseIndex = prefs.getInt(_kReferenceNoteBase) ?? BaseNote.a.index;
    final noteOctave = prefs.getInt(_kReferenceNoteOctave) ?? 4;
    referenceNote = MusicalNote(
      base: BaseNote.values[noteBaseIndex.clamp(0, BaseNote.values.length - 1)],
      octave: noteOctave,
    );

    temperamentName = prefs.getString(_kTemperamentName) ?? 'EDO 12';
    toleranceInCents = prefs.getInt(_kToleranceInCents) ?? 10;
    preferFlat = prefs.getBool(_kPreferFlat) ?? false;
    notationType = prefs.getString(_kNotationType) ?? 'Standard (C D E)';
    chromaticAsStaff = prefs.getBool(_kChromaticAsStaff) ?? false;
    sensitivity = prefs.getInt(_kSensitivity) ?? 50;

    final algoIndex = prefs.getInt(_kPitchAlgorithm);
    if (algoIndex != null &&
        algoIndex >= 0 &&
        algoIndex < PitchAlgorithm.values.length) {
      pitchAlgorithm = PitchAlgorithm.values[algoIndex];
    }

    final weightIndex = prefs.getInt(_kAcousticWeighting);
    if (weightIndex != null &&
        weightIndex >= 0 &&
        weightIndex < AcousticWeightingMode.values.length) {
      acousticWeighting = AcousticWeightingMode.values[weightIndex];
    }

    octaveJumpGate = prefs.getBool(_kOctaveJumpGate) ?? true;
    medianFilter = prefs.getBool(_kMedianFilter) ?? true;

    scientificMode = prefs.getBool(_kScientificMode) ?? false;
    numMovingAverage = prefs.getInt(_kNumMovingAverage) ?? 3;
    stretchTuningName =
        prefs.getString(_kStretchTuningName) ?? 'No Stretch Tuning';
    windowSizeExponent = prefs.getInt(_kWindowSizeExponent) ?? 11;

    final winIndex = prefs.getInt(_kWindowingFunction);
    if (winIndex != null &&
        winIndex >= 0 &&
        winIndex < WindowingFunction.values.length) {
      windowingFunction = WindowingFunction.values[winIndex];
    }

    overlapPercent = prefs.getInt(_kOverlapPercent) ?? 50;
    pitchHistoryDuration = prefs.getDouble(_kPitchHistoryDuration) ?? 4.0;
    pitchHistoryNumFaultyValues =
        prefs.getInt(_kPitchHistoryNumFaultyValues) ?? 3;
    waveWriterDuration = prefs.getInt(_kWaveWriterDuration) ?? 1;
    displayOnLockScreen = prefs.getBool(_kDisplayOnLockScreen) ?? false;

    notifyListeners();
  }

  /// Flushes current in-memory settings to [SharedPreferences].
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final themeStr = themeMode == ThemeMode.light
        ? 'light'
        : (themeMode == ThemeMode.dark ? 'dark' : 'system');
    await prefs.setString(_kThemeMode, themeStr);

    if (language != null) {
      await prefs.setString(_kLanguage, language!);
    } else {
      await prefs.remove(_kLanguage);
    }

    await prefs.setBool(_kKeepScreenOn, keepScreenOn);
    await prefs.setDouble(_kReferenceFrequency, referenceFrequency);
    await prefs.setInt(_kReferenceNoteBase, referenceNote.base.index);
    await prefs.setInt(_kReferenceNoteOctave, referenceNote.octave);
    await prefs.setString(_kTemperamentName, temperamentName);
    await prefs.setInt(_kToleranceInCents, toleranceInCents);
    await prefs.setBool(_kPreferFlat, preferFlat);
    await prefs.setString(_kNotationType, notationType);
    await prefs.setBool(_kChromaticAsStaff, chromaticAsStaff);
    await prefs.setInt(_kSensitivity, sensitivity);

    await prefs.setInt(_kPitchAlgorithm, pitchAlgorithm.index);
    await prefs.setInt(_kAcousticWeighting, acousticWeighting.index);
    await prefs.setBool(_kOctaveJumpGate, octaveJumpGate);
    await prefs.setBool(_kMedianFilter, medianFilter);

    await prefs.setBool(_kScientificMode, scientificMode);
    await prefs.setInt(_kNumMovingAverage, numMovingAverage);
    await prefs.setString(_kStretchTuningName, stretchTuningName);
    await prefs.setInt(_kWindowSizeExponent, windowSizeExponent);
    await prefs.setInt(_kWindowingFunction, windowingFunction.index);
    await prefs.setInt(_kOverlapPercent, overlapPercent);
    await prefs.setDouble(_kPitchHistoryDuration, pitchHistoryDuration);
    await prefs.setInt(
      _kPitchHistoryNumFaultyValues,
      pitchHistoryNumFaultyValues,
    );
    await prefs.setInt(_kWaveWriterDuration, waveWriterDuration);
    await prefs.setBool(_kDisplayOnLockScreen, displayOnLockScreen);
  }

  /// Resets all settings to their original factory defaults.
  Future<void> resetToDefaults() async {
    _loadFromDefaults();
    notifyListeners();
    await save();
  }

  // --- Setter helpers ---
  void setScientificMode(bool value) {
    if (scientificMode != value) {
      scientificMode = value;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode != mode) {
      themeMode = mode;
      notifyListeners();
    }
  }

  void setPreferFlat(bool value) {
    if (preferFlat != value) {
      preferFlat = value;
      notifyListeners();
    }
  }

  void setReferenceFrequency(double freq) {
    if (referenceFrequency != freq) {
      referenceFrequency = freq;
      notifyListeners();
    }
  }

  void setReferenceNote(MusicalNote note) {
    if (referenceNote != note) {
      referenceNote = note;
      notifyListeners();
    }
  }

  void setTemperamentName(String name) {
    if (temperamentName != name) {
      temperamentName = name;
      notifyListeners();
    }
  }

  void setStretchTuningName(String name) {
    if (stretchTuningName != name) {
      stretchTuningName = name;
      notifyListeners();
    }
  }
}
