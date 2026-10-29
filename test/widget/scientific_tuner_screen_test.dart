// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/mock_audio_source.dart';
import 'package:tuner_flutter/audio/permissions/audio_permission_service.dart';
import 'package:tuner_flutter/core/theme/tuner_theme.dart';
import 'package:tuner_flutter/dsp/tuner_pipeline_runner.dart';
import 'package:tuner_flutter/state/audio_permission_provider.dart';
import 'package:tuner_flutter/state/scientific_mode_provider.dart';
import 'package:tuner_flutter/state/tuner_worker_provider.dart';
import 'package:tuner_flutter/ui/plot/autocorrelation_plot.dart';
import 'package:tuner_flutter/ui/plot/pitch_history_plot.dart';
import 'package:tuner_flutter/ui/plot/spectrum_plot.dart';
import 'package:tuner_flutter/ui/screens/scientific_tuner_screen.dart';
import 'package:tuner_flutter/ui/staff/note_staff.dart';
import 'package:tuner_flutter/ui/widgets/tuning_indicator_banner.dart';

void main() {
  Widget buildScientificTunerTestHarness({ProviderContainer? container}) {
    final mockPermission = MockAudioPermissionService(
      initialStatus: AudioPermissionStatus.granted,
    );
    final mockSource = MockAudioSource();
    final syncRunner = TunerSyncPipelineRunner();

    final overrides = [
      audioPermissionServiceProvider.overrideWithValue(mockPermission),
      audioSourceProvider.overrideWithValue(mockSource),
      tunerPipelineRunnerProvider.overrideWithValue(syncRunner),
    ];

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: TunerTheme.light(),
          home: const ScientificTunerScreen(),
        ),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: TunerTheme.light(),
        home: const ScientificTunerScreen(),
      ),
    );
  }

  group('ScientificTunerScreen Widget Tests', () {
    testWidgets('Mounts with all 4 oscilloscope/staff panels and banner', (
      tester,
    ) async {
      await tester.pumpWidget(buildScientificTunerTestHarness());
      await tester.pump();

      // Top Header & Banner
      expect(find.text('Scientific Tuner'), findsOneWidget);
      expect(find.byType(TuningIndicatorBanner), findsOneWidget);

      // 4 Core Scientific Sub-panels
      expect(find.byType(SpectrumPlot), findsOneWidget);
      expect(find.byType(AutocorrelationPlot), findsOneWidget);
      expect(find.byType(PitchHistoryPlot), findsOneWidget);
      expect(find.byType(NoteStaff), findsOneWidget);

      // Floating action button for audio export
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Tapping piano icon switches scientific mode back to instrument tuner',
      (tester) async {
        final mockPermission = MockAudioPermissionService(
          initialStatus: AudioPermissionStatus.granted,
        );
        final mockSource = MockAudioSource();
        final syncRunner = TunerSyncPipelineRunner();

        final container = ProviderContainer(
          overrides: [
            audioPermissionServiceProvider.overrideWithValue(mockPermission),
            audioSourceProvider.overrideWithValue(mockSource),
            tunerPipelineRunnerProvider.overrideWithValue(syncRunner),
          ],
        );
        addTearDown(container.dispose);

        // Start in scientific mode
        container.read(scientificModeProvider.notifier).setScientificMode(true);
        expect(container.read(scientificModeProvider), isTrue);

        await tester.pumpWidget(
          buildScientificTunerTestHarness(container: container),
        );
        await tester.pump();

        // Tap piano icon
        final pianoIcon = find.byIcon(Icons.piano);
        expect(pianoIcon, findsOneWidget);
        await tester.tap(pianoIcon);
        await tester.pump();

        // Scientific mode should now be toggled to false
        expect(container.read(scientificModeProvider), isFalse);
      },
    );

    testWidgets(
      'Tapping floating action button when buffer is empty shows snackbar feedback',
      (tester) async {
        await tester.pumpWidget(buildScientificTunerTestHarness());
        await tester.pump();

        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);
        await tester.tap(fab);
        await tester.pump();

        // Feedback snackbar
        expect(find.text('No audio buffer data to export'), findsOneWidget);
      },
    );
  });
}
