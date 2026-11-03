import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../audio/audio_file_loader.dart';
import '../../domain/instruments/instrument.dart';
import '../../domain/instruments/predefined_instruments.dart';
import '../../domain/models/dsp_enums.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../../domain/tuning/frequency_to_note_converter.dart';
import '../../dsp/analysis/offline_audio_analyzer.dart';
import '../instruments/instruments_screen.dart';
import '../instruments/string_with_info.dart';
import '../instruments/strings.dart';
import '../plot/plot_window_outline.dart';
import '../plot/static_pitch_timeline_plot.dart';
import '../widgets/tuning_indicator_banner.dart';

/// Screen providing offline playback and static inspection of an imported audio track.
/// Matches the main screen layout (Tuning banner on top, strings on sidebar, static pitch plot in center),
/// with an interactive scrubber slider and playback controls at the bottom.
class AudioAnalysisScreen extends StatefulWidget {
  const AudioAnalysisScreen({
    super.key,
    required this.analysisResult,
    required this.fileName,
    this.decodedAudio,
    this.audioPath,
    this.initialInstrument,
    this.onSelectNewFile,
    this.onReanalyzeWithConfig,
    this.mpmCutoffClarity = 0.45,
    this.mpmPeakThresholdRatio = 0.85,
    this.twmMaxHarmonics = 10,
    this.twmInharmonicity = 0.0,
    this.twmMaxMismatchError = 0.40,
    this.useMedianFilter = true,
    this.useOctaveJumpGate = true,
  });

  final OfflineAnalysisResult analysisResult;
  final String fileName;
  final DecodedAudio? decodedAudio;
  final String? audioPath;
  final Instrument? initialInstrument;
  final VoidCallback? onSelectNewFile;
  final void Function(
    PitchAlgorithm algorithm,
    AcousticWeightingMode weighting,
  )?
  onReanalyzeWithConfig;
  final double mpmCutoffClarity;
  final double mpmPeakThresholdRatio;
  final int twmMaxHarmonics;
  final double twmInharmonicity;
  final double twmMaxMismatchError;
  final bool useMedianFilter;
  final bool useOctaveJumpGate;

  @override
  State<AudioAnalysisScreen> createState() => _AudioAnalysisScreenState();
}

class _AudioAnalysisScreenState extends State<AudioAnalysisScreen> {
  late OfflineAnalysisResult _result;
  late Instrument _currentInstrument;
  late FrequencyToNoteConverter _pitchConverter;

  double _currentTime = 0.0;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isAnalyzing = false;
  Timer? _playbackTimer;
  AudioPlayer? _audioPlayer;
  StreamSubscription? _posSub;
  StreamSubscription? _playerCompleteSub;

  int? _lockedStringKey;
  MusicalNote _targetNote = const MusicalNote(base: BaseNote.a, octave: 4);
  double _targetFrequency = 440.0;
  double _measuredFrequency = 0.0;
  double _deviationCents = 0.0;
  TuningState _tuningState = TuningState.unknown;

  late PitchAlgorithm _selectedAlgorithm;
  late AcousticWeightingMode _selectedWeighting;

  @override
  void initState() {
    super.initState();
    _result = widget.analysisResult;
    _currentInstrument =
        widget.initialInstrument ?? PredefinedInstruments.guitarStandard;
    _pitchConverter = FrequencyToNoteConverter(
      referenceFrequency: 440.0,
      referenceMidi: 69,
      toleranceInCents: 5.0,
    );

    _selectedAlgorithm = _result.algorithm;
    _selectedWeighting = _result.weightingMode;

    if (_currentInstrument.strings.isNotEmpty) {
      _targetNote = _currentInstrument.strings.first;
      _targetFrequency = _pitchConverter.noteToFrequency(_targetNote);
    }

    _updateStateAtTime(0.0);

    try {
      _audioPlayer = AudioPlayer();
      _posSub = _audioPlayer?.onPositionChanged.listen((pos) {
        if (_isPlaying && mounted) {
          setState(() {
            _currentTime = (pos.inMilliseconds / 1000.0).clamp(
              0.0,
              _result.durationSeconds,
            );
            _updateStateAtTime(_currentTime);
          });
        }
      });
      _playerCompleteSub = _audioPlayer?.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentTime = _result.durationSeconds;
            _updateStateAtTime(_currentTime);
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _posSub?.cancel();
    _playerCompleteSub?.cancel();
    try {
      _audioPlayer?.stop();
      _audioPlayer?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _updateStateAtTime(double t) {
    _currentTime = t.clamp(0.0, _result.durationSeconds);
    final frame = _result.getFrameAt(_currentTime);

    _measuredFrequency = (!frame.isSilence && frame.frequency > 0.0)
        ? frame.frequency
        : 0.0;

    if (_measuredFrequency > 0.0) {
      if (_lockedStringKey != null) {
        _deviationCents = _pitchConverter.centsDeviation(
          _measuredFrequency,
          _targetFrequency,
        );
        _tuningState = _pitchConverter.determineTuningState(_deviationCents);
      } else {
        final assessment = _pitchConverter.evaluatePitch(
          _measuredFrequency,
          previousTarget: _targetNote,
        );
        _targetNote = assessment.target.note;
        _targetFrequency = assessment.target.frequency;
        _deviationCents = assessment.centsDeviation;
        _tuningState = assessment.tuningState;
      }
    } else {
      _tuningState = TuningState.unknown;
      _deviationCents = 0.0;
    }
  }

  void _seekTo(double time) {
    setState(() {
      _updateStateAtTime(time);
    });
    try {
      _audioPlayer?.seek(Duration(milliseconds: (time * 1000).round()));
    } catch (_) {}
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    try {
      _audioPlayer?.setVolume(_isMuted ? 0.0 : 1.0);
    } catch (_) {}
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (_currentTime >= _result.durationSeconds - 0.05) {
          _currentTime = 0.0;
        }
        _startPlayback();
      } else {
        _playbackTimer?.cancel();
        try {
          _audioPlayer?.pause();
        } catch (_) {}
      }
    });
  }

