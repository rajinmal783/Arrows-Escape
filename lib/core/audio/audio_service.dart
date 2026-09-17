import 'package:flutter/services.dart';
import '../../services/local_storage_service.dart';

class AudioService {
  final LocalStorageService _storage;

  AudioService(this._storage);

  bool get isSoundEnabled => _storage.loadSettings().soundEnabled;
  bool get isVibrationEnabled => _storage.loadSettings().vibrationEnabled;

  void playTap() {
    if (isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void playEscapeSuccess() {
    if (isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playBlockedError() {
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void playLevelComplete() {
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
