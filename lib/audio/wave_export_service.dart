// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'wave_writer.dart';

/// Service for exporting audio buffer snapshots into standard RIFF WAVE files.
class WaveExportService {
  const WaveExportService();

  /// Writes snapshot from [waveWriter] to a WAVE file in application documents or temp directory.
  /// Returns the absolute path of the generated file.
  Future<String> exportSnapshot({
    required WaveWriter waveWriter,
    String? customFileName,
    bool pcm16Bit = true,
  }) async {
    Directory dir;
    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (_) {
      dir = await getTemporaryDirectory();
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = customFileName ?? 'tuner_export_$timestamp.wav';
    final file = File('${dir.path}/$filename');

    await waveWriter.writeStoredSnapshotToFile(file, useIeeeFloat: !pcm16Bit);
    return file.path;
  }
}
