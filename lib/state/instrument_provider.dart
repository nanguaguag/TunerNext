// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/instrument.dart';
import '../domain/models/musical_note.dart';
import '../ui/plot/pitch_history_data.dart';
import 'tuner_worker_provider.dart';

/// Provider managing the active instrument selection.
final instrumentProvider = NotifierProvider<InstrumentNotifier, Instrument>(
  InstrumentNotifier.new,
);

class InstrumentNotifier extends Notifier<Instrument> {
  @override
  Instrument build() => PredefinedInstruments.guitar6String;

  void selectInstrument(Instrument instrument) {
    state = instrument;
    // Update DSP worker config with instrument strings and reset any lock
    ref
        .read(tunerDspConfigProvider.notifier)
        .update(
          (prev) => prev.copyWith(
            instrumentStrings: instrument.strings,
            manualTargetNote: null,
          ),
        );
    ref.read(lockedStringProvider.notifier).clear();
  }
}

/// Provider managing manual note/string locking.
final lockedStringProvider =
    NotifierProvider<LockedStringNotifier, MusicalNote?>(
      LockedStringNotifier.new,
    );

class LockedStringNotifier extends Notifier<MusicalNote?> {
  @override
  MusicalNote? build() => null;

  void toggleLock(MusicalNote note) {
    if (state != null && state!.matches(note)) {
      clear();
    } else {
      state = note;
      ref
          .read(tunerDspConfigProvider.notifier)
          .update((prev) => prev.copyWith(manualTargetNote: note));
    }
  }

  void clear() {
    state = null;
    ref
        .read(tunerDspConfigProvider.notifier)
        .update((prev) => prev.copyWith(manualTargetNote: null));
  }
}

/// Provider holding the rolling pitch history buffer for canvas plotting.
final pitchHistoryDataProvider = Provider<PitchHistoryData>((ref) {
  final history = PitchHistoryData(capacity: 80);

  // Listen to real-time DSP results and feed history data
  ref.listen(tunerWorkerResultStreamProvider, (_, next) {
    final result = next.value;
    if (result != null) {
      history.add(frequency: result.frequency, isSilence: result.isSilence);
    }
  });

  return history;
});
