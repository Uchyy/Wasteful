import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';

class Schedule {
  final String id; 
  final String addressId;                   
  final BinType binTypes;      
  final int collectionWeekday;       
  final RepeatInterval repeatInterval;
  final DateTime startDate;
  final TimeOfDay? notificationTime; 
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReminderTiming reminderTiming;

  Schedule({
    required this.id,
    required this.addressId,
    required this.binTypes,
    required this.collectionWeekday,
    required this.repeatInterval,
    required this.startDate,
    this.notificationTime,
    required this.isArchived,
    this.reminderTiming = ReminderTiming.eveningBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  Schedule copyWith({
    String? id,
    String? addressId,
    BinType? binTypes,
    int? collectionWeekday,
    RepeatInterval? repeatInterval,
    DateTime? startDate,
    ReminderTiming? reminderTimig,
    TimeOfDay? notificationTime,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      reminderTiming: reminderTiming ,
      addressId: addressId ?? this.addressId,
      binTypes: binTypes ?? this.binTypes,
      collectionWeekday: collectionWeekday ?? this.collectionWeekday,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      startDate: startDate ?? this.startDate,
      notificationTime: notificationTime ?? this.notificationTime,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address_id': addressId,
      'reminder_timing': reminderTiming.name,
      'bin_type': binTypes.name,
      'collection_weekday': collectionWeekday,
      'repeat_interval': repeatInterval.name,
      'start_date': startDate.toIso8601String(),
      'notification_time': notificationTime != null
          ? '${notificationTime!.hour}:${notificationTime!.minute}'
          : null,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Builds a Schedule from a `schedules` table row.
  /// [binTypes] must be fetched separately from `schedule_bin_types`
  /// and passed in — this method doesn't touch the database itself.
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      addressId: map['address_id'] as String,
      reminderTiming: map['reminder_timing'] != null
        ? ReminderTiming.values.byName(
            map['reminder_timing'] as String,
          )
        : ReminderTiming.eveningBefore,
      binTypes: BinType.values.byName(map['bin_type'] as String),
      collectionWeekday: map['collection_weekday'] as int,
      repeatInterval: RepeatInterval.values.byName(map['repeat_interval'] as String),
      startDate: DateTime.parse(map['start_date'] as String),
      notificationTime: map['notification_time'] != null
          ? _parseTimeOfDay(map['notification_time'] as String)
          : null,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toString() {
    return 'Schedule('
        'id: $id, '
        'addressId: $addressId'
        'binTypes: $binTypes, '
        'reminderTiming: ${reminderTiming.name}'
        'collectionWeekday: $collectionWeekday, '
        'repeatInterval: ${repeatInterval.name}, '
        'startDate: ${startDate.toIso8601String()}, '
        'notificationTime: ${notificationTime?.format24Hour() ?? "default"}, '
        'isArchived: $isArchived'
        ')';
  }
}

extension TimeOfDayX on TimeOfDay {
  String format24Hour() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

extension ScheduleX on Schedule {
  /// Returns the next collection date from [from].
  ///
  /// Used by the UI to show the next upcoming collection.
  DateTime nextCollectionDate([DateTime? from]) {
    return _nextCollectionDate(from ?? DateTime.now());
  }

  /// Returns the next [count] collection dates.
  ///
  /// Used by the notification scheduler to prepare future reminders.
  List<DateTime> upcomingCollectionDates({
    DateTime? from,
    int count = 8,
  }) {
    if (count <= 0) return [];

    final dates = <DateTime>[];
    var cursor = from ?? DateTime.now();

    for (var i = 0; i < count; i++) {
      final next = _nextCollectionDate(cursor);

      dates.add(next);

      // Move to the next calendar day.
      // Do not use Duration(days: 1) because DST can
      // produce 23:00/01:00 when crossing a clock change.
      cursor = _addDays(next, 1);
    }

    return dates;
  }

  bool get isDueTonight {
    final now = DateTime.now();

    if (reminderTiming == ReminderTiming.morningOf) {
      return _isCollectionToday(now);
    }

    final tomorrow = _addDays(now, 1);
    final next = nextCollectionDate();

    return next.year == tomorrow.year &&
        next.month == tomorrow.month &&
        next.day == tomorrow.day;
  }

  bool _isCollectionToday(DateTime date) {
  final today = DateTime(
    date.year,
    date.month,
    date.day,
  );

  if (repeatInterval == RepeatInterval.monthly) {
    final occurrence = ((startDate.day - 1) ~/ 7) + 1;

    DateTime findNthWeekday(
      DateTime monthStart,
      int weekday,
      int n,
    ) {
      var candidate = monthStart;

      while (candidate.weekday != weekday) {
        candidate = _addDays(candidate, 1);
      }

      return _addDays(candidate, 7 * (n - 1));
    }

    final candidate = findNthWeekday(
      DateTime(today.year, today.month, 1),
      collectionWeekday,
      occurrence,
    );

    return _sameDate(candidate, today);
  }

  final weeks = switch (repeatInterval) {
    RepeatInterval.weekly => 1,
    RepeatInterval.everyTwoWeeks => 2,
    RepeatInterval.everyThreeWeeks => 3,
    RepeatInterval.monthly => throw StateError(
        'Monthly interval should already be handled.',
      ),
  };

  final cycleLength = weeks * 7;

  final start = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
  );

  final daysSinceStart = today.difference(start).inDays;

  if (daysSinceStart < 0) {
    return false;
  }

  final daysIntoCycle = daysSinceStart % cycleLength;

  var candidate = _addDays(
    today,
    -daysIntoCycle,
  );

  while (candidate.weekday != collectionWeekday) {
    candidate = _addDays(candidate, 1);
  }

  return _sameDate(candidate, today);
}

bool _sameDate(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}

  DateTime _nextCollectionDate(DateTime from) {
    final today = DateTime(from.year,from.month,from.day,);

    if (repeatInterval == RepeatInterval.monthly) {
      final occurrence = ((startDate.day - 1) ~/ 7) + 1;

      DateTime findNthWeekday(
        DateTime monthStart,
        int weekday,
        int n,
      ) {
        var date = monthStart;

        while (date.weekday != weekday) {
          date = _addDays(date, 1);
        }

        return _addDays(date, 7 * (n - 1));
      }

      var candidateMonth = DateTime(
        today.year,
        today.month,
        1,
      );

      var candidate = findNthWeekday(
        candidateMonth,
        collectionWeekday,
        occurrence,
      );

      if (candidate.isBefore(today)) {
        candidateMonth = DateTime(
          today.year,
          today.month + 1,
          1,
        );

        candidate = findNthWeekday(
          candidateMonth,
          collectionWeekday,
          occurrence,
        );
      }

      return candidate;
    }

    final weeks = switch (repeatInterval) {
      RepeatInterval.weekly => 1,
      RepeatInterval.everyTwoWeeks => 2,
      RepeatInterval.everyThreeWeeks => 3,
      RepeatInterval.monthly => throw StateError(
          'Monthly interval should already be handled.',
        ),
    };

    final cycleLength = weeks * 7;

    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final daysSinceStart = today.difference(start).inDays;

    if (daysSinceStart < 0) {
      var candidate = start;

      while (candidate.weekday != collectionWeekday) {
        candidate = _addDays(candidate, 1);
      }

      return candidate;
    }

    final daysIntoCycle = daysSinceStart % cycleLength;

    var candidate = _addDays(
      today,
      -daysIntoCycle,
    );

    while (candidate.weekday != collectionWeekday) {
      candidate = _addDays(candidate, 1);
    }

    if (!candidate.isAfter(today)) {
      candidate = _addDays(candidate, cycleLength);

      while (candidate.weekday != collectionWeekday) {
        candidate = _addDays(candidate, 1);
      }
    }

    return candidate;
  }

  /// Adds calendar days rather than elapsed 24-hour periods.
  ///
  /// This avoids DST problems when crossing UK daylight-saving
  /// transitions.
  DateTime _addDays(DateTime date, int days) {
    return DateTime(
      date.year,
      date.month,
      date.day + days,
    );
  }

  bool get isCollectionToday {
    return _isCollectionToday(DateTime.now());
  }
}

