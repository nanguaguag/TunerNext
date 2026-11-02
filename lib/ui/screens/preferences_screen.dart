import 'package:flutter/material.dart';

import '../../data/preferences/app_preferences.dart';
import '../../domain/temperaments/predefined_temperament.dart';
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
    this.onPreferencesChanged,
  });

  final AppPreferences preferences;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // ==================== BASIC SECTION ====================
          const PreferenceSection(title: 'Basic'),
          SimplePreference(
            title: 'Language',
            subtitle: _pref.language == null
                ? 'System Default'
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
            title: 'Appearance',
            subtitle: _pref.themeMode == ThemeMode.light
                ? 'Light'
                : (_pref.themeMode == ThemeMode.dark
                      ? 'Dark'
                      : 'System Default'),
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
            title: 'Keep Screen On',
            subtitle: 'Prevents display from sleeping while tuning',
            icon: Icons.screen_lock_portrait,
            value: _pref.keepScreenOn,
            onChanged: (v) => _pref.setKeepScreenOn(v),
          ),
          SimplePreference(
            title: 'Reference Pitch',
            subtitle:
                '${_pref.referenceNote.name}${_pref.referenceNote.octave} = ${_pref.referenceFrequency.toStringAsFixed(1)} Hz',
            icon: Icons.music_note,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => ReferenceNoteDialog(
                  initialNote: _pref.referenceNote,
                  initialFrequency: _pref.referenceFrequency,
                  onConfirm: (n, f) {
                    _pref.setReferenceNote(n);
                    _pref.setReferenceFrequency(f);
                  },
                ),
              );
            },
          ),
          SimplePreference(
            title: 'Temperament',
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
            title: 'In-Tune Tolerance',
            subtitle: 'Threshold for green pitch accuracy indicator',
            valueLabel: '±${_pref.toleranceInCents} ¢',
            icon: Icons.adjust,
            value: _pref.toleranceInCents.toDouble(),
            min: 1.0,
            max: 20.0,
            divisions: 19,
            onChanged: (v) => _pref.setToleranceInCents(v.round()),
          ),
          SwitchPreference(
            title: 'Prefer Flat (♭)',
            subtitle: 'Display accidentals as flat instead of sharp (♯)',
            icon: Icons.music_note_outlined,
            value: _pref.preferFlat,
            onChanged: (v) => _pref.setPreferFlat(v),
          ),
          SwitchPreference(
            title: 'Chromatic as Staff',
            subtitle: 'Display musical stave in chromatic instrument mode',
            icon: Icons.piano,
            value: _pref.chromaticAsStaff,
            onChanged: (v) => _pref.setChromaticAsStaff(v),
          ),
          SliderPreference(
            title: 'Microphone Sensitivity',
            subtitle: 'Input gain threshold for pitch detection',
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
          const PreferenceSection(title: 'Advanced Acoustic DSP'),
          SimplePreference(
            title: 'Pitch Algorithm',
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
            title: 'Acoustic Weighting',
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
            title: 'Octave Jump Gate',
            subtitle: 'Eliminates transient harmonic doubling attacks',
            icon: Icons.electric_bolt,
            value: _pref.octaveJumpGate,
            onChanged: (v) => _pref.setOctaveJumpGate(v),
          ),
          SwitchPreference(
            title: '3-Tap Median Filter',
            subtitle: 'Filters anomalous single-frame pitch spikes',
            icon: Icons.filter_alt,
            value: _pref.medianFilter,
            onChanged: (v) => _pref.setMedianFilter(v),
          ),

          const Divider(),

          // ==================== EXPERT / SCIENTIFIC ====================
          const PreferenceSection(title: 'Expert / Scientific Mode'),
          SwitchPreference(
            title: 'Scientific Mode',
            subtitle: 'Enable FFT spectrum and correlation analysis views',
            icon: Icons.science,
            value: _pref.scientificMode,
            onChanged: (v) => _pref.setScientificMode(v),
          ),
          SliderPreference(
            title: 'Moving Average Smoothing',
            subtitle: 'Taps for outlier-removing smoothing buffer',
            valueLabel: '${_pref.numMovingAverage} frames',
            icon: Icons.timeline,
            value: _pref.numMovingAverage.toDouble(),
            min: 1.0,
            max: 15.0,
            divisions: 14,
            onChanged: (v) => _pref.setNumMovingAverage(v.round()),
          ),
          SimplePreference(
            title: 'Stretch Tuning',
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
            title: 'FFT Window Size',
            subtitle: 'Analysis buffer sample length',
            valueLabel: '${_pref.windowSize} samples',
            icon: Icons.view_column,
            value: _pref.windowSizeExponent.toDouble(),
            min: 7.0,
            max: 15.0,
            divisions: 8,
            onChanged: (v) => _pref.setWindowSizeExponent(v.round()),
          ),
          SimplePreference(
            title: 'Windowing Function',
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
            title: 'Buffer Overlap',
            subtitle: 'Consecutive analysis frame overlap',
            valueLabel: '${_pref.overlapPercent}%',
            icon: Icons.layers,
            value: _pref.overlapPercent.toDouble(),
            min: 0.0,
            max: 80.0,
            divisions: 16,
            onChanged: (v) => _pref.setOverlapPercent(v.round()),
          ),
          SliderPreference(
            title: 'Pitch History Duration',
            subtitle: 'Time window shown on pitch history plot',
            valueLabel: '${_pref.pitchHistoryDuration.toStringAsFixed(1)} s',
            icon: Icons.history,
            value: _pref.pitchHistoryDuration,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            onChanged: (v) => _pref.setPitchHistoryDuration(v),
          ),
          SliderPreference(
            title: 'Audio Capture Duration',
            subtitle: 'WAV export buffer capacity (0s disables export button)',
            valueLabel: _pref.waveWriterDuration == 0
                ? 'Disabled'
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
          const PreferenceSection(title: 'Others'),
          SimplePreference(
            title: 'Reset All Settings',
            subtitle: 'Restore factory default parameters',
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
            title: 'About',
            subtitle: 'Version and architectural specifications',
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
