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
  static const _kOctaveNotation = 'pref_octave_notation';
  static const _kChromaticAsStaff = 'pref_chromatic_as_staff';
  static const _kSensitivity = 'pref_sensitivity';
  static const _kPitchAlgorithm = 'pref_pitch_algorithm';
  static const _kAcousticWeighting = 'pref_acoustic_weighting';
  static const _kOctaveJumpGate = 'pref_octave_jump_gate';
  static const _kMedianFilter = 'pref_median_filter';
  static const _kMpmCutoffClarity = 'pref_mpm_cutoff_clarity';
  static const _kMpmPeakThresholdRatio = 'pref_mpm_peak_threshold_ratio';
  static const _kTwmMaxHarmonics = 'pref_twm_max_harmonics';
  static const _kTwmInharmonicity = 'pref_twm_inharmonicity';
  static const _kTwmMaxMismatchError = 'pref_twm_max_mismatch_error';
  static const _kShowStaffTargetNote = 'pref_show_staff_target_note';
  static const _kShowStaffCurrentNote = 'pref_show_staff_current_note';
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
  String octaveNotation = 'Scientific';
  bool chromaticAsStaff = false;
  int sensitivity = 50;

  // DSP
  PitchAlgorithm pitchAlgorithm = PitchAlgorithm.mpm;
  AcousticWeightingMode acousticWeighting = AcousticWeightingMode.none;
  bool octaveJumpGate = true;
  bool medianFilter = true;
  double mpmCutoffClarity = 0.45;
  double mpmPeakThresholdRatio = 0.85;
  int twmMaxHarmonics = 10;
  double twmInharmonicity = 0.0;
  double twmMaxMismatchError = 0.40;

  // Staff display
  bool showStaffTargetNote = true;
  bool showStaffCurrentNote = true;

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
    octaveNotation = 'Scientific';
    chromaticAsStaff = false;
    sensitivity = 50;

    pitchAlgorithm = PitchAlgorithm.mpm;
    acousticWeighting = AcousticWeightingMode.none;
    octaveJumpGate = true;
    medianFilter = true;
    mpmCutoffClarity = 0.45;
    mpmPeakThresholdRatio = 0.85;
    twmMaxHarmonics = 10;
    twmInharmonicity = 0.0;
    twmMaxMismatchError = 0.40;
    showStaffTargetNote = true;
    showStaffCurrentNote = true;

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
    octaveNotation = prefs.getString(_kOctaveNotation) ?? 'Scientific';
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
    mpmCutoffClarity = prefs.getDouble(_kMpmCutoffClarity) ?? 0.45;
    mpmPeakThresholdRatio = prefs.getDouble(_kMpmPeakThresholdRatio) ?? 0.85;
    twmMaxHarmonics = prefs.getInt(_kTwmMaxHarmonics) ?? 10;
    twmInharmonicity = prefs.getDouble(_kTwmInharmonicity) ?? 0.0;
    twmMaxMismatchError = prefs.getDouble(_kTwmMaxMismatchError) ?? 0.40;
    showStaffTargetNote = prefs.getBool(_kShowStaffTargetNote) ?? true;
    showStaffCurrentNote = prefs.getBool(_kShowStaffCurrentNote) ?? true;

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
    await prefs.setString(_kOctaveNotation, octaveNotation);
    await prefs.setBool(_kChromaticAsStaff, chromaticAsStaff);
    await prefs.setInt(_kSensitivity, sensitivity);

    await prefs.setInt(_kPitchAlgorithm, pitchAlgorithm.index);
    await prefs.setInt(_kAcousticWeighting, acousticWeighting.index);
    await prefs.setBool(_kOctaveJumpGate, octaveJumpGate);
    await prefs.setBool(_kMedianFilter, medianFilter);
    await prefs.setDouble(_kMpmCutoffClarity, mpmCutoffClarity);
    await prefs.setDouble(_kMpmPeakThresholdRatio, mpmPeakThresholdRatio);
    await prefs.setInt(_kTwmMaxHarmonics, twmMaxHarmonics);
    await prefs.setDouble(_kTwmInharmonicity, twmInharmonicity);
    await prefs.setDouble(_kTwmMaxMismatchError, twmMaxMismatchError);
    await prefs.setBool(_kShowStaffTargetNote, showStaffTargetNote);
    await prefs.setBool(_kShowStaffCurrentNote, showStaffCurrentNote);

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
      save();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode != mode) {
      themeMode = mode;
      notifyListeners();
      save();
    }
  }

  void setLanguage(String? lang) {
    if (language != lang) {
      language = lang;
      notifyListeners();
      save();
    }
  }

  void setKeepScreenOn(bool value) {
    if (keepScreenOn != value) {
      keepScreenOn = value;
      notifyListeners();
      save();
    }
  }

  void setPreferFlat(bool value) {
    if (preferFlat != value) {
      preferFlat = value;
      notifyListeners();
      save();
    }
  }

  void setReferenceFrequency(double freq) {
    if (referenceFrequency != freq) {
      referenceFrequency = freq;
      notifyListeners();
      save();
    }
  }

  void setReferenceNote(MusicalNote note) {
    if (referenceNote != note) {
      referenceNote = note;
      notifyListeners();
      save();
    }
  }

  void setTemperamentName(String name) {
    if (temperamentName != name) {
      temperamentName = name;
      notifyListeners();
      save();
    }
  }

  void setToleranceInCents(int cents) {
    if (toleranceInCents != cents) {
      toleranceInCents = cents;
      notifyListeners();
      save();
    }
  }

  void setNotationType(String type) {
    if (notationType != type) {
      notationType = type;
      notifyListeners();
      save();
    }
  }

  void setOctaveNotation(String notation) {
    if (octaveNotation != notation) {
      octaveNotation = notation;
      notifyListeners();
      save();
    }
  }

  void setChromaticAsStaff(bool value) {
    if (chromaticAsStaff != value) {
      chromaticAsStaff = value;
      notifyListeners();
      save();
    }
  }

  void setSensitivity(int value) {
    if (sensitivity != value) {
      sensitivity = value;
      notifyListeners();
      save();
    }
  }

  void setPitchAlgorithm(PitchAlgorithm algo) {
    if (pitchAlgorithm != algo) {
      pitchAlgorithm = algo;
      notifyListeners();
      save();
    }
  }

  void setAcousticWeighting(AcousticWeightingMode mode) {
    if (acousticWeighting != mode) {
      acousticWeighting = mode;
      notifyListeners();
      save();
    }
  }

  void setOctaveJumpGate(bool value) {
    if (octaveJumpGate != value) {
      octaveJumpGate = value;
      notifyListeners();
      save();
    }
  }

  void setMedianFilter(bool value) {
    if (medianFilter != value) {
      medianFilter = value;
      notifyListeners();
      save();
    }
  }

  void setNumMovingAverage(int value) {
    if (numMovingAverage != value) {
      numMovingAverage = value;
      notifyListeners();
      save();
    }
  }

  void setStretchTuningName(String name) {
    if (stretchTuningName != name) {
      stretchTuningName = name;
      notifyListeners();
      save();
    }
  }

  void setWindowSizeExponent(int exp) {
    if (windowSizeExponent != exp) {
      windowSizeExponent = exp;
      notifyListeners();
      save();
    }
  }

  void setWindowingFunction(WindowingFunction func) {
    if (windowingFunction != func) {
      windowingFunction = func;
      notifyListeners();
      save();
    }
  }

  void setOverlapPercent(int pct) {
    if (overlapPercent != pct) {
      overlapPercent = pct;
      notifyListeners();
      save();
    }
  }

  void setPitchHistoryDuration(double dur) {
    if (pitchHistoryDuration != dur) {
      pitchHistoryDuration = dur;
      notifyListeners();
      save();
    }
  }

  void setPitchHistoryNumFaultyValues(int num) {
    if (pitchHistoryNumFaultyValues != num) {
      pitchHistoryNumFaultyValues = num;
      notifyListeners();
      save();
    }
  }

  void setWaveWriterDuration(int dur) {
    if (waveWriterDuration != dur) {
      waveWriterDuration = dur;
      notifyListeners();
      save();
    }
  }

  void setDisplayOnLockScreen(bool value) {
    if (displayOnLockScreen != value) {
      displayOnLockScreen = value;
      notifyListeners();
      save();
    }
  }

  void setMpmCutoffClarity(double value) {
    if (mpmCutoffClarity != value) {
      mpmCutoffClarity = value;
      notifyListeners();
      save();
    }
  }

  void setMpmPeakThresholdRatio(double value) {
    if (mpmPeakThresholdRatio != value) {
      mpmPeakThresholdRatio = value;
      notifyListeners();
      save();
    }
  }

  void setTwmMaxHarmonics(int value) {
    if (twmMaxHarmonics != value) {
      twmMaxHarmonics = value;
      notifyListeners();
      save();
    }
  }

  void setTwmInharmonicity(double value) {
    if (twmInharmonicity != value) {
      twmInharmonicity = value;
      notifyListeners();
      save();
    }
  }

  void setTwmMaxMismatchError(double value) {
    if (twmMaxMismatchError != value) {
      twmMaxMismatchError = value;
      notifyListeners();
      save();
    }
  }

  void setShowStaffTargetNote(bool value) {
    if (showStaffTargetNote != value) {
      showStaffTargetNote = value;
      notifyListeners();
      save();
    }
  }

  void setShowStaffCurrentNote(bool value) {
    if (showStaffCurrentNote != value) {
      showStaffCurrentNote = value;
      notifyListeners();
      save();
    }
  }
}
