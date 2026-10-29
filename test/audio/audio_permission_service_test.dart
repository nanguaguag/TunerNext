// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/audio/permissions/audio_permission_service.dart';

void main() {
  group('AudioPermissionService Tests', () {
    test(
      'MockAudioPermissionService tracks status and operation counts',
      () async {
        final service = MockAudioPermissionService(
          initialStatus: AudioPermissionStatus.denied,
        );

        expect(await service.checkPermission(), AudioPermissionStatus.denied);
        expect(service.checkCount, 1);

        service.currentStatus = AudioPermissionStatus.granted;
        expect(
          await service.requestPermission(),
          AudioPermissionStatus.granted,
        );
        expect(service.requestCount, 1);

        final opened = await service.openAppSettings();
        expect(opened, isTrue);
        expect(service.openSettingsCount, 1);
      },
    );

    test('AudioPermissionStatus has all required states', () {
      expect(AudioPermissionStatus.values.length, 4);
      expect(
        AudioPermissionStatus.values,
        containsAll([
          AudioPermissionStatus.granted,
          AudioPermissionStatus.denied,
          AudioPermissionStatus.permanentlyDenied,
          AudioPermissionStatus.restricted,
        ]),
      );
    });
  });
}
