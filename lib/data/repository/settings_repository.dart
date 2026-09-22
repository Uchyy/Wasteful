// data/repositories/settings_repository.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/reminder_timing.dart';

class SettingsRepository {
  static const _reminderTimingKey = 'reminder_timing';
  static const _defaultTimeHourKey = 'default_notification_hour';
  static const _defaultTimeMinuteKey = 'default_notification_minute';
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

  Future<TimeOfDay> getDefaultNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_defaultTimeHourKey) ?? 20; // 8:00 PM default
    final minute = prefs.getInt(_defaultTimeMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setDefaultNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultTimeHourKey, time.hour);
    await prefs.setInt(_defaultTimeMinuteKey, time.minute);
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