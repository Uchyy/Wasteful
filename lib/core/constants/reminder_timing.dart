// core/constants/reminder_timing.dart
enum ReminderTiming { eveningBefore, morningOf }

extension ReminderTimingX on ReminderTiming {
  String get label {
    switch (this) {
      case ReminderTiming.eveningBefore:
        return 'Evening before';
      case ReminderTiming.morningOf:
        return 'Morning of';
    }
  }
}