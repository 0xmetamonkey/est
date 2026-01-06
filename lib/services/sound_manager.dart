import 'package:flutter/services.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  // ENHANCED haptics - way more noticeable!
  
  void playClick() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void playStart() {
    if (_hapticsEnabled) {
      // Double tap for start
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  void playStop() {
    if (_hapticsEnabled) {
      // Single strong tap for stop
      HapticFeedback.heavyImpact();
    }
  }

  void playComplete() {
    if (_hapticsEnabled) {
      // TRIPLE TAP CELEBRATION! 🎉
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.heavyImpact();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  void playCamera() {
    if (_hapticsEnabled) {
      // Quick double tap like a shutter
      HapticFeedback.selectionClick();
      Future.delayed(const Duration(milliseconds: 30), () {
        HapticFeedback.selectionClick();
      });
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  bool get isSoundEnabled => _soundEnabled;
  bool get isHapticsEnabled => _hapticsEnabled;
}
