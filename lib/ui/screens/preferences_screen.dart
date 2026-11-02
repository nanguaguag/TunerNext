import 'package:flutter/material.dart';

import '../../data/preferences/app_preferences.dart';
import '../../domain/temperaments/predefined_temperament.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/reference_note_dialog.dart';
import '../dialogs/temperament_dialog.dart';
import '../preferences/preference_dialogs.dart';
import '../preferences/preference_section.dart';
import '../preferences/simple_preference.dart';
import '../preferences/slider_preference.dart';
import '../preferences/switch_preference.dart';
import 'stretch_tuning_overview_screen.dart';

/// Full preferences and settings configuration screen.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.screens.Preferences`.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({
    super.key,
    required this.preferences,
    this.currentFrequency,
    this.onPreferencesChanged,
  });

  final AppPreferences preferences;
  final double? currentFrequency;
  final VoidCallback? onPreferencesChanged;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late final AppPreferences _pref;

  @override
  void initState() {
    super.initState();
    _pref = widget.preferences;
    _pref.addListener(_onChanged);
  }

  @override
  void dispose() {
    _pref.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    widget.onPreferencesChanged?.call();
    _pref.save();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // ==================== BASIC SECTION ====================
          PreferenceSection(title: l10n?.basic ?? 'Basic'),
          SimplePreference(
            title: l10n?.language ?? 'Language',
            subtitle: _pref.language == null
                ? (l10n?.systemDefault ?? 'System Default')
                : _pref.language!,
            icon: Icons.language,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => LanguageDialog(
                  selectedLanguage: _pref.language,
                  onSelected: (l) => _pref.setLanguage(l),
                ),
              );
            },
          ),
          SimplePreference(
            title: l10n?.appearance ?? 'Appearance',
            subtitle: _pref.themeMode == ThemeMode.light
                ? (l10n?.lightAppearanceShort ?? 'Light')
                : (_pref.themeMode == ThemeMode.dark
                      ? (l10n?.darkAppearanceShort ?? 'Dark')
                      : (l10n?.systemAppearanceShort ?? 'System Default')),
            icon: Icons.brightness_6,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AppearanceDialog(
                  selectedMode: _pref.themeMode,
                  onSelected: (m) => _pref.setThemeMode(m),
                ),
              );
            },
          ),
          SwitchPreference(
            title: l10n?.keepScreenOn ?? 'Keep Screen On',
            subtitle:
                l10n?.keepScreenOnDesc ??
                'Prevents display from sleeping while tuning',
            icon: Icons.screen_lock_portrait,
            value: _pref.keepScreenOn,
            onChanged: (v) => _pref.setKeepScreenOn(v),
          ),
          SimplePreference(
            title: l10n?.referenceFrequency ?? 'Reference Pitch',
            subtitle:
                '${_pref.referenceNote.name} = ${_pref.referenceFrequency.toStringAsFixed(1)} Hz',
            icon: Icons.music_note,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => ReferenceNoteDialog(
                  initialNote: _pref.referenceNote,
                  initialFrequency: _pref.referenceFrequency,
                  detectedFrequency: widget.currentFrequency,
                  onConfirm: (n, f) {
                    _pref.setReferenceNote(n);
                    _pref.setReferenceFrequency(f);
                  },
                ),
              );
            },
          ),
          SimplePreference(
            title: l10n?.temperament ?? 'Temperament',
            subtitle: _pref.temperamentName,
            icon: Icons.tune,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => TemperamentDialog(
                  selectedTemperament: PredefinedTemperaments.getAll()
                      .firstWhere(
                        (t) => t.name == _pref.temperamentName,
                        orElse: () => PredefinedTemperaments.edo12(),
                      ),
                  onSelectTemperament: (t) {
                    _pref.setTemperamentName(t.name);
                  },
                ),
              );
            },
          ),
          SliderPreference(
            title: l10n?.toleranceInCents ?? 'In-Tune Tolerance',
            subtitle:
                l10n?.toleranceDesc ??
                'Threshold for green pitch accuracy indicator',
            valueLabel: '±${_pref.toleranceInCents} ¢',
            icon: Icons.adjust,
            value: _pref.toleranceInCents.toDouble(),
            min: 1.0,
            max: 20.0,
            divisions: 19,
            onChanged: (v) => _pref.setToleranceInCents(v.round()),
          ),
          SwitchPreference(
            title: l10n?.preferFlat ?? 'Prefer Flat (♭)',
            subtitle:
                l10n?.preferFlatDesc ??
                'Display accidentals as flat instead of sharp (♯)',
            icon: Icons.music_note_outlined,
            value: _pref.preferFlat,
            onChanged: (v) => _pref.setPreferFlat(v),
          ),
          SimplePreference(
            title: l10n?.notation ?? 'Notation',
            subtitle: '${_pref.notationType}, ${_pref.octaveNotation}',
            icon: Icons.queue_music,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => NotationDialog(
                  currentNotation: _pref.notationType,
                  currentOctaveNotation: _pref.octaveNotation,
                  onConfirm: (notation, octave) {
                    _pref.setNotationType(notation);
                    _pref.setOctaveNotation(octave);
                  },
                ),
              );
            },
          ),
          SwitchPreference(
            title: l10n?.chromaticAsStaff ?? 'Chromatic as Staff',
            subtitle:
                l10n?.chromaticAsStaffDesc ??
                'Display musical stave in chromatic instrument mode',
            icon: Icons.piano,
            value: _pref.chromaticAsStaff,
            onChanged: (v) => _pref.setChromaticAsStaff(v),
          ),
          SliderPreference(
            title: l10n?.sensitivity ?? 'Microphone Sensitivity',
            subtitle:
                l10n?.sensitivityDesc ??
                'Input gain threshold for pitch detection',
            valueLabel: '${_pref.sensitivity}%',
            icon: Icons.mic,
            value: _pref.sensitivity.toDouble(),
            min: 0.0,
            max: 100.0,
            divisions: 20,
            onChanged: (v) => _pref.setSensitivity(v.round()),
          ),

          const Divider(),

          // ==================== ADVANCED ACOUSTIC DSP ====================
          PreferenceSection(
            title: l10n?.advancedAcousticDsp ?? 'Advanced Acoustic DSP',
          ),
          SimplePreference(
            title: l10n?.pitchAlgorithm ?? 'Pitch Algorithm',
            subtitle: _pref.pitchAlgorithm.name.toUpperCase(),
            icon: Icons.auto_graph,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => PitchAlgorithmDialog(
                  selectedAlgorithm: _pref.pitchAlgorithm,
                  onSelected: (a) => _pref.setPitchAlgorithm(a),
                ),
              );
            },
          ),
          SimplePreference(
            title: l10n?.acousticWeighting ?? 'Acoustic Weighting',
            subtitle: _pref.acousticWeighting.name,
            icon: Icons.graphic_eq,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AcousticWeightingDialog(
                  selectedMode: _pref.acousticWeighting,
                  onSelected: (w) => _pref.setAcousticWeighting(w),
                ),
              );
            },
          ),
          SwitchPreference(
            title: l10n?.octaveJumpGate ?? 'Octave Jump Gate',
            subtitle:
                l10n?.octaveJumpGateDesc ??
                'Eliminates transient harmonic doubling attacks',
            icon: Icons.electric_bolt,
            value: _pref.octaveJumpGate,
            onChanged: (v) => _pref.setOctaveJumpGate(v),
          ),
          SwitchPreference(
            title: l10n?.medianFilter ?? '3-Tap Median Filter',
            subtitle:
                l10n?.medianFilterDesc ??
                'Filters anomalous single-frame pitch spikes',
            icon: Icons.filter_alt,
            value: _pref.medianFilter,
            onChanged: (v) => _pref.setMedianFilter(v),
          ),

          const Divider(),

          // ==================== EXPERT / SCIENTIFIC ====================
          PreferenceSection(title: l10n?.expert ?? 'Expert / Scientific Mode'),
          SwitchPreference(
            title: l10n?.scientificMode ?? 'Scientific Mode',
            subtitle:
                l10n?.scientificModeDesc ??
                'Enable FFT spectrum and correlation analysis views',
            icon: Icons.science,
            value: _pref.scientificMode,
            onChanged: (v) => _pref.setScientificMode(v),
          ),
          SliderPreference(
            title: l10n?.numMovingAverage ?? 'Moving Average Smoothing',
            subtitle:
                l10n?.numMovingAverageDesc ??
                'Taps for outlier-removing smoothing buffer',
            valueLabel: '${_pref.numMovingAverage} frames',
            icon: Icons.timeline,
            value: _pref.numMovingAverage.toDouble(),
            min: 1.0,
            max: 15.0,
            divisions: 14,
            onChanged: (v) => _pref.setNumMovingAverage(v.round()),
          ),
          SimplePreference(
            title: l10n?.stretchTuning ?? 'Stretch Tuning',
            subtitle: _pref.stretchTuningName,
            icon: Icons.stacked_line_chart,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => StretchTuningOverviewScreen(
                    onSelectStretchTuning: (st) {
                      _pref.setStretchTuningName(st.name);
                    },
                  ),
                ),
              );
            },
          ),
          SliderPreference(
            title: l10n?.windowSize ?? 'FFT Window Size',
            subtitle: l10n?.windowSizeDesc ?? 'Analysis buffer sample length',
            valueLabel: '${_pref.windowSize} samples',
            icon: Icons.view_column,
            value: _pref.windowSizeExponent.toDouble(),
            min: 7.0,
            max: 15.0,
            divisions: 8,
            onChanged: (v) => _pref.setWindowSizeExponent(v.round()),
          ),
          SimplePreference(
            title: l10n?.windowingFunction ?? 'Windowing Function',
            subtitle: _pref.windowingFunction.name,
            icon: Icons.waves,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => WindowingFunctionDialog(
                  selectedWindowing: _pref.windowingFunction,
                  onSelected: (wf) => _pref.setWindowingFunction(wf),
                ),
              );
            },
          ),
          SliderPreference(
            title: l10n?.overlap ?? 'Buffer Overlap',
            subtitle: l10n?.overlapDesc ?? 'Consecutive analysis frame overlap',
            valueLabel: '${_pref.overlapPercent}%',
            icon: Icons.layers,
            value: _pref.overlapPercent.toDouble(),
            min: 0.0,
            max: 80.0,
            divisions: 16,
            onChanged: (v) => _pref.setOverlapPercent(v.round()),
          ),
          SliderPreference(
            title: l10n?.pitchHistoryDuration ?? 'Pitch History Duration',
            subtitle:
                l10n?.pitchHistoryDurationDesc ??
                'Time window shown on pitch history plot',
            valueLabel: '${_pref.pitchHistoryDuration.toStringAsFixed(1)} s',
            icon: Icons.history,
            value: _pref.pitchHistoryDuration,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            onChanged: (v) => _pref.setPitchHistoryDuration(v),
          ),
          SliderPreference(
            title: l10n?.pitchHistoryNumFaultyValues ?? 'Jump to New Pitch',
            subtitle: _pref.pitchHistoryNumFaultyValues == 1
                ? (l10n?.jumpToNewPitchDirect ??
                      'Directly jump to new pitch result')
                : (l10n?.jumpToNewPitchMultiple(
                        _pref.pitchHistoryNumFaultyValues,
                      ) ??
                      'After ${_pref.pitchHistoryNumFaultyValues} similar pitch results'),
            valueLabel: '${_pref.pitchHistoryNumFaultyValues}',
            icon: Icons.alt_route,
            value: _pref.pitchHistoryNumFaultyValues.toDouble(),
            min: 1.0,
            max: 12.0,
            divisions: 11,
            onChanged: (v) => _pref.setPitchHistoryNumFaultyValues(v.round()),
          ),
          SliderPreference(
            title: l10n?.capture ?? 'Audio Capture Duration',
            subtitle:
                l10n?.audioCaptureDesc ??
                'WAV export buffer capacity (0s disables export button)',
            valueLabel: _pref.waveWriterDuration == 0
                ? (l10n?.audioCaptureDisabled ?? 'Disabled')
                : '${_pref.waveWriterDuration} s',
            icon: Icons.audio_file,
            value: _pref.waveWriterDuration.toDouble(),
            min: 0.0,
            max: 5.0,
            divisions: 5,
            onChanged: (v) => _pref.setWaveWriterDuration(v.round()),
          ),

          const Divider(),

          // ==================== OTHERS ====================
          PreferenceSection(title: l10n?.others ?? 'Others'),
          SwitchPreference(
            title: l10n?.displayOnLockScreen ?? 'Display on Lock Screen',
            subtitle:
                l10n?.displayOnLockScreenDesc ??
                'Allows tuner to be active over device lock screen',
            icon: Icons.lock_outline,
            value: _pref.displayOnLockScreen,
            onChanged: (v) => _pref.setDisplayOnLockScreen(v),
          ),
          SimplePreference(
            title: l10n?.resetAllSettings ?? 'Reset All Settings',
            subtitle:
                l10n?.resetAllSettingsDesc ??
                'Restore factory default parameters',
            icon: Icons.restore,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => ResetSettingsDialog(
                  onConfirm: () async {
                    await _pref.resetToDefaults();
                    setState(() {});
                  },
                ),
              );
            },
          ),
          SimplePreference(
            title: l10n?.about ?? 'About',
            subtitle:
                l10n?.aboutTunerDesc ??
                'Version and architectural specifications',
            icon: Icons.info_outline,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => const AboutTunerDialog(),
              );
            },
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
