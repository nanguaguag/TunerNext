// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/mock_audio_source.dart';
import 'package:tuner_flutter/audio/permissions/audio_permission_service.dart';
import 'package:tuner_flutter/dsp/tuner_pipeline_runner.dart';
import 'package:tuner_flutter/main.dart';
import 'package:tuner_flutter/state/audio_permission_provider.dart';
import 'package:tuner_flutter/state/tuner_worker_provider.dart';
import 'package:tuner_flutter/ui/screens/instrument_tuner_screen.dart';

void main() {
  testWidgets('TunerApp smoke test mounts with M3 and InstrumentTunerScreen', (
    WidgetTester tester,
  ) async {
    final mockPermission = MockAudioPermissionService(
      initialStatus: AudioPermissionStatus.granted,
    );
    final mockAudioSource = MockAudioSource();
    final syncRunner = TunerSyncPipelineRunner();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPermissionServiceProvider.overrideWithValue(mockPermission),
          audioSourceProvider.overrideWithValue(mockAudioSource),
          tunerPipelineRunnerProvider.overrideWithValue(syncRunner),
        ],
        child: const TunerApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(InstrumentTunerScreen), findsOneWidget);
    expect(find.text('Tuner'), findsOneWidget);
  });
}
