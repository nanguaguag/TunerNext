// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import '../core/constants/acoustic_constants.dart';
import '../domain/models/dsp_enums.dart';
import '../domain/models/musical_note.dart';
import '../domain/models/tuning_state.dart';
import '../domain/models/tuning_target.dart';
import '../domain/temperaments/temperament_models.dart';
import '../domain/tuning/tuning_target_computer.dart';
import 'pitch/pitch_detector_interface.dart';

/// Configuration parameters for DSP analysis and tuning evaluation.
class TunerDspConfig {
  const TunerDspConfig({
    this.sampleRate = 44100,
    this.windowSize = 4096,
    this.overlap = 0.75,
    this.pitchAlgorithm = PitchAlgorithm.classic,
    this.weightingMode = AcousticWeightingMode.none,
    this.octaveJumpGateEnabled = true,
    this.medianFilterEnabled = true,
    this.movingAverageCount = AcousticConstants.defaultMovingAverageCount,
    this.inTuneToleranceCents = 5.0,
    this.frequencyMin = AcousticConstants.defaultFrequencyMin,
    this.frequencyMax = AcousticConstants.defaultFrequencyMax,
    this.referenceFrequency = 440.0,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    Temperament? temperament,
    this.instrumentStrings = const [],
    this.manualTargetNote,
    this.exportSpectrum = false,
    this.exportCorrelation = false,
  }) : temperament =
           temperament ??
           const TemperamentEDO(notesPerOctave: 12, stableId: -1);

  final int sampleRate;
  final int windowSize;
  final double overlap;
  final PitchAlgorithm pitchAlgorithm;
  final AcousticWeightingMode weightingMode;
  final bool octaveJumpGateEnabled;
  final bool medianFilterEnabled;
  final int movingAverageCount;
  final double inTuneToleranceCents;
  final double frequencyMin;
  final double frequencyMax;
  final double referenceFrequency;
  final MusicalNote referenceNote;
  final Temperament temperament;
  final List<MusicalNote> instrumentStrings;
  final MusicalNote? manualTargetNote;
  final bool exportSpectrum;
  final bool exportCorrelation;

  TunerDspConfig copyWith({
    int? sampleRate,
    int? windowSize,
    double? overlap,
    PitchAlgorithm? pitchAlgorithm,
    AcousticWeightingMode? weightingMode,
    bool? octaveJumpGateEnabled,
    bool? medianFilterEnabled,
    int? movingAverageCount,
    double? inTuneToleranceCents,
    double? frequencyMin,
    double? frequencyMax,
    double? referenceFrequency,
    MusicalNote? referenceNote,
    Temperament? temperament,
    List<MusicalNote>? instrumentStrings,
    MusicalNote? manualTargetNote,
    bool? exportSpectrum,
    bool? exportCorrelation,
  }) {
    return TunerDspConfig(
      sampleRate: sampleRate ?? this.sampleRate,
      windowSize: windowSize ?? this.windowSize,
      overlap: overlap ?? this.overlap,
      pitchAlgorithm: pitchAlgorithm ?? this.pitchAlgorithm,
      weightingMode: weightingMode ?? this.weightingMode,
      octaveJumpGateEnabled:
          octaveJumpGateEnabled ?? this.octaveJumpGateEnabled,
      medianFilterEnabled: medianFilterEnabled ?? this.medianFilterEnabled,
      movingAverageCount: movingAverageCount ?? this.movingAverageCount,
      inTuneToleranceCents: inTuneToleranceCents ?? this.inTuneToleranceCents,
      frequencyMin: frequencyMin ?? this.frequencyMin,
      frequencyMax: frequencyMax ?? this.frequencyMax,
      referenceFrequency: referenceFrequency ?? this.referenceFrequency,
      referenceNote: referenceNote ?? this.referenceNote,
      temperament: temperament ?? this.temperament,
      instrumentStrings: instrumentStrings ?? this.instrumentStrings,
      manualTargetNote: manualTargetNote ?? this.manualTargetNote,
      exportSpectrum: exportSpectrum ?? this.exportSpectrum,
      exportCorrelation: exportCorrelation ?? this.exportCorrelation,
    );
  }
}

/// Comprehensive evaluated output event emitted for each processed audio window.
class TunerWorkerResult {
  const TunerWorkerResult({
    required this.evaluation,
    required this.pitchResult,
    required this.frameIndex,
    required this.timestampUs,
    this.spectrum,
    this.correlation,
  });

  final TuningEvaluation evaluation;
  final PitchDetectionResult pitchResult;
  final int frameIndex;
  final int timestampUs;
  final Float32List? spectrum;
  final Float32List? correlation;

  double get frequency => pitchResult.frequency;
  bool get isSilence => pitchResult.isSilence;
  TuningState get state => evaluation.state;
  TuningTarget get target => evaluation.target;
  double get deviationCents => evaluation.deviationCents;
  double get confidence => pitchResult.confidence;
}

/// Base class for commands sent from main isolate to worker isolate.
sealed class TunerWorkerCommand {
  const TunerWorkerCommand();
}

class TunerCommandProcessFrame extends TunerWorkerCommand {
  const TunerCommandProcessFrame({
    required this.samples,
    required this.frameIndex,
  });
  final Float32List samples;
  final int frameIndex;
}

class TunerCommandUpdateConfig extends TunerWorkerCommand {
  const TunerCommandUpdateConfig(this.config);
  final TunerDspConfig config;
}

class TunerCommandReset extends TunerWorkerCommand {
  const TunerCommandReset();
}

class TunerCommandDispose extends TunerWorkerCommand {
  const TunerCommandDispose();
}
