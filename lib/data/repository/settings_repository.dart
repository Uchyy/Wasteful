// data/repositories/settings_repository.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/reminder_timing.dart';

class SettingsRepository {
  static const _reminderTimingKey = 'reminder_timing';
  static const _themeModeKey = 'theme_mode';

  Future<ReminderTiming> getReminderTiming() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_reminderTimingKey);
    return ReminderTiming.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ReminderTiming.eveningBefore, // default
    );
  }

  Future<void> setReminderTiming(ReminderTiming timing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimingKey, timing.name);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system, // default
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}