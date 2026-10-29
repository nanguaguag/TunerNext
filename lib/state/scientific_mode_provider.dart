// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/wave_export_service.dart';
import '../ui/staff/staff_models.dart';
import 'tuner_worker_provider.dart';

/// Provider for whether the app is in Scientific Mode (oscilloscope + staff)
/// versus Instrument Mode (strings sidebar + pitch history).
final scientificModeProvider = NotifierProvider<ScientificModeNotifier, bool>(
  ScientificModeNotifier.new,
);

class ScientificModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    setScientificMode(!state);
  }

  void setScientificMode(bool enabled) {
    if (state == enabled) return;
    state = enabled;

    // Dynamically toggle spectrum and correlation extraction in DSP pipeline
    ref
        .read(tunerDspConfigProvider.notifier)
        .update(
          (prev) => prev.copyWith(
            exportSpectrum: enabled,
            exportCorrelation: enabled,
          ),
        );
  }
}

/// Provider for selected staff clef.
final staffClefProvider = NotifierProvider<StaffClefNotifier, StaffClef>(
  StaffClefNotifier.new,
);

class StaffClefNotifier extends Notifier<StaffClef> {
  @override
  StaffClef build() => StaffClef.grand;

  void setClef(StaffClef clef) => state = clef;
}

/// Provider for active key signature (number of sharps > 0 or flats < 0, range -7 to +7).
final keySignatureProvider = NotifierProvider<KeySignatureNotifier, int>(
  KeySignatureNotifier.new,
);

class KeySignatureNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setKeySignature(int sig) => state = sig;
}

/// Provider for WaveExportService.
final waveExportServiceProvider = Provider<WaveExportService>((ref) {
  return const WaveExportService();
});