  void _startPlayback() {
    // 1. Play real audio if audioPath is provided
    if (widget.audioPath != null && widget.audioPath!.isNotEmpty) {
      try {
        final path = widget.audioPath!;
        _audioPlayer?.setVolume(_isMuted ? 0.0 : 1.0);
        if (path == 'builtin://whistle' || path.contains('assets/')) {
          _audioPlayer?.play(
            AssetSource('audio/test_music.wav'),
            position: Duration(milliseconds: (_currentTime * 1000).round()),
          );
        } else {
          _audioPlayer?.play(
            DeviceFileSource(path),
            position: Duration(milliseconds: (_currentTime * 1000).round()),
          );
        }
      } catch (_) {}
    }

    // 2. Playback progress ticker
    _playbackTimer?.cancel();
    const intervalMs = 50;
    const stepSec = intervalMs / 1000.0;

    _playbackTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (
      _,
    ) {
      if (!mounted) return;
      if (!_isPlaying) {
        _playbackTimer?.cancel();
        return;
      }
      setState(() {
        final nextTime = _currentTime + stepSec;
        if (nextTime >= _result.durationSeconds) {
          _currentTime = _result.durationSeconds;
          _isPlaying = false;
          _playbackTimer?.cancel();
          try {
            _audioPlayer?.pause();
          } catch (_) {}
        } else {
          _currentTime = nextTime;
        }
        _updateStateAtTime(_currentTime);
      });
    });
  }

  void _openInstrumentSelector() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InstrumentsScreen(
          selectedInstrument: _currentInstrument,
          customInstruments: const [],
          onSelectInstrument: (Instrument inst) {
            setState(() {
              _currentInstrument = inst;
              _lockedStringKey = null;
              if (inst.strings.isNotEmpty) {
                _targetNote = inst.strings.first;
                _targetFrequency = _pitchConverter.noteToFrequency(_targetNote);
              }
              _updateStateAtTime(_currentTime);
            });
          },
        ),
      ),
    );
  }

  Future<void> _reanalyze(
    PitchAlgorithm algo,
    AcousticWeightingMode weight,
  ) async {
    setState(() {
      _selectedAlgorithm = algo;
      _selectedWeighting = weight;
      _isAnalyzing = true;
    });

    if (widget.decodedAudio != null) {
      try {
        final newResult = await OfflineAudioAnalyzer.analyze(
          samples: widget.decodedAudio!.samples,
          sampleRate: widget.decodedAudio!.sampleRate,
          algorithm: algo,
          weightingMode: weight,
          mpmCutoffClarity: widget.mpmCutoffClarity,
          mpmPeakThresholdRatio: widget.mpmPeakThresholdRatio,
          twmMaxHarmonics: widget.twmMaxHarmonics,
          twmInharmonicity: widget.twmInharmonicity,
          twmMaxMismatchError: widget.twmMaxMismatchError,
          useMedianFilter: widget.useMedianFilter,
          useOctaveJumpGate: widget.useOctaveJumpGate,
        );
        if (mounted) {
          setState(() {
            _result = newResult;
            _isAnalyzing = false;
            _updateStateAtTime(_currentTime);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to re-analyze audio: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }

    if (widget.onReanalyzeWithConfig != null) {
      widget.onReanalyzeWithConfig!(algo, weight);
    }
  }

  List<StringWithInfo> get _currentStringInfos {
    final list = <StringWithInfo>[];
    for (int i = 0; i < _currentInstrument.strings.length; i++) {
      list.add(StringWithInfo(key: i, note: _currentInstrument.strings[i]));
    }
    return list;
  }

  void _onStringClicked(int key, MusicalNote note) {
    setState(() {
      if (_lockedStringKey == key) {
        _lockedStringKey = null;
      } else {
        _lockedStringKey = key;
        _targetNote = note;
        _targetFrequency = _pitchConverter.noteToFrequency(note);
      }
      _updateStateAtTime(_currentTime);
    });
  }

  void _showConfigDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        var tempAlgo = _selectedAlgorithm;
        var tempWeight = _selectedWeighting;

        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: const Text('Re-analyze Audio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pitch Algorithm:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<PitchAlgorithm>(
                    value: tempAlgo,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: PitchAlgorithm.mpm,
                        child: Text('MPM (McLeod)'),
                      ),
                      DropdownMenuItem(
                        value: PitchAlgorithm.twm,
                        child: Text('TWM (Two-Way Mismatch)'),
                      ),
                      DropdownMenuItem(
                        value: PitchAlgorithm.classic,
                        child: Text('Classic (Autocorrelation)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => tempAlgo = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Acoustic Weighting:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<AcousticWeightingMode>(
                    value: tempWeight,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: AcousticWeightingMode.none,
                        child: Text('None (Flat)'),
                      ),
                      DropdownMenuItem(
                        value: AcousticWeightingMode.cWeighting,
                        child: Text('C-Weighting (Wide)'),
                      ),
                      DropdownMenuItem(
                        value: AcousticWeightingMode.aWeighting,
                        child: Text('A-Weighting (Speech/Noise Cut)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => tempWeight = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _reanalyze(tempAlgo, tempWeight);
                  },
                  child: const Text('Analyze'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = PlotWindowOutline(
      lineWidth: 1.0,
      cornerRadius: 12.0,
      color: theme.colorScheme.outlineVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Audio Pitch Analysis', style: TextStyle(fontSize: 16)),
            Text(
              widget.fileName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Change Algorithm / Weighting',
            onPressed: _showConfigDialog,
          ),
          if (widget.onSelectNewFile != null)
            IconButton(
              icon: const Icon(Icons.file_open_outlined),
              tooltip: 'Open Another Audio File',
              onPressed: widget.onSelectNewFile,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isAnalyzing) const LinearProgressIndicator(),
            // 1. Top Tuning Indicator Banner
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: TuningIndicatorBanner(
                targetNote: _targetNote,
                targetFrequency: _targetFrequency,
                measuredFrequency: _measuredFrequency > 0
                    ? _measuredFrequency
                    : null,
                deviationCents: _deviationCents,
                tuningState: _tuningState,
                isLocked: _lockedStringKey != null,
                onSelectInstrument: _openInstrumentSelector,
                onToggleLock: () {
                  setState(() {
                    if (_lockedStringKey != null) {
                      _lockedStringKey = null;
                    } else if (_currentInstrument.strings.isNotEmpty) {
                      _lockedStringKey = 0;
                      _targetNote = _currentInstrument.strings.first;
                      _targetFrequency = _pitchConverter.noteToFrequency(
                        _targetNote,
                      );
                    }
                    _updateStateAtTime(_currentTime);
                  });
                },
                currentInstrumentName: _currentInstrument.name,
                currentInstrumentIcon: _currentInstrument.icon,
              ),
            ),

            const SizedBox(height: 6.0),

            // 2. Middle Row: Strings on sidebar + Static Pitch History Timeline
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Compact Strings Sidebar (76dp)
                    if (_currentInstrument.strings.isNotEmpty)
                      SizedBox(
                        width: 76.0,
                        child: Strings(
                          strings: _currentStringInfos,
                          highlightedNoteKey: _lockedStringKey,
                          onStringClicked: _onStringClicked,
                          sidebarPosition: StringsSidebarPosition.none,
                        ),
                      ),

                    if (_currentInstrument.strings.isNotEmpty)
                      const SizedBox(width: 8.0),

                    // Static Pitch Timeline Plot
                    Expanded(
                      child: StaticPitchTimelinePlot(
                        frames: _result.frames,
                        durationSeconds: _result.durationSeconds,
                        currentTime: _currentTime,
                        onSeekTime: _seekTo,
                        targetNote: _targetNote,
                        targetFrequency: _targetFrequency,
                        tuningState: _tuningState,
                        toleranceInCents: 10,
                        outline: outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8.0),

            // 3. Bottom Playback & Scrubber Controls
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time Slider
                  Row(
                    children: [
                      Text(
                        '${_currentTime.toStringAsFixed(1)}s',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentTime.clamp(
                            0.0,
                            _result.durationSeconds,
                          ),
                          min: 0.0,
                          max: math.max(0.1, _result.durationSeconds),
                          onChanged: _seekTo,
                        ),
                      ),
                      Text(
                        '${_result.durationSeconds.toStringAsFixed(1)}s',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Playback button, mute button & Config status pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            tooltip: _isPlaying ? 'Pause' : 'Play',
                            onPressed: _togglePlayback,
                          ),
                          const SizedBox(width: 8.0),
                          IconButton(
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                            ),
                            tooltip: _isMuted ? 'Unmute' : 'Mute',
                            onPressed: _toggleMute,
                          ),
                        ],
                      ),
                      Chip(
                        avatar: const Icon(Icons.analytics_outlined, size: 16),
                        label: Text(
                          '${_result.algorithm.name.toUpperCase()} • ${_result.weightingMode.name.replaceAll('Weighting', ' Wt')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
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
