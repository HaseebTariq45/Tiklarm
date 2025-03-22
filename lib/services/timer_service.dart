import 'package:flutter/material.dart';
import 'package:tiklarm/services/settings_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  
  factory TimerService() {
    return _instance;
  }
  
  TimerService._internal();

  final SettingsService _settingsService = SettingsService();
  
  // Handle screen wakelock based on settings
  void handleWakelock(bool isTimerRunning) async {
    if (isTimerRunning && _settingsService.keepScreenOn) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  // Format time based on settings (12h or 24h)
  String formatTimeOfDay(TimeOfDay time) {
    final is24HourFormat = _settingsService.timeFormat == '24h';
    
    if (is24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }
} 