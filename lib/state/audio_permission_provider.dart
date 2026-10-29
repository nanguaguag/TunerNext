// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/permissions/audio_permission_service.dart';

/// Provider for audio permission service abstraction.
final audioPermissionServiceProvider = Provider<AudioPermissionService>((ref) {
  return const DeviceAudioPermissionService();
});

/// Riverpod notifier tracking microphone capture permission status.
class AudioPermissionNotifier extends AsyncNotifier<AudioPermissionStatus> {
  @override
  Future<AudioPermissionStatus> build() async {
    final service = ref.watch(audioPermissionServiceProvider);
    return service.checkPermission();
  }

  Future<AudioPermissionStatus> requestPermission() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(audioPermissionServiceProvider);
      final status = await service.requestPermission();
      state = AsyncValue.data(status);
      return status;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<bool> openSettings() async {
    final service = ref.read(audioPermissionServiceProvider);
    return service.openAppSettings();
  }
}

final audioPermissionProvider =
    AsyncNotifierProvider<AudioPermissionNotifier, AudioPermissionStatus>(
      AudioPermissionNotifier.new,
    );
