import 'package:flutter/services.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  Future<void> show10MinuteReminder() async {
    // Play system sound + strong vibration
    SystemSound.play(SystemSoundType.alert);
    
    // Triple vibration for attention
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
  }
}
