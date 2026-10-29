// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:permission_handler/permission_handler.dart' as ph;

/// Standardized status of microphone recording permission.
enum AudioPermissionStatus { granted, denied, permanentlyDenied, restricted }

/// Service interface managing microphone capture permissions.
abstract class AudioPermissionService {
  Future<AudioPermissionStatus> checkPermission();
  Future<AudioPermissionStatus> requestPermission();
  Future<bool> openAppSettings();
}

/// Platform implementation using permission_handler.
class DeviceAudioPermissionService implements AudioPermissionService {
  const DeviceAudioPermissionService();

  @override
  Future<AudioPermissionStatus> checkPermission() async {
    final status = await ph.Permission.microphone.status;
    return _mapStatus(status);
  }

  @override
  Future<AudioPermissionStatus> requestPermission() async {
    final status = await ph.Permission.microphone.request();
    return _mapStatus(status);
  }

  @override
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }

  AudioPermissionStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return AudioPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return AudioPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) {
      return AudioPermissionStatus.restricted;
    }
    return AudioPermissionStatus.denied;
  }
}

/// Mock implementation for deterministic testing and preview environments.
class MockAudioPermissionService implements AudioPermissionService {
  MockAudioPermissionService({
    this.initialStatus = AudioPermissionStatus.granted,
  }) : currentStatus = initialStatus;

  AudioPermissionStatus initialStatus;
  AudioPermissionStatus currentStatus;
  int checkCount = 0;
  int requestCount = 0;
  int openSettingsCount = 0;

  @override
  Future<AudioPermissionStatus> checkPermission() async {
    checkCount++;
    return currentStatus;
  }

  @override
  Future<AudioPermissionStatus> requestPermission() async {
    requestCount++;
    return currentStatus;
  }

  @override
  Future<bool> openAppSettings() async {
    openSettingsCount++;
    return true;
  }
}
