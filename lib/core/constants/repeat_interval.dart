// core/constants/repeat_interval.dart
enum RepeatInterval { weekly, everyTwoWeeks, everyThreeWeeks, monthly }

extension RepeatIntervalX on RepeatInterval {
  String get label {
    switch (this) {
      case RepeatInterval.weekly:
        return 'Every week';
      case RepeatInterval.everyTwoWeeks:
        return 'Every 2 weeks';
      case RepeatInterval.everyThreeWeeks:
        return 'Every 3 weeks';
      case RepeatInterval.monthly:
        return 'Every month';
    }
  }
}