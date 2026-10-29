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
import 'package:tuner_flutter/state/tuner_worker_provider.dart';
import 'package:tuner_flutter/ui/plot/pitch_history_plot.dart';
import 'package:tuner_flutter/ui/screens/instrument_tuner_screen.dart';
import 'package:tuner_flutter/ui/widgets/strings_sidebar.dart';
import 'package:tuner_flutter/ui/widgets/tuning_indicator_banner.dart';

void main() {
  group('InstrumentTunerScreen Widget & Interaction Tests', () {
    testWidgets(
      'Screen mounts with M3 layout, banner, strings sidebar, and history canvas',
      (WidgetTester tester) async {
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
            child: MaterialApp(
              theme: TunerTheme.light(),
              darkTheme: TunerTheme.dark(),
              home: const InstrumentTunerScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Verify Top Bar and Banner
        expect(find.text('Tuner'), findsOneWidget);
        expect(find.byType(TuningIndicatorBanner), findsOneWidget);
        expect(find.text('6-string guitar'), findsOneWidget);

        // 2. Verify Strings Sidebar with guitar strings
        expect(find.byType(StringsSidebar), findsOneWidget);
        expect(find.text('E4'), findsOneWidget);
        expect(find.text('B3'), findsOneWidget);
        expect(find.text('G3'), findsOneWidget);
        expect(find.text('D3'), findsOneWidget);
        expect(find.text('A2'), findsOneWidget);
        expect(find.text('E2'), findsOneWidget);

        // 3. Verify Pitch History Plot Canvas
        expect(find.byType(PitchHistoryPlot), findsOneWidget);
      },
    );

    testWidgets('Tapping a string row toggles string lock mode', (
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
          child: MaterialApp(
            theme: TunerTheme.light(),
            home: const InstrumentTunerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // No string is locked initially
      expect(find.byIcon(Icons.lock), findsNothing);

      // Tap E4 string to lock
      await tester.tap(find.text('E4'));
      await tester.pumpAndSettle();

      // Lock icon appears on locked string and banner button indicates locked state
      expect(find.byIcon(Icons.lock), findsAtLeastNWidgets(1));

      // Tap E4 string again to unlock
      await tester.tap(find.text('E4'));
      await tester.pumpAndSettle();

      // Lock cleared
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets(
      'Opening instrument selector and choosing Violin updates strings sidebar',
      (WidgetTester tester) async {
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
            child: MaterialApp(
              theme: TunerTheme.light(),
              home: const InstrumentTunerScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open instrument selector
        await tester.tap(find.text('6-string guitar'));
        await tester.pumpAndSettle();

        // BottomSheet is displayed
        expect(find.text('Select Instrument'), findsOneWidget);
        expect(find.text('Violin'), findsOneWidget);

        // Select Violin
        await tester.tap(find.text('Violin'));
        await tester.pumpAndSettle();

        // Banner updated
        expect(find.text('Violin'), findsOneWidget);

        // Violin strings (G3, D4, A4, E5) are now visible in the sidebar
        expect(
          find.descendant(
            of: find.byType(StringsSidebar),
            matching: find.text('E5'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(StringsSidebar),
            matching: find.text('A4'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(StringsSidebar),
            matching: find.text('D4'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(StringsSidebar),
            matching: find.text('G3'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('Dark theme renders correctly without layout overflow', (
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
          child: MaterialApp(
            theme: TunerTheme.dark(),
            home: const InstrumentTunerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(InstrumentTunerScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
